
source("./connect.R")


# all nutrients for cheddar cheese

cheese <- fromJSON(paste0("https://api.nal.usda.gov/ndb/reports/?ndbno=01009&type=b&format=json&api_key=", 
                          key),
                   flatten = TRUE) # same if false 


cheese <- as_tibble(cheese$report$food$nutrients)

# looks like we can unnest straight away as everything was imported as character
cheese <- cheese %>% unnest()


