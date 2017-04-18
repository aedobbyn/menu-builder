

# https://api.nal.usda.gov/ndb/list?format=json&lt=f&sort=n&api_key=DEMO_KEY


library(httr)
library(tidyverse)
library(jsonlite)
library(tidyjson)

key = "2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm"

raw_nut <- fromJSON(paste0("https://api.nal.usda.gov/ndb/list?format=json&lt=n&sort=n&max=1500&api_key=", 
                           key),
                    flatten = TRUE)

nutrients <- as_tibble(raw_nut$list$item)

# set type of id column
nutrients$id <- as.numeric(nutrients$id)


