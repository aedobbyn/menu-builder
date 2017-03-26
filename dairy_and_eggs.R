# 


library(httr)
library(tidyverse)
library(jsonlite)
library(tidyjson)

key = "2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm"



# Dairy and Egg Products (fg = 0100) and Poultry Products (fg =0500)
# woot
raw <- fromJSON(paste0("https://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", key, "&nutrients=205&nutrients=204&nutrients=208&nutrients=269&fg=0100&fg=0500"))
# , 
# flatten = TRUE,
# simplifyDataFrame = TRUE))

cooked <- as_tibble(raw$report$foods)


# cooked2 <- tbl_json(cooked)

# dairy_and_eggs$nutrients[[1]]$gm <- as.character(dairy_and_eggs$nutrients[[1]]$gm)

# cooked$nutrients <- as.character(cooked$nutrients)

cooked$nutrients[[1]]$gm <- as.character(cooked$nutrients[[1]]$gm)
cooked$nutrients[[2]]$gm <- as.character(cooked$nutrients[[2]]$gm)
cooked$nutrients[[3]]$gm <- as.character(cooked$nutrients[[3]]$gm)

breakfast <- cooked[1:3, ]

free_range <- breakfast %>% unnest()




