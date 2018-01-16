# get all nutrients for all foods
  # our nutrients list has 190 nutrients
  # our foods list has 184022 foods
  # we want all nutrients for all foods

# USDA specs for nutrient request
  # Up to 20 nutrient_ids may be specified. Likewise, you may request up to 10 food group id's in the fg parameter.

# loop through list

# then join nutrient name to nutrient id


source("./other/nutrient_list.R")

# ------- to change once get working ------
# change max to 1500 in url
# pipe into db rather than df
# change while (offset < whatever the max is or a big number)

get_all_things <- function () {
  df <- NULL
  offset <- 0
  while (offset < 5) {
    for (nut in seq_along(nutrients$id[1:10])) {

      print(paste0("offset: ", offset))
      print(paste0("nutrient: ", nutrients$id[nut]))

      raw_req <- fromJSON(paste0("http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=",
                                 key, "&offset=", offset, "&subset=0&max=1&nutrients=", nutrients$id[nut]),
                          flatten = TRUE)
      this_food_list <- as_tibble(raw_req$report$foods)
      df <- rbind(df, this_food_list)
      
    }
  offset <- offset + 1
  }
  df
}

baz <- get_all_things()

baz



# grab the foods report
# baz <- as_tibble(dat$report$foods)

# make all gm elements in the nutrients list-column characters so that we can unnest
# this list-column
for (i in 1:length(baz$nutrients)) {
  for (j in 1:4) {
  # for (j in 1:nrow(nutrients)) {
    baz$nutrients[[i]]$gm[j] <- as.character(baz$nutrients[[i]]$gm[j])
    baz$nutrients[[i]]$value[j] <- as.character(baz$nutrients[[i]]$value[j])
  }
}


# unnest it
baz <- baz %>% unnest()

# code NAs
baz <- baz %>% 
  mutate(
    gm = ifelse(gm == "--", NA, gm),
    value = ifelse(value == "--", NA, value)
  )






# --------------- sandbox -----------------

unique(baz$nutrient_id)

for (nut in seq_along(nutrients$id)) {
  print(paste0("nutrient: ", nutrients$id[nut]))
}
