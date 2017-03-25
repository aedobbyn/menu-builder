
library(httr)
library(tidyverse)
library(jsonlite)

# help site: https://ndb.nal.usda.gov/ndb/doc/index#

# key
key = "2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm"

# example
example = "https://api.data.gov/nrel/alt-fuel-stations/v1/nearest.json?api_key=2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm&location=Denver+CO"


foo <- GET(url = "https://api.data.gov/nrel/alt-fuel-stations/v1/nearest.json?api_key=2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm&location=Denver+CO")

head(foo)
content(foo)


# 
all_foods <- GET(url = "http://api.nal.usda.gov/ndb/reports/?nutrients=204&nutrients=208&nutrients=205&nutrients=269&max=50&offset=25&format=xml&api_key=DEMO_KEY")
head(all_foods$content)

str(all_foods$content)



b <- fromJSON(bar)


bar <- GET(url = "https://api.nal.usda.gov/ndb/reports/V2?ndbno=01009&ndbno=01009&ndbno=45202763&ndbno=35193&type=b&format=json&api_key=DEMO_KEY")


# Dairy and Egg Products (fg = 0100) and Poultry Products (fg =0500)
# woot
baz <- fromJSON(paste0("https://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", key, "&nutrients=205&nutrients=204&nutrients=208&nutrients=269&fg=0100&fg=0500", 
                       flatten = TRUE))

dairy_and_eggs <- as_tibble(baz$report$foods)

names(dairy_and_eggs)


dim(dairy_and_eggs)


# each ingredient has a df of nutrient values
head(dairy_and_eggs$nutrients)


# df of nutrient IDs for first nutrient
dairy_and_eggs$nutrients[1][[1]][1]

# vector of units for first nutrient
dairy_and_eggs$nutrients[[1]]$unit


# each food has multiple nutrients
# want to unnest everything in nutrients or keep them nested?
dairy_and_eggs$nutrients[[1]]



