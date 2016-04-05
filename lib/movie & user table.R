library(dplyr)
library(tidyr)

movie <- read.csv("D:/data/ADS/Project_4/movies.csv", header = T)

# Parsing the helpfulness votes
movie.raw <- movie %>%
  separate(review_helpfulness, c("helpful.v", "total.v"), sep = "/", remove = F)
movie.raw <- movie.raw %>%
  mutate(review_h = as.numeric(helpful.v) / as.numeric(total.v))
movie.raw[is.na(movie.raw)] <- 0

# Compute some user summaries
user.table <- movie.raw %>%
  group_by(review_userid) %>%
  summarize(
    user_count = n(),
    user_read = mean(as.numeric(total.v)),
    user_help = mean(review_h),
    user_score_ave = mean(review_score),
    user_score_1 = sum(review_score == 1),
    user_score_2 = sum(review_score == 2),
    user_score_3 = sum(review_score == 3),
    user_score_4 = sum(review_score == 4),
    user_score_5 = sum(review_score == 5)
  )

movie.raw <- left_join(movie.raw, user.table, by = "review_userid")

# Compute some movie summaries
movie.table <- movie.raw %>%
  group_by(product_productid) %>%
  summarize(
    movie_count = n(),
    movie_read = sum(as.numeric(total.v)),
    movie_score_ave = mean(review_score),
    movie_score_1 = sum(review_score == 1),
    movie_score_2 = sum(review_score == 2),
    movie_score_3 = sum(review_score == 3),
    movie_score_4 = sum(review_score == 4),
    movie_score_5 = sum(review_score == 5)
  )

movie.raw <- left_join(movie.raw, product.table, by = "product_productid")

save(movie.raw, file = "movie.RDS")
save(movie.table, file = "movie_table.RDS")
save(user.table, file = "user_table.RDS")



