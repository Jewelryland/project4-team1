# This code merges 24 misaligned rows from the .csv file provided by the professor 
# into 12 properly aligned rows and writes a new .csv file.

library(dplyr)
movies.raw <- readRDS("data/moviesrds.rds")
movies.raw <- tbl_df(movies.raw)
misaligned_rows <- which(movies.raw$product_productid == "")
movies.raw$product_productid[misaligned_rows] <- movies.raw$product_productid[misaligned_rows - 1]
movies.raw$review_userid[misaligned_rows] <- movies.raw$review_userid[misaligned_rows - 1]
movies.raw <- filter(movies.raw, !is.na(review_score))
write.csv(movies.raw, "moviescsvnew.csv")
