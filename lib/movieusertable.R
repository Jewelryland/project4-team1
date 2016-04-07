library(dplyr)
library(tidyr)

reviews_filtered <- readRDS("./data/reviews_filtered.RDS")
reviews_filtered2 <- readRDS("./data/reviews_filtered2.RDS")

users <- reviews_filtered2 %>%
  group_by(review_userid) %>%
  summarize(
    user_count = n(),
    avg_helpful_votes_per_review = mean(as.numeric(helpful.v)),
    total_helpful_votes = sum(as.numeric(helpful.v)),
    avg_votes_per_review = mean(as.numeric(total.v)),
    total_votes = sum(as.numeric(total.v)),
    avg_review_helpfulness = mean(review_helpfulness),
    user_score_avg = mean(review_score),
    user_score_1 = sum(review_score == 1),
    user_score_2 = sum(review_score == 2),
    user_score_3 = sum(review_score == 3),
    user_score_4 = sum(review_score == 4),
    user_score_5 = sum(review_score == 5),
    movies_1_star = list(product_productid[review_score == 1]),
    movies_2_star = list(product_productid[review_score == 2]),
    movies_3_star = list(product_productid[review_score == 3]),
    movies_4_star = list(product_productid[review_score == 4]),
    movies_5_star = list(product_productid[review_score == 5]),
    review_1_star = list(review_id[review_score == 1]),
    review_2_star = list(review_id[review_score == 2]),
    review_3_star = list(review_id[review_score == 3]),
    review_4_star = list(review_id[review_score == 4]),
    review_5_star = list(review_id[review_score == 5])
  )

saveRDS(users, "./data/users_filtered.RDS")

movies <- reviews_filtered %>%
  group_by(product_productid) %>%
  summarize(
    movie_count = n(),
    total_votes = sum(as.numeric(total.v)),
    movie_score_avg = mean(review_score),
    movie_score_1 = sum(review_score == 1),
    movie_score_2 = sum(review_score == 2),
    movie_score_3 = sum(review_score == 3),
    movie_score_4 = sum(review_score == 4),
    movie_score_5 = sum(review_score == 5)
  )

saveRDS(movies, "./data/movies_filtered.RDS")
