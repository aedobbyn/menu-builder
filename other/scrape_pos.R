library(rvest)
library(tidyverse)

url <- "https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html"

pos_table_raw <- url %>% 
  read_html() %>% 
  html_nodes("table") %>% 
  html_table() 

pos_table <- pos_table_raw[[1]] %>% 
  as_tibble()

names(pos_table) <- pos_table[1,]

pos_table <- pos_table %>% 
  slice(-1) %>% 
  select(-Number)