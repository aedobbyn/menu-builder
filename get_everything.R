# get all nutrients for all foods
  # our nutrients list has 190 nutrients
  # our foods list has 184023 foods
  # we want all nutrients for all foods

# USDA specs for nutrient request
  # Up to 20 nutrient_ids may be specified. Likewise, you may request up to 10 food group id's in the fg parameter.

# loop through list

# then join nutrient name to nutrient id


source("./nutrient_list.R")

# change max to 1500
# pipe into db rather than df

get_all_things <- function () {
  df <- NULL
  offset <- 0
  while (offset < 10) {
    for (nut in seq_along(nutrients$id)) {
      # print(offset)
      print(nut)
      raw_req <- fromJSON(paste0("http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", 
                                 key, "&offset=", offset, "&subset=0&max=10&nutrients=", nutrients$id[nut]),
                          flatten = TRUE)
      this_food_list <- as_tibble(raw_req$report$foods)
      df <- rbind(df, this_food_list)
      # dbWriteTable(con, "everything", 
      #              value = this_food_list, append = TRUE, row.names = FALSE)
      offset <- offset + nrow(this_food_list)
    }
    # nut <- nut+1
  }
  df
}

baz <- get_all_things()

baz


for (nut in seq_along(nutrients$id)) {
  print(nutrients$id)
}


# grab the foods report
# baz <- as_tibble(dat$report$foods)

# make all gm elements in the nutrients list-column characters so that we can unnest
# this list-column
for (i in 1:length(baz$nutrients)) {
  for (j in 1:1) {
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




baz %>% group_by(
  nutrient_id
) %>% arrange(
  nutrient_id
)

unique(baz$nutrient_id)

for (nut in seq_along(nutrients$id)) {
  print(nutrients$id[nut])
}
