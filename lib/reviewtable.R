library(dplyr)
library(tidyr)

reviews_raw <- readRDS("./data/reviews_raw.rds")
reviews_raw <- tbl_df(reviews_raw)

# Create a unique ID for each review
reviews_raw <- mutate(reviews_raw, review_id = as.integer(rownames(reviews_raw)))

# Change product ID from factor to character
reviews_raw$product_productid <- as.character(reviews_raw$product_productid)

# Merge 24 misaligned rows into 12 properly aligned rows
misaligned_rows <- which(reviews_raw$product_productid == "")
reviews_raw$product_productid[misaligned_rows] <- reviews_raw$product_productid[misaligned_rows - 1]
reviews_raw$review_userid[misaligned_rows] <- reviews_raw$review_userid[misaligned_rows - 1]
reviews_original <- filter(reviews_raw, !is.na(review_score))

# Separate review helpfulness into numerator, denominator, and ratio
reviews_original <- reviews_original %>% separate(review_helpfulness, c("helpful.v", "total.v"), sep = "/", remove = T)
reviews_original <- reviews_original %>% mutate(review_helpfulness = as.numeric(helpful.v) / as.numeric(total.v))

# Clean product IDs into proper ASIN format

improper_rows <- grep("\\.0", reviews_original$product_productid)
reviews_original$product_productid[improper_rows] <- 
  substr(reviews_original$product_productid[improper_rows],
         start = 1, stop = nchar(reviews_original$product_productid[improper_rows]) - 2)

length_7_rows <- which(nchar(reviews_original$product_productid) == 7)
length_8_rows <- which(nchar(reviews_original$product_productid) == 8)
length_9_rows <- which(nchar(reviews_original$product_productid) == 9)
reviews_original$product_productid[length_7_rows] <- 
  paste("000", reviews_original$product_productid[length_7_rows], sep = "")
reviews_original$product_productid[length_8_rows] <- 
  paste("00", reviews_original$product_productid[length_8_rows], sep = "")
reviews_original$product_productid[length_9_rows] <- 
  paste("0", reviews_original$product_productid[length_9_rows], sep = "")

saveRDS(reviews_original, "./data/reviews_original.RDS")

reviews_original <- readRDS("reviews_original.RDS")

# Create a vector of all movies with 100 or more reviews
reviews_per_movie <- reviews_original %>% group_by(product_productid) %>% summarize(count = n())
reviews_per_movie <- reviews_per_movie %>% arrange(desc(count))
reviews_per_movie_morethan100 <- filter(reviews_per_movie, count >= 100)

# Filter reviews_original: return only reviews for movies with 100 or more reviews
reviews_filtered <- filter(reviews_original, product_productid %in% reviews_per_movie_morethan100$product_productid)

# Create a vector of all users with 50 or more reviews who have also reviewed at least 1 movie with 100 or more reviews
reviews_per_user <- reviews_filtered %>% group_by(review_userid) %>% summarize(count = n())
reviews_per_user <- reviews_per_user %>% arrange(desc(count))
reviews_per_user_morethan50 <- filter(reviews_per_user, count >= 50)

# reviews_filtered2 contains only reviews by users with 50 or more reviews of movies with 100 or more reviews
# This table is for creating the user summary table
reviews_filtered2 <- filter(reviews_filtered, review_userid %in% reviews_per_user_morethan50$review_userid)

# reviews_filtered contains all reviews of movies with 100 or more reviews that were reviewed by at least 1 user with 50 or more reviews
# This table is for creating the movie summary table
reviews_filtered <- filter(reviews_filtered, product_productid %in% reviews_filtered2$product_productid)

saveRDS(reviews_filtered, "./data/reviews_filtered.RDS")
saveRDS(reviews_filtered2, "./data/reviews_filtered2.RDS")
