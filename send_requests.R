# multiple requests

# https://api.nal.usda.gov/ndb/list?format=json&lt=f&sort=n&api_key=DEMO_KEY


get_food_list <- function(n_req, offset) {
  df <- NULL
  offset <- 0
  n_req <- 3
  for (i in n_req) {
    raw_req <- fromJSON(paste0("https://api.nal.usda.gov/ndb/list?format=json&lt=f&sort=y&offset=", offset, 
                               "&api_key=", 
                               key),
                        flatten = TRUE)
    this_food_list <- as_tibble(raw_req$list$item)
    df <- rbind(df, this_food_list)
    offset <- offset + nrow(this_food_list)
  }
  df <- as_tibble(df)
}

get_food_list()


food_list <- fromJSON(paste0("https://api.nal.usda.gov/ndb/list?format=json&lt=f&sort=n&api_key=", 
                          key),
                   flatten = TRUE)
