# pull in data from the usda db
# help site: https://ndb.nal.usda.gov/ndb/doc/index#

library(httr)
library(tidyverse)
library(jsonlite)
library(tidyjson)

key = "2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm"
key2 = "JpZKpLFyYzRToNxCrcKSDHy6aJZKDdzo65MNZ1AH"


# get all foods
# max per request is 1500, default is 50 so specify 1500 
# use offset to specify beginning row
# set subset to 1 so get most common foods. else a 1:1500 query only brings you from a to beef
dat <- fromJSON(paste0("http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", 
                       key2, "&subset=1&max=1500&nutrients=205&nutrients=204&nutrients=208&nutrients=269"),
                flatten = TRUE) # same if false


# grab the foods report
all_foods <- as_tibble(dat$report$foods)

# make all gm elements in the nutrients list-column characters so that we can unnest
# this list-column
for (i in 1:length(all_foods$nutrients)) {
  for (j in 1:4) {
    all_foods$nutrients[[i]]$gm[j] <- as.character(all_foods$nutrients[[i]]$gm[j])
    all_foods$nutrients[[i]]$value[j] <- as.character(all_foods$nutrients[[i]]$value[j])
  }
}

# unnest it
all_foods <- all_foods %>% unnest()

# code NAs
all_foods <- all_foods %>% 
  mutate(
    gm = ifelse(gm == "--", NA, gm),
    value = ifelse(value == "--", NA, value)
  )



# --------------------- set datatypes --------------------
# numeric: ndbno, nutrient_id, value, gm
all_foods$ndbno <- as.numeric(all_foods$ndbno)
all_foods$nutrient_id <- as.numeric(all_foods$nutrient_id)
all_foods$value <- as.numeric(all_foods$value)
all_foods$gm <- as.numeric(all_foods$gm)

# factors: name, nutrient, unit
all_foods$name <- factor(all_foods$name)
all_foods$nutrient <- factor(all_foods$nutrient)
all_foods$unit <- factor(all_foods$unit)



# value: 100 g equivalent value of the nutrient
# get per gram 



# ---------

# order by most sugar

fried <- all_foods %>% 
  filter(
    nutrient == "Sugars, total"
  ) %>% 
  arrange(
    desc(gm)
  )


by_nutrient <- all_foods %>% 
  group_by(
    nutrient
  ) %>% 
  arrange(
    desc(value)
  )



all_nutrients <- fromJSON(paste0("http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", 
                                        key, "&subset=1&max=1500&nutrients=205&nutrients=204&nutrients=208&nutrients=269"),
                                 flatten = TRUE) # same if false





