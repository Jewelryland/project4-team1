# -*- coding: utf-8 -*-
"""
Created on Sat Apr  9 18:36:22 2016

@author: Arnold
"""
# User-Item Collaborative Filtering

import os
# Set working directory to wherever your project4-team1 folder is
wd = "C:\\Users\\Arnold\\Dropbox\\Columbia\\2016 Spring\\STAT W4249 Applied Data Science\\project4-team1\\"
os.chdir(wd)
os.getcwd()

import pandas as pd
import numpy as np
users = pd.read_csv("./data/users_filtered.csv") # Read in the user table
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
        print((user, col))
    
def pearson(ratings1, ratings2):
    '''
    Computes the Pearson correlation coefficient between two users' ratings.
    Only applies to the movies that the two users have rated in common.
    '''
    
    sum_xy = 0
    sum_x = 0
    sum_y = 0
    sum_x2 = 0
    sum_y2 = 0
    n = 0
    for key in ratings1:
        if key in ratings2:
            n += 1
            x = ratings1[key]
            y = ratings2[key]
            sum_xy += x * y
            sum_x += x
            sum_y += y
            sum_x2 += x ** 2
            sum_y2 += y ** 2
    if n == 0:
        return 0
    denominator = np.sqrt(sum_x2 - (sum_x ** 2) / n) * np.sqrt(sum_y2 - (sum_y ** 2) / n)
    if denominator == 0:
        return 0
    else:
        return (sum_xy - (sum_x * sum_y) / n) / denominator
        
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
            distance = pearson(users_data[userids[user]], users_data[username])
            intersection = users_data[userids[user]].keys() & users_data[username].keys()
            distances.append((round(distance, 2), len(intersection), userids[user]))
    # sort based on distance - closest first
    distances.sort(reverse = True)
    return distances

def recommend(username, userids):
    '''
    Recommends 3 movies based on user-item collaborative filtering.
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
        new_movies = new_movies | (users_data[similar_users[similar_user][2]].keys() - users_data[username].keys())
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
    
    # Obtain the top 3 UNIQUE scores and match them to movies
    # (Not specifically looking for UNIQUE scores will yield duplicate movies)
    # Amazon has different ASINs for different versions of the same movie
    # e.g. VHS, DVD, Anniversary Edition, web streaming, etc.
    # Those different versions will all share the same reviews
    top_3_scores = np.unique(ranking)
    recommended_movies = []
    for i in range(3):
        recommended_movies.append(new_movies[np.where(ranking == top_3_scores[-i - 1])[0].tolist()[0]])
    return(recommended_movies)

# Demonstration of the recommend() function:
# 1. On an existing user
demo = recommend('A2OXDJP1Z3LNOK', userids)
print(demo)
# It recommends Casablanca, A Clockwork Orange, and The Maltese Falcon
                        
# 2. On a new user, generated with fake data
# When generating a new user, you must first give them an ID and then
# add them to users_data as follows:
userids[len(userids)] = 'newuser1'
users_data['newuser1'] = {"078062551X": 5, "6301972066": 4, "B00005JLZK": 3, "B000W4HJ44": 2, "B0060D38EQ": 1}

demo2 = recommend('newuser1', userids)
print(demo2)
# It recommends 28 Days Later, Saw, and Office Space

# 3. On another existing user
demo3 = recommend('AUK4Q3BY8BLT2', userids)
print(demo3)
# It recommends Sideways, Red Eye, and Monster-in-Law
    
    