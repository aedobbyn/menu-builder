# get all the dairy and egg data
# this is a nutrient report
  # documentation: 
    # Up to 20 nutrient_ids may be specified. 
    # Likewise, you may request up to 10 food group id's in the fg parameter.

library(httr)
library(tidyverse)
library(jsonlite)
library(tidyjson)

key = "2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm"

# Dairy and Egg Products (fg = 0100) and Poultry Products (fg =0500)
raw <- fromJSON(paste0("https://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", 
                       key, "&nutrients=205&nutrients=204&nutrients=208&nutrients=269&fg=0100&fg=0500"),
                flatten = TRUE) # same if false


# grab the foods report
cooked <- as_tibble(raw$report$foods)


# gm_vec <- cooked %>% 
#   map(., c("nutrients", "gm")) 
# 
# val_vec <- cooked$nutrients %>% 
#   map(., "value") 



for (i in 1:length(cooked$nutrients)) {
  for (j in 1:4) {
    cooked$nutrients[[i]]$gm[j] <- as.character(cooked$nutrients[[i]]$gm[j])
    cooked$nutrients[[i]]$value[j] <- as.character(cooked$nutrients[[i]]$value[j])
  }
}

cooked <- cooked %>% unnest()

# code NAs
cooked <- cooked %>% 
  mutate(
    gm = ifelse(gm == "--", NA, gm),
    value = ifelse(value == "--", NA, value)
  )

