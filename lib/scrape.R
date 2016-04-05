setwd("/Volumes/HDDData/Chenlu_files/Courses/Columbia/W4249/project4/lib")

library(rvest)
library(dplyr)
library(gdata)
movies.raw <- readRDS("data/moviesrds.rds")
movies.ASIN <- as.character(movies.raw[,1])
movies.ASIN[1]

a <- rep("0", times=1000) # movie_title_raw
b <- rep("0", times=1000) # movie_title
c <- rep("0", times=1000) # movie_genre_raw
d <- rep("0", times=1000) # movie_genre
e <- matrix(rep("0", times=3000), ncol =3) # movie_genre with multiple genre

# Fetch product title from html
for(i in 1:1000){
  ASIN.inq <- movies.ASIN[i]
  movie1 <- read_html(paste("http://www.amazon.com/exec/obidos/ASIN/", ASIN.inq, sep=""))
  # movie name node1
  tryCatch({
    a[i] <- movie1 %>% 
      html_node("#productTitle") %>%
      html_text()
  }, 
  error = function(err){print(i)})
  # movie name node2
  tryCatch({
    a[i] <- movie1 %>% 
      html_node("#aiv-content-title") %>%
      html_text()
  }, 
  error = function(err){print(i)})
  # movie genre node1
  tryCatch({
    c[i] <- movie1 %>% 
      html_node("tr:nth-child(1) td") %>%
      html_text()
  }, 
  error = function(err){print(i)})
  # movie genre node2
  tryCatch({
    c[i] <- movie1 %>% 
      html_node("li:nth-child(5) .a-color-tertiary") %>%
      html_text()
  }, 
  error = function(err){print(i)})
}


# Remove "\n" from movies_title
for(i in 1:1000){
  if(grepl("\n", a[i])){
    s <- unlist(strsplit(a[i],"\n"))
    b[i] <- trim(s[[2]])
  }
  else{b[i] <- a[i]}
}

# Remove "\n" from movies_genre
for(i in 1:1000){
  if(grepl("\n", c[i])){
    s <- unlist(strsplit(c[i],"\n"))
    d[i] <- trim(s[[2]])
  }
  else{d[i] <- c[i]}
}

# Split moview_genre if multiple genre exist
for(i in 1:1000){
  if(grepl(",", d[i])){
    s <- unlist(strsplit(d[i],","))
    e[i,1] <- trim(s[[1]])
    e[i,2] <- trim(s[[2]])
    tryCatch({e[i,3] <- trim(s[[3]])}, error = function(err){print(i)})
  }
  else{e[i,1] <- d[i]}
}

movie_title <- b
movie_genre <- e
saveRDS(movie_title, "movie_title.rds")
saveRDS(movie_genre, "movie_genre.rds")
