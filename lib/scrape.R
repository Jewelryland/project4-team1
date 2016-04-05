setwd("/Volumes/HDDData/Chenlu_files/Courses/Columbia/W4249/project4/lib")
movies.raw <- readRDS("moviesrds.rds")
movies.ASIN <- as.character(movies.raw[,1])
movies.ASIN[1]
library(rvest)
a <- rep("0", times=100)
#b <- rep("0", times=100)
c <- rep("0", times=100)
#d <- rep("0", times=100)
# Fetch product title from html
for(i in 1:100){
  ASIN.inq <- movies.ASIN[i]
  movie1 <- read_html(paste("http://www.amazon.com/exec/obidos/ASIN/", ASIN.inq, sep=""))
  tryCatch({
    a[i] <- movie1 %>% 
      html_node("#productTitle") %>%
      html_text()
  }, 
  error = function(err){print(i)})
  tryCatch({
    a[i] <- movie1 %>% 
      html_node("#aiv-content-title") %>%
      html_text()
  }, 
  error = function(err){print(i)})
  tryCatch({
    c[i] <- movie1 %>% 
      html_node("tr:nth-child(1) td") %>%
      html_text()
  }, 
  error = function(err){print(i)})
  tryCatch({
    c[i] <- movie1 %>% 
      html_node("li:nth-child(5) .a-color-tertiary") %>%
      html_text()
  }, 
  error = function(err){print(i)})
}
saveRDS(a, "movie_name.rds")
saveRDS(c, "movie_genre.rds")