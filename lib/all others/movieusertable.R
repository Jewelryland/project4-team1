library(dplyr)
library(tidyr)

reviews_filtered <- readRDS("./data/reviews_filtered.RDS")
reviews_filtered2 <- readRDS("./data/reviews_filtered2.RDS")

users <- reviews_filtered2 %>%
  group_by(review_userid) %>%
  summarize(
    user_count = n(),
    avg_helpful_votes = mean(as.numeric(helpful.v)),
    total_helpful_votes = sum(as.numeric(helpful.v)),
    avg_votes = mean(as.numeric(total.v)),
    total_votes = sum(as.numeric(total.v)),
    avg_review_helpfulness = mean(review_helpfulness),
    user_score_avg = mean(review_score),
    user_score_1 = sum(review_score == 1),
    user_score_2 = sum(review_score == 2),
    user_score_3 = sum(review_score == 3),
    user_score_4 = sum(review_score == 4),
    user_score_5 = sum(review_score == 5),
    movies_1_star = paste(product_productid[review_score == 1], collapse = " "),
    movies_2_star = paste(product_productid[review_score == 2], collapse = " "),
    movies_3_star = paste(product_productid[review_score == 3], collapse = " "),
    movies_4_star = paste(product_productid[review_score == 4], collapse = " "),
    movies_5_star = paste(product_productid[review_score == 5], collapse = " "),
    review_1_star = paste(review_id[review_score == 1], collapse = " "),
    review_2_star = paste(review_id[review_score == 2], collapse = " "),
    review_3_star = paste(review_id[review_score == 3], collapse = " "),
    review_4_star = paste(review_id[review_score == 4], collapse = " "),
    review_5_star = paste(review_id[review_score == 5], collapse = " ")
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
