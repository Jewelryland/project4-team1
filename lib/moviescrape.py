# -*- coding: utf-8 -*-
'''
Notes:
1. Not all movies will have OMDB entries
2. Amazon frequently denies requests from scripts
3. Can't use Amazon API because it requires you to be a marketing affiliate
   with your own website
'''

import os
wd = "C:\\Users\\Arnold\\Downloads" # set this to wherever the movies csv file is
os.chdir(wd)
os.getcwd()

from bs4 import BeautifulSoup
import numpy
import urllib
import pandas
# this is a new .csv file - see fixcsv.R
movies = pandas.read_csv("moviescsvnew.csv")

# Get all unique movie IDs
movies_unique = movies['product_productid'].unique()

# Format movie IDs properly
for i in range(len(movies_unique)):
    if movies_unique[i][0] == "B":
        continue
    elif len(movies_unique[i]) == 11:
        movies_unique[i] = "0" + movies_unique[i][:-2]
    elif len(movies_unique[i]) == 12:
        movies_unique[i] = movies_unique[i][:-2]
        
# Open connection to Amazon
temp = movies_unique[8000] # input any number from 0 to 253058 
link = "http://www.amazon.com/dp/" + temp
r = urllib.request.urlopen(link).read()
soup = BeautifulSoup(r, "lxml")

# Get product title and clean it
if len(soup.find_all(id = "titleSection")) != 0:
    title = soup.find_all(id = "titleSection")[0].find_all(id = "productTitle")[0].contents[0]
else:
    title = str.strip(soup.find_all(id = "aiv-content-title")[0].contents[0])    
if "(" in title:
    title = title.partition(" (")[0]
elif "[" in title:
    title = title.partition(" [")[0]

# OMDB    
import omdb

movie_omdb = omdb.title(title)
genre = movie_omdb['genre']