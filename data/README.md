# Project: Movies
### Data folder

reviews_raw.rds is the raw RDS file obtained directly from the original
text file, removing the columns for review date, review summary and
review text.

reviews_original.rds is a clean version of the raw RDS file with the
following changes:
- Merged 24 misaligned rows into 12 properly aligned rows
- Separated review helpfulness into numerator, denominator, and ratio
- Cleaned product IDs into proper 10-digit ASIN format

reviews_filtered.RDS contains all reviews of movies with 100 or more
reviews that were reviewed by at least 1 user with 50 or more reviews.
This file was used to create the movie summary table. It has 4,704,312
rows.

reviews_filtered2.RDS contains only reviews by users with 50 or more
reviews of movies with 100 or more reviews. This file was used to create
the user summary table. It has 1.782,477 rows.

users_filtered.RDS is the user summary table containing the following
info for each user: number of reviews, average number of helpful votes,
total number of helpful votes, average number of votes, total number of
votes, average ratio of helpful votes to total votes, average review
score across all movies, number of 1-star, 2-star, 3-star, 4-star, and
5-star reviews, list of movies given 1 star, 2 stars, 3 stars, 4 stars,
5 stars, and a list of reviews for movies given 1 star, 2 stars, 3
stars, 4 stars and 5 stars.

movies_filtered.RDS is the movie summary table containing the following
info for each movie: number of reviews, total votes, average review
score, number of 1-star, 2-star, 3-star, 4-star and 5-star reviews.

