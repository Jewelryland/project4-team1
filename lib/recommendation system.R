library(data.table)
library(ggplot2)
library(recommenderlab)
library(dplyr)
library(plyr)

# Build rating matrix
load("movie.RDS")
table <- select(movie.raw, review_userid, product_productid, review_score)
table <- table0[!duplicated(table0[,1:2]),]
rating_matrix <- as(table, "realRatingMatrix")
rating_movies <- rating_matrix[rowCounts(rating_matrix) > 10, colCounts(rating_matrix) > 10]

# Exploring the most relevant data
min_movies <- quantile(rowCounts(rating_movies), 0.98)
min_users <- quantile(colCounts(rating_movies), 0.98)
image(rating_movies[rowCounts(rating_movies) > min_movies, colCounts(rating_movies) > min_users],
      main = "Heatmap of the top users and movies")

average_rating_per_user <- rowMeans(rating_movies)
qplot(average_rating_per_user) + stat_bin(binwidth = 0.1) + ggtitle("Distribution of the average rating per user")

# Normalizing the data
rating_movies_norm <- normalize(rating_movies)

# Binarizing the data
rating_movies_reviewed <- binarize(rating_movies, minRating = 1)
image(rating_movies_reviewed[rowCounts(rating_movies) > min_movies, colCounts(rating_movies) > min_users],
      main = "Heatmap of the top users and movies")

# Item-based collaborative filtering
which_set <- sample(x = 1:5, size = nrow(rating_movies), replace = TRUE)
n_recommend <- 5
recommend_list <- list()
for (i in 1:5){
  which_train <- (which_set == i)
  train <- rating_movies[!which_train,]
  test <- rating_movies[which_train,]
  recommend_model <- Recommender(data = train, method = "IBCF", parameter = list(k = 30))
  recommend_predict <- predict(object = recommend_model, newdata = test, n = n_recommend)
  recommend_list0 <- sapply(recommend_predict@items, function(x) colnames(rating_movies)[x])
  recommend_list <- append(recommend_list, recommend_list0)
}









