
library(httr)
library(tidyverse)

# help site: https://ndb.nal.usda.gov/ndb/doc/index#

# key
key = "2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm"

# example
example = "https://api.data.gov/nrel/alt-fuel-stations/v1/nearest.json?api_key=2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm&location=Denver+CO"


foo <- GET(url = "https://api.data.gov/nrel/alt-fuel-stations/v1/nearest.json?api_key=2fj5UPgl5SjzhpJ43fsGD9Olxi6UgjNXrtoVJ2Wm&location=Denver+CO")

head(foo)

content(foo)

b <- fromJSON(bar)


bar <- GET(url = "https://api.nal.usda.gov/ndb/reports/V2?ndbno=01009&ndbno=01009&ndbno=45202763&ndbno=35193&type=b&format=json&api_key=DEMO_KEY")


# woot
baz <- fromJSON("https://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=DEMO_KEY&nutrients=205&nutrients=204&nutrients=208&nutrients=269&fg=0100&fg=0500")
head(baz)

meat_and_eggs <- as_tibble(baz$report$foods)

names(meat_and_eggs)

