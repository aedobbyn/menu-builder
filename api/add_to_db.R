# add foods to a db

# set up the connection
# for the case where we already have some foods in the table and we want to add to it:
  # retrieve everything in the food_list db table and save it as food_list dataframe
  # inside the add_foods() function, set offset to max(food_list$offset). 
    # this is equivalent to getting the number of the last row in the db table
# if we're setting up a new table, there wouldn't be any rows yet so we'd set offset to 0
# ping the api to get some foods. get the max number of foods you can get in a query by setting max=1500 in the url
  # save this in the local variable this_food_list, which should always be 1500 rows long
# append this_food_list to the db table directly rather than appending it to an R dataframe
  # this way we don't have to keep the whole table in memory, we send it it to the db
    # if we did want to get the entire table we can do that with the dbGetQuery() as we did earlier
# increment offset until we hit the max number of foods (184023)


#### -------------------- Postgres ----------------------- ####
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="usda", host='localhost', port=5432, user="amanda")

# existing foods in food_list table in postgres db
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









#### -------------------- MySQL ----------------------- ####
library(RMySQL)

drv <- dbDriver("RMySQL")
con <- dbConnect(RMySQL::MySQL(), dbname="usda", host='localhost', port=3306, user="root")
                 # password = "")

# add food to db using while loop
# total number of foods is 184023 accoriding to https://ndb.nal.usda.gov/ndb/search/list
add_nutrients <- function () {
  df <- NULL
  offset <- 0
  while (offset < 1000) {
    print(offset)
    raw_req <- fromJSON(paste0("http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", key, 
                               "&nutrients=203&nutrients=401&nutrients=262&nutrients=405&offset=", offset),
                        flatten = TRUE)
    this_food_list <- as_tibble(raw_req$report$foods)
    
      # prepare the food df for unnesting the nutrients column
      for (i in 1:length(this_food_list$nutrients)) {
        for (j in 1:4) {
          this_food_list$nutrients[[i]]$gm[j] <- as.character(this_food_list$nutrients[[i]]$gm[j])
          this_food_list$nutrients[[i]]$value[j] <- as.character(this_food_list$nutrients[[i]]$value[j])
        }
      }
      
      # unnest it
      this_food_list <- this_food_list %>% unnest()
      
      # code NAs
      this_food_list <- this_food_list %>% 
        mutate(
          gm = ifelse(gm == "--", NA, gm),
          value = ifelse(value == "--", NA, value)
        )
      
    dbWriteTable(con, "some_nutrients", 
                 value = this_food_list, append = TRUE, row.names = FALSE)
    offset <- offset + nrow(this_food_list)
  }
}

add_nutrients()






