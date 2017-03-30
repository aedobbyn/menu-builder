# pull in data from the usda db
# help site: https://ndb.nal.usda.gov/ndb/doc/index#

library(httr)
library(tidyverse)
library(jsonlite)
library(tidyjson)

key = "2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm"

# get all foods
# max per request is 1500, default is 50 so specify 1500 
# use offset to specify beginning row
# set subset to 1 so get most common foods. else a 1:1500 query only brings you from a to beef
dat <- fromJSON(paste0("http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", 
                       key, "&subset=1&max=1500&nutrients=205&nutrients=204&nutrients=208&nutrients=269"),
                flatten = TRUE) # same if false


# grab the foods report
all_foods <- as_tibble(dat$report$foods)

# make all gm elements in the nutrients list-column characters so that we can unnest
# this list-column
for (i in 1:length(all_foods$nutrients)) {
  for (j in 1:4) {
    all_foods$nutrients[[i]]$gm[j] <- as.character(all_foods$nutrients[[i]]$gm[j])
  }
}

# unnest it
all_foods <- all_foods %>% unnest()

# code NAs
all_foods <- all_foods %>% 
  mutate(
    gm = ifelse(gm == "--", NA, gm),
    value = ifelse(gm == "--", NA, value)
  )



# --------------------- set datatypes --------------------
# numeric: ndbno, nutrient_id, value, gm
all_foods$ndbno <- as.numeric(all_foods$ndbno)
all_foods$nutrient_id <- as.numeric(all_foods$nutrient_id)
all_foods$value <- as.numeric(all_foods$value)
all_foods$gm <- as.numeric(all_foods$gm)

# factors: name, nutrient, unit
all_foods$name <- factor(all_foods$name)
all_foods$nutrient <- factor(all_foods$nutrient)
all_foods$unit <- factor(all_foods$unit)



# value: 100 g equivalent value of the nutrient
# get per gram 



ggplot(data = na.omit(all_foods), aes(x = ndbno, y = value, colour = nutrient)) +
  geom_point() +
  theme_light()


# take a sample of just 100 of the most common 1000 foods
some_foods <- sample_n(all_foods, 100)

# trim the names to 20 characters
some_foods$name <- strtrim(some_foods$name, 20)

# ---- fivethirtyeight rip off graph -----
# plot energy per 100g for a sample of
ggplot(data = na.omit(some_foods[some_foods[["nutrient"]] == "Energy", ]), aes(x = ndbno, y = value)) +
  geom_point() +
  geom_text_repel(aes(label = name), 
                  box.padding = unit(1, "lines"),
                  family = "Helvetica",
                  size = 3.5,
                  label.size = 0.5) +
  theme_bw() +
  theme(panel.background=element_rect(fill="#F0F0F0")) +
  theme(plot.background=element_rect(fill="#F0F0F0")) +
  theme(panel.border=element_rect(colour="#F0F0F0")) +
  theme(panel.grid.major=element_line(colour="#D0D0D0",size=.75)) +
  theme(axis.ticks=element_blank()) +
  ggtitle("Energy of Common Foods") +
  theme(plot.title=element_text(face="bold",colour="#3C3C3C",size=20)) +
  ylab("Kcal/100g") +
  xlab("NDB number") +
  theme(axis.text.x=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.text.y=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.title.y=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.title.x=element_text(size=11,colour="#535353",face="bold"))

# same thing except bar graph
ggplot(data = na.omit(some_foods[some_foods[["nutrient"]] == "Energy", ]), aes(x = name, y = value)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  theme(panel.background=element_rect(fill="#F0F0F0")) +
  theme(plot.background=element_rect(fill="#F0F0F0")) +
  theme(panel.border=element_rect(colour="#F0F0F0")) +
  theme(panel.grid.major=element_line(colour="#D0D0D0",size=.75)) +
  theme(axis.ticks=element_blank()) +
  ggtitle("Energy of Common Foods") +
  theme(plot.title=element_text(face="bold",colour="#3C3C3C",size=20)) +
  ylab("Kcal/100g") +
  xlab("NDB number") +
  theme(axis.text.x=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.text.y=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.title.y=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.title.x=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1, family = "Helvetica"))



# plot energy vs. sugar
ggplot(data = some_foods[some_foods[["nutrient"]] == "Energy", ], aes(x = some_foods[some_foods[["nutrient"]] == "Energy", ]$value, 
                                       y = some_foods[some_foods[["nutrient"]] == "Sugars, total", ]$value,
                                       colour = factor(ndbno))) +
  geom_point() +
  geom_text_repel(aes(label = name), 
                  box.padding = unit(0.45, "lines"),
                  family = "Courier",
                  label.size = 0.5) +
  theme_bw()




# ---------

# order by most sugar

fried <- all_foods %>% 
  filter(
    nutrient == "Sugars, total"
  ) %>% 
  arrange(
    desc(gm)
  )


by_nutrient <- all_foods %>% 
  group_by(
    nutrient
  ) %>% 
  arrange(
    desc(value)
  )


