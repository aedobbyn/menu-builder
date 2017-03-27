# get all the dairy and egg data

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

lunch <- cooked

for (i in 1:length(lunch$nutrients)) {
  for (j in 1:4) {
    lunch$nutrients[[i]]$gm[j] <- as.character(lunch$nutrients[[i]]$gm[j])
  }
}

home_on_range <- lunch %>% unnest()

# code NAs
hor <- home_on_range %>% 
  mutate(
    gm2 = ifelse(gm == "--", NA, gm),
    value2 = ifelse(gm == "--", NA, value)
  )





