from flask import Flask, render_template, json, request
from amazonproduct import API
import os
import pandas as pd
import numpy as np
from recommender.py import cossimilarity, most_similar_users, recommend

app = Flask(__name__)

############recommender###################
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


@app.route("/")
def main():
    return render_template('index.html')

# @app.route('/showNewUser')
# def showNewUser():
#     return render_template('NewUser.html')

@app.route('/Recommend', methods=['POST'])
def Recommend():
    _movie1 = str(request.form['movie1'])
    _movie2 = str(request.form['movie2'])
    _movie3 = str(request.form['movie3'])
    _movie4 = str(request.form['movie4'])
    _movie5 = str(request.form['movie5'])
    _rate1 = int(request.form['rate1'])
    _rate2 = int(request.form['rate2'])
    _rate3 = int(request.form['rate3'])
    _rate3 = int(request.form['rate4'])
    _rate3 = int(request.form['rate5'])

    # keywords to ASIN
    api = API("AKIAJGEEABW2F4H7ZB4Q", "6+ShIy2suLuPzWOdhEbzA8y4Cd3QDdfzokAbILB1","us","yueyingteng-20")

    ASIN = {}
    keywords = [_movie1, _movie2, _movie3, _movie4, _movie5]
    for keyword in keywords:
        ASIN[keyword] = []
        results = api.item_search('DVD', Title = keyword)
        for item in results:
            item =  item.ASIN
            ASIN[keyword].append(item)

    from recommender.py import create_new_user_data
    create_new_user_data('newuser1', keywords, [_rate1, _rate2, _rate3, _rate2, _rate1])

    testrun = recommend('newuser1', userids)

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



    data = [{"title1" : movies[testrun[0]][0], "url1" : movies[testrun[0]][1], "imgUrl1" : movies[testrun[0]][2],
    "title2" : movies[testrun[1]][0], "url2" : movies[testrun[1]][1], "imgUrl2" : movies[testrun[1]][2],
    "title3" : movies[testrun[2]][0], "url3" : movies[testrun[2]][1], "imgUrl3" : movies[testrun[2]][2]}]
    # Writing JSON data
    with open('static/js/data.json', 'w') as f:
      json.dump(data,f)

    return render_template('index.html')
    #return json.dumps({'status':'OK','user':_movie1,'pass':_rate1})
    #return redirect('NewUser.html')

if __name__ == "__main__":
    # Bind to PORT if defined, otherwise default to 5000.
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)

