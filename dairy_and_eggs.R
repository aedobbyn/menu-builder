# get all the dairy and egg data



# Dairy and Egg Products (fg = 0100) and Poultry Products (fg =0500)
raw <- fromJSON(paste0("https://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", 
                       key, "&nutrients=205&nutrients=204&nutrients=208&nutrients=269&fg=0100&fg=0500"),
                flatten = TRUE) # same if false


# grab the foods report
cooked <- as_tibble(raw$report$foods)

for (i in 1:length(cooked$nutrients)) {
  for (j in 1:4) {
    cooked$nutrients[[i]]$gm[j] <- as.character(cooked$nutrients[[i]]$gm[j])
  }
}

cooked <- cooked %>% unnest()

# code NAs
cooked <- cooked %>% 
  mutate(
    gm = ifelse(gm == "--", NA, gm),
    value = ifelse(gm == "--", NA, value)
  )






