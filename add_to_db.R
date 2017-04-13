# add foods to a postgres db

library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="usda", host='localhost', port=5432, user="amanda")

# now get those foods
food_list <- dbGetQuery(con, "SELECT * FROM food_list") 
food_list <- as_tibble(food_list)

# add food to db using while loop
# total number of foods is 184023 accoriding to https://ndb.nal.usda.gov/ndb/search/list
add_foods <- function () {
  df <- NULL
  offset <- max(food_list$offset) # if we're adding to a new table, offset <- 0
  while (offset < 184023) {
    print(offset)
    raw_req <- fromJSON(paste0("https://api.nal.usda.gov/ndb/list?format=json&lt=f&max=1500&sort=n&offset=", offset,
                               "&api_key=", 
                               key),
                        flatten = TRUE)
    this_food_list <- as_tibble(raw_req$list$item)
    dbWriteTable(con, "food_list", 
                 value = this_food_list, append = TRUE, row.names = FALSE)
    offset <- offset + nrow(this_food_list)
  }
}

add_foods()









##### mysql

library(RMySQL)

drv <- dbDriver("RMySQL")
con <- dbConnect(drv, dbname="food-prog", host='localhost', port=3306, user="amanda")

# now get those foods
food_list <- dbGetQuery(con, "SELECT * FROM food_list") 
food_list <- as_tibble(food_list)

# add food to db using while loop
# total number of foods is 184023 accoriding to https://ndb.nal.usda.gov/ndb/search/list
add_foods <- function () {
  df <- NULL
  offset <- 0
  while (offset < 1000) {
    print(offset)
    raw_req <- fromJSON(paste0("http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", key, 
                               "&nutrients=205&nutrients=204&nutrients=208&nutrients=269&offset=", offset,
                               "&api_key=", 
                               key),
                        flatten = TRUE)
    this_food_list <- as_tibble(raw_req$list$item)
    dbWriteTable(con, "food_list", 
                 value = this_food_list, append = TRUE, row.names = FALSE)
    offset <- offset + nrow(this_food_list)
  }
}

add_foods()










