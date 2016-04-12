import pandas as pd
import numpy as np

movies_list = pd.read_csv("./static/csv/movies_filtered.csv")
movies_list = list(movies_list['product_productid']) # Read in a list of movies in the data
users = pd.read_csv("./static/csv/users_filtered.csv") # Read in the user table
users = users.fillna("") # Change NaN to ""
users_colnames = list(users) # Get column names



# Create a dictionary with indices as keys and user IDs as values
userids = {}
for i in range(len(users)):
    userids[i] = users['review_userid'][i]

# Create a dictionary:
#     keys are user IDs
#     values are themselves dictionaries
#         for each value-dictionary, keys are movie IDs, values are review scores
# eg. {'A123456789': {'B00000000': 5, 'B000099999': 3}, 'A987654321': {'B00000000': 4}} 
# Access a particular user's dictionary via users_data[userids][0] or users_data['A123456789']

users_data = {}
for user in range(len(users)):
    users_data[userids[user]] = {}    
    star = 1
    for col in range(14, 19):        
        for movie in users[users_colnames[col]][user].split():
            users_data[userids[user]][movie] = star
        star += 1



def cossimilarity(ratings1, ratings2):
    '''
    Computes cosine similarity between two users' ratings.
    Only applies to movies that the two users have rated in common.
    '''
    
    x = []
    y = []
    n = 0
    for key in ratings1:
        if key in ratings2:
            n += 1
            x.append(ratings1[key])
            y.append(ratings2[key])
    if n == 0:
        return 0
    x = np.asarray(x)
    y = np.asarray(y)
    if np.dot(x, x) == 0 or np.dot(y, y) == 0:
        return 0
    result = np.dot(x, y) / np.sqrt(np.dot(x, x) * np.dot(y, y))
    return result    
        

def most_similar_users(username, userids):
    ''' 
    Returns the Pearson correlation between a given user and all others
    Input: username, dict
    Input: userids, dict
    Output: list
    '''
    distances = []
    for user in range(len(userids)):
        if userids[user] != username:
            distance = cossimilarity(users_data[userids[user]], users_data[username])
            intersection = list(set(users_data[userids[user]].keys()) & set(users_data[username].keys()))
            distances.append((round(distance, 2), len(intersection), userids[user]))
    # sort based on distance - closest first
    distances.sort(reverse = True)
    return distances


def recommend(username, userids):
    '''
    Recommends 3 movies based on user-based collaborative filtering.
    Input: username, str, e.g. 'A2OXDJP1Z3LNOK', must be in userids dict
    Input: userids, dict
    Output: list of 3 movies
    '''
    similar_users = most_similar_users(username, userids)
    
    # Obtain the set of all movies seen by similar users and not yet seen by new user
    new_movies = set()
    if len(users_data[username]) == 0:
        return "Cannot recommend without any ratings"
    elif len(users_data[username]) < 10:
        k = len(users_data[username])
    else:
        k = 10
    for similar_user in range(k):
        new_movies = new_movies | set(users_data[similar_users[similar_user][2]].keys()) - set(users_data[username].keys())
    new_movies = list(new_movies)
        
    # Create a matrix with the score for each user-movie combination
    # Weight each score by number of movies new user has in common with similar user
    #     multiplied by the Pearson correlation coefficient
    score_matrix = np.zeros((k, len(new_movies)))  
    for i in range(len(new_movies)):
        for similar_user in range(k):
            if new_movies[i] in users_data[similar_users[similar_user][2]]:
                score_matrix[similar_user, i] = users_data[similar_users[similar_user][2]][new_movies[i]] * similar_users[similar_user][0] * similar_users[similar_user][1]
    ranking = score_matrix.mean(axis = 0)
    if sum(ranking) == 0:
        return "Cosine similarity value is 0 for all users"
    
    # Obtain the top 3 UNIQUE scores and match them to movies
    # (Not specifically looking for UNIQUE scores will yield duplicate movies)
    # Amazon has different ASINs for different versions of the same movie
    # e.g. VHS, DVD, Anniversary Edition, web streaming, etc.
    # Those different versions will all share the same reviews
    top_3_scores = np.unique(ranking)
    recommended_movies = []
    for i in range(3):
        recommended_movies.append(new_movies[np.where(ranking == top_3_scores[-i-1])[0].tolist()[0]])
    return(recommended_movies)




# use API to change entered movie name keywords to ASIN 
# and put ASIN into the recommendation system to get three movie ASIN as recommendation
# use API to change recommended movie ASIN to movie Title and URL
# the following are done for newuser1

# for example the newuser gives the following keywords: 
# 5 stars to Batman - Mask of the Phantasm 
# 4 stars to Harry Potter: Years 1-5
# 3 stars to the mask
# 2 stars to Spirited Away, 
# 1 stars to the lord of the rings: the return of the kings

# store these keywords in a list caled keywords

# keywords to ASIN
from amazonproduct import API
api = API("AKIAJGEEABW2F4H7ZB4Q", "6+ShIy2suLuPzWOdhEbzA8y4Cd3QDdfzokAbILB1","us","yueyingteng-20")

ASIN = {}
keywords = ["The Last Samurai","Harry Potter: Years 1-5","World Cup Soccer in Africa: Who Really Wins","spirited away","the Walking Dead"]
for keyword in keywords:
    ASIN[keyword] = []
    results = api.item_search('DVD', Title = keyword)
    for item in results:
        item =  item.ASIN
        ASIN[keyword].append(item)
        

# userids[len(userids)] = 'newuser1'
# We don't need this if we're not going to create a new username, we can just overwrite the original 'newuser1'
        
def create_new_user_data(username, keywords, ratings):
    '''
    Input: username, str, e.g. 'A2OXDJP1Z3LNOK', must be in userids dict
    Input: keywords, list of keywords used to index ASIN dictionary
    Input: ratings, list of ratings for each movie
    Output: new entry in users_data for username
    
    Example: create_new_user_data('newuser3', ['the mask', 'harry potter'], [5, 4])
    '''
    empty_dict = {}
    for i in range(len(keywords)):
        # if there are no ASINs in common between the Amazon API results and our data, do not create an entry
        if len(set(ASIN[keywords[i]]) & set(movies_list)) == 0:
            continue
        else:
            # get the first entry from the intersection of the Amazon API results and the ASINs in our data
            empty_dict[list(set(ASIN[keywords[i]]) & set(movies_list))[0]] = ratings[i]
    users_data[username] = empty_dict

create_new_user_data('newuser1', keywords, [5, 4, 3, 2, 1])




# ASIN to keywords
# the result is a dictioanry with recommended movie ASIN as key and movie titel, movie URL and movie poster URL as entries

from amazonproduct import API 
api = API("AKIAJGEEABW2F4H7ZB4Q", "6+ShIy2suLuPzWOdhEbzA8y4Cd3QDdfzokAbILB1","us","yueyingteng-20")

movies = {}
for movie in testrun:
    movies[movie] = []
    #result = api.item_lookup(str(movie))
    for item in api.item_lookup(str(movie)).Items.Item:
        title = item.ItemAttributes.Title 
        URL = item.ItemLinks.ItemLink.URL
        movies[movie].append(title)
        movies[movie].append(URL)
    #result2 = api.item_lookup(str(movie), ResponseGroup='Images')
    for items in api.item_lookup(str(movie), ResponseGroup='Images').Items.Item:
        imageURL = items.ImageSets.ImageSet.LargeImage.URL
        movies[movie].append(imageURL)
        