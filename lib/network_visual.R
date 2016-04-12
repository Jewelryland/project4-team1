library(dplyr)
library(recommenderlab)
library(statnet)
library(tidyr)


reviews <- as.data.frame(readRDS("./data/reviews_original.RDS"))
users <- as.data.frame(readRDS("./data/users_filtered.RDS"))
movies <- as.data.frame(readRDS("./data/movies_filtered.RDS"))

# Users who give highest average scores
users_high_id <- users$review_userid[order(users$user_score_avg, users$user_count, decreasing = T)[1:50]]
users_high_review <- reviews %>%
                     filter(review_userid %in% users_high_id) %>%
                     select(review_userid, product_productid, review_score) %>%
                     left_join(users[,1:2], by = "review_userid")

# Users who give lowest average scores
users_low_id <- users$review_userid[order(-users$user_score_avg, users$user_count, decreasing = T)[1:50]]
users_low_review <- reviews %>%
                    filter(review_userid %in% users_low_id) %>%
                    select(review_userid, product_productid, review_score) %>%
                    left_join(users[,1:2], by = "review_userid")

# Combine two groups of people who give highest and lowest average scores and plot the network
users_reivew <- rbind(users_high_review, users_low_review)
users_realRating <- as(users_reivew, "realRatingMatrix")
users_group <- ifelse(rownames(users_realRating) %in% users_high_id, "high", "low")
users_similarity <- as.matrix(similarity(users_realRating, method = "cosine", which = "users"))
users_similarity[is.na(users_similarity)] <- 0
users_netmat <- ifelse(users_similarity > 0.05, 1, 0)
users_net <- network(users_netmat, matrix.type = "adjacency")
set.vertex.attribute(users_net, "group", users_group)
vertex_col <- ifelse(users_group == "high", "slateblue", "green")
gplot(users_net, usearrows = FALSE, vertex.cex = 1.5, vertex.col = vertex_col, edge.col = "grey75")
legend("bottomleft", legend = c("high", "low"), col = c("slateblue", "green"), pch = 19, pt.cex = 1.5, bty = "n", title = "Users", cex = 1.2)
title("The network of users give\nhighest and lowest average scores")


# Moives which have highest average scores
movies_high_id <- movies$product_productid[order(movies$movie_score_avg, movies$movie_count, decreasing = T)[1:50]]
movies_high_review <- reviews %>%
  filter(product_productid %in% movies_high_id) %>%
  select(review_userid, product_productid, review_score)

# Users who give lowest average scores
movies_low_id <- movies$product_productid[order(-movies$movie_score_avg, movies$movie_count, decreasing = T)[1:50]]
movies_low_review <- reviews %>%
  filter(product_productid %in% movies_low_id) %>%
  select(review_userid, product_productid, review_score)

# Combine two groups of people who give highest and lowest average scores and plot the network
movies_reivew <- rbind(movies_high_review, movies_low_review)
movies_realRating <- as(movies_reivew, "realRatingMatrix")
movies_group <- ifelse(colnames(movies_realRating) %in% movies_high_id, "high", "low")
movies_similarity <- as.matrix(similarity(movies_realRating, method = "cosine", which = "items"))
movies_similarity[is.na(movies_similarity)] <- 0
movies_netmat <- ifelse(movies_similarity > 0.01, 1, 0)
movies_net <- network(movies_netmat, matrix.type = "adjacency")
set.vertex.attribute(movies_net, "group", movies_group)
vertex_col <- ifelse(movies_group == "high", "slateblue", "green")
gplot(movies_net, usearrows = FALSE, vertex.cex = 1.5, vertex.col = vertex_col, edge.col = "grey75")
legend("bottomleft", legend = c("high", "low"), col = c("slateblue", "green"), pch = 19, pt.cex = 1.5, bty = "n", title = "Users", cex = 1.2)
title("The network of movies with\nhighest and lowest average scores")


# Network of movies with genre as labels
genre <- readRDS("./data/movie_genre.rds")
reviews_original <- as.data.frame(readRDS("./data/reviews_original.RDS"))
genre <- data.frame(product_productid = unique(reviews_original$product_productid)[1:100], genre = genre[,1])
reviews_genre <- reviews_original %>%
                 filter(product_productid %in% movies_genre$product_productid) %>%
                 select(review_userid, product_productid, review_score) %>%
                 left_join(genre, by = "product_productid")
movies_genre_realRating <- as(reviews_genre[,1:3], "realRatingMatrix")
movies_genre_group <- lapply(colnames(movies_genre_realRating), function(x) as.character(reviews_genre$genre[which(reviews_genre$product_productid == x)[1]]))
movies_genre_group <- unlist(movies_genre_group)
movies_genre_similarity <- as.matrix(similarity(movies_genre_realRating, method = "cosine", which = "items"))
movies_genre_similarity[is.na(movies_genre_similarity)] <- 0
movies_genre_netmat <- ifelse(movies_genre_similarity > 0.01, 1, 0)
movies_genre_net <- network(movies_genre_netmat, matrix.type = "adjacency")
set.vertex.attribute(movies_genre_net, "group", movies_genre_group)
genre_name <- unique(movies_genre_group)
vertex_col <- unlist(lapply(movies_genre_group, function(x) which(genre_name == x)))
gplot(movies_genre_net, gmode = "graph", mode = "fruchtermanreingold", usearrows = FALSE, vertex.cex = 1.5, 
      vertex.col = vertex_col, edge.col = "grey75")
legend(5, 45, legend = genre_name, col = 1:8, pch = 19, pt.cex = 1.5, bty = "n", title = "Genres", cex = 1)
title("The network of movies with genre")


# Similarity of genres
n_genre <- length(genre_name)
n_movie <- nrow(movies_genre_similarity)
movie_name <- rownames(movies_genre_similarity)
genre_similarity <- as.data.frame(matrix(0, n_genre, n_genre))
rownames(genre_similarity) <- genre_name
colnames(genre_similarity) <- genre_name

for (i in 1:n_movie){
  for (j in 1:n_movie){
    i_genre <- reviews_genre$genre[which(reviews_genre$product_productid == movie_name[i])[1]]
    j_genre <- reviews_genre$genre[which(reviews_genre$product_productid == movie_name[j])[1]]
    if (i != j){  genre_similarity[which(genre_name == i_genre), which(genre_name == j_genre)] <- movies_genre_similarity[i,j] }
  }
}

genre_similarity_net <- network(genre_similarity, matrix.type = "adjacency")
set.vertex.attribute(genre_similarity_net, "genre", genre_name)

# Chord diagram to show the similarity between genres
library(circlize)
chordDiagram(genre_similarity)
title("Similarity between genres")


plot(users$user_count, users$avg_review_helpfulness, pch = 19)
plot(movies$movie_count, movies$movie_score_avg, pch = 19)







