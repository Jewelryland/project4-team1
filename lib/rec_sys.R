library(recommenderlab)
library(dplyr)
library(plyr)

reviews <- readRDS("./data/reviews_filtered2.rds")
reviews <- as.data.frame(reviews)
reviews <- reviews[!duplicated(reviews[,1:2]),]
reviews <- select(reviews, review_userid, product_productid, review_score)
realRating <- as(reviews, "realRatingMatrix")

set.seed(1)
which_test <- sample(1:nrow(realRating), 5, replace = FALSE)
train <- realRating[-which_test]
test <- realRating[which_test]
colnames <- c("userid", "rec_movie1", "rec_movie2", "rec_movie3", "rec_movie4", "rec_movie5")
test_recommend <- as.data.frame(setNames(replicate(6,numeric(0), simplify = F), colnames))
n_recommend <- 5

for (i in 1:nrow(test)){
  
  cat(i,'of 5\n')
  new <- test[i,]
  similarity <- rep(NA, nrow(train))
  for (j in 1:length(similarity)) { similarity[j] <- sum(!is.na(as(train[i,], "matrix") * as(new, "matrix"))) }
  similar_users <- train[order(similarity)[1:1000],]
  movie_index <- order(colSums(similar_users))[1:2000]
  RatingMatrix_Similar <- similar_users[, movie_index]
  new <- new[,movie_index]
  rec_model <- Recommender(data = RatingMatrix_Similar, method = "IBCF", parameter = list(k = 30))
  rec_pred <- predict(object = rec_model, newdata = new, n = n_recommend)
  rec_movieid <- colnames(RatingMatrix_Similar)[unlist(rec_pred@items)]
  test_recommend <- rbind(test_recommend, c(rownames(test)[i], rec_movieid))
  
}

colnames(test_recommend) <- colnames
rownames(test_recommend) <- rownames(test)
test_recommend



