# documentation for food report: https://ndb.nal.usda.gov/ndb/doc/apilist/API-FOOD-REPORT.md

source("./connect.R")

# all nutrients for cheddar cheese
cheese <- fromJSON(paste0("https://api.nal.usda.gov/ndb/reports/?ndbno=01009&type=b&format=json&api_key=", 
                          key),
                   flatten = TRUE) # same if false 


cheese <- as_tibble(cheese$report$food$nutrients)

# looks like we can unnest straight away as everything was imported as character
cheese <- cheese %>% unnest()

# change nested value to evalue so we don't have two columns with the same name
names(cheese)[10] <- "evalue"



