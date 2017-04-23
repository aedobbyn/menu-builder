# scratchpad


# the nesting problem -----------

raw <- fromJSON(paste0("https://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", 
                       key, "&nutrients=205&nutrients=204&nutrients=208&nutrients=269&fg=0100&fg=0500"),
                flatten = TRUE) # same if false
# grab the foods report
cooked <- as_tibble(raw$report$foods)
lunch <- cooked
# the unnesting for loop that worked
for (i in 1:length(lunch$nutrients)) {
  for (j in 1:4) {
    lunch$nutrients[[i]]$gm[j] <- as.character(lunch$nutrients[[i]]$gm[j])
  }
}

# functionize it
dinner <- lunch[1:12,]

characterize <- function(list_column, col)
  for (i in 1:length(list_column)) {
    for (j in 1:length(col)) {
      list_column[[i]][[col]][j] <- as.character(list_column[[i]][[col]][j])
      print(list_column[[i]][[col]][j])
    }
    list_column
  }

dinner$nutrients <- characterize(dinner$nutrients, "gm")


# cooked2 <- tbl_json(cooked)

# dairy_and_eggs$nutrients[[1]]$gm <- as.character(dairy_and_eggs$nutrients[[1]]$gm)

# cooked$nutrients <- as.character(cooked$nutrients)

cooked$nutrients[[1]]$gm <- as.character(cooked$nutrients[[1]]$gm)
cooked$nutrients[[2]]$gm <- as.character(cooked$nutrients[[2]]$gm)
cooked$nutrients[[3]]$gm <- as.character(cooked$nutrients[[3]]$gm)
breakfast <- cooked[1:3, ]
free_range <- breakfast %>% unnest()



l <- lunch %>% map_if(is.numeric, as.character) %>% as_data_frame



lunch <- cooked
lunch[] <- lapply(cooked[["nutrients"]], `[[`, as.character)




post_free_range <- lunch %>% unnest()




for (i in 1:length(lunch$nutrients)) {
  lunch$nutrients[[i]]["gm"] <- as.character(lunch$nutrients[[i]]["gm"])
}

home_on_range <- lunch %>% unnest()



cduR=NULL
for (i in 1:length(lunch$nutrients)){
  grams=lunch$nutrients[[i]]
  cduR=c(cduR,as.character(grams["4"]))
}




class(lunch$nutrients[[11]]$gm)


lapply(lunch$nutrients, `[[`, as.character("4"))

















# general scratch notes


example = "https://api.data.gov/nrel/alt-fuel-stations/v1/nearest.json?api_key=2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm&location=Denver+CO"



foo <- GET(url = "https://api.data.gov/nrel/alt-fuel-stations/v1/nearest.json?api_key=2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm&location=Denver+CO")

head(foo)
content(foo)


# 
all_foods <- GET(url = "http://api.nal.usda.gov/ndb/reports/?nutrients=204&nutrients=208&nutrients=205&nutrients=269&max=50&offset=25&format=xml&api_key=DEMO_KEY")
head(all_foods$content)

str(all_foods$content)



b <- fromJSON(bar)


bar <- GET(url = "https://api.nal.usda.gov/ndb/reports/V2?ndbno=01009&ndbno=01009&ndbno=45202763&ndbno=35193&type=b&format=json&api_key=DEMO_KEY")


# Dairy and Egg Products (fg = 0100) and Poultry Products (fg =0500)
# woot
baz <- fromJSON(paste0("https://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", key, "&nutrients=205&nutrients=204&nutrients=208&nutrients=269&fg=0100&fg=0500"))
# , 
# flatten = TRUE,
# simplifyDataFrame = TRUE))

dairy_and_eggs <- as_tibble(baz$report$foods)

names(dairy_and_eggs)


dim(dairy_and_eggs)


# each ingredient has a df of nutrient values
head(dairy_and_eggs$nutrients)


# df of nutrient IDs for first nutrient
dairy_and_eggs$nutrients[1][[1]][1]

# vector of units for first nutrient
dairy_and_eggs$nutrients[[3]]$gm <- as.character(dairy_and_eggs$nutrients[[3]]$gm)


dairy_and_eggs$nutrients$gm


dairy_and_eggs %>% unnest()






# each food has multiple nutrients
# want to unnest everything in nutrients or keep them nested?
dairy_and_eggs$nutrients[[1]] %>% unnest()



dairy_and_eggs$nutrients[[1:2]] %>% unnest(nutrients)



df <- data_frame(
  x = 1:3,
  y = c("a", "d,e,f", "g,h")
)




library(tidyjson)

dairy_and_eggs <- tbl_json(dairy_and_eggs)


dairy_and_eggs$nutrients[] <- dairy_and_eggs$nutrients[][4]



unnested <- dairy_and_eggs %>% unnest()

dairy_and_eggs %>%
  gather_array(column.name = "nutrients") %>%                                     # stack the users 
  spread_values(person = jstring("nutrients"))


baz <- tbl_json(baz)

library(data.tree)
b <- as.Node(baz)

de <- as.Node(dairy_and_eggs)

d <- ToDataFrameTable(de)





# ---- tidyjson


'{"name": {"first": "bob", "last": "jones"}, "age": 32}' %>%
  spread_values(
    first.name = jstring("name", "first"), 
    age = jnumber("age")
  )


test <- GET(url = paste0("http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", 
                           key, "&subset=1&max=1500&nutrients=205&nutrients=204&nutrients=208&nutrients=269"))

t <- test$content







test <- toJSON(dat)
test <- as.character(test) %>% as.tbl_json

test %>% 
  enter_object("report", "foods", "nutrients") %>% gather_array %>% 
  spread_values(
    nut_value = jstring("unit")
  )

test %>% spread_values(
  nut_unit = jstring("nutrients", "unit")
)













# heatmap


library(shiny)
library(heatmaply)
library(shinyHeatmaply)
runApp(system.file("shinyapp", package = "shinyHeatmaply"))


data(abbrev)
launch_heatmaply(abbrev)

