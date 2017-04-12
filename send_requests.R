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


