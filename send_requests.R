# multiple requests

# https://api.nal.usda.gov/ndb/list?format=json&lt=f&sort=n&api_key=DEMO_KEY


# at some point will want to figure out how to keep sending requests until we have every row
# while loop maybe: find out how to get total somehow and while raw_req$list$item$offset < total, keep sending requests
get_food_list <- function(n_req, offset) {
  df <- NULL
  offset <- 0
  n_req <- 3
  for (i in 1:n_req) {
    print(i)
    raw_req <- fromJSON(paste0("https://api.nal.usda.gov/ndb/list?format=json&lt=f&sort=n&offset=", offset,
                               "&api_key=", 
                                            key),
                                     flatten = TRUE)
      print(offset)
    this_food_list <- as_tibble(raw_req$list$item)
    df <- rbind(df, this_food_list)
    offset <- offset + nrow(this_food_list)
  }
  df
}

fl <- get_food_list()




get_food_list2 <- function(offset) {
  df <- NULL
  offset <- 0
  while (offset < 1000) {
    raw_req <- fromJSON(paste0("https://api.nal.usda.gov/ndb/list?format=json&lt=f&sort=n&offset=", offset,
                               "&api_key=", 
                               key),
                        flatten = TRUE)
    print(offset)
    this_food_list <- as_tibble(raw_req$list$item)
    df <- rbind(df, this_food_list)
    offset <- offset + nrow(this_food_list)
  }
  df
}


fl2 <- get_food_list2()


library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

# set connection to our db
con <- dbConnect(drv, dbname="usda", host='localhost', port=5432, user="amanda")

dbWriteTable(con, "foods", 
             value = fl2, append = TRUE, row.names = FALSE)






# add food to db


add_foods <- function () {
  df <- NULL
  offset <- 0
  while (offset < 5000) {
    raw_req <- fromJSON(paste0("https://api.nal.usda.gov/ndb/list?format=json&lt=f&sort=n&offset=", offset,
                               "&api_key=", 
                               key),
                        flatten = TRUE)
    this_food_list <- as_tibble(raw_req$list$item)
    dbWriteTable(con, "all_foods", 
                 value = this_food_list, append = TRUE, row.names = FALSE)
    offset <- offset + nrow(this_food_list)
  }
}

add_foods()






