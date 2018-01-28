# Food for Thought

***






```r
dirs <- c("prep", "build", "score", "scrape", "solve", "simulate")
paths <- stringr::str_c("./scripts/", dirs)

# Import all .R scripts from all the dirs above 
for (p in paths) {
  suppressMessages(suppressPackageStartupMessages(dobtools::import_scripts(p)))
}
```

```
## [1] "File not found :("
## [1] "File not found :("
## [1] "File not found :("
## [1] "File not found :("
## [1] "File not found :("
## [1] "File not found :("
## [1] "File not found :("
## [1] "File not found :("
```





### About

This is an ongoing project on food. A few data science techniques come into play in various proportions here: along the way I query an API, generate menus, solve them algorithmically, simulate solving them, scrape the web for real menus, and touch on some natural language processing techniques.

The meat of it surrounds building menus and changing them until they are in compliance with daily nutritional guidelines. We'll simulate the curve of the proportion of these that are solvable as we increase the minimum portion size that each item must meet, and start about trying to improve the quality of the menus by taking a cue from actual recipes scraped from Allrecipes.com.


### Getting from A to Beef

The data we'll be using here is conveniently located in an Excel file called ABBREV.xlsx on the USDA website. As the name suggests, this is an abbreviated version of all the foods in their database. 

If you do want the full list, they provide a Microsoft Access SQL dump as well (which requires that you have Access). The USDA also does have an open API so you can create an API key and grab foods from them with requests along the lines of a quick example I'll go through. The [API documentation](https://ndb.nal.usda.gov/ndb/doc/apilist/API-FOOD-REPORTV2.md) walks through the format for requesting data in more detail. 

The base URL you'll want is `http://api.nal.usda.gov/ndb/`.

The default number of results per request is 50 so we specify 1500 as our `max`. In this example I set `subset` to 1 in order to grab the most common foods. (Otherwise 1:1500 query only gets you from a to beef 😆.) If you do want to grab all foods, you can send requests of 1500 iteratively specifying `offset`, which refers to the number of the first row you want, and then glue them together.

We've specified just 4 nutrient values we want here: calories, sugar, lipids, and carbohydrates.




```r
food_raw <- jsonlite::fromJSON(paste0("http://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=", 
                       key, "&subset=1&max=1500&nutrients=205&nutrients=204&nutrients=208&nutrients=269"))

foods <- as_tibble(food_raw$report$foods)
```

In the browser, you could paste that same thing in to see:

![](img/json_resp_long.jpg)


```r
head(foods) %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> ndbno </th>
   <th style="text-align:left;"> name </th>
   <th style="text-align:right;"> weight </th>
   <th style="text-align:left;"> measure </th>
   <th style="text-align:left;"> nutrients </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 14007 </td>
   <td style="text-align:left;"> Alcoholic beverage, beer, light, BUD LIGHT </td>
   <td style="text-align:right;"> 29.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208, 269, 204, 205, Energy, Sugars, total, Total lipid (fat), Carbohydrate, by difference, kcal, g, g, g, 9, --, 0.00, 0.38, 29, --, 0, 1.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14009 </td>
   <td style="text-align:left;"> Alcoholic beverage, daiquiri, canned </td>
   <td style="text-align:right;"> 30.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208, 269, 204, 205, Energy, Sugars, total, Total lipid (fat), Carbohydrate, by difference, kcal, g, g, g, 38, --, 0.00, 4.79, 125, --, 0, 15.7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14534 </td>
   <td style="text-align:left;"> Alcoholic beverage, liqueur, coffee, 63 proof </td>
   <td style="text-align:right;"> 34.8 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208, 269, 204, 205, Energy, Sugars, total, Total lipid (fat), Carbohydrate, by difference, kcal, g, g, g, 107, --, 0.10, 11.21, 308, --, 0.3, 32.2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14015 </td>
   <td style="text-align:left;"> Alcoholic beverage, pina colada, canned </td>
   <td style="text-align:right;"> 32.6 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208, 269, 204, 205, Energy, Sugars, total, Total lipid (fat), Carbohydrate, by difference, kcal, g, g, g, 77, --, 2.48, 9.00, 237, --, 7.6, 27.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14019 </td>
   <td style="text-align:left;"> Alcoholic beverage, tequila sunrise, canned </td>
   <td style="text-align:right;"> 31.1 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208, 269, 204, 205, Energy, Sugars, total, Total lipid (fat), Carbohydrate, by difference, kcal, g, g, g, 34, --, 0.03, 3.51, 110, --, 0.1, 11.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14027 </td>
   <td style="text-align:left;"> Alcoholic beverage, whiskey sour, canned </td>
   <td style="text-align:right;"> 30.8 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208, 269, 204, 205, Energy, Sugars, total, Total lipid (fat), Carbohydrate, by difference, kcal, g, g, g, 37, --, 0.00, 4.13, 119, --, 0, 13.4 </td>
  </tr>
</tbody>
</table>

We've got one row per food and a nested list-col of nutrients [^1].


```r
str(foods$nutrients[1:3])
```

```
## List of 3
##  $ :'data.frame':	4 obs. of  5 variables:
##   ..$ nutrient_id: chr [1:4] "208" "269" "204" "205"
##   ..$ nutrient   : chr [1:4] "Energy" "Sugars, total" "Total lipid (fat)" "Carbohydrate, by difference"
##   ..$ unit       : chr [1:4] "kcal" "g" "g" "g"
##   ..$ value      : chr [1:4] "9" "--" "0.00" "0.38"
##   ..$ gm         : chr [1:4] "29" "--" "0" "1.3"
##  $ :'data.frame':	4 obs. of  5 variables:
##   ..$ nutrient_id: chr [1:4] "208" "269" "204" "205"
##   ..$ nutrient   : chr [1:4] "Energy" "Sugars, total" "Total lipid (fat)" "Carbohydrate, by difference"
##   ..$ unit       : chr [1:4] "kcal" "g" "g" "g"
##   ..$ value      : chr [1:4] "38" "--" "0.00" "4.79"
##   ..$ gm         : chr [1:4] "125" "--" "0" "15.7"
##  $ :'data.frame':	4 obs. of  5 variables:
##   ..$ nutrient_id: chr [1:4] "208" "269" "204" "205"
##   ..$ nutrient   : chr [1:4] "Energy" "Sugars, total" "Total lipid (fat)" "Carbohydrate, by difference"
##   ..$ unit       : chr [1:4] "kcal" "g" "g" "g"
##   ..$ value      : chr [1:4] "107" "--" "0.10" "11.21"
##   ..$ gm         : chr [1:4] "308" "--" "0.3" "32.2"
```


Now we can take these `--`s and change them into `NA`s.


```r
foods <- foods %>% 
  mutate(
    gm = ifelse(gm == "--", NA, gm),
    value = ifelse(value == "--", NA, value)
  )

foods$value <- as.numeric(foods$value)
foods$gm <- as.numeric(foods$gm)
```


```r
foods[1:20, ] %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> ndbno </th>
   <th style="text-align:left;"> name </th>
   <th style="text-align:right;"> weight </th>
   <th style="text-align:left;"> measure </th>
   <th style="text-align:left;"> nutrient_id </th>
   <th style="text-align:left;"> nutrient </th>
   <th style="text-align:left;"> unit </th>
   <th style="text-align:right;"> value </th>
   <th style="text-align:right;"> gm </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 14007 </td>
   <td style="text-align:left;"> Alcoholic beverage, beer, light, BUD LIGHT </td>
   <td style="text-align:right;"> 29.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208 </td>
   <td style="text-align:left;"> Energy </td>
   <td style="text-align:left;"> kcal </td>
   <td style="text-align:right;"> 9.00 </td>
   <td style="text-align:right;"> 29.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14007 </td>
   <td style="text-align:left;"> Alcoholic beverage, beer, light, BUD LIGHT </td>
   <td style="text-align:right;"> 29.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 269 </td>
   <td style="text-align:left;"> Sugars, total </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14007 </td>
   <td style="text-align:left;"> Alcoholic beverage, beer, light, BUD LIGHT </td>
   <td style="text-align:right;"> 29.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 204 </td>
   <td style="text-align:left;"> Total lipid (fat) </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14007 </td>
   <td style="text-align:left;"> Alcoholic beverage, beer, light, BUD LIGHT </td>
   <td style="text-align:right;"> 29.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 205 </td>
   <td style="text-align:left;"> Carbohydrate, by difference </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 0.38 </td>
   <td style="text-align:right;"> 1.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14009 </td>
   <td style="text-align:left;"> Alcoholic beverage, daiquiri, canned </td>
   <td style="text-align:right;"> 30.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208 </td>
   <td style="text-align:left;"> Energy </td>
   <td style="text-align:left;"> kcal </td>
   <td style="text-align:right;"> 38.00 </td>
   <td style="text-align:right;"> 125.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14009 </td>
   <td style="text-align:left;"> Alcoholic beverage, daiquiri, canned </td>
   <td style="text-align:right;"> 30.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 269 </td>
   <td style="text-align:left;"> Sugars, total </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14009 </td>
   <td style="text-align:left;"> Alcoholic beverage, daiquiri, canned </td>
   <td style="text-align:right;"> 30.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 204 </td>
   <td style="text-align:left;"> Total lipid (fat) </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14009 </td>
   <td style="text-align:left;"> Alcoholic beverage, daiquiri, canned </td>
   <td style="text-align:right;"> 30.5 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 205 </td>
   <td style="text-align:left;"> Carbohydrate, by difference </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 4.79 </td>
   <td style="text-align:right;"> 15.7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14534 </td>
   <td style="text-align:left;"> Alcoholic beverage, liqueur, coffee, 63 proof </td>
   <td style="text-align:right;"> 34.8 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208 </td>
   <td style="text-align:left;"> Energy </td>
   <td style="text-align:left;"> kcal </td>
   <td style="text-align:right;"> 107.00 </td>
   <td style="text-align:right;"> 308.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14534 </td>
   <td style="text-align:left;"> Alcoholic beverage, liqueur, coffee, 63 proof </td>
   <td style="text-align:right;"> 34.8 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 269 </td>
   <td style="text-align:left;"> Sugars, total </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14534 </td>
   <td style="text-align:left;"> Alcoholic beverage, liqueur, coffee, 63 proof </td>
   <td style="text-align:right;"> 34.8 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 204 </td>
   <td style="text-align:left;"> Total lipid (fat) </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 0.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14534 </td>
   <td style="text-align:left;"> Alcoholic beverage, liqueur, coffee, 63 proof </td>
   <td style="text-align:right;"> 34.8 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 205 </td>
   <td style="text-align:left;"> Carbohydrate, by difference </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 11.21 </td>
   <td style="text-align:right;"> 32.2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14015 </td>
   <td style="text-align:left;"> Alcoholic beverage, pina colada, canned </td>
   <td style="text-align:right;"> 32.6 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208 </td>
   <td style="text-align:left;"> Energy </td>
   <td style="text-align:left;"> kcal </td>
   <td style="text-align:right;"> 77.00 </td>
   <td style="text-align:right;"> 237.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14015 </td>
   <td style="text-align:left;"> Alcoholic beverage, pina colada, canned </td>
   <td style="text-align:right;"> 32.6 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 269 </td>
   <td style="text-align:left;"> Sugars, total </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14015 </td>
   <td style="text-align:left;"> Alcoholic beverage, pina colada, canned </td>
   <td style="text-align:right;"> 32.6 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 204 </td>
   <td style="text-align:left;"> Total lipid (fat) </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 2.48 </td>
   <td style="text-align:right;"> 7.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14015 </td>
   <td style="text-align:left;"> Alcoholic beverage, pina colada, canned </td>
   <td style="text-align:right;"> 32.6 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 205 </td>
   <td style="text-align:left;"> Carbohydrate, by difference </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 9.00 </td>
   <td style="text-align:right;"> 27.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14019 </td>
   <td style="text-align:left;"> Alcoholic beverage, tequila sunrise, canned </td>
   <td style="text-align:right;"> 31.1 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 208 </td>
   <td style="text-align:left;"> Energy </td>
   <td style="text-align:left;"> kcal </td>
   <td style="text-align:right;"> 34.00 </td>
   <td style="text-align:right;"> 110.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14019 </td>
   <td style="text-align:left;"> Alcoholic beverage, tequila sunrise, canned </td>
   <td style="text-align:right;"> 31.1 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 269 </td>
   <td style="text-align:left;"> Sugars, total </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14019 </td>
   <td style="text-align:left;"> Alcoholic beverage, tequila sunrise, canned </td>
   <td style="text-align:right;"> 31.1 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 204 </td>
   <td style="text-align:left;"> Total lipid (fat) </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 14019 </td>
   <td style="text-align:left;"> Alcoholic beverage, tequila sunrise, canned </td>
   <td style="text-align:right;"> 31.1 </td>
   <td style="text-align:left;"> 1.0 fl oz </td>
   <td style="text-align:left;"> 205 </td>
   <td style="text-align:left;"> Carbohydrate, by difference </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:right;"> 3.51 </td>
   <td style="text-align:right;"> 11.3 </td>
  </tr>
</tbody>
</table>


Great, we've successfully unnested. As I mentioned before, we'll use our nice ABBREV.xlsx rather than using data pulled from the API. So:


```r
abbrev_raw <- readxl::read_excel("./data/raw/ABBREV.xlsx") %>% as_tibble()

abbrev_raw[1:20, ] %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> NDB_No </th>
   <th style="text-align:left;"> Shrt_Desc </th>
   <th style="text-align:right;"> Water_(g) </th>
   <th style="text-align:right;"> Energ_Kcal </th>
   <th style="text-align:right;"> Protein_(g) </th>
   <th style="text-align:right;"> Lipid_Tot_(g) </th>
   <th style="text-align:right;"> Ash_(g) </th>
   <th style="text-align:right;"> Carbohydrt_(g) </th>
   <th style="text-align:right;"> Fiber_TD_(g) </th>
   <th style="text-align:right;"> Sugar_Tot_(g) </th>
   <th style="text-align:right;"> Calcium_(mg) </th>
   <th style="text-align:right;"> Iron_(mg) </th>
   <th style="text-align:right;"> Magnesium_(mg) </th>
   <th style="text-align:right;"> Phosphorus_(mg) </th>
   <th style="text-align:right;"> Potassium_(mg) </th>
   <th style="text-align:right;"> Sodium_(mg) </th>
   <th style="text-align:right;"> Zinc_(mg) </th>
   <th style="text-align:right;"> Copper_mg) </th>
   <th style="text-align:right;"> Manganese_(mg) </th>
   <th style="text-align:right;"> Selenium_(µg) </th>
   <th style="text-align:right;"> Vit_C_(mg) </th>
   <th style="text-align:right;"> Thiamin_(mg) </th>
   <th style="text-align:right;"> Riboflavin_(mg) </th>
   <th style="text-align:right;"> Niacin_(mg) </th>
   <th style="text-align:right;"> Panto_Acid_mg) </th>
   <th style="text-align:right;"> Vit_B6_(mg) </th>
   <th style="text-align:right;"> Folate_Tot_(µg) </th>
   <th style="text-align:right;"> Folic_Acid_(µg) </th>
   <th style="text-align:right;"> Food_Folate_(µg) </th>
   <th style="text-align:right;"> Folate_DFE_(µg) </th>
   <th style="text-align:right;"> Choline_Tot_ (mg) </th>
   <th style="text-align:right;"> Vit_B12_(µg) </th>
   <th style="text-align:right;"> Vit_A_IU </th>
   <th style="text-align:right;"> Vit_A_RAE </th>
   <th style="text-align:right;"> Retinol_(µg) </th>
   <th style="text-align:right;"> Alpha_Carot_(µg) </th>
   <th style="text-align:right;"> Beta_Carot_(µg) </th>
   <th style="text-align:right;"> Beta_Crypt_(µg) </th>
   <th style="text-align:right;"> Lycopene_(µg) </th>
   <th style="text-align:right;"> Lut+Zea_ (µg) </th>
   <th style="text-align:right;"> Vit_E_(mg) </th>
   <th style="text-align:right;"> Vit_D_µg </th>
   <th style="text-align:right;"> Vit_D_IU </th>
   <th style="text-align:right;"> Vit_K_(µg) </th>
   <th style="text-align:right;"> FA_Sat_(g) </th>
   <th style="text-align:right;"> FA_Mono_(g) </th>
   <th style="text-align:right;"> FA_Poly_(g) </th>
   <th style="text-align:right;"> Cholestrl_(mg) </th>
   <th style="text-align:right;"> GmWt_1 </th>
   <th style="text-align:left;"> GmWt_Desc1 </th>
   <th style="text-align:right;"> GmWt_2 </th>
   <th style="text-align:left;"> GmWt_Desc2 </th>
   <th style="text-align:right;"> Refuse_Pct </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 01001 </td>
   <td style="text-align:left;"> BUTTER,WITH SALT </td>
   <td style="text-align:right;"> 15.87 </td>
   <td style="text-align:right;"> 717 </td>
   <td style="text-align:right;"> 0.85 </td>
   <td style="text-align:right;"> 81.11 </td>
   <td style="text-align:right;"> 2.11 </td>
   <td style="text-align:right;"> 0.06 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.06 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 643 </td>
   <td style="text-align:right;"> 0.09 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.034 </td>
   <td style="text-align:right;"> 0.042 </td>
   <td style="text-align:right;"> 0.110 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 18.8 </td>
   <td style="text-align:right;"> 0.17 </td>
   <td style="text-align:right;"> 2499 </td>
   <td style="text-align:right;"> 684 </td>
   <td style="text-align:right;"> 671 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 158 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 2.32 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 7.0 </td>
   <td style="text-align:right;"> 51.368 </td>
   <td style="text-align:right;"> 21.021 </td>
   <td style="text-align:right;"> 3.043 </td>
   <td style="text-align:right;"> 215 </td>
   <td style="text-align:right;"> 5.00 </td>
   <td style="text-align:left;"> 1 pat,  (1&quot; sq, 1/3&quot; high) </td>
   <td style="text-align:right;"> 14.20 </td>
   <td style="text-align:left;"> 1 tbsp </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01002 </td>
   <td style="text-align:left;"> BUTTER,WHIPPED,W/ SALT </td>
   <td style="text-align:right;"> 16.72 </td>
   <td style="text-align:right;"> 718 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 78.30 </td>
   <td style="text-align:right;"> 1.62 </td>
   <td style="text-align:right;"> 2.87 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.06 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:right;"> 583 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 0.010 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.064 </td>
   <td style="text-align:right;"> 0.022 </td>
   <td style="text-align:right;"> 0.097 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 18.8 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 2468 </td>
   <td style="text-align:right;"> 683 </td>
   <td style="text-align:right;"> 671 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 135 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 1.37 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 4.6 </td>
   <td style="text-align:right;"> 45.390 </td>
   <td style="text-align:right;"> 19.874 </td>
   <td style="text-align:right;"> 3.331 </td>
   <td style="text-align:right;"> 225 </td>
   <td style="text-align:right;"> 3.80 </td>
   <td style="text-align:left;"> 1 pat,  (1&quot; sq, 1/3&quot; high) </td>
   <td style="text-align:right;"> 9.40 </td>
   <td style="text-align:left;"> 1 tbsp </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01003 </td>
   <td style="text-align:left;"> BUTTER OIL,ANHYDROUS </td>
   <td style="text-align:right;"> 0.24 </td>
   <td style="text-align:right;"> 876 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 99.48 </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 0.010 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 22.3 </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 3069 </td>
   <td style="text-align:right;"> 840 </td>
   <td style="text-align:right;"> 824 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 2.80 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 8.6 </td>
   <td style="text-align:right;"> 61.924 </td>
   <td style="text-align:right;"> 28.732 </td>
   <td style="text-align:right;"> 3.694 </td>
   <td style="text-align:right;"> 256 </td>
   <td style="text-align:right;"> 12.80 </td>
   <td style="text-align:left;"> 1 tbsp </td>
   <td style="text-align:right;"> 205.00 </td>
   <td style="text-align:left;"> 1 cup </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01004 </td>
   <td style="text-align:left;"> CHEESE,BLUE </td>
   <td style="text-align:right;"> 42.41 </td>
   <td style="text-align:right;"> 353 </td>
   <td style="text-align:right;"> 21.40 </td>
   <td style="text-align:right;"> 28.74 </td>
   <td style="text-align:right;"> 5.11 </td>
   <td style="text-align:right;"> 2.34 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 528 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 387 </td>
   <td style="text-align:right;"> 256 </td>
   <td style="text-align:right;"> 1146 </td>
   <td style="text-align:right;"> 2.66 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.029 </td>
   <td style="text-align:right;"> 0.382 </td>
   <td style="text-align:right;"> 1.016 </td>
   <td style="text-align:right;"> 1.729 </td>
   <td style="text-align:right;"> 0.166 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 15.4 </td>
   <td style="text-align:right;"> 1.22 </td>
   <td style="text-align:right;"> 721 </td>
   <td style="text-align:right;"> 198 </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.25 </td>
   <td style="text-align:right;"> 0.5 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 2.4 </td>
   <td style="text-align:right;"> 18.669 </td>
   <td style="text-align:right;"> 7.778 </td>
   <td style="text-align:right;"> 0.800 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:left;"> 1 oz </td>
   <td style="text-align:right;"> 17.00 </td>
   <td style="text-align:left;"> 1 cubic inch </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01005 </td>
   <td style="text-align:left;"> CHEESE,BRICK </td>
   <td style="text-align:right;"> 41.11 </td>
   <td style="text-align:right;"> 371 </td>
   <td style="text-align:right;"> 23.24 </td>
   <td style="text-align:right;"> 29.68 </td>
   <td style="text-align:right;"> 3.18 </td>
   <td style="text-align:right;"> 2.79 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 674 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 451 </td>
   <td style="text-align:right;"> 136 </td>
   <td style="text-align:right;"> 560 </td>
   <td style="text-align:right;"> 2.60 </td>
   <td style="text-align:right;"> 0.024 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.014 </td>
   <td style="text-align:right;"> 0.351 </td>
   <td style="text-align:right;"> 0.118 </td>
   <td style="text-align:right;"> 0.288 </td>
   <td style="text-align:right;"> 0.065 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 15.4 </td>
   <td style="text-align:right;"> 1.26 </td>
   <td style="text-align:right;"> 1080 </td>
   <td style="text-align:right;"> 292 </td>
   <td style="text-align:right;"> 286 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.26 </td>
   <td style="text-align:right;"> 0.5 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 2.5 </td>
   <td style="text-align:right;"> 18.764 </td>
   <td style="text-align:right;"> 8.598 </td>
   <td style="text-align:right;"> 0.784 </td>
   <td style="text-align:right;"> 94 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:left;"> 1 cup, diced </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:left;"> 1 cup, shredded </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01006 </td>
   <td style="text-align:left;"> CHEESE,BRIE </td>
   <td style="text-align:right;"> 48.42 </td>
   <td style="text-align:right;"> 334 </td>
   <td style="text-align:right;"> 20.75 </td>
   <td style="text-align:right;"> 27.68 </td>
   <td style="text-align:right;"> 2.70 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 184 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 188 </td>
   <td style="text-align:right;"> 152 </td>
   <td style="text-align:right;"> 629 </td>
   <td style="text-align:right;"> 2.38 </td>
   <td style="text-align:right;"> 0.019 </td>
   <td style="text-align:right;"> 0.034 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.070 </td>
   <td style="text-align:right;"> 0.520 </td>
   <td style="text-align:right;"> 0.380 </td>
   <td style="text-align:right;"> 0.690 </td>
   <td style="text-align:right;"> 0.235 </td>
   <td style="text-align:right;"> 65 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 65 </td>
   <td style="text-align:right;"> 65 </td>
   <td style="text-align:right;"> 15.4 </td>
   <td style="text-align:right;"> 1.65 </td>
   <td style="text-align:right;"> 592 </td>
   <td style="text-align:right;"> 174 </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.24 </td>
   <td style="text-align:right;"> 0.5 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 2.3 </td>
   <td style="text-align:right;"> 17.410 </td>
   <td style="text-align:right;"> 8.013 </td>
   <td style="text-align:right;"> 0.826 </td>
   <td style="text-align:right;"> 100 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:left;"> 1 oz </td>
   <td style="text-align:right;"> 144.00 </td>
   <td style="text-align:left;"> 1 cup, sliced </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01007 </td>
   <td style="text-align:left;"> CHEESE,CAMEMBERT </td>
   <td style="text-align:right;"> 51.80 </td>
   <td style="text-align:right;"> 300 </td>
   <td style="text-align:right;"> 19.80 </td>
   <td style="text-align:right;"> 24.26 </td>
   <td style="text-align:right;"> 3.68 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 388 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 347 </td>
   <td style="text-align:right;"> 187 </td>
   <td style="text-align:right;"> 842 </td>
   <td style="text-align:right;"> 2.38 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 0.038 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.028 </td>
   <td style="text-align:right;"> 0.488 </td>
   <td style="text-align:right;"> 0.630 </td>
   <td style="text-align:right;"> 1.364 </td>
   <td style="text-align:right;"> 0.227 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:right;"> 15.4 </td>
   <td style="text-align:right;"> 1.30 </td>
   <td style="text-align:right;"> 820 </td>
   <td style="text-align:right;"> 241 </td>
   <td style="text-align:right;"> 240 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.21 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:right;"> 15.259 </td>
   <td style="text-align:right;"> 7.023 </td>
   <td style="text-align:right;"> 0.724 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:left;"> 1 oz </td>
   <td style="text-align:right;"> 246.00 </td>
   <td style="text-align:left;"> 1 cup </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01008 </td>
   <td style="text-align:left;"> CHEESE,CARAWAY </td>
   <td style="text-align:right;"> 39.28 </td>
   <td style="text-align:right;"> 376 </td>
   <td style="text-align:right;"> 25.18 </td>
   <td style="text-align:right;"> 29.20 </td>
   <td style="text-align:right;"> 3.28 </td>
   <td style="text-align:right;"> 3.06 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 673 </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 490 </td>
   <td style="text-align:right;"> 93 </td>
   <td style="text-align:right;"> 690 </td>
   <td style="text-align:right;"> 2.94 </td>
   <td style="text-align:right;"> 0.024 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.031 </td>
   <td style="text-align:right;"> 0.450 </td>
   <td style="text-align:right;"> 0.180 </td>
   <td style="text-align:right;"> 0.190 </td>
   <td style="text-align:right;"> 0.074 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.27 </td>
   <td style="text-align:right;"> 1054 </td>
   <td style="text-align:right;"> 271 </td>
   <td style="text-align:right;"> 262 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 18.584 </td>
   <td style="text-align:right;"> 8.275 </td>
   <td style="text-align:right;"> 0.830 </td>
   <td style="text-align:right;"> 93 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:left;"> 1 oz </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01009 </td>
   <td style="text-align:left;"> CHEESE,CHEDDAR </td>
   <td style="text-align:right;"> 37.02 </td>
   <td style="text-align:right;"> 404 </td>
   <td style="text-align:right;"> 22.87 </td>
   <td style="text-align:right;"> 33.31 </td>
   <td style="text-align:right;"> 3.71 </td>
   <td style="text-align:right;"> 3.09 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.48 </td>
   <td style="text-align:right;"> 710 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 455 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:right;"> 653 </td>
   <td style="text-align:right;"> 3.64 </td>
   <td style="text-align:right;"> 0.030 </td>
   <td style="text-align:right;"> 0.027 </td>
   <td style="text-align:right;"> 28.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.029 </td>
   <td style="text-align:right;"> 0.428 </td>
   <td style="text-align:right;"> 0.059 </td>
   <td style="text-align:right;"> 0.410 </td>
   <td style="text-align:right;"> 0.066 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 16.5 </td>
   <td style="text-align:right;"> 1.10 </td>
   <td style="text-align:right;"> 1242 </td>
   <td style="text-align:right;"> 330 </td>
   <td style="text-align:right;"> 330 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 85 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 2.4 </td>
   <td style="text-align:right;"> 18.867 </td>
   <td style="text-align:right;"> 9.246 </td>
   <td style="text-align:right;"> 1.421 </td>
   <td style="text-align:right;"> 99 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:left;"> 1 cup, diced </td>
   <td style="text-align:right;"> 244.00 </td>
   <td style="text-align:left;"> 1 cup, melted </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01010 </td>
   <td style="text-align:left;"> CHEESE,CHESHIRE </td>
   <td style="text-align:right;"> 37.65 </td>
   <td style="text-align:right;"> 387 </td>
   <td style="text-align:right;"> 23.37 </td>
   <td style="text-align:right;"> 30.60 </td>
   <td style="text-align:right;"> 3.60 </td>
   <td style="text-align:right;"> 4.78 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 643 </td>
   <td style="text-align:right;"> 0.21 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 464 </td>
   <td style="text-align:right;"> 95 </td>
   <td style="text-align:right;"> 700 </td>
   <td style="text-align:right;"> 2.79 </td>
   <td style="text-align:right;"> 0.042 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.046 </td>
   <td style="text-align:right;"> 0.293 </td>
   <td style="text-align:right;"> 0.080 </td>
   <td style="text-align:right;"> 0.413 </td>
   <td style="text-align:right;"> 0.074 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 985 </td>
   <td style="text-align:right;"> 233 </td>
   <td style="text-align:right;"> 220 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 19.475 </td>
   <td style="text-align:right;"> 8.671 </td>
   <td style="text-align:right;"> 0.870 </td>
   <td style="text-align:right;"> 103 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:left;"> 1 oz </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01011 </td>
   <td style="text-align:left;"> CHEESE,COLBY </td>
   <td style="text-align:right;"> 38.20 </td>
   <td style="text-align:right;"> 394 </td>
   <td style="text-align:right;"> 23.76 </td>
   <td style="text-align:right;"> 32.11 </td>
   <td style="text-align:right;"> 3.36 </td>
   <td style="text-align:right;"> 2.57 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.52 </td>
   <td style="text-align:right;"> 685 </td>
   <td style="text-align:right;"> 0.76 </td>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:right;"> 457 </td>
   <td style="text-align:right;"> 127 </td>
   <td style="text-align:right;"> 604 </td>
   <td style="text-align:right;"> 3.07 </td>
   <td style="text-align:right;"> 0.042 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 0.375 </td>
   <td style="text-align:right;"> 0.093 </td>
   <td style="text-align:right;"> 0.210 </td>
   <td style="text-align:right;"> 0.079 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 15.4 </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 994 </td>
   <td style="text-align:right;"> 264 </td>
   <td style="text-align:right;"> 257 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 82 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 2.7 </td>
   <td style="text-align:right;"> 20.218 </td>
   <td style="text-align:right;"> 9.280 </td>
   <td style="text-align:right;"> 0.953 </td>
   <td style="text-align:right;"> 95 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:left;"> 1 cup, diced </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:left;"> 1 cup, shredded </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01012 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,CRMD,LRG OR SML CURD </td>
   <td style="text-align:right;"> 79.79 </td>
   <td style="text-align:right;"> 98 </td>
   <td style="text-align:right;"> 11.12 </td>
   <td style="text-align:right;"> 4.30 </td>
   <td style="text-align:right;"> 1.41 </td>
   <td style="text-align:right;"> 3.38 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 2.67 </td>
   <td style="text-align:right;"> 83 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 159 </td>
   <td style="text-align:right;"> 104 </td>
   <td style="text-align:right;"> 364 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 0.029 </td>
   <td style="text-align:right;"> 0.002 </td>
   <td style="text-align:right;"> 9.7 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.027 </td>
   <td style="text-align:right;"> 0.163 </td>
   <td style="text-align:right;"> 0.099 </td>
   <td style="text-align:right;"> 0.557 </td>
   <td style="text-align:right;"> 0.046 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 18.4 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 140 </td>
   <td style="text-align:right;"> 37 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 0.1 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 1.718 </td>
   <td style="text-align:right;"> 0.778 </td>
   <td style="text-align:right;"> 0.123 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:left;"> 4 oz </td>
   <td style="text-align:right;"> 210.00 </td>
   <td style="text-align:left;"> 1 cup, large curd (not packed) </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01013 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,CRMD,W/FRUIT </td>
   <td style="text-align:right;"> 79.64 </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 10.69 </td>
   <td style="text-align:right;"> 3.85 </td>
   <td style="text-align:right;"> 1.20 </td>
   <td style="text-align:right;"> 4.61 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:right;"> 2.38 </td>
   <td style="text-align:right;"> 53 </td>
   <td style="text-align:right;"> 0.16 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 113 </td>
   <td style="text-align:right;"> 90 </td>
   <td style="text-align:right;"> 344 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 7.7 </td>
   <td style="text-align:right;"> 1.4 </td>
   <td style="text-align:right;"> 0.033 </td>
   <td style="text-align:right;"> 0.142 </td>
   <td style="text-align:right;"> 0.150 </td>
   <td style="text-align:right;"> 0.181 </td>
   <td style="text-align:right;"> 0.068 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 17.5 </td>
   <td style="text-align:right;"> 0.53 </td>
   <td style="text-align:right;"> 146 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 37 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 2.311 </td>
   <td style="text-align:right;"> 1.036 </td>
   <td style="text-align:right;"> 0.124 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:left;"> 4 oz </td>
   <td style="text-align:right;"> 226.00 </td>
   <td style="text-align:left;"> 1 cup,  (not packed) </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01014 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,NONFAT,UNCRMD,DRY,LRG OR SML CURD </td>
   <td style="text-align:right;"> 81.01 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 10.34 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 1.71 </td>
   <td style="text-align:right;"> 6.66 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 1.85 </td>
   <td style="text-align:right;"> 86 </td>
   <td style="text-align:right;"> 0.15 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 190 </td>
   <td style="text-align:right;"> 137 </td>
   <td style="text-align:right;"> 372 </td>
   <td style="text-align:right;"> 0.47 </td>
   <td style="text-align:right;"> 0.030 </td>
   <td style="text-align:right;"> 0.022 </td>
   <td style="text-align:right;"> 9.4 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.226 </td>
   <td style="text-align:right;"> 0.144 </td>
   <td style="text-align:right;"> 0.446 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 17.9 </td>
   <td style="text-align:right;"> 0.46 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.169 </td>
   <td style="text-align:right;"> 0.079 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 145.00 </td>
   <td style="text-align:left;"> 1 cup,  (not packed) </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:left;"> 4 oz </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01015 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,LOWFAT,2% MILKFAT </td>
   <td style="text-align:right;"> 81.24 </td>
   <td style="text-align:right;"> 81 </td>
   <td style="text-align:right;"> 10.45 </td>
   <td style="text-align:right;"> 2.27 </td>
   <td style="text-align:right;"> 1.27 </td>
   <td style="text-align:right;"> 4.76 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 4.00 </td>
   <td style="text-align:right;"> 111 </td>
   <td style="text-align:right;"> 0.13 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 150 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 308 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 0.033 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 11.9 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.020 </td>
   <td style="text-align:right;"> 0.251 </td>
   <td style="text-align:right;"> 0.103 </td>
   <td style="text-align:right;"> 0.524 </td>
   <td style="text-align:right;"> 0.057 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 16.3 </td>
   <td style="text-align:right;"> 0.47 </td>
   <td style="text-align:right;"> 225 </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 1.235 </td>
   <td style="text-align:right;"> 0.516 </td>
   <td style="text-align:right;"> 0.083 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:left;"> 4 oz </td>
   <td style="text-align:right;"> 226.00 </td>
   <td style="text-align:left;"> 1 cup,  (not packed) </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01016 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,LOWFAT,1% MILKFAT </td>
   <td style="text-align:right;"> 82.48 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 12.39 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 1.39 </td>
   <td style="text-align:right;"> 2.72 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 2.72 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 134 </td>
   <td style="text-align:right;"> 86 </td>
   <td style="text-align:right;"> 406 </td>
   <td style="text-align:right;"> 0.38 </td>
   <td style="text-align:right;"> 0.028 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 9.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 0.165 </td>
   <td style="text-align:right;"> 0.128 </td>
   <td style="text-align:right;"> 0.215 </td>
   <td style="text-align:right;"> 0.068 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 17.5 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.1 </td>
   <td style="text-align:right;"> 0.645 </td>
   <td style="text-align:right;"> 0.291 </td>
   <td style="text-align:right;"> 0.031 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:left;"> 4 oz </td>
   <td style="text-align:right;"> 226.00 </td>
   <td style="text-align:left;"> 1 cup,  (not packed) </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01017 </td>
   <td style="text-align:left;"> CHEESE,CREAM </td>
   <td style="text-align:right;"> 52.62 </td>
   <td style="text-align:right;"> 350 </td>
   <td style="text-align:right;"> 6.15 </td>
   <td style="text-align:right;"> 34.44 </td>
   <td style="text-align:right;"> 1.27 </td>
   <td style="text-align:right;"> 5.52 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 3.76 </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 0.11 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 107 </td>
   <td style="text-align:right;"> 132 </td>
   <td style="text-align:right;"> 314 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 0.018 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 8.6 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.230 </td>
   <td style="text-align:right;"> 0.091 </td>
   <td style="text-align:right;"> 0.517 </td>
   <td style="text-align:right;"> 0.056 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 27.2 </td>
   <td style="text-align:right;"> 0.22 </td>
   <td style="text-align:right;"> 1111 </td>
   <td style="text-align:right;"> 308 </td>
   <td style="text-align:right;"> 303 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 59 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 0.86 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 2.1 </td>
   <td style="text-align:right;"> 20.213 </td>
   <td style="text-align:right;"> 8.907 </td>
   <td style="text-align:right;"> 1.483 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 14.50 </td>
   <td style="text-align:left;"> 1 tbsp </td>
   <td style="text-align:right;"> 232.00 </td>
   <td style="text-align:left;"> 1 cup </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01018 </td>
   <td style="text-align:left;"> CHEESE,EDAM </td>
   <td style="text-align:right;"> 41.56 </td>
   <td style="text-align:right;"> 357 </td>
   <td style="text-align:right;"> 24.99 </td>
   <td style="text-align:right;"> 27.80 </td>
   <td style="text-align:right;"> 4.22 </td>
   <td style="text-align:right;"> 1.43 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 1.43 </td>
   <td style="text-align:right;"> 731 </td>
   <td style="text-align:right;"> 0.44 </td>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:right;"> 536 </td>
   <td style="text-align:right;"> 188 </td>
   <td style="text-align:right;"> 812 </td>
   <td style="text-align:right;"> 3.75 </td>
   <td style="text-align:right;"> 0.036 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.037 </td>
   <td style="text-align:right;"> 0.389 </td>
   <td style="text-align:right;"> 0.082 </td>
   <td style="text-align:right;"> 0.281 </td>
   <td style="text-align:right;"> 0.076 </td>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:right;"> 15.4 </td>
   <td style="text-align:right;"> 1.54 </td>
   <td style="text-align:right;"> 825 </td>
   <td style="text-align:right;"> 243 </td>
   <td style="text-align:right;"> 242 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.24 </td>
   <td style="text-align:right;"> 0.5 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 2.3 </td>
   <td style="text-align:right;"> 17.572 </td>
   <td style="text-align:right;"> 8.125 </td>
   <td style="text-align:right;"> 0.665 </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:left;"> 1 oz </td>
   <td style="text-align:right;"> 198.00 </td>
   <td style="text-align:left;"> 1 package,  (7 oz) </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01019 </td>
   <td style="text-align:left;"> CHEESE,FETA </td>
   <td style="text-align:right;"> 55.22 </td>
   <td style="text-align:right;"> 264 </td>
   <td style="text-align:right;"> 14.21 </td>
   <td style="text-align:right;"> 21.28 </td>
   <td style="text-align:right;"> 5.20 </td>
   <td style="text-align:right;"> 4.09 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 4.09 </td>
   <td style="text-align:right;"> 493 </td>
   <td style="text-align:right;"> 0.65 </td>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:right;"> 337 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:right;"> 917 </td>
   <td style="text-align:right;"> 2.88 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 0.028 </td>
   <td style="text-align:right;"> 15.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.154 </td>
   <td style="text-align:right;"> 0.844 </td>
   <td style="text-align:right;"> 0.991 </td>
   <td style="text-align:right;"> 0.967 </td>
   <td style="text-align:right;"> 0.424 </td>
   <td style="text-align:right;"> 32 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 32 </td>
   <td style="text-align:right;"> 32 </td>
   <td style="text-align:right;"> 15.4 </td>
   <td style="text-align:right;"> 1.69 </td>
   <td style="text-align:right;"> 422 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:right;"> 1.8 </td>
   <td style="text-align:right;"> 14.946 </td>
   <td style="text-align:right;"> 4.623 </td>
   <td style="text-align:right;"> 0.591 </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 150.00 </td>
   <td style="text-align:left;"> 1 cup, crumbled </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:left;"> 1 oz </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01020 </td>
   <td style="text-align:left;"> CHEESE,FONTINA </td>
   <td style="text-align:right;"> 37.92 </td>
   <td style="text-align:right;"> 389 </td>
   <td style="text-align:right;"> 25.60 </td>
   <td style="text-align:right;"> 31.14 </td>
   <td style="text-align:right;"> 3.79 </td>
   <td style="text-align:right;"> 1.55 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 1.55 </td>
   <td style="text-align:right;"> 550 </td>
   <td style="text-align:right;"> 0.23 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:right;"> 346 </td>
   <td style="text-align:right;"> 64 </td>
   <td style="text-align:right;"> 800 </td>
   <td style="text-align:right;"> 3.50 </td>
   <td style="text-align:right;"> 0.025 </td>
   <td style="text-align:right;"> 0.014 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 0.204 </td>
   <td style="text-align:right;"> 0.150 </td>
   <td style="text-align:right;"> 0.429 </td>
   <td style="text-align:right;"> 0.083 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 15.4 </td>
   <td style="text-align:right;"> 1.68 </td>
   <td style="text-align:right;"> 913 </td>
   <td style="text-align:right;"> 261 </td>
   <td style="text-align:right;"> 258 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 32 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.27 </td>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 2.6 </td>
   <td style="text-align:right;"> 19.196 </td>
   <td style="text-align:right;"> 8.687 </td>
   <td style="text-align:right;"> 1.654 </td>
   <td style="text-align:right;"> 116 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:left;"> 1 cup, diced </td>
   <td style="text-align:right;"> 108.00 </td>
   <td style="text-align:left;"> 1 cup, shredded </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>


```r
dim(abbrev_raw)
```

```
## [1] 8790   53
```



You can read in depth the prep I did on this file in `/scripts/prep`. Mainly this involved a bit of cleaning like stripping out parentheses from column names, e.g., `Vit_C_(mg)` becomes `Vit_C_mg`. In there you'll also find a dataframe called `all_nut_and_mr_df` where I define the nutritional constraints on menus. If a nutrient is among the "must restricts," that is, Lipid_Tot_g, Sodium_mg, Cholestrl_mg, FA_Sat_g then that value is a daily upper bound. Otherwise, it's a lower bound. 

So for example, you're supposed to have at least 18mg of Iron and no more than 2400mg of Sodium per day. (As someone who puts salt on everything indiscriminately I'd be shocked if I've ever been under that threshold.)


```r
all_nut_and_mr_df %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> nutrient </th>
   <th style="text-align:right;"> value </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Lipid_Tot_g </td>
   <td style="text-align:right;"> 65 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sodium_mg </td>
   <td style="text-align:right;"> 2400 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cholestrl_mg </td>
   <td style="text-align:right;"> 300 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FA_Sat_g </td>
   <td style="text-align:right;"> 20 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Protein_g </td>
   <td style="text-align:right;"> 56 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Calcium_mg </td>
   <td style="text-align:right;"> 1000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iron_mg </td>
   <td style="text-align:right;"> 18 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Magnesium_mg </td>
   <td style="text-align:right;"> 400 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Phosphorus_mg </td>
   <td style="text-align:right;"> 1000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Potassium_mg </td>
   <td style="text-align:right;"> 3500 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Zinc_mg </td>
   <td style="text-align:right;"> 15 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Copper_mg </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Manganese_mg </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Selenium_µg </td>
   <td style="text-align:right;"> 70 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Vit_C_mg </td>
   <td style="text-align:right;"> 60 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Thiamin_mg </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Riboflavin_mg </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Niacin_mg </td>
   <td style="text-align:right;"> 20 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Panto_Acid_mg </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Vit_B6_mg </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
</tbody>
</table>

In `/scripts/prep` we also create a z-scored version of `abbrev` with:


```r
scaled <- abbrev %>% 
  drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) %>% 
  mutate_at(
    vars(nutrient_names, "Energ_Kcal"), dobtools::z_score   # <-- equivalent to scale(), but simpler
  )

scaled[1:20, ] %>% kable()
```



shorter_desc    solution_amounts   GmWt_1   serving_gmwt   cost   Lipid_Tot_g    Sodium_mg   Cholestrl_mg     FA_Sat_g    Protein_g   Calcium_mg      Iron_mg   Magnesium_mg   Phosphorus_mg   Potassium_mg      Zinc_mg    Copper_mg   Manganese_mg   Selenium_µg     Vit_C_mg   Thiamin_mg   Riboflavin_mg    Niacin_mg   Panto_Acid_mg    Vit_B6_mg   Energ_Kcal  Shrt_Desc                                          NDB_No        score   scaled_score
-------------  -----------------  -------  -------------  -----  ------------  -----------  -------------  -----------  -----------  -----------  -----------  -------------  --------------  -------------  -----------  -----------  -------------  ------------  -----------  -----------  --------------  -----------  --------------  -----------  -----------  -------------------------------------------------  -------  ----------  -------------
BUTTER                         1     5.00           5.00   7.80     5.0713727    0.3020499      1.1239165    7.6802714   -1.1342898   -0.2071890   -0.5151346     -0.6086378      -0.6680318     -0.6719806   -0.5944711   -0.3061583     -0.0822562    -0.4821958   -0.1318713   -0.3814302      -0.4448635   -0.7689737      -0.3962200   -0.6405274    3.3042137  BUTTER,WITH SALT                                   01001     -3419.716     -0.4532518
BUTTER                         1     3.80           3.80   6.50     4.8707676    0.2487875      1.1929970    6.7219460   -1.1671035   -0.2119396   -0.5081402     -0.6277555      -0.6680318     -0.6299679   -0.6053622   -0.2910091     -0.0821312    -0.5130922   -0.1318713   -0.3772865      -0.3796632   -0.7732304      -0.4056312   -0.6287325    3.3107643  BUTTER,WHIPPED,W/ SALT                             01002     -3405.992     -0.4270146
BUTTER OIL                     1    12.80          12.80   8.20     6.3828013   -0.2669700      1.4071466    9.3724902   -1.1862449   -0.3022006   -0.5197976     -0.6468732      -0.7618769     -0.7189361   -0.6162534   -0.3046434     -0.0822562    -0.5130922   -0.1318713   -0.3897175      -0.5078905   -0.7772742      -0.4686138   -0.6452454    4.3457655  BUTTER OIL,ANHYDROUS                               01003     -3426.108     -0.4654711
CHEESE                         1    28.35          28.35   4.28     1.3326945    0.7485664      0.1567890    2.4383369    0.7388273    2.1871032   -0.4475222     -0.2071661       0.9541465     -0.0986301    0.1052854   -0.2455614     -0.0811313    -0.0650934   -0.1318713   -0.3317063       0.3114603   -0.5616729       0.7758346   -0.2560127    0.9197807  CHEESE,BLUE                                        01004     -3383.120     -0.3832890
CHEESE                         1   132.00         132.00   5.42     1.3998008    0.2283703      0.2880420    2.4535663    0.9065419    2.8806878   -0.4195446     -0.1880484       1.2401504     -0.3951907    0.0889486   -0.2698001     -0.0807564    -0.0650934   -0.1318713   -0.3627837       0.2440866   -0.7527983      -0.2673592   -0.4942703    1.0376922  CHEESE,BRICK                                       01005     -2550.059      1.2092995
CHEESE                         1    28.35          28.35   5.17     1.2570214    0.2896220      0.3294903    2.2365083    0.6795803    0.5529037   -0.4032243     -0.2645192       0.0648531     -0.3556493    0.0290473   -0.2773748     -0.0780068    -0.0650934   -0.1318713   -0.2467613       0.6113818   -0.6970356       0.0236636   -0.0932426    0.7953185  CHEESE,BRIE                                        01006     -3427.868     -0.4688367
CHEESE                         1    28.35          28.35   7.37     1.0128687    0.4787035      0.1360648    1.8916842    0.5929885    1.5220220   -0.4428592     -0.2645192       0.7753941     -0.2691525    0.0290473   -0.2743449     -0.0775069    -0.0650934   -0.1318713   -0.3337781       0.5418348   -0.6438270       0.5115974   -0.1121145    0.5725968  CHEESE,CAMEMBERT                                   01007     -3365.981     -0.3505239
CHEESE                         1    28.35          28.35   5.26     1.3655338    0.3437721      0.2811339    2.4247107    1.0833714    2.8759373   -0.3705838     -0.2262838       1.4144340     -0.5014583    0.1815234   -0.2698001     -0.0796316    -0.0650934   -0.1318713   -0.3275626       0.4592477   -0.7396025      -0.3383050   -0.4730394    1.0704454  CHEESE,CARAWAY                                     01008     -3234.675     -0.0995030
CHEESE                         1   132.00         132.00   7.99     1.6589454    0.3109270      0.3225823    2.4700781    0.8728167    3.0517087   -0.4871571     -0.1306952       1.2580257     -0.5434710    0.3721185   -0.2607106     -0.0788817     0.3674573   -0.1318713   -0.3317063       0.4114341   -0.7653555      -0.1790388   -0.4919113    1.2538633  CHEESE,CHEDDAR                                     01009     -2687.571      0.9464129
CHEESE                         1    28.35          28.35   2.99     1.4654793    0.3526492      0.3502145    2.5675458    0.9183913    2.7334199   -0.4708368     -0.2454015       1.2982450     -0.4965156    0.1406816   -0.2425315     -0.0807564    -0.0650934   -0.1318713   -0.2964852       0.1180326   -0.7608860      -0.1768670   -0.4730394    1.1425025  CHEESE,CHESHIRE                                    01010     -3257.267     -0.1426935
CHEESE                         1   132.00         132.00   1.14     1.5732778    0.2674294      0.2949501    2.6866551    0.9539395    2.9329442   -0.3426062     -0.1498129       1.2669633     -0.4174328    0.2169196   -0.2425315     -0.0807564    -0.0650934   -0.1318713   -0.3607119       0.2962469   -0.7581191      -0.3238263   -0.4612445    1.1883569  CHEESE,COLBY                                       01011     -2599.704      1.1143912
CHEESE                         1   113.00         113.00   1.67    -0.4120696    0.0543798     -0.2438781   -0.2790560   -0.1981870    0.0730952   -0.5034773     -0.4939316      -0.0647424     -0.4742736   -0.5100647   -0.2622255     -0.0820062    -0.2133964   -0.1318713   -0.3358499      -0.1645021   -0.7568421      -0.0726200   -0.5390910   -0.7506325  CHEESE,COTTAGE,CRMD,LRG OR SML CURD                01012     -3386.210     -0.3891963
CHEESE                         1   113.00         113.00   1.87    -0.4441949    0.0366256     -0.2715103   -0.1839929   -0.2373812   -0.0694222   -0.4824941     -0.5130493      -0.2703077     -0.5088723   -0.5291242   -0.2455614     -0.0818812    -0.2751894   -0.1061157   -0.3234190      -0.2101423   -0.7459876      -0.3448205   -0.4871933   -0.7571832  CHEESE,COTTAGE,CRMD,W/FRUIT                        01013     -3463.568     -0.5370853
CHEESE                         1   145.00         145.00   8.64    -0.6983422    0.0614814     -0.3129586   -0.5273742   -0.2692834    0.0873469   -0.4848256     -0.4365785       0.0737908     -0.3927194   -0.4910051   -0.2607106     -0.0795066    -0.2226654   -0.1318713   -0.3441373      -0.0275814   -0.7472646      -0.1529771   -0.6098606   -0.9209492  CHEESE,COTTAGE,NONFAT,UNCRMD,DRY,LRG OR SML CURD   01014     -3278.578     -0.1834343
CHEESE                         1   113.00         113.00   8.15    -0.5569906    0.0046682     -0.2784184   -0.3564851   -0.2592570    0.2061114   -0.4894885     -0.4748139      -0.1049617     -0.4223755   -0.4801140   -0.2561658     -0.0803815    -0.1454242   -0.1318713   -0.3503528       0.0267522   -0.7559908      -0.0965100   -0.5131421   -0.8619934  CHEESE,COTTAGE,LOWFAT,2% MILKFAT                   01015     -3266.099     -0.1595762
CHEESE                         1   113.00         113.00   1.33    -0.6462277    0.0916634     -0.3336828   -0.4510672   -0.0824275   -0.0314176   -0.4871571     -0.5512847      -0.1764626     -0.5187577   -0.5155102   -0.2637404     -0.0818812    -0.2350240   -0.1318713   -0.3482809      -0.1601554   -0.7506699      -0.3202066   -0.4871933   -0.9209492  CHEESE,COTTAGE,LOWFAT,1% MILKFAT                   01016     -3490.534     -0.5886355
CHEESE                         1    14.50          14.50   3.15     1.7396158    0.0099944      0.3363984    2.6858536   -0.6511988    0.1396033   -0.4941514     -0.4748139      -0.2971205     -0.4050761   -0.4828368   -0.2788897     -0.0808814    -0.2473826   -0.1318713   -0.3441373      -0.0188880   -0.7585448      -0.1015775   -0.5155011    0.9001288  CHEESE,CREAM                                       01017     -3389.710     -0.3958887
CHEESE                         1    28.35          28.35   3.94     1.2655882    0.4520723      0.2535017    2.2624783    1.0660531    3.1514709   -0.4172131     -0.0733421       1.6199993     -0.2666811    0.4020692   -0.2516211     -0.0808814    -0.0650934   -0.1318713   -0.3151317       0.3266737   -0.7604603      -0.2724267   -0.4683214    0.9459833  CHEESE,EDAM                                        01018     -3208.657     -0.0497637
CHEESE                         1   150.00         150.00   4.61     0.8001274    0.5452815      0.2535017    1.8415076    0.0834642    2.0208329   -0.3682524     -0.2836369       0.7307060     -0.5780698    0.1651867   -0.2576807     -0.0787567    -0.0496451   -0.1318713   -0.0727276       1.3155454   -0.5669938       0.2241943    0.3526058    0.3367737  CHEESE,FETA                                        01019     -3516.569     -0.6384083
CHEESE                         1   132.00         132.00   1.73     1.5040298    0.4414199      0.4400192    2.5228196    1.1216541    2.2916159   -0.4661739     -0.3792254       0.7709253     -0.5731271    0.3339995   -0.2682852     -0.0805064    -0.0650934   -0.1318713   -0.3482809      -0.0753950   -0.7459876      -0.1652840   -0.4518085    1.1556037  CHEESE,FONTINA                                     01020     -3304.806     -0.2335737

Then we do a few mutates to `abbrev` using the function below. This is a function we can use on any menu dataframe, not just `abbrev`, which is why it's called `do_menu_mutates()`. Turns out that the short descriptions of foods in the `Shrt_Desc` column actually aren't so short so we'll create a `shorter_desc` column by taking only the values in `Shrt_Desc` up to the first comma. That turns "BUTTER,WHIPPED,W/ SALT" into just "BUTTER".

Since we'll need a cost associated with each row in order to optimize something, for now each item gets a random cost between \$1 and \$10.

What we'll do when we eventually "solve" these menus is change the amount we have of each item, i.e. its `GmWt_1`. We'll vary that by multiplying it by some `solution_amount`. In order to keep a record of what the gram weight of a single serving of a food is, we'll save that in `serving_gmwt`. Since we know that all foods in `abbrev` are exactly one serving, for now `GmWt_1` and `serving_gmwt` are the same thing, and `solution_amounts` is 1.

Finally, we rearrange columns a bit.


```r
cols_to_keep <- c(nutrient_names, "Shrt_Desc", "GmWt_1", "NDB_No")

do_menu_mutates <- function(menu, to_keep = cols_to_keep) {

  quo_to_keep <- quo(to_keep)
  
  menu <- menu %>% 
    mutate(
      shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Take only the fist word
      cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2) # Add a cost column
    ) 
  
  if (!("serving_gmwt" %in% names(menu))) {
    menu <- menu %>% mutate(
      serving_gmwt = GmWt_1   # Single serving gram weight
    )
  }
  
  if (!("solution_amounts" %in% names(menu))) {
    menu <- menu %>% mutate(
      solution_amounts = 1   # Single serving gram weight
    )
  }
  
  menu <- menu %>%
    select(shorter_desc, solution_amounts, GmWt_1, serving_gmwt, cost, !!quo_to_keep,  Shrt_Desc, NDB_No)
  
  return(menu)
}
```

We'll do these mutates and score each item (see `/scripts/score/rank_foods.R` for `add_ranked_foods()`; also more on scoring in the Scoring section below).



```r
abbrev <- abbrev %>% do_menu_mutates() %>% add_ranked_foods() 
```

```
## score column doesn't exist; creating it
```

```
## scaled_score doesn't exist; creating it
```

```r
abbrev[1:20, ] %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> shorter_desc </th>
   <th style="text-align:right;"> solution_amounts </th>
   <th style="text-align:right;"> GmWt_1 </th>
   <th style="text-align:right;"> serving_gmwt </th>
   <th style="text-align:right;"> cost </th>
   <th style="text-align:right;"> Lipid_Tot_g </th>
   <th style="text-align:right;"> Sodium_mg </th>
   <th style="text-align:right;"> Cholestrl_mg </th>
   <th style="text-align:right;"> FA_Sat_g </th>
   <th style="text-align:right;"> Protein_g </th>
   <th style="text-align:right;"> Calcium_mg </th>
   <th style="text-align:right;"> Iron_mg </th>
   <th style="text-align:right;"> Magnesium_mg </th>
   <th style="text-align:right;"> Phosphorus_mg </th>
   <th style="text-align:right;"> Potassium_mg </th>
   <th style="text-align:right;"> Zinc_mg </th>
   <th style="text-align:right;"> Copper_mg </th>
   <th style="text-align:right;"> Manganese_mg </th>
   <th style="text-align:right;"> Selenium_µg </th>
   <th style="text-align:right;"> Vit_C_mg </th>
   <th style="text-align:right;"> Thiamin_mg </th>
   <th style="text-align:right;"> Riboflavin_mg </th>
   <th style="text-align:right;"> Niacin_mg </th>
   <th style="text-align:right;"> Panto_Acid_mg </th>
   <th style="text-align:right;"> Vit_B6_mg </th>
   <th style="text-align:right;"> Energ_Kcal </th>
   <th style="text-align:left;"> Shrt_Desc </th>
   <th style="text-align:left;"> NDB_No </th>
   <th style="text-align:right;"> score </th>
   <th style="text-align:right;"> scaled_score </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> BUTTER </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 5.00 </td>
   <td style="text-align:right;"> 5.00 </td>
   <td style="text-align:right;"> 6.26 </td>
   <td style="text-align:right;"> 81.11 </td>
   <td style="text-align:right;"> 643 </td>
   <td style="text-align:right;"> 215 </td>
   <td style="text-align:right;"> 51.368 </td>
   <td style="text-align:right;"> 0.85 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 0.09 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.034 </td>
   <td style="text-align:right;"> 0.042 </td>
   <td style="text-align:right;"> 0.110 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 717 </td>
   <td style="text-align:left;"> BUTTER,WITH SALT </td>
   <td style="text-align:left;"> 01001 </td>
   <td style="text-align:right;"> -3419.716 </td>
   <td style="text-align:right;"> -0.4532518 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BUTTER </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 3.80 </td>
   <td style="text-align:right;"> 3.80 </td>
   <td style="text-align:right;"> 3.88 </td>
   <td style="text-align:right;"> 78.30 </td>
   <td style="text-align:right;"> 583 </td>
   <td style="text-align:right;"> 225 </td>
   <td style="text-align:right;"> 45.390 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 0.010 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.064 </td>
   <td style="text-align:right;"> 0.022 </td>
   <td style="text-align:right;"> 0.097 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 718 </td>
   <td style="text-align:left;"> BUTTER,WHIPPED,W/ SALT </td>
   <td style="text-align:left;"> 01002 </td>
   <td style="text-align:right;"> -3405.992 </td>
   <td style="text-align:right;"> -0.4270146 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BUTTER OIL </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 12.80 </td>
   <td style="text-align:right;"> 12.80 </td>
   <td style="text-align:right;"> 8.05 </td>
   <td style="text-align:right;"> 99.48 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 256 </td>
   <td style="text-align:right;"> 61.924 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 0.010 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 876 </td>
   <td style="text-align:left;"> BUTTER OIL,ANHYDROUS </td>
   <td style="text-align:left;"> 01003 </td>
   <td style="text-align:right;"> -3426.108 </td>
   <td style="text-align:right;"> -0.4654711 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 6.20 </td>
   <td style="text-align:right;"> 28.74 </td>
   <td style="text-align:right;"> 1146 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 18.669 </td>
   <td style="text-align:right;"> 21.40 </td>
   <td style="text-align:right;"> 528 </td>
   <td style="text-align:right;"> 0.31 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 387 </td>
   <td style="text-align:right;"> 256 </td>
   <td style="text-align:right;"> 2.66 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.029 </td>
   <td style="text-align:right;"> 0.382 </td>
   <td style="text-align:right;"> 1.016 </td>
   <td style="text-align:right;"> 1.729 </td>
   <td style="text-align:right;"> 0.166 </td>
   <td style="text-align:right;"> 353 </td>
   <td style="text-align:left;"> CHEESE,BLUE </td>
   <td style="text-align:left;"> 01004 </td>
   <td style="text-align:right;"> -3383.120 </td>
   <td style="text-align:right;"> -0.3832890 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:right;"> 7.83 </td>
   <td style="text-align:right;"> 29.68 </td>
   <td style="text-align:right;"> 560 </td>
   <td style="text-align:right;"> 94 </td>
   <td style="text-align:right;"> 18.764 </td>
   <td style="text-align:right;"> 23.24 </td>
   <td style="text-align:right;"> 674 </td>
   <td style="text-align:right;"> 0.43 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 451 </td>
   <td style="text-align:right;"> 136 </td>
   <td style="text-align:right;"> 2.60 </td>
   <td style="text-align:right;"> 0.024 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.014 </td>
   <td style="text-align:right;"> 0.351 </td>
   <td style="text-align:right;"> 0.118 </td>
   <td style="text-align:right;"> 0.288 </td>
   <td style="text-align:right;"> 0.065 </td>
   <td style="text-align:right;"> 371 </td>
   <td style="text-align:left;"> CHEESE,BRICK </td>
   <td style="text-align:left;"> 01005 </td>
   <td style="text-align:right;"> -2550.059 </td>
   <td style="text-align:right;"> 1.2092995 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 1.06 </td>
   <td style="text-align:right;"> 27.68 </td>
   <td style="text-align:right;"> 629 </td>
   <td style="text-align:right;"> 100 </td>
   <td style="text-align:right;"> 17.410 </td>
   <td style="text-align:right;"> 20.75 </td>
   <td style="text-align:right;"> 184 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 188 </td>
   <td style="text-align:right;"> 152 </td>
   <td style="text-align:right;"> 2.38 </td>
   <td style="text-align:right;"> 0.019 </td>
   <td style="text-align:right;"> 0.034 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.070 </td>
   <td style="text-align:right;"> 0.520 </td>
   <td style="text-align:right;"> 0.380 </td>
   <td style="text-align:right;"> 0.690 </td>
   <td style="text-align:right;"> 0.235 </td>
   <td style="text-align:right;"> 334 </td>
   <td style="text-align:left;"> CHEESE,BRIE </td>
   <td style="text-align:left;"> 01006 </td>
   <td style="text-align:right;"> -3427.868 </td>
   <td style="text-align:right;"> -0.4688367 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 1.33 </td>
   <td style="text-align:right;"> 24.26 </td>
   <td style="text-align:right;"> 842 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:right;"> 15.259 </td>
   <td style="text-align:right;"> 19.80 </td>
   <td style="text-align:right;"> 388 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 347 </td>
   <td style="text-align:right;"> 187 </td>
   <td style="text-align:right;"> 2.38 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 0.038 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.028 </td>
   <td style="text-align:right;"> 0.488 </td>
   <td style="text-align:right;"> 0.630 </td>
   <td style="text-align:right;"> 1.364 </td>
   <td style="text-align:right;"> 0.227 </td>
   <td style="text-align:right;"> 300 </td>
   <td style="text-align:left;"> CHEESE,CAMEMBERT </td>
   <td style="text-align:left;"> 01007 </td>
   <td style="text-align:right;"> -3365.981 </td>
   <td style="text-align:right;"> -0.3505239 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 8.82 </td>
   <td style="text-align:right;"> 29.20 </td>
   <td style="text-align:right;"> 690 </td>
   <td style="text-align:right;"> 93 </td>
   <td style="text-align:right;"> 18.584 </td>
   <td style="text-align:right;"> 25.18 </td>
   <td style="text-align:right;"> 673 </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 490 </td>
   <td style="text-align:right;"> 93 </td>
   <td style="text-align:right;"> 2.94 </td>
   <td style="text-align:right;"> 0.024 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.031 </td>
   <td style="text-align:right;"> 0.450 </td>
   <td style="text-align:right;"> 0.180 </td>
   <td style="text-align:right;"> 0.190 </td>
   <td style="text-align:right;"> 0.074 </td>
   <td style="text-align:right;"> 376 </td>
   <td style="text-align:left;"> CHEESE,CARAWAY </td>
   <td style="text-align:left;"> 01008 </td>
   <td style="text-align:right;"> -3234.675 </td>
   <td style="text-align:right;"> -0.0995030 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:right;"> 2.61 </td>
   <td style="text-align:right;"> 33.31 </td>
   <td style="text-align:right;"> 653 </td>
   <td style="text-align:right;"> 99 </td>
   <td style="text-align:right;"> 18.867 </td>
   <td style="text-align:right;"> 22.87 </td>
   <td style="text-align:right;"> 710 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 455 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:right;"> 3.64 </td>
   <td style="text-align:right;"> 0.030 </td>
   <td style="text-align:right;"> 0.027 </td>
   <td style="text-align:right;"> 28.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.029 </td>
   <td style="text-align:right;"> 0.428 </td>
   <td style="text-align:right;"> 0.059 </td>
   <td style="text-align:right;"> 0.410 </td>
   <td style="text-align:right;"> 0.066 </td>
   <td style="text-align:right;"> 404 </td>
   <td style="text-align:left;"> CHEESE,CHEDDAR </td>
   <td style="text-align:left;"> 01009 </td>
   <td style="text-align:right;"> -2687.571 </td>
   <td style="text-align:right;"> 0.9464129 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 7.93 </td>
   <td style="text-align:right;"> 30.60 </td>
   <td style="text-align:right;"> 700 </td>
   <td style="text-align:right;"> 103 </td>
   <td style="text-align:right;"> 19.475 </td>
   <td style="text-align:right;"> 23.37 </td>
   <td style="text-align:right;"> 643 </td>
   <td style="text-align:right;"> 0.21 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 464 </td>
   <td style="text-align:right;"> 95 </td>
   <td style="text-align:right;"> 2.79 </td>
   <td style="text-align:right;"> 0.042 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.046 </td>
   <td style="text-align:right;"> 0.293 </td>
   <td style="text-align:right;"> 0.080 </td>
   <td style="text-align:right;"> 0.413 </td>
   <td style="text-align:right;"> 0.074 </td>
   <td style="text-align:right;"> 387 </td>
   <td style="text-align:left;"> CHEESE,CHESHIRE </td>
   <td style="text-align:left;"> 01010 </td>
   <td style="text-align:right;"> -3257.267 </td>
   <td style="text-align:right;"> -0.1426935 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:right;"> 4.12 </td>
   <td style="text-align:right;"> 32.11 </td>
   <td style="text-align:right;"> 604 </td>
   <td style="text-align:right;"> 95 </td>
   <td style="text-align:right;"> 20.218 </td>
   <td style="text-align:right;"> 23.76 </td>
   <td style="text-align:right;"> 685 </td>
   <td style="text-align:right;"> 0.76 </td>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:right;"> 457 </td>
   <td style="text-align:right;"> 127 </td>
   <td style="text-align:right;"> 3.07 </td>
   <td style="text-align:right;"> 0.042 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 0.375 </td>
   <td style="text-align:right;"> 0.093 </td>
   <td style="text-align:right;"> 0.210 </td>
   <td style="text-align:right;"> 0.079 </td>
   <td style="text-align:right;"> 394 </td>
   <td style="text-align:left;"> CHEESE,COLBY </td>
   <td style="text-align:left;"> 01011 </td>
   <td style="text-align:right;"> -2599.704 </td>
   <td style="text-align:right;"> 1.1143912 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 8.72 </td>
   <td style="text-align:right;"> 4.30 </td>
   <td style="text-align:right;"> 364 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:right;"> 1.718 </td>
   <td style="text-align:right;"> 11.12 </td>
   <td style="text-align:right;"> 83 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 159 </td>
   <td style="text-align:right;"> 104 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 0.029 </td>
   <td style="text-align:right;"> 0.002 </td>
   <td style="text-align:right;"> 9.7 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.027 </td>
   <td style="text-align:right;"> 0.163 </td>
   <td style="text-align:right;"> 0.099 </td>
   <td style="text-align:right;"> 0.557 </td>
   <td style="text-align:right;"> 0.046 </td>
   <td style="text-align:right;"> 98 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,CRMD,LRG OR SML CURD </td>
   <td style="text-align:left;"> 01012 </td>
   <td style="text-align:right;"> -3386.210 </td>
   <td style="text-align:right;"> -0.3891963 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 3.85 </td>
   <td style="text-align:right;"> 3.85 </td>
   <td style="text-align:right;"> 344 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 2.311 </td>
   <td style="text-align:right;"> 10.69 </td>
   <td style="text-align:right;"> 53 </td>
   <td style="text-align:right;"> 0.16 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 113 </td>
   <td style="text-align:right;"> 90 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 7.7 </td>
   <td style="text-align:right;"> 1.4 </td>
   <td style="text-align:right;"> 0.033 </td>
   <td style="text-align:right;"> 0.142 </td>
   <td style="text-align:right;"> 0.150 </td>
   <td style="text-align:right;"> 0.181 </td>
   <td style="text-align:right;"> 0.068 </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,CRMD,W/FRUIT </td>
   <td style="text-align:left;"> 01013 </td>
   <td style="text-align:right;"> -3463.568 </td>
   <td style="text-align:right;"> -0.5370853 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 145.00 </td>
   <td style="text-align:right;"> 145.00 </td>
   <td style="text-align:right;"> 3.07 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 372 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 0.169 </td>
   <td style="text-align:right;"> 10.34 </td>
   <td style="text-align:right;"> 86 </td>
   <td style="text-align:right;"> 0.15 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 190 </td>
   <td style="text-align:right;"> 137 </td>
   <td style="text-align:right;"> 0.47 </td>
   <td style="text-align:right;"> 0.030 </td>
   <td style="text-align:right;"> 0.022 </td>
   <td style="text-align:right;"> 9.4 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.226 </td>
   <td style="text-align:right;"> 0.144 </td>
   <td style="text-align:right;"> 0.446 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,NONFAT,UNCRMD,DRY,LRG OR SML CURD </td>
   <td style="text-align:left;"> 01014 </td>
   <td style="text-align:right;"> -3278.578 </td>
   <td style="text-align:right;"> -0.1834343 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 7.66 </td>
   <td style="text-align:right;"> 2.27 </td>
   <td style="text-align:right;"> 308 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 1.235 </td>
   <td style="text-align:right;"> 10.45 </td>
   <td style="text-align:right;"> 111 </td>
   <td style="text-align:right;"> 0.13 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 150 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 0.51 </td>
   <td style="text-align:right;"> 0.033 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 11.9 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.020 </td>
   <td style="text-align:right;"> 0.251 </td>
   <td style="text-align:right;"> 0.103 </td>
   <td style="text-align:right;"> 0.524 </td>
   <td style="text-align:right;"> 0.057 </td>
   <td style="text-align:right;"> 81 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,LOWFAT,2% MILKFAT </td>
   <td style="text-align:left;"> 01015 </td>
   <td style="text-align:right;"> -3266.099 </td>
   <td style="text-align:right;"> -0.1595762 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 3.56 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 406 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0.645 </td>
   <td style="text-align:right;"> 12.39 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 134 </td>
   <td style="text-align:right;"> 86 </td>
   <td style="text-align:right;"> 0.38 </td>
   <td style="text-align:right;"> 0.028 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 9.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 0.165 </td>
   <td style="text-align:right;"> 0.128 </td>
   <td style="text-align:right;"> 0.215 </td>
   <td style="text-align:right;"> 0.068 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:left;"> CHEESE,COTTAGE,LOWFAT,1% MILKFAT </td>
   <td style="text-align:left;"> 01016 </td>
   <td style="text-align:right;"> -3490.534 </td>
   <td style="text-align:right;"> -0.5886355 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 14.50 </td>
   <td style="text-align:right;"> 14.50 </td>
   <td style="text-align:right;"> 8.59 </td>
   <td style="text-align:right;"> 34.44 </td>
   <td style="text-align:right;"> 314 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 20.213 </td>
   <td style="text-align:right;"> 6.15 </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 0.11 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 107 </td>
   <td style="text-align:right;"> 132 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> 0.018 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 8.6 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.230 </td>
   <td style="text-align:right;"> 0.091 </td>
   <td style="text-align:right;"> 0.517 </td>
   <td style="text-align:right;"> 0.056 </td>
   <td style="text-align:right;"> 350 </td>
   <td style="text-align:left;"> CHEESE,CREAM </td>
   <td style="text-align:left;"> 01017 </td>
   <td style="text-align:right;"> -3389.710 </td>
   <td style="text-align:right;"> -0.3958887 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 4.73 </td>
   <td style="text-align:right;"> 27.80 </td>
   <td style="text-align:right;"> 812 </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 17.572 </td>
   <td style="text-align:right;"> 24.99 </td>
   <td style="text-align:right;"> 731 </td>
   <td style="text-align:right;"> 0.44 </td>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:right;"> 536 </td>
   <td style="text-align:right;"> 188 </td>
   <td style="text-align:right;"> 3.75 </td>
   <td style="text-align:right;"> 0.036 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.037 </td>
   <td style="text-align:right;"> 0.389 </td>
   <td style="text-align:right;"> 0.082 </td>
   <td style="text-align:right;"> 0.281 </td>
   <td style="text-align:right;"> 0.076 </td>
   <td style="text-align:right;"> 357 </td>
   <td style="text-align:left;"> CHEESE,EDAM </td>
   <td style="text-align:left;"> 01018 </td>
   <td style="text-align:right;"> -3208.657 </td>
   <td style="text-align:right;"> -0.0497637 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 150.00 </td>
   <td style="text-align:right;"> 150.00 </td>
   <td style="text-align:right;"> 3.77 </td>
   <td style="text-align:right;"> 21.28 </td>
   <td style="text-align:right;"> 917 </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 14.946 </td>
   <td style="text-align:right;"> 14.21 </td>
   <td style="text-align:right;"> 493 </td>
   <td style="text-align:right;"> 0.65 </td>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:right;"> 337 </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:right;"> 2.88 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 0.028 </td>
   <td style="text-align:right;"> 15.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.154 </td>
   <td style="text-align:right;"> 0.844 </td>
   <td style="text-align:right;"> 0.991 </td>
   <td style="text-align:right;"> 0.967 </td>
   <td style="text-align:right;"> 0.424 </td>
   <td style="text-align:right;"> 264 </td>
   <td style="text-align:left;"> CHEESE,FETA </td>
   <td style="text-align:left;"> 01019 </td>
   <td style="text-align:right;"> -3516.569 </td>
   <td style="text-align:right;"> -0.6384083 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:right;"> 132.00 </td>
   <td style="text-align:right;"> 6.64 </td>
   <td style="text-align:right;"> 31.14 </td>
   <td style="text-align:right;"> 800 </td>
   <td style="text-align:right;"> 116 </td>
   <td style="text-align:right;"> 19.196 </td>
   <td style="text-align:right;"> 25.60 </td>
   <td style="text-align:right;"> 550 </td>
   <td style="text-align:right;"> 0.23 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:right;"> 346 </td>
   <td style="text-align:right;"> 64 </td>
   <td style="text-align:right;"> 3.50 </td>
   <td style="text-align:right;"> 0.025 </td>
   <td style="text-align:right;"> 0.014 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 0.204 </td>
   <td style="text-align:right;"> 0.150 </td>
   <td style="text-align:right;"> 0.429 </td>
   <td style="text-align:right;"> 0.083 </td>
   <td style="text-align:right;"> 389 </td>
   <td style="text-align:left;"> CHEESE,FONTINA </td>
   <td style="text-align:left;"> 01020 </td>
   <td style="text-align:right;"> -3304.806 </td>
   <td style="text-align:right;"> -0.2335737 </td>
  </tr>
</tbody>
</table>


**Per 100g vs. Raw**

Note how our column titles have aways end with `_g` or `_mg`. That's because this column is giving us the value of each nutrient, *per 100g of this food*. The value we've got in that column isn't the raw value. Our contraints, though, are in raw terms. We'll need a way to know whether we've gotten our 1000mg of Calcium from the foods in our menu, each of which list how much Calcium they provide per 100g of that food.

In order to get to the raw value of a nutrient, for each food in our menu we'll multiply the 100g value of that nutrient by the weight of the food in grams, or its `GmWt_1`.

$TotalNutrientVal = \sum_{i=1}^{k} Per100gVal_{i} * GmWt_{i}$ 


Two helper functions `get_per_g_vals()` and `get_raw_vals()` in `/scripts/solve` allow us to go back and forth between raw and per 100g values. We'll try to keep everything in per 100g whenever possible, as that's the format our raw data is in. Our main solving function does accept both formats, however.


```r
abbrev %>% sample_n(10) %>% get_raw_vals()
```

```
## # A tibble: 10 x 30
##     shorter_desc GmWt_1 serving_gmwt  cost Lipid_Tot_g Sodium_mg
##            <chr>  <dbl>        <dbl> <dbl>       <dbl>     <dbl>
##  1         SAUCE  30.00        30.00  9.83     5.01000  200.1000
##  2         PASTA 117.00       117.00  9.78     2.00070    4.6800
##  3        CHEESE 132.00       132.00  7.85    23.23200  811.8000
##  4      BABYFOOD  15.00        15.00  3.47     0.07800    2.1000
##  5      MACKEREL  28.35        28.35  6.69     1.78605  107.4465
##  6          NUTS 157.00       157.00  4.44    86.61690  224.5100
##  7          PORK  85.00        85.00  2.25    11.57700   40.8000
##  8        YOGURT 170.00       170.00  5.29     0.66300   61.2000
##  9 RUFFED GROUSE 113.00       113.00  4.41     0.99440   56.5000
## 10          PATE  13.00        13.00  7.78     3.64000   90.6100
## # ... with 24 more variables: Cholestrl_mg <dbl>, FA_Sat_g <dbl>,
## #   Protein_g <dbl>, Calcium_mg <dbl>, Iron_mg <dbl>, Magnesium_mg <dbl>,
## #   Phosphorus_mg <dbl>, Potassium_mg <dbl>, Zinc_mg <dbl>,
## #   Copper_mg <dbl>, Manganese_mg <dbl>, Selenium_µg <dbl>,
## #   Vit_C_mg <dbl>, Thiamin_mg <dbl>, Riboflavin_mg <dbl>,
## #   Niacin_mg <dbl>, Panto_Acid_mg <dbl>, Vit_B6_mg <dbl>,
## #   Energ_Kcal <dbl>, solution_amounts <dbl>, Shrt_Desc <chr>,
## #   NDB_No <chr>, score <dbl>, scaled_score <dbl>
```



# Creating and Solving Menus

### Building

Now to build a menu. The only constraint we'll worry about for now is that menus have to contain at least 2300 calories. Our strategy is simple; pick one serving of a food at random from our dataset and, if it doesn't yet exist in our menu, add it. We do this until we're no longer under 2300 calories. 

That's implemented in `add_calories()` below, which we'll as a helper inside `build_menu()`. The reason I've spun `add_calories()` out into its own function is so that we can easily add more foods to existing menus. It takes `menu` as its first argument, unlike `build_menu()` which takes a dataframe of possible foods to choose from as its first argument. That makes it more convenient to call `add_calories()` from inside `build_menu()` and use `build_menu()` primarily to create totally new menus.


```r
add_calories <- function(menu = NULL, df = abbrev, seed = NULL, ...) {

  # If we're starting from an existing menu
  if (! is.null(menu)) {
    menu <- menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>%  filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
    cals <- sum((menu$Energ_Kcal * menu$GmWt_1), na.rm = TRUE)/100   # Set calories to our current number of calories
  # If we're starting from scratch
  } else {
    cals <- 0   
    menu <- NULL
  }

  while (cals < 2300) {
    df <- df %>% filter(!NDB_No %in% menu$NDB_No)   # Only add foods we don't already have

    if (nrow(df) == 0) {
      message("No more elligible foods to sample from. Returning menu too low in calories.")
      return(menu)
    } else {
      food_i <- df %>%
        sample_n(1)   # Sample a new index from a food that doesn't already exist in our menu
    }

    this_food_cal <- (food_i$Energ_Kcal * food_i$GmWt_1)/100   
    cals <- cals + this_food_cal    

    menu <- bind_rows(menu, food_i)   
  }
  return(menu)   
}
```


Okay now for `build_menu()`. We'll make sure we don't have missing values in any of our nutrient columns, calories, or the food weight. The `from_better_cutoff` argument allows us to specify that we only want to pull foods that have at least a certain z-score on our `scaled_score` dimension. More on scoring in a bit. 

The default, though, will just be to pull foods from our main `abbrev` dataframe.


```r
build_menu <- function(df = abbrev, menu = NULL, seed = NULL, from_better_cutoff = NULL, do_mutates = TRUE) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  df <- df %>% drop_na_(all_nut_and_mr_df$nutrient) %>%
    filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))    # Filter out rows that have NAs in columns that we need
  
  # Optionally choose a floor for what the z-score of each food to build from should be
  if (!is.null(from_better_cutoff)) {
    assert_that(is.numeric(from_better_cutoff), msg = "from_better_cutoff must be numeric or NULL")
    if (! "scaled_score" %in% names(df)) {
      df <- df %>% 
        add_ranked_foods()
    }
    df <- df %>% 
      filter(scaled_score > from_better_cutoff)
  }
  
  if (nrow(df) == 0) {
    stop("No foods to speak of; you might try a lower cutoff.")
  }
  
  # Add one serving of food until we hit 2300
  menu <- add_calories(menu = menu, df = df)
  
  return(menu)
}
```




```r
our_random_menu <- build_menu()
```

Alright nice -- we've got random menu that's at least compliant on calories. Is it compliant on nutrients and must restricts?


#### Testing Compliance

A few quick functions for testing whether we're compliant on the other dimensions. Nothing fancy here; all we're doing is going through positives and must restricts and figuring out how much of a given nutrient we've got and comparing that to the requirement. If we're below the minimum on any positives, above the maximum on any must restricts, or we're below 2300 calories we're out of compliance. To make it easier to see where we're out of compliance, we'll return a dataframe of the nutrients we're uncompliant on.

For must restricts:


```r
test_mr_compliance <- function(orig_menu, capitalize_colname = TRUE) {
  
  compliance_df <- list(must_restricts_uncompliant_on = vector(), 
                        `difference_(g)` = vector()) %>% as_tibble()
  
  for (m in seq_along(mr_df$must_restrict)) {    
    nut_to_restrict <- mr_df$must_restrict[m]    # Grab the name of the nutrient we're restricting
    to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # Get the amount of that must restrict nutrient in our original menu
    
    if ((to_restrict - mr_df$value[m]) > 0.01) {    # Account for rounding error
      this_compliance <- list(must_restricts_uncompliant_on = nut_to_restrict,
                              `difference_(g)` = (to_restrict - mr_df$value[m]) %>% round(digits = 2)) %>% as_tibble()
      compliance_df <- bind_rows(compliance_df, this_compliance)
    }
  }
  if (capitalize_colname == TRUE) {
    compliance_df <- compliance_df %>% cap_df()
  }
  return(compliance_df)
}
```

Same idea for positives. Then to test whether we're compliant overall, we'll see whether we pass all of these tsts. If not, we're not compliant.


```r
test_all_compliance <- function(orig_menu) {
  combined_compliance <- "Undetermined"
  
  if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) > 0 |
      test_calories(orig_menu) == "Calories too low") {
    combined_compliance <- "Not Compliant"
    
  } else if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) == 0 &
             test_calories(orig_menu) == "Calorie compliant") {
    combined_compliance <- "Compliant"
    
  } else {
    combined_compliance <- "Undetermined"
  }
  return(combined_compliance)
}
```


Let's see where we are with our random menu.


```r
our_random_menu %>% test_all_compliance
```

```
## [1] "Not Compliant"
```



#### Scoring

Now I want an objective and preferably single scalar metric by which to judge menus. We want a metric that takes into account the following things:

* You don't get extra credit for going above the daily minimum on positive nutrients
    * This reflects the fact that your body can only absorb up to a certain amount of a vitamin
* You do, however, keep getting penalized for going farther and farther above the minimum on `must_restricts`
    * There's no cap on how bad an increase in bad stuff will keep 
    
For simplicity and because I'm not a doctor, we'll assume a linear relationship between increasing and decreasing nutrients and their effect on our score. Though they're really two different dimensions, I want to be able to combine a must restrict score with a postiive score to get a single number out. The directionality of the scores will also have to be the same if we want to combine them; so in both cases, *more positive scores mean worse*.

Similar to how we tested compliance, I'll do is go through a given menu and multiply the nutrient value per 100g by `GmWt_1`, the amount of the food we have. That will give us the raw amount of this nutrient. Then I'll see how much that raw amount differs from the minimum or maximum daily value of that nutrient we're supposed to have and give it a score accordingly. Then I'll add it up.

First, the must restricts. For each must restrict, we find the difference between our maximum allowed value and the value of that must restrict and add those all up. (Perhaps percent above the maximum would be a better metric.)

$\sum_{i=1}^{k} MaxAllowedAmount_{i} - AmountWeHave_{i}$ 

So the farther above our max we are on must restricts, the higher our score will be.


```r
mr_score <- function(orig_menu) {
  total_mr_score <- 0
  
  for (m in seq_along(mr_df$must_restrict)) {    
    mr_considering <- mr_df$must_restrict[m]    
    val_mr_considering <- (sum((orig_menu[[mr_considering]] * orig_menu$GmWt_1), 
                                na.rm = TRUE))/100   
    
    mr_score <- mr_df$value[m] - val_mr_considering  # max amount it's supposed to be - amount it is

    total_mr_score <- total_mr_score + mr_score
  }
  return(total_mr_score)
}
```



Similar story for the positives: we'll take the difference between our minimum required amount and the amount of the nutrient we've got in our menu and multiply that by -1. 

$\sum_{i=1}^{k} (-1) * (MaxAllowedAmount_{i} - AmountWeHave_{i})$ 

That means that if we've got less than the amount we need, this value will be negative; if we've got more than we need it'll be positive. Next, to make the best score 0 I'll turn everything greater than 0 into 0. This takes away the extra brownie points for going above and beyond. Same as with must restricts, lower scores mean "better." 



```r
pos_score <- function(orig_menu) {
  total_nut_score <- 0
  
  for (p in seq_along(pos_df$positive_nut)) {    
    nut_considering <- pos_df$positive_nut[p]    
    val_nut_considering <- (sum((orig_menu[[nut_considering]] * orig_menu$GmWt_1), 
                                na.rm = TRUE))/100   
    
    nut_score <- (-1)*(pos_df$value[p] - val_nut_considering)    # (-1)*(min amount it's supposed to be - amount it is here)
    
    if (nut_score > 0) {
      nut_score <- 0
    } else if (is.na(nut_score)) {
      message("Nutrient has no score")
      break
    }
    total_nut_score <- total_nut_score + nut_score
  }
  return(total_nut_score)
}
```


Last step is just a simple sum:


```r
score_menu <- function(orig_menu) {
  healthiness_score <- pos_score(orig_menu) + mr_score(orig_menu)
  return(healthiness_score)
}
```



```r
our_random_menu %>% score_menu()
```

```
## [1] -2018.912
```


### Solving

#### Getting a Solution

The algorithm we use for solving is the [GNU linear program solver](https://cran.r-project.org/web/packages/Rglpk/Rglpk.pdf).

Our goal is to return a solution that is a list of a few things we're intersted in: the cost of our final menu, the original menu, and the multiplier on each food's portion size.


```r
solve_it <- function(df, nut_df = nutrient_df, df_is_per_100g = TRUE, only_full_servings = FALSE, 
                     min_food_amount = 1, max_food_amount = 100, 
                     verbose = TRUE, v_v_verbose = FALSE, maximize = FALSE) {
  
  # If our nutrient values are per 100g (i.e., straight from menu_builder)
  if (df_is_per_100g == TRUE) {
    df_per_100g <- df        # Save our original df in df_per_100g
    df <- get_raw_vals(df)   # Get the raw values
  } else {
    df_per_100g <- get_per_g_vals(df)
    df <- df
  }
  
  n_foods <- length(df$shorter_desc)
  nut_quo <- quo(nut_df$nutrient)
  
  dir_mr <- rep("<", nut_df %>% filter(is_must_restrict == TRUE) %>% ungroup() %>% count() %>% as_vector())       # And less than on all the must_restricts
  dir_pos <- rep(">", nut_df %>% filter(is_must_restrict == FALSE) %>% ungroup() %>% count() %>% as_vector())     # Final menu must be greater than on all the positives
  
  dir <- c(dir_mr, dir_pos)
  rhs <- nut_df[["value"]]      # The right-hand side of the equation is all of the min or max nutrient values
  obj_fn <- df[["cost"]]             # Objective function will be to minimize total cost
  
  bounds <- list(lower = list(ind = seq(n_foods), 
                              val = rep(min_food_amount, n_foods)),
                 upper = list(ind = seq(n_foods), 
                              val = rep(max_food_amount, n_foods)))
  
  construct_matrix <- function(df, nut_df) {       # Set up matrix constraints
    mat_base <- df %>% select(!!nut_quo) %>% as_vector()    # Get a vector of all our nutrients
    mat <- matrix(mat_base, nrow = nrow(nut_df), byrow = TRUE)       # One row per constraint, one column per food (variable)
    return(mat)
  }
  
  const_mat_names <- str_c(df$shorter_desc,  # Use combo of shorter_desc and NDB_No
        df$NDB_No, sep = ", ")  # so that names are interpretable but also unique
  
  mat <- construct_matrix(df, nut_df)
  constraint_matrix <- mat %>% dplyr::as_data_frame() 
  names(constraint_matrix) <- const_mat_names
  
  constraint_matrix <- constraint_matrix %>% 
    mutate(
      dir = dir,
      rhs = rhs
    ) %>% left_join(nut_df, by = c("rhs" = "value")) %>% 
    select(nutrient, everything())
  
  if(only_full_servings == TRUE) {    # Integer values of coefficients if only full servings
    types <- rep("I", n_foods)
  } else {
    types <- rep("C", n_foods)
  }
  
  if(v_v_verbose == TRUE) {
    v_v_verbose <- TRUE
    message("Constraint matrix below:")
    print(constraint_matrix)
  } else {
    v_v_verbose <- FALSE
  }
  
  out <- Rglpk_solve_LP(obj_fn, mat, dir, rhs,                    # Do the solving; we get a list back
                        bounds = bounds, types = types, 
                        max = maximize, verbose = v_v_verbose)   
  
  out <- append(append(append(                                           # Append the dataframe of all min/max nutrient values
    out, list(necessary_nutrients = nut_df)),
    list(constraint_matrix = constraint_matrix)),                        # our constraint matrix
    list(original_menu_raw = df))                                            # and our original menu
  
  if (!is.null(df_per_100g)) {
    out <- append(out, list(original_menu_per_g = df_per_100g))
  }
  
  if (verbose == TRUE) {
    message(paste0("Cost is $", round(out$optimum, digits = 2), ".")) 
    if (out$status == 0) {
      message("Optimal solution found :)")
    } else {
      message("No optimal solution found :'(")
    }
  }
  
  return(out)
}
```



```r
system.time(our_random_menu %>% solve_it())
```

```
## Cost is $98.79.
```

```
## No optimal solution found :'(
```

```
##    user  system elapsed 
##   0.038   0.001   0.044
```



```r
our_menu_solution <- our_random_menu %>% solve_it()
```

```
## Cost is $98.79.
```

```
## No optimal solution found :'(
```


### Solve menu

`solve_menu` takes one main argument: the result of a call to `solve_it()`. Since the return value of solve it contains the original menu and a vector of solution amounts -- that is, the amount we're multiplying each portion size by in order to arrive at our solution -- we can combine these to get our solved menu.

We also return a message, if `verbose` is TRUE, telling us which food we've got the most servings of, as this might be something we'd want to decrease. (Now that I'm thining about it, maybe a more helpful message would take a threshold portion size and only alert us if we've exceeded that threshold.)


```r
solve_menu <- function(sol, verbose = TRUE) {
  
  solved_col <-  tibble(solution_amounts = sol$solution)    # Grab the vector of solution amounts
  
  if (! "solution_amounts" %in% names(sol$original_menu_per_g)) {   # If we don't yet have a solution amounts column add it
    df_solved <- sol$original_menu_per_g %>% 
      bind_cols(solved_col)            # cbind that to the original menu
  } else {
    df_solved <- sol$original_menu_per_g %>% 
      mutate(
        solution_amounts = solved_col %>% as_vector()    # If we've already got a solution amounts column, replace the old one with the new
      ) 
  }
  
  df_solved <- df_solved %>% 
    mutate(
      GmWt_1 = GmWt_1 * solution_amounts,
      cost = cost * solution_amounts
    ) %>% 
    select(shorter_desc, solution_amounts, GmWt_1, serving_gmwt, everything()) 
  
  max_food <- df_solved %>%                                   # Find what the most of any one food we've got is
    filter(solution_amounts == max(df_solved$solution_amounts)) %>% 
    slice(1:1)                                           # If we've got multiple maxes, take only the first
  
  if (verbose == TRUE) {
    message(paste0("We've got a lot of ", max_food$shorter_desc %>% as_vector()), ". ",
            max_food$solution_amounts %>% round(digits = 2), " servings of ",
            max_food$shorter_desc %>% as_vector() %>% is_plural(return_bool = FALSE), ".")  
  }
  
  return(df_solved)
}
```


```r
our_solved_menu <- our_menu_solution %>% solve_menu()
```

```
## We've got a lot of CANDIES. 1 servings of them.
```

```r
our_solved_menu %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> shorter_desc </th>
   <th style="text-align:right;"> solution_amounts </th>
   <th style="text-align:right;"> GmWt_1 </th>
   <th style="text-align:right;"> serving_gmwt </th>
   <th style="text-align:right;"> cost </th>
   <th style="text-align:right;"> Lipid_Tot_g </th>
   <th style="text-align:right;"> Sodium_mg </th>
   <th style="text-align:right;"> Cholestrl_mg </th>
   <th style="text-align:right;"> FA_Sat_g </th>
   <th style="text-align:right;"> Protein_g </th>
   <th style="text-align:right;"> Calcium_mg </th>
   <th style="text-align:right;"> Iron_mg </th>
   <th style="text-align:right;"> Magnesium_mg </th>
   <th style="text-align:right;"> Phosphorus_mg </th>
   <th style="text-align:right;"> Potassium_mg </th>
   <th style="text-align:right;"> Zinc_mg </th>
   <th style="text-align:right;"> Copper_mg </th>
   <th style="text-align:right;"> Manganese_mg </th>
   <th style="text-align:right;"> Selenium_µg </th>
   <th style="text-align:right;"> Vit_C_mg </th>
   <th style="text-align:right;"> Thiamin_mg </th>
   <th style="text-align:right;"> Riboflavin_mg </th>
   <th style="text-align:right;"> Niacin_mg </th>
   <th style="text-align:right;"> Panto_Acid_mg </th>
   <th style="text-align:right;"> Vit_B6_mg </th>
   <th style="text-align:right;"> Energ_Kcal </th>
   <th style="text-align:left;"> Shrt_Desc </th>
   <th style="text-align:left;"> NDB_No </th>
   <th style="text-align:right;"> score </th>
   <th style="text-align:right;"> scaled_score </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> CANDIES </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 40.00 </td>
   <td style="text-align:right;"> 40.00 </td>
   <td style="text-align:right;"> 2.24 </td>
   <td style="text-align:right;"> 34.50 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 20.600 </td>
   <td style="text-align:right;"> 5.58 </td>
   <td style="text-align:right;"> 109 </td>
   <td style="text-align:right;"> 1.33 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 129 </td>
   <td style="text-align:right;"> 306 </td>
   <td style="text-align:right;"> 0.79 </td>
   <td style="text-align:right;"> 0.180 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 0.160 </td>
   <td style="text-align:right;"> 0.330 </td>
   <td style="text-align:right;"> 0.250 </td>
   <td style="text-align:right;"> 0.060 </td>
   <td style="text-align:right;"> 563 </td>
   <td style="text-align:left;"> CANDIES,HERSHEY'S,ALMOND JOY BITES </td>
   <td style="text-align:left;"> 19248 </td>
   <td style="text-align:right;"> -4490.352 </td>
   <td style="text-align:right;"> 0.0062599 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SALMON </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 9.02 </td>
   <td style="text-align:right;"> 7.31 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:right;"> 1.644 </td>
   <td style="text-align:right;"> 20.47 </td>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:right;"> 1.06 </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:right;"> 326 </td>
   <td style="text-align:right;"> 377 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.084 </td>
   <td style="text-align:right;"> 0.030 </td>
   <td style="text-align:right;"> 35.4 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 0.193 </td>
   <td style="text-align:right;"> 5.480 </td>
   <td style="text-align:right;"> 0.550 </td>
   <td style="text-align:right;"> 0.300 </td>
   <td style="text-align:right;"> 153 </td>
   <td style="text-align:left;"> SALMON,SOCKEYE,CND,WO/SALT,DRND SOL W/BONE </td>
   <td style="text-align:left;"> 15182 </td>
   <td style="text-align:right;"> -3913.498 </td>
   <td style="text-align:right;"> 1.1090489 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BROADBEANS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 109.00 </td>
   <td style="text-align:right;"> 109.00 </td>
   <td style="text-align:right;"> 3.93 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 50 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.138 </td>
   <td style="text-align:right;"> 5.60 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 1.90 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 95 </td>
   <td style="text-align:right;"> 250 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 0.074 </td>
   <td style="text-align:right;"> 0.320 </td>
   <td style="text-align:right;"> 1.2 </td>
   <td style="text-align:right;"> 33.0 </td>
   <td style="text-align:right;"> 0.170 </td>
   <td style="text-align:right;"> 0.110 </td>
   <td style="text-align:right;"> 1.500 </td>
   <td style="text-align:right;"> 0.086 </td>
   <td style="text-align:right;"> 0.038 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:left;"> BROADBEANS,IMMAT SEEDS,RAW </td>
   <td style="text-align:left;"> 11088 </td>
   <td style="text-align:right;"> -4250.264 </td>
   <td style="text-align:right;"> 0.4652428 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GELATIN DSSRT </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 1.96 </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 466 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 7.80 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0.13 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 141 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 0.118 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 6.7 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 0.041 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.014 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 381 </td>
   <td style="text-align:left;"> GELATIN DSSRT,DRY MIX </td>
   <td style="text-align:left;"> 19172 </td>
   <td style="text-align:right;"> -4938.439 </td>
   <td style="text-align:right;"> -0.8503611 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CRAYFISH </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 6.64 </td>
   <td style="text-align:right;"> 1.20 </td>
   <td style="text-align:right;"> 94 </td>
   <td style="text-align:right;"> 133 </td>
   <td style="text-align:right;"> 0.181 </td>
   <td style="text-align:right;"> 16.77 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:right;"> 270 </td>
   <td style="text-align:right;"> 296 </td>
   <td style="text-align:right;"> 1.76 </td>
   <td style="text-align:right;"> 0.685 </td>
   <td style="text-align:right;"> 0.522 </td>
   <td style="text-align:right;"> 36.7 </td>
   <td style="text-align:right;"> 0.9 </td>
   <td style="text-align:right;"> 0.050 </td>
   <td style="text-align:right;"> 0.085 </td>
   <td style="text-align:right;"> 2.280 </td>
   <td style="text-align:right;"> 0.580 </td>
   <td style="text-align:right;"> 0.076 </td>
   <td style="text-align:right;"> 82 </td>
   <td style="text-align:left;"> CRAYFISH,MXD SP,WILD,CKD,MOIST HEAT </td>
   <td style="text-align:left;"> 15146 </td>
   <td style="text-align:right;"> -4266.922 </td>
   <td style="text-align:right;"> 0.4333988 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CRACKERS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 30.00 </td>
   <td style="text-align:right;"> 30.00 </td>
   <td style="text-align:right;"> 3.41 </td>
   <td style="text-align:right;"> 11.67 </td>
   <td style="text-align:right;"> 1167 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 3.333 </td>
   <td style="text-align:right;"> 10.00 </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:right;"> 4.80 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 162 </td>
   <td style="text-align:right;"> 141 </td>
   <td style="text-align:right;"> 0.90 </td>
   <td style="text-align:right;"> 0.118 </td>
   <td style="text-align:right;"> 0.517 </td>
   <td style="text-align:right;"> 26.2 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 1.087 </td>
   <td style="text-align:right;"> 0.750 </td>
   <td style="text-align:right;"> 7.170 </td>
   <td style="text-align:right;"> 0.528 </td>
   <td style="text-align:right;"> 0.044 </td>
   <td style="text-align:right;"> 418 </td>
   <td style="text-align:left;"> CRACKERS,CHS,RED FAT </td>
   <td style="text-align:left;"> 18965 </td>
   <td style="text-align:right;"> -4906.367 </td>
   <td style="text-align:right;"> -0.7890484 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHEESE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 7.25 </td>
   <td style="text-align:right;"> 30.64 </td>
   <td style="text-align:right;"> 1809 </td>
   <td style="text-align:right;"> 90 </td>
   <td style="text-align:right;"> 19.263 </td>
   <td style="text-align:right;"> 21.54 </td>
   <td style="text-align:right;"> 662 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:right;"> 392 </td>
   <td style="text-align:right;"> 91 </td>
   <td style="text-align:right;"> 2.08 </td>
   <td style="text-align:right;"> 0.034 </td>
   <td style="text-align:right;"> 0.030 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 0.586 </td>
   <td style="text-align:right;"> 0.734 </td>
   <td style="text-align:right;"> 1.731 </td>
   <td style="text-align:right;"> 0.124 </td>
   <td style="text-align:right;"> 369 </td>
   <td style="text-align:left;"> CHEESE,ROQUEFORT </td>
   <td style="text-align:left;"> 01039 </td>
   <td style="text-align:right;"> -4892.506 </td>
   <td style="text-align:right;"> -0.7625507 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SPICES </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 9.03 </td>
   <td style="text-align:right;"> 4.07 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 2.157 </td>
   <td style="text-align:right;"> 22.98 </td>
   <td style="text-align:right;"> 2240 </td>
   <td style="text-align:right;"> 89.80 </td>
   <td style="text-align:right;"> 711 </td>
   <td style="text-align:right;"> 274 </td>
   <td style="text-align:right;"> 2630 </td>
   <td style="text-align:right;"> 7.10 </td>
   <td style="text-align:right;"> 2.100 </td>
   <td style="text-align:right;"> 9.800 </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:right;"> 0.8 </td>
   <td style="text-align:right;"> 0.080 </td>
   <td style="text-align:right;"> 1.200 </td>
   <td style="text-align:right;"> 4.900 </td>
   <td style="text-align:right;"> 0.838 </td>
   <td style="text-align:right;"> 1.340 </td>
   <td style="text-align:right;"> 233 </td>
   <td style="text-align:left;"> SPICES,BASIL,DRIED </td>
   <td style="text-align:left;"> 02003 </td>
   <td style="text-align:right;"> -4643.583 </td>
   <td style="text-align:right;"> -0.2866766 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> RAVIOLI </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 242.00 </td>
   <td style="text-align:right;"> 242.00 </td>
   <td style="text-align:right;"> 7.63 </td>
   <td style="text-align:right;"> 1.45 </td>
   <td style="text-align:right;"> 306 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0.723 </td>
   <td style="text-align:right;"> 2.48 </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:right;"> 0.74 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 50 </td>
   <td style="text-align:right;"> 232 </td>
   <td style="text-align:right;"> 0.36 </td>
   <td style="text-align:right;"> 0.142 </td>
   <td style="text-align:right;"> 0.176 </td>
   <td style="text-align:right;"> 3.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.074 </td>
   <td style="text-align:right;"> 0.080 </td>
   <td style="text-align:right;"> 1.060 </td>
   <td style="text-align:right;"> 0.272 </td>
   <td style="text-align:right;"> 0.102 </td>
   <td style="text-align:right;"> 77 </td>
   <td style="text-align:left;"> RAVIOLI,CHEESE-FILLED,CND </td>
   <td style="text-align:left;"> 22899 </td>
   <td style="text-align:right;"> -4617.693 </td>
   <td style="text-align:right;"> -0.2371810 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LUXURY LOAF </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.00 </td>
   <td style="text-align:right;"> 28.00 </td>
   <td style="text-align:right;"> 4.64 </td>
   <td style="text-align:right;"> 4.80 </td>
   <td style="text-align:right;"> 1225 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 1.580 </td>
   <td style="text-align:right;"> 18.40 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 185 </td>
   <td style="text-align:right;"> 377 </td>
   <td style="text-align:right;"> 3.05 </td>
   <td style="text-align:right;"> 0.100 </td>
   <td style="text-align:right;"> 0.041 </td>
   <td style="text-align:right;"> 21.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.707 </td>
   <td style="text-align:right;"> 0.297 </td>
   <td style="text-align:right;"> 3.482 </td>
   <td style="text-align:right;"> 0.515 </td>
   <td style="text-align:right;"> 0.310 </td>
   <td style="text-align:right;"> 141 </td>
   <td style="text-align:left;"> LUXURY LOAF,PORK </td>
   <td style="text-align:left;"> 07060 </td>
   <td style="text-align:right;"> -4852.980 </td>
   <td style="text-align:right;"> -0.6869870 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CANDIES </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 14.50 </td>
   <td style="text-align:right;"> 14.50 </td>
   <td style="text-align:right;"> 9.99 </td>
   <td style="text-align:right;"> 30.00 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 17.750 </td>
   <td style="text-align:right;"> 4.20 </td>
   <td style="text-align:right;"> 32 </td>
   <td style="text-align:right;"> 3.13 </td>
   <td style="text-align:right;"> 115 </td>
   <td style="text-align:right;"> 132 </td>
   <td style="text-align:right;"> 365 </td>
   <td style="text-align:right;"> 1.62 </td>
   <td style="text-align:right;"> 0.700 </td>
   <td style="text-align:right;"> 0.800 </td>
   <td style="text-align:right;"> 4.2 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.055 </td>
   <td style="text-align:right;"> 0.090 </td>
   <td style="text-align:right;"> 0.427 </td>
   <td style="text-align:right;"> 0.105 </td>
   <td style="text-align:right;"> 0.035 </td>
   <td style="text-align:right;"> 480 </td>
   <td style="text-align:left;"> CANDIES,SEMISWEET CHOC </td>
   <td style="text-align:left;"> 19080 </td>
   <td style="text-align:right;"> -4597.911 </td>
   <td style="text-align:right;"> -0.1993645 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ONIONS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 210.00 </td>
   <td style="text-align:right;"> 210.00 </td>
   <td style="text-align:right;"> 4.83 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 0.09 </td>
   <td style="text-align:right;"> 0.024 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 5.1 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 0.018 </td>
   <td style="text-align:right;"> 0.132 </td>
   <td style="text-align:right;"> 0.078 </td>
   <td style="text-align:right;"> 0.070 </td>
   <td style="text-align:right;"> 28 </td>
   <td style="text-align:left;"> ONIONS,FRZ,WHL,CKD,BLD,DRND,WO/SALT </td>
   <td style="text-align:left;"> 11290 </td>
   <td style="text-align:right;"> -4397.386 </td>
   <td style="text-align:right;"> 0.1839856 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PIZZA HUT 14&quot; PEPPERONI PIZZA </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 5.69 </td>
   <td style="text-align:right;"> 13.07 </td>
   <td style="text-align:right;"> 676 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 4.823 </td>
   <td style="text-align:right;"> 11.47 </td>
   <td style="text-align:right;"> 147 </td>
   <td style="text-align:right;"> 2.57 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 187 </td>
   <td style="text-align:right;"> 1.36 </td>
   <td style="text-align:right;"> 0.104 </td>
   <td style="text-align:right;"> 0.425 </td>
   <td style="text-align:right;"> 15.5 </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 0.420 </td>
   <td style="text-align:right;"> 0.210 </td>
   <td style="text-align:right;"> 3.750 </td>
   <td style="text-align:right;"> 0.323 </td>
   <td style="text-align:right;"> 0.090 </td>
   <td style="text-align:right;"> 291 </td>
   <td style="text-align:left;"> PIZZA HUT 14&quot; PEPPERONI PIZZA,PAN CRUST </td>
   <td style="text-align:left;"> 21297 </td>
   <td style="text-align:right;"> -4832.658 </td>
   <td style="text-align:right;"> -0.6481376 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BEANS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 104.00 </td>
   <td style="text-align:right;"> 104.00 </td>
   <td style="text-align:right;"> 8.77 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.085 </td>
   <td style="text-align:right;"> 6.15 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 1.93 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 100 </td>
   <td style="text-align:right;"> 307 </td>
   <td style="text-align:right;"> 0.89 </td>
   <td style="text-align:right;"> 0.356 </td>
   <td style="text-align:right;"> 0.408 </td>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:right;"> 18.8 </td>
   <td style="text-align:right;"> 0.390 </td>
   <td style="text-align:right;"> 0.215 </td>
   <td style="text-align:right;"> 1.220 </td>
   <td style="text-align:right;"> 0.825 </td>
   <td style="text-align:right;"> 0.191 </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:left;"> BEANS,NAVY,MATURE SEEDS,SPROUTED,RAW </td>
   <td style="text-align:left;"> 11046 </td>
   <td style="text-align:right;"> -4122.162 </td>
   <td style="text-align:right;"> 0.7101393 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GRAPE JUC </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 253.00 </td>
   <td style="text-align:right;"> 253.00 </td>
   <td style="text-align:right;"> 4.53 </td>
   <td style="text-align:right;"> 0.13 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.025 </td>
   <td style="text-align:right;"> 0.37 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 0.25 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:right;"> 104 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.018 </td>
   <td style="text-align:right;"> 0.239 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.1 </td>
   <td style="text-align:right;"> 0.017 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 0.133 </td>
   <td style="text-align:right;"> 0.048 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:left;"> GRAPE JUC,CND OR BTLD,UNSWTND,WO/ ADDED VIT C </td>
   <td style="text-align:left;"> 09135 </td>
   <td style="text-align:right;"> -4343.103 </td>
   <td style="text-align:right;"> 0.2877596 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PIE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 1.75 </td>
   <td style="text-align:right;"> 12.50 </td>
   <td style="text-align:right;"> 211 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 3.050 </td>
   <td style="text-align:right;"> 2.40 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 1.12 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 28 </td>
   <td style="text-align:right;"> 79 </td>
   <td style="text-align:right;"> 0.19 </td>
   <td style="text-align:right;"> 0.053 </td>
   <td style="text-align:right;"> 0.185 </td>
   <td style="text-align:right;"> 7.8 </td>
   <td style="text-align:right;"> 1.7 </td>
   <td style="text-align:right;"> 0.148 </td>
   <td style="text-align:right;"> 0.107 </td>
   <td style="text-align:right;"> 1.230 </td>
   <td style="text-align:right;"> 0.093 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:left;"> PIE,APPL,PREP FROM RECIPE </td>
   <td style="text-align:left;"> 18302 </td>
   <td style="text-align:right;"> -4710.654 </td>
   <td style="text-align:right;"> -0.4148992 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PORK </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 2.46 </td>
   <td style="text-align:right;"> 2.59 </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:right;"> 0.906 </td>
   <td style="text-align:right;"> 22.81 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 251 </td>
   <td style="text-align:right;"> 354 </td>
   <td style="text-align:right;"> 1.72 </td>
   <td style="text-align:right;"> 0.069 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 37.4 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.610 </td>
   <td style="text-align:right;"> 0.256 </td>
   <td style="text-align:right;"> 7.348 </td>
   <td style="text-align:right;"> 0.728 </td>
   <td style="text-align:right;"> 0.611 </td>
   <td style="text-align:right;"> 121 </td>
   <td style="text-align:left;"> PORK,FRSH,LOIN,SIRLOIN (CHOPS OR ROASTS),BNLESS,LN,RAW </td>
   <td style="text-align:left;"> 10214 </td>
   <td style="text-align:right;"> -4192.317 </td>
   <td style="text-align:right;"> 0.5760225 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FAST FOODS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 226.00 </td>
   <td style="text-align:right;"> 226.00 </td>
   <td style="text-align:right;"> 5.02 </td>
   <td style="text-align:right;"> 11.75 </td>
   <td style="text-align:right;"> 350 </td>
   <td style="text-align:right;"> 54 </td>
   <td style="text-align:right;"> 4.654 </td>
   <td style="text-align:right;"> 15.17 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:right;"> 2.59 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 139 </td>
   <td style="text-align:right;"> 252 </td>
   <td style="text-align:right;"> 2.51 </td>
   <td style="text-align:right;"> 0.097 </td>
   <td style="text-align:right;"> 0.110 </td>
   <td style="text-align:right;"> 11.3 </td>
   <td style="text-align:right;"> 0.5 </td>
   <td style="text-align:right;"> 0.160 </td>
   <td style="text-align:right;"> 0.170 </td>
   <td style="text-align:right;"> 3.350 </td>
   <td style="text-align:right;"> 0.240 </td>
   <td style="text-align:right;"> 0.240 </td>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:left;"> FAST FOODS,HAMBURGER; DOUBLE,LRG PATTY; W/ CONDMNT &amp; VEG </td>
   <td style="text-align:left;"> 21114 </td>
   <td style="text-align:right;"> -4517.685 </td>
   <td style="text-align:right;"> -0.0459943 </td>
  </tr>
</tbody>
</table>


#### Solve nutrients

This function will let us find what the raw nutrient amounts in our solved menu are, and let us know which nutrient we've overshot the lower bound on the most. Like `solve_menu()`, a result from `solve_it()` can be piped nicely in here.


```r
solve_nutrients <- function(sol, verbose = TRUE) {
  
  solved_nutrient_value <- list(solution_nutrient_value =         # Grab the vector of nutrient values in the solution
                                  sol$auxiliary$primal) %>% as_tibble()
  
  nut_df_small_solved <- sol$necessary_nutrients %>%       # cbind it to the nutrient requirements
    bind_cols(solved_nutrient_value)  %>% 
    rename(
      required_value = value
    ) %>% 
    select(nutrient, is_must_restrict, required_value, solution_nutrient_value)
  
  ratios <- nut_df_small_solved %>%                # Find the solution:required ratios for each nutrient
    mutate(
      ratio = solution_nutrient_value/required_value
    )
  
  max_pos_overshot <- ratios %>%             # Find where we've overshot our positives the most
    filter(is_must_restrict == FALSE) %>% 
    filter(ratio == max(.$ratio))
  
  if (verbose == TRUE) {
    message(paste0("We've overshot the most on ", max_pos_overshot$nutrient %>% as_vector()), 
            ". It's ", 
        max_pos_overshot$ratio %>% round(digits = 2), " times what is needed.")
  }
  
  return(nut_df_small_solved)
}
```


```r
our_solved_nutrients <- our_menu_solution %>% solve_nutrients()
```

```
## We've overshot the most on Protein_g. It's 2.57 times what is needed.
```

```r
our_solved_nutrients %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> nutrient </th>
   <th style="text-align:left;"> is_must_restrict </th>
   <th style="text-align:right;"> required_value </th>
   <th style="text-align:right;"> solution_nutrient_value </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Lipid_Tot_g </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:right;"> 65 </td>
   <td style="text-align:right;"> 91.337680 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sodium_mg </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:right;"> 2400 </td>
   <td style="text-align:right;"> 4269.667000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cholestrl_mg </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:right;"> 300 </td>
   <td style="text-align:right;"> 399.285000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FA_Sat_g </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 38.956894 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Protein_g </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 56 </td>
   <td style="text-align:right;"> 143.787350 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Calcium_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 1000 </td>
   <td style="text-align:right;"> 1019.891500 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iron_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 21.990730 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Magnesium_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 400 </td>
   <td style="text-align:right;"> 432.931500 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Phosphorus_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 1000 </td>
   <td style="text-align:right;"> 2032.328000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Potassium_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 3500 </td>
   <td style="text-align:right;"> 3677.960000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Zinc_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 16.206145 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Copper_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 2.316085 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Manganese_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 3.516592 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Selenium_µg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 70 </td>
   <td style="text-align:right;"> 173.897050 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Vit_C_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:right;"> 70.397550 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Thiamin_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 2.861833 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Riboflavin_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 2.313175 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Niacin_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 34.651609 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Panto_Acid_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 5.334605 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Vit_B6_mg </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 2.381441 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Energ_Kcal </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 2300 </td>
   <td style="text-align:right;"> 2681.570000 </td>
  </tr>
</tbody>
</table>



### Swapping

Single swap


```r
our_random_menu %>% do_single_swap() %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> shorter_desc </th>
   <th style="text-align:right;"> solution_amounts </th>
   <th style="text-align:right;"> GmWt_1 </th>
   <th style="text-align:right;"> serving_gmwt </th>
   <th style="text-align:right;"> cost </th>
   <th style="text-align:right;"> Lipid_Tot_g </th>
   <th style="text-align:right;"> Sodium_mg </th>
   <th style="text-align:right;"> Cholestrl_mg </th>
   <th style="text-align:right;"> FA_Sat_g </th>
   <th style="text-align:right;"> Protein_g </th>
   <th style="text-align:right;"> Calcium_mg </th>
   <th style="text-align:right;"> Iron_mg </th>
   <th style="text-align:right;"> Magnesium_mg </th>
   <th style="text-align:right;"> Phosphorus_mg </th>
   <th style="text-align:right;"> Potassium_mg </th>
   <th style="text-align:right;"> Zinc_mg </th>
   <th style="text-align:right;"> Copper_mg </th>
   <th style="text-align:right;"> Manganese_mg </th>
   <th style="text-align:right;"> Selenium_µg </th>
   <th style="text-align:right;"> Vit_C_mg </th>
   <th style="text-align:right;"> Thiamin_mg </th>
   <th style="text-align:right;"> Riboflavin_mg </th>
   <th style="text-align:right;"> Niacin_mg </th>
   <th style="text-align:right;"> Panto_Acid_mg </th>
   <th style="text-align:right;"> Vit_B6_mg </th>
   <th style="text-align:right;"> Energ_Kcal </th>
   <th style="text-align:left;"> Shrt_Desc </th>
   <th style="text-align:left;"> NDB_No </th>
   <th style="text-align:right;"> score </th>
   <th style="text-align:right;"> scaled_score </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> RUTABAGAS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 170.00 </td>
   <td style="text-align:right;"> 170.00 </td>
   <td style="text-align:right;"> 7.72 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.029 </td>
   <td style="text-align:right;"> 0.93 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:right;"> 216 </td>
   <td style="text-align:right;"> 0.12 </td>
   <td style="text-align:right;"> 0.029 </td>
   <td style="text-align:right;"> 0.097 </td>
   <td style="text-align:right;"> 0.7 </td>
   <td style="text-align:right;"> 18.8 </td>
   <td style="text-align:right;"> 0.082 </td>
   <td style="text-align:right;"> 0.041 </td>
   <td style="text-align:right;"> 0.715 </td>
   <td style="text-align:right;"> 0.155 </td>
   <td style="text-align:right;"> 0.102 </td>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:left;"> RUTABAGAS,CKD,BLD,DRND,WO/SALT </td>
   <td style="text-align:left;"> 11436 </td>
   <td style="text-align:right;"> -2861.039 </td>
   <td style="text-align:right;"> 0.6147894 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SALMON </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 9.02 </td>
   <td style="text-align:right;"> 7.31 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:right;"> 1.644 </td>
   <td style="text-align:right;"> 20.47 </td>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:right;"> 1.06 </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:right;"> 326 </td>
   <td style="text-align:right;"> 377 </td>
   <td style="text-align:right;"> 1.02 </td>
   <td style="text-align:right;"> 0.084 </td>
   <td style="text-align:right;"> 0.030 </td>
   <td style="text-align:right;"> 35.4 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 0.193 </td>
   <td style="text-align:right;"> 5.480 </td>
   <td style="text-align:right;"> 0.550 </td>
   <td style="text-align:right;"> 0.300 </td>
   <td style="text-align:right;"> 153 </td>
   <td style="text-align:left;"> SALMON,SOCKEYE,CND,WO/SALT,DRND SOL W/BONE </td>
   <td style="text-align:left;"> 15182 </td>
   <td style="text-align:right;"> -3913.498 </td>
   <td style="text-align:right;"> 1.1090489 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BROADBEANS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 109.00 </td>
   <td style="text-align:right;"> 109.00 </td>
   <td style="text-align:right;"> 3.93 </td>
   <td style="text-align:right;"> 0.60 </td>
   <td style="text-align:right;"> 50 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.138 </td>
   <td style="text-align:right;"> 5.60 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 1.90 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 95 </td>
   <td style="text-align:right;"> 250 </td>
   <td style="text-align:right;"> 0.58 </td>
   <td style="text-align:right;"> 0.074 </td>
   <td style="text-align:right;"> 0.320 </td>
   <td style="text-align:right;"> 1.2 </td>
   <td style="text-align:right;"> 33.0 </td>
   <td style="text-align:right;"> 0.170 </td>
   <td style="text-align:right;"> 0.110 </td>
   <td style="text-align:right;"> 1.500 </td>
   <td style="text-align:right;"> 0.086 </td>
   <td style="text-align:right;"> 0.038 </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:left;"> BROADBEANS,IMMAT SEEDS,RAW </td>
   <td style="text-align:left;"> 11088 </td>
   <td style="text-align:right;"> -4250.264 </td>
   <td style="text-align:right;"> 0.4652428 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GELATIN DSSRT </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 1.96 </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 466 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 7.80 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0.13 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 141 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 0.01 </td>
   <td style="text-align:right;"> 0.118 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 6.7 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 0.041 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.014 </td>
   <td style="text-align:right;"> 0.001 </td>
   <td style="text-align:right;"> 381 </td>
   <td style="text-align:left;"> GELATIN DSSRT,DRY MIX </td>
   <td style="text-align:left;"> 19172 </td>
   <td style="text-align:right;"> -4938.439 </td>
   <td style="text-align:right;"> -0.8503611 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> COWPEAS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 171.00 </td>
   <td style="text-align:right;"> 171.00 </td>
   <td style="text-align:right;"> 6.26 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 255 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.185 </td>
   <td style="text-align:right;"> 8.13 </td>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:right;"> 3.05 </td>
   <td style="text-align:right;"> 96 </td>
   <td style="text-align:right;"> 142 </td>
   <td style="text-align:right;"> 375 </td>
   <td style="text-align:right;"> 1.87 </td>
   <td style="text-align:right;"> 0.271 </td>
   <td style="text-align:right;"> 0.473 </td>
   <td style="text-align:right;"> 2.5 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 0.162 </td>
   <td style="text-align:right;"> 0.046 </td>
   <td style="text-align:right;"> 0.714 </td>
   <td style="text-align:right;"> 0.386 </td>
   <td style="text-align:right;"> 0.092 </td>
   <td style="text-align:right;"> 117 </td>
   <td style="text-align:left;"> COWPEAS,CATJANG,MATURE SEEDS,CKD,BLD,W/SALT </td>
   <td style="text-align:left;"> 16361 </td>
   <td style="text-align:right;"> -2687.950 </td>
   <td style="text-align:right;"> 0.9456888 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CRACKERS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 30.00 </td>
   <td style="text-align:right;"> 30.00 </td>
   <td style="text-align:right;"> 3.41 </td>
   <td style="text-align:right;"> 11.67 </td>
   <td style="text-align:right;"> 1167 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 3.333 </td>
   <td style="text-align:right;"> 10.00 </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:right;"> 4.80 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 162 </td>
   <td style="text-align:right;"> 141 </td>
   <td style="text-align:right;"> 0.90 </td>
   <td style="text-align:right;"> 0.118 </td>
   <td style="text-align:right;"> 0.517 </td>
   <td style="text-align:right;"> 26.2 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 1.087 </td>
   <td style="text-align:right;"> 0.750 </td>
   <td style="text-align:right;"> 7.170 </td>
   <td style="text-align:right;"> 0.528 </td>
   <td style="text-align:right;"> 0.044 </td>
   <td style="text-align:right;"> 418 </td>
   <td style="text-align:left;"> CRACKERS,CHS,RED FAT </td>
   <td style="text-align:left;"> 18965 </td>
   <td style="text-align:right;"> -4906.367 </td>
   <td style="text-align:right;"> -0.7890484 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PORK </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 8.59 </td>
   <td style="text-align:right;"> 32.93 </td>
   <td style="text-align:right;"> 94 </td>
   <td style="text-align:right;"> 100 </td>
   <td style="text-align:right;"> 11.311 </td>
   <td style="text-align:right;"> 22.83 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 1.15 </td>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> 280 </td>
   <td style="text-align:right;"> 2.58 </td>
   <td style="text-align:right;"> 0.038 </td>
   <td style="text-align:right;"> 0.013 </td>
   <td style="text-align:right;"> 38.0 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.341 </td>
   <td style="text-align:right;"> 0.488 </td>
   <td style="text-align:right;"> 7.522 </td>
   <td style="text-align:right;"> 0.984 </td>
   <td style="text-align:right;"> 0.508 </td>
   <td style="text-align:right;"> 393 </td>
   <td style="text-align:left;"> PORK,GROUND,72% LN / 28% FAT,CKD,CRUMBLES </td>
   <td style="text-align:left;"> 10974 </td>
   <td style="text-align:right;"> -2981.649 </td>
   <td style="text-align:right;"> 0.3842142 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SPICES </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 9.03 </td>
   <td style="text-align:right;"> 4.07 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 2.157 </td>
   <td style="text-align:right;"> 22.98 </td>
   <td style="text-align:right;"> 2240 </td>
   <td style="text-align:right;"> 89.80 </td>
   <td style="text-align:right;"> 711 </td>
   <td style="text-align:right;"> 274 </td>
   <td style="text-align:right;"> 2630 </td>
   <td style="text-align:right;"> 7.10 </td>
   <td style="text-align:right;"> 2.100 </td>
   <td style="text-align:right;"> 9.800 </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:right;"> 0.8 </td>
   <td style="text-align:right;"> 0.080 </td>
   <td style="text-align:right;"> 1.200 </td>
   <td style="text-align:right;"> 4.900 </td>
   <td style="text-align:right;"> 0.838 </td>
   <td style="text-align:right;"> 1.340 </td>
   <td style="text-align:right;"> 233 </td>
   <td style="text-align:left;"> SPICES,BASIL,DRIED </td>
   <td style="text-align:left;"> 02003 </td>
   <td style="text-align:right;"> -4643.583 </td>
   <td style="text-align:right;"> -0.2866766 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> RAVIOLI </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 242.00 </td>
   <td style="text-align:right;"> 242.00 </td>
   <td style="text-align:right;"> 7.63 </td>
   <td style="text-align:right;"> 1.45 </td>
   <td style="text-align:right;"> 306 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0.723 </td>
   <td style="text-align:right;"> 2.48 </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:right;"> 0.74 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 50 </td>
   <td style="text-align:right;"> 232 </td>
   <td style="text-align:right;"> 0.36 </td>
   <td style="text-align:right;"> 0.142 </td>
   <td style="text-align:right;"> 0.176 </td>
   <td style="text-align:right;"> 3.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.074 </td>
   <td style="text-align:right;"> 0.080 </td>
   <td style="text-align:right;"> 1.060 </td>
   <td style="text-align:right;"> 0.272 </td>
   <td style="text-align:right;"> 0.102 </td>
   <td style="text-align:right;"> 77 </td>
   <td style="text-align:left;"> RAVIOLI,CHEESE-FILLED,CND </td>
   <td style="text-align:left;"> 22899 </td>
   <td style="text-align:right;"> -4617.693 </td>
   <td style="text-align:right;"> -0.2371810 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LUXURY LOAF </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.00 </td>
   <td style="text-align:right;"> 28.00 </td>
   <td style="text-align:right;"> 4.64 </td>
   <td style="text-align:right;"> 4.80 </td>
   <td style="text-align:right;"> 1225 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 1.580 </td>
   <td style="text-align:right;"> 18.40 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 1.05 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 185 </td>
   <td style="text-align:right;"> 377 </td>
   <td style="text-align:right;"> 3.05 </td>
   <td style="text-align:right;"> 0.100 </td>
   <td style="text-align:right;"> 0.041 </td>
   <td style="text-align:right;"> 21.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.707 </td>
   <td style="text-align:right;"> 0.297 </td>
   <td style="text-align:right;"> 3.482 </td>
   <td style="text-align:right;"> 0.515 </td>
   <td style="text-align:right;"> 0.310 </td>
   <td style="text-align:right;"> 141 </td>
   <td style="text-align:left;"> LUXURY LOAF,PORK </td>
   <td style="text-align:left;"> 07060 </td>
   <td style="text-align:right;"> -4852.980 </td>
   <td style="text-align:right;"> -0.6869870 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BEVERAGES </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 240.00 </td>
   <td style="text-align:right;"> 240.00 </td>
   <td style="text-align:right;"> 3.77 </td>
   <td style="text-align:right;"> 1.04 </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.000 </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 188 </td>
   <td style="text-align:right;"> 0.30 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 50 </td>
   <td style="text-align:right;"> 0.63 </td>
   <td style="text-align:right;"> 0.017 </td>
   <td style="text-align:right;"> 0.033 </td>
   <td style="text-align:right;"> 0.1 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 0.177 </td>
   <td style="text-align:right;"> 0.075 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.003 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:left;"> BEVERAGES,ALMOND MILK,SWTND,VANILLA FLAVOR,RTD </td>
   <td style="text-align:left;"> 14016 </td>
   <td style="text-align:right;"> -2916.226 </td>
   <td style="text-align:right;"> 0.5092852 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ONIONS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 210.00 </td>
   <td style="text-align:right;"> 210.00 </td>
   <td style="text-align:right;"> 4.83 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.71 </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:right;"> 0.34 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 0.09 </td>
   <td style="text-align:right;"> 0.024 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 5.1 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 0.018 </td>
   <td style="text-align:right;"> 0.132 </td>
   <td style="text-align:right;"> 0.078 </td>
   <td style="text-align:right;"> 0.070 </td>
   <td style="text-align:right;"> 28 </td>
   <td style="text-align:left;"> ONIONS,FRZ,WHL,CKD,BLD,DRND,WO/SALT </td>
   <td style="text-align:left;"> 11290 </td>
   <td style="text-align:right;"> -4397.386 </td>
   <td style="text-align:right;"> 0.1839856 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PIZZA HUT 14&quot; PEPPERONI PIZZA </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 113.00 </td>
   <td style="text-align:right;"> 5.69 </td>
   <td style="text-align:right;"> 13.07 </td>
   <td style="text-align:right;"> 676 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 4.823 </td>
   <td style="text-align:right;"> 11.47 </td>
   <td style="text-align:right;"> 147 </td>
   <td style="text-align:right;"> 2.57 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 187 </td>
   <td style="text-align:right;"> 1.36 </td>
   <td style="text-align:right;"> 0.104 </td>
   <td style="text-align:right;"> 0.425 </td>
   <td style="text-align:right;"> 15.5 </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 0.420 </td>
   <td style="text-align:right;"> 0.210 </td>
   <td style="text-align:right;"> 3.750 </td>
   <td style="text-align:right;"> 0.323 </td>
   <td style="text-align:right;"> 0.090 </td>
   <td style="text-align:right;"> 291 </td>
   <td style="text-align:left;"> PIZZA HUT 14&quot; PEPPERONI PIZZA,PAN CRUST </td>
   <td style="text-align:left;"> 21297 </td>
   <td style="text-align:right;"> -4832.658 </td>
   <td style="text-align:right;"> -0.6481376 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BEANS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 104.00 </td>
   <td style="text-align:right;"> 104.00 </td>
   <td style="text-align:right;"> 8.77 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.085 </td>
   <td style="text-align:right;"> 6.15 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 1.93 </td>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 100 </td>
   <td style="text-align:right;"> 307 </td>
   <td style="text-align:right;"> 0.89 </td>
   <td style="text-align:right;"> 0.356 </td>
   <td style="text-align:right;"> 0.408 </td>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:right;"> 18.8 </td>
   <td style="text-align:right;"> 0.390 </td>
   <td style="text-align:right;"> 0.215 </td>
   <td style="text-align:right;"> 1.220 </td>
   <td style="text-align:right;"> 0.825 </td>
   <td style="text-align:right;"> 0.191 </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:left;"> BEANS,NAVY,MATURE SEEDS,SPROUTED,RAW </td>
   <td style="text-align:left;"> 11046 </td>
   <td style="text-align:right;"> -4122.162 </td>
   <td style="text-align:right;"> 0.7101393 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GRAPE JUC </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 253.00 </td>
   <td style="text-align:right;"> 253.00 </td>
   <td style="text-align:right;"> 4.53 </td>
   <td style="text-align:right;"> 0.13 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.025 </td>
   <td style="text-align:right;"> 0.37 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 0.25 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:right;"> 104 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.018 </td>
   <td style="text-align:right;"> 0.239 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.1 </td>
   <td style="text-align:right;"> 0.017 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 0.133 </td>
   <td style="text-align:right;"> 0.048 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:left;"> GRAPE JUC,CND OR BTLD,UNSWTND,WO/ ADDED VIT C </td>
   <td style="text-align:left;"> 09135 </td>
   <td style="text-align:right;"> -4343.103 </td>
   <td style="text-align:right;"> 0.2877596 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PIE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 1.75 </td>
   <td style="text-align:right;"> 12.50 </td>
   <td style="text-align:right;"> 211 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 3.050 </td>
   <td style="text-align:right;"> 2.40 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 1.12 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 28 </td>
   <td style="text-align:right;"> 79 </td>
   <td style="text-align:right;"> 0.19 </td>
   <td style="text-align:right;"> 0.053 </td>
   <td style="text-align:right;"> 0.185 </td>
   <td style="text-align:right;"> 7.8 </td>
   <td style="text-align:right;"> 1.7 </td>
   <td style="text-align:right;"> 0.148 </td>
   <td style="text-align:right;"> 0.107 </td>
   <td style="text-align:right;"> 1.230 </td>
   <td style="text-align:right;"> 0.093 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:left;"> PIE,APPL,PREP FROM RECIPE </td>
   <td style="text-align:left;"> 18302 </td>
   <td style="text-align:right;"> -4710.654 </td>
   <td style="text-align:right;"> -0.4148992 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PORK </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 2.46 </td>
   <td style="text-align:right;"> 2.59 </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:right;"> 0.906 </td>
   <td style="text-align:right;"> 22.81 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 251 </td>
   <td style="text-align:right;"> 354 </td>
   <td style="text-align:right;"> 1.72 </td>
   <td style="text-align:right;"> 0.069 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 37.4 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.610 </td>
   <td style="text-align:right;"> 0.256 </td>
   <td style="text-align:right;"> 7.348 </td>
   <td style="text-align:right;"> 0.728 </td>
   <td style="text-align:right;"> 0.611 </td>
   <td style="text-align:right;"> 121 </td>
   <td style="text-align:left;"> PORK,FRSH,LOIN,SIRLOIN (CHOPS OR ROASTS),BNLESS,LN,RAW </td>
   <td style="text-align:left;"> 10214 </td>
   <td style="text-align:right;"> -4192.317 </td>
   <td style="text-align:right;"> 0.5760225 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FAST FOODS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 226.00 </td>
   <td style="text-align:right;"> 226.00 </td>
   <td style="text-align:right;"> 5.02 </td>
   <td style="text-align:right;"> 11.75 </td>
   <td style="text-align:right;"> 350 </td>
   <td style="text-align:right;"> 54 </td>
   <td style="text-align:right;"> 4.654 </td>
   <td style="text-align:right;"> 15.17 </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:right;"> 2.59 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 139 </td>
   <td style="text-align:right;"> 252 </td>
   <td style="text-align:right;"> 2.51 </td>
   <td style="text-align:right;"> 0.097 </td>
   <td style="text-align:right;"> 0.110 </td>
   <td style="text-align:right;"> 11.3 </td>
   <td style="text-align:right;"> 0.5 </td>
   <td style="text-align:right;"> 0.160 </td>
   <td style="text-align:right;"> 0.170 </td>
   <td style="text-align:right;"> 3.350 </td>
   <td style="text-align:right;"> 0.240 </td>
   <td style="text-align:right;"> 0.240 </td>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:left;"> FAST FOODS,HAMBURGER; DOUBLE,LRG PATTY; W/ CONDMNT &amp; VEG </td>
   <td style="text-align:left;"> 21114 </td>
   <td style="text-align:right;"> -4517.685 </td>
   <td style="text-align:right;"> -0.0459943 </td>
  </tr>
</tbody>
</table>


Wholesale swap

```r
our_random_menu %>% wholesale_swap() %>% kable(format = "html")
```

```
## Swapping out a random 50% of foods: LUXURY LOAF, CRACKERS, CANDIES, SPICES, PORK, GRAPE JUC, PIE, PIZZA HUT 14" PEPPERONI PIZZA, FAST FOODS
```

```
## Swap candidate is good enough. Doing the wholesale swap.
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> shorter_desc </th>
   <th style="text-align:right;"> solution_amounts </th>
   <th style="text-align:right;"> GmWt_1 </th>
   <th style="text-align:right;"> serving_gmwt </th>
   <th style="text-align:right;"> cost </th>
   <th style="text-align:right;"> Lipid_Tot_g </th>
   <th style="text-align:right;"> Sodium_mg </th>
   <th style="text-align:right;"> Cholestrl_mg </th>
   <th style="text-align:right;"> FA_Sat_g </th>
   <th style="text-align:right;"> Protein_g </th>
   <th style="text-align:right;"> Calcium_mg </th>
   <th style="text-align:right;"> Iron_mg </th>
   <th style="text-align:right;"> Magnesium_mg </th>
   <th style="text-align:right;"> Phosphorus_mg </th>
   <th style="text-align:right;"> Potassium_mg </th>
   <th style="text-align:right;"> Zinc_mg </th>
   <th style="text-align:right;"> Copper_mg </th>
   <th style="text-align:right;"> Manganese_mg </th>
   <th style="text-align:right;"> Selenium_µg </th>
   <th style="text-align:right;"> Vit_C_mg </th>
   <th style="text-align:right;"> Thiamin_mg </th>
   <th style="text-align:right;"> Riboflavin_mg </th>
   <th style="text-align:right;"> Niacin_mg </th>
   <th style="text-align:right;"> Panto_Acid_mg </th>
   <th style="text-align:right;"> Vit_B6_mg </th>
   <th style="text-align:right;"> Energ_Kcal </th>
   <th style="text-align:left;"> Shrt_Desc </th>
   <th style="text-align:left;"> NDB_No </th>
   <th style="text-align:right;"> score </th>
   <th style="text-align:right;"> scaled_score </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> POTATOES </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 245.00 </td>
   <td style="text-align:right;"> 245.00 </td>
   <td style="text-align:right;"> 4.01 </td>
   <td style="text-align:right;"> 3.68 </td>
   <td style="text-align:right;"> 335 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 2.255 </td>
   <td style="text-align:right;"> 2.87 </td>
   <td style="text-align:right;"> 57 </td>
   <td style="text-align:right;"> 0.57 </td>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:right;"> 378 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 0.163 </td>
   <td style="text-align:right;"> 0.166 </td>
   <td style="text-align:right;"> 1.6 </td>
   <td style="text-align:right;"> 10.6 </td>
   <td style="text-align:right;"> 0.069 </td>
   <td style="text-align:right;"> 0.092 </td>
   <td style="text-align:right;"> 1.053 </td>
   <td style="text-align:right;"> 0.514 </td>
   <td style="text-align:right;"> 0.178 </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> POTATOES,SCALLPD,HOME-PREPARED W/BUTTER </td>
   <td style="text-align:left;"> 11372 </td>
   <td style="text-align:right;"> -2927.267 </td>
   <td style="text-align:right;"> 0.4881786 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TURKEY BREAST </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 7.74 </td>
   <td style="text-align:right;"> 3.46 </td>
   <td style="text-align:right;"> 397 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:right;"> 0.980 </td>
   <td style="text-align:right;"> 22.16 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 248 </td>
   <td style="text-align:right;"> 1.53 </td>
   <td style="text-align:right;"> 0.041 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 25.7 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.053 </td>
   <td style="text-align:right;"> 0.133 </td>
   <td style="text-align:right;"> 9.067 </td>
   <td style="text-align:right;"> 0.489 </td>
   <td style="text-align:right;"> 0.320 </td>
   <td style="text-align:right;"> 126 </td>
   <td style="text-align:left;"> TURKEY BREAST,PRE-BASTED,MEAT&amp;SKN,CKD,RSTD </td>
   <td style="text-align:left;"> 05293 </td>
   <td style="text-align:right;"> -3281.581 </td>
   <td style="text-align:right;"> -0.1891749 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SNACKS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 28.35 </td>
   <td style="text-align:right;"> 6.90 </td>
   <td style="text-align:right;"> 49.60 </td>
   <td style="text-align:right;"> 1531 </td>
   <td style="text-align:right;"> 133 </td>
   <td style="text-align:right;"> 20.800 </td>
   <td style="text-align:right;"> 21.50 </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:right;"> 3.40 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:right;"> 257 </td>
   <td style="text-align:right;"> 2.42 </td>
   <td style="text-align:right;"> 0.130 </td>
   <td style="text-align:right;"> 0.086 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 6.8 </td>
   <td style="text-align:right;"> 0.141 </td>
   <td style="text-align:right;"> 0.436 </td>
   <td style="text-align:right;"> 4.540 </td>
   <td style="text-align:right;"> 0.328 </td>
   <td style="text-align:right;"> 0.205 </td>
   <td style="text-align:right;"> 550 </td>
   <td style="text-align:left;"> SNACKS,BF STKS,SMOKED </td>
   <td style="text-align:left;"> 19407 </td>
   <td style="text-align:right;"> -3705.245 </td>
   <td style="text-align:right;"> -0.9991068 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BEEF </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 85.00 </td>
   <td style="text-align:right;"> 8.03 </td>
   <td style="text-align:right;"> 7.67 </td>
   <td style="text-align:right;"> 81 </td>
   <td style="text-align:right;"> 70 </td>
   <td style="text-align:right;"> 3.419 </td>
   <td style="text-align:right;"> 20.87 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 2.31 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:right;"> 195 </td>
   <td style="text-align:right;"> 330 </td>
   <td style="text-align:right;"> 7.86 </td>
   <td style="text-align:right;"> 0.092 </td>
   <td style="text-align:right;"> 0.014 </td>
   <td style="text-align:right;"> 21.9 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.070 </td>
   <td style="text-align:right;"> 0.190 </td>
   <td style="text-align:right;"> 4.097 </td>
   <td style="text-align:right;"> 0.680 </td>
   <td style="text-align:right;"> 0.355 </td>
   <td style="text-align:right;"> 152 </td>
   <td style="text-align:left;"> BEEF,CHUCK EYE COUNTRY-STYLE RIBS,BNLESS,LN,0&quot; FAT,CHOIC,RAW </td>
   <td style="text-align:left;"> 23072 </td>
   <td style="text-align:right;"> -2987.803 </td>
   <td style="text-align:right;"> 0.3724493 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> WHEAT FLR </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 9.73 </td>
   <td style="text-align:right;"> 1.45 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.268 </td>
   <td style="text-align:right;"> 11.50 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 5.06 </td>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:right;"> 112 </td>
   <td style="text-align:right;"> 138 </td>
   <td style="text-align:right;"> 0.84 </td>
   <td style="text-align:right;"> 0.161 </td>
   <td style="text-align:right;"> 0.679 </td>
   <td style="text-align:right;"> 27.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.736 </td>
   <td style="text-align:right;"> 0.445 </td>
   <td style="text-align:right;"> 5.953 </td>
   <td style="text-align:right;"> 0.405 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 363 </td>
   <td style="text-align:left;"> WHEAT FLR,WHITE (INDUSTRIAL),11.5% PROT,UNBLEACHED,ENR </td>
   <td style="text-align:left;"> 20636 </td>
   <td style="text-align:right;"> -3374.000 </td>
   <td style="text-align:right;"> -0.3658548 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> OKARA </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 122.00 </td>
   <td style="text-align:right;"> 122.00 </td>
   <td style="text-align:right;"> 9.38 </td>
   <td style="text-align:right;"> 1.73 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.193 </td>
   <td style="text-align:right;"> 3.52 </td>
   <td style="text-align:right;"> 80 </td>
   <td style="text-align:right;"> 1.30 </td>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:right;"> 213 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 0.200 </td>
   <td style="text-align:right;"> 0.404 </td>
   <td style="text-align:right;"> 10.6 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.020 </td>
   <td style="text-align:right;"> 0.020 </td>
   <td style="text-align:right;"> 0.100 </td>
   <td style="text-align:right;"> 0.088 </td>
   <td style="text-align:right;"> 0.115 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:left;"> OKARA </td>
   <td style="text-align:left;"> 16130 </td>
   <td style="text-align:right;"> -2904.295 </td>
   <td style="text-align:right;"> 0.5320946 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHICKEN </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 140.00 </td>
   <td style="text-align:right;"> 140.00 </td>
   <td style="text-align:right;"> 1.78 </td>
   <td style="text-align:right;"> 13.60 </td>
   <td style="text-align:right;"> 82 </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:right;"> 3.790 </td>
   <td style="text-align:right;"> 27.30 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 1.26 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 182 </td>
   <td style="text-align:right;"> 223 </td>
   <td style="text-align:right;"> 1.94 </td>
   <td style="text-align:right;"> 0.066 </td>
   <td style="text-align:right;"> 0.020 </td>
   <td style="text-align:right;"> 23.9 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.063 </td>
   <td style="text-align:right;"> 0.168 </td>
   <td style="text-align:right;"> 8.487 </td>
   <td style="text-align:right;"> 1.030 </td>
   <td style="text-align:right;"> 0.400 </td>
   <td style="text-align:right;"> 239 </td>
   <td style="text-align:left;"> CHICKEN,BROILERS OR FRYERS,MEAT&amp;SKN,CKD,RSTD </td>
   <td style="text-align:left;"> 05009 </td>
   <td style="text-align:right;"> -2925.658 </td>
   <td style="text-align:right;"> 0.4912538 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FISH </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 6.40 </td>
   <td style="text-align:right;"> 12.95 </td>
   <td style="text-align:right;"> 870 </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:right;"> 2.440 </td>
   <td style="text-align:right;"> 23.19 </td>
   <td style="text-align:right;"> 55 </td>
   <td style="text-align:right;"> 0.55 </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:right;"> 270 </td>
   <td style="text-align:right;"> 390 </td>
   <td style="text-align:right;"> 0.77 </td>
   <td style="text-align:right;"> 0.148 </td>
   <td style="text-align:right;"> 0.037 </td>
   <td style="text-align:right;"> 30.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.043 </td>
   <td style="text-align:right;"> 0.201 </td>
   <td style="text-align:right;"> 8.610 </td>
   <td style="text-align:right;"> 0.822 </td>
   <td style="text-align:right;"> 0.378 </td>
   <td style="text-align:right;"> 209 </td>
   <td style="text-align:left;"> FISH,SALMON,KING,W/ SKN,KIPPERED,(ALASKA NATIVE) </td>
   <td style="text-align:left;"> 35168 </td>
   <td style="text-align:right;"> -3374.000 </td>
   <td style="text-align:right;"> -0.3658548 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KRAFT </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 28.00 </td>
   <td style="text-align:right;"> 28.00 </td>
   <td style="text-align:right;"> 8.07 </td>
   <td style="text-align:right;"> 4.10 </td>
   <td style="text-align:right;"> 1532 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0.800 </td>
   <td style="text-align:right;"> 12.60 </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:right;"> 4.32 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 129 </td>
   <td style="text-align:right;"> 267 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3.3 </td>
   <td style="text-align:right;"> 0.390 </td>
   <td style="text-align:right;"> 0.290 </td>
   <td style="text-align:right;"> 3.840 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 381 </td>
   <td style="text-align:left;"> KRAFT,STOVE TOP STUFFING MIX CHICKEN FLAVOR </td>
   <td style="text-align:left;"> 18567 </td>
   <td style="text-align:right;"> -3670.005 </td>
   <td style="text-align:right;"> -0.9317363 </td>
  </tr>
</tbody>
</table>


### Full Solving


```r
fully_solved <- build_menu() %>% solve_full(verbose = FALSE)
fully_solved %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> shorter_desc </th>
   <th style="text-align:right;"> solution_amounts </th>
   <th style="text-align:right;"> GmWt_1 </th>
   <th style="text-align:right;"> serving_gmwt </th>
   <th style="text-align:right;"> cost </th>
   <th style="text-align:right;"> Lipid_Tot_g </th>
   <th style="text-align:right;"> Sodium_mg </th>
   <th style="text-align:right;"> Cholestrl_mg </th>
   <th style="text-align:right;"> FA_Sat_g </th>
   <th style="text-align:right;"> Protein_g </th>
   <th style="text-align:right;"> Calcium_mg </th>
   <th style="text-align:right;"> Iron_mg </th>
   <th style="text-align:right;"> Magnesium_mg </th>
   <th style="text-align:right;"> Phosphorus_mg </th>
   <th style="text-align:right;"> Potassium_mg </th>
   <th style="text-align:right;"> Zinc_mg </th>
   <th style="text-align:right;"> Copper_mg </th>
   <th style="text-align:right;"> Manganese_mg </th>
   <th style="text-align:right;"> Selenium_µg </th>
   <th style="text-align:right;"> Vit_C_mg </th>
   <th style="text-align:right;"> Thiamin_mg </th>
   <th style="text-align:right;"> Riboflavin_mg </th>
   <th style="text-align:right;"> Niacin_mg </th>
   <th style="text-align:right;"> Panto_Acid_mg </th>
   <th style="text-align:right;"> Vit_B6_mg </th>
   <th style="text-align:right;"> Energ_Kcal </th>
   <th style="text-align:left;"> Shrt_Desc </th>
   <th style="text-align:left;"> NDB_No </th>
   <th style="text-align:right;"> score </th>
   <th style="text-align:right;"> scaled_score </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> LAMB </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 114.00000 </td>
   <td style="text-align:right;"> 114.0 </td>
   <td style="text-align:right;"> 1.540000 </td>
   <td style="text-align:right;"> 4.73 </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 76 </td>
   <td style="text-align:right;"> 1.857 </td>
   <td style="text-align:right;"> 23.42 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 2.27 </td>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:right;"> 210 </td>
   <td style="text-align:right;"> 311 </td>
   <td style="text-align:right;"> 2.32 </td>
   <td style="text-align:right;"> 0.128 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 8.1 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.147 </td>
   <td style="text-align:right;"> 0.380 </td>
   <td style="text-align:right;"> 8.490 </td>
   <td style="text-align:right;"> 0.880 </td>
   <td style="text-align:right;"> 0.556 </td>
   <td style="text-align:right;"> 136 </td>
   <td style="text-align:left;"> LAMB,AUSTRALIAN,IMP,FRSH,TENDERLOIN,BNLESS,LN,1/8&quot; FAT,RAW </td>
   <td style="text-align:left;"> 17443 </td>
   <td style="text-align:right;"> -2872.275 </td>
   <td style="text-align:right;"> 0.5933092 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CHI FORMU </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 31.00000 </td>
   <td style="text-align:right;"> 31.0 </td>
   <td style="text-align:right;"> 8.040000 </td>
   <td style="text-align:right;"> 4.70 </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 1.256 </td>
   <td style="text-align:right;"> 2.80 </td>
   <td style="text-align:right;"> 92 </td>
   <td style="text-align:right;"> 1.32 </td>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:right;"> 80 </td>
   <td style="text-align:right;"> 124 </td>
   <td style="text-align:right;"> 0.56 </td>
   <td style="text-align:right;"> 0.106 </td>
   <td style="text-align:right;"> 0.144 </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:right;"> 9.6 </td>
   <td style="text-align:right;"> 0.256 </td>
   <td style="text-align:right;"> 0.200 </td>
   <td style="text-align:right;"> 0.960 </td>
   <td style="text-align:right;"> 0.960 </td>
   <td style="text-align:right;"> 0.248 </td>
   <td style="text-align:right;"> 99 </td>
   <td style="text-align:left;"> CHI FORMU,ABBT NUTR,PEDIASU,RTF,W/ IRON &amp; FIB (FORMER ROSS) </td>
   <td style="text-align:left;"> 03870 </td>
   <td style="text-align:right;"> -3283.729 </td>
   <td style="text-align:right;"> -0.1932802 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PUMPKIN LEAVES </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 360.87918 </td>
   <td style="text-align:right;"> 39.0 </td>
   <td style="text-align:right;"> 76.987558 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.207 </td>
   <td style="text-align:right;"> 3.15 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 2.22 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 104 </td>
   <td style="text-align:right;"> 436 </td>
   <td style="text-align:right;"> 0.20 </td>
   <td style="text-align:right;"> 0.133 </td>
   <td style="text-align:right;"> 0.355 </td>
   <td style="text-align:right;"> 0.9 </td>
   <td style="text-align:right;"> 11.0 </td>
   <td style="text-align:right;"> 0.094 </td>
   <td style="text-align:right;"> 0.128 </td>
   <td style="text-align:right;"> 0.920 </td>
   <td style="text-align:right;"> 0.042 </td>
   <td style="text-align:right;"> 0.207 </td>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:left;"> PUMPKIN LEAVES,RAW </td>
   <td style="text-align:left;"> 11418 </td>
   <td style="text-align:right;"> -3130.351 </td>
   <td style="text-align:right;"> 0.0999373 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TANGERINES </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2958.09865 </td>
   <td style="text-align:right;"> 252.0 </td>
   <td style="text-align:right;"> 29.111447 </td>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 0.45 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 0.37 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 78 </td>
   <td style="text-align:right;"> 0.24 </td>
   <td style="text-align:right;"> 0.044 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 19.8 </td>
   <td style="text-align:right;"> 0.053 </td>
   <td style="text-align:right;"> 0.044 </td>
   <td style="text-align:right;"> 0.445 </td>
   <td style="text-align:right;"> 0.125 </td>
   <td style="text-align:right;"> 0.042 </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> TANGERINES,(MANDARIN ORANGES),CND,LT SYRUP PK </td>
   <td style="text-align:left;"> 09220 </td>
   <td style="text-align:right;"> -3074.289 </td>
   <td style="text-align:right;"> 0.2071124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CEREALS RTE </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 39.30006 </td>
   <td style="text-align:right;"> 27.0 </td>
   <td style="text-align:right;"> 7.874567 </td>
   <td style="text-align:right;"> 4.50 </td>
   <td style="text-align:right;"> 639 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1.000 </td>
   <td style="text-align:right;"> 8.80 </td>
   <td style="text-align:right;"> 370 </td>
   <td style="text-align:right;"> 16.70 </td>
   <td style="text-align:right;"> 89 </td>
   <td style="text-align:right;"> 222 </td>
   <td style="text-align:right;"> 230 </td>
   <td style="text-align:right;"> 13.90 </td>
   <td style="text-align:right;"> 0.253 </td>
   <td style="text-align:right;"> 2.320 </td>
   <td style="text-align:right;"> 18.5 </td>
   <td style="text-align:right;"> 22.2 </td>
   <td style="text-align:right;"> 1.400 </td>
   <td style="text-align:right;"> 1.600 </td>
   <td style="text-align:right;"> 18.500 </td>
   <td style="text-align:right;"> 0.749 </td>
   <td style="text-align:right;"> 1.852 </td>
   <td style="text-align:right;"> 378 </td>
   <td style="text-align:left;"> CEREALS RTE,GENERAL MILLS,BERRY BURST CHEERIOS,TRIPLE BERRY </td>
   <td style="text-align:left;"> 08239 </td>
   <td style="text-align:right;"> -3273.216 </td>
   <td style="text-align:right;"> -0.1731829 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EGG CUSTARDS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 141.00000 </td>
   <td style="text-align:right;"> 141.0 </td>
   <td style="text-align:right;"> 6.590000 </td>
   <td style="text-align:right;"> 2.83 </td>
   <td style="text-align:right;"> 87 </td>
   <td style="text-align:right;"> 49 </td>
   <td style="text-align:right;"> 1.475 </td>
   <td style="text-align:right;"> 4.13 </td>
   <td style="text-align:right;"> 146 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:right;"> 137 </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 0.61 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 4.9 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:right;"> 0.056 </td>
   <td style="text-align:right;"> 0.235 </td>
   <td style="text-align:right;"> 0.135 </td>
   <td style="text-align:right;"> 0.683 </td>
   <td style="text-align:right;"> 0.066 </td>
   <td style="text-align:right;"> 112 </td>
   <td style="text-align:left;"> EGG CUSTARDS,DRY MIX,PREP W/ 2% MILK </td>
   <td style="text-align:left;"> 19205 </td>
   <td style="text-align:right;"> -2831.054 </td>
   <td style="text-align:right;"> 0.6721117 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PUDDINGS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 140.00000 </td>
   <td style="text-align:right;"> 140.0 </td>
   <td style="text-align:right;"> 4.490000 </td>
   <td style="text-align:right;"> 2.90 </td>
   <td style="text-align:right;"> 156 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 1.643 </td>
   <td style="text-align:right;"> 2.80 </td>
   <td style="text-align:right;"> 99 </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 74 </td>
   <td style="text-align:right;"> 119 </td>
   <td style="text-align:right;"> 0.33 </td>
   <td style="text-align:right;"> 0.025 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 3.3 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.036 </td>
   <td style="text-align:right;"> 0.149 </td>
   <td style="text-align:right;"> 0.078 </td>
   <td style="text-align:right;"> 0.326 </td>
   <td style="text-align:right;"> 0.028 </td>
   <td style="text-align:right;"> 113 </td>
   <td style="text-align:left;"> PUDDINGS,VANILLA,DRY MIX,REG,PREP W/ WHL MILK </td>
   <td style="text-align:left;"> 19207 </td>
   <td style="text-align:right;"> -3179.996 </td>
   <td style="text-align:right;"> 0.0050279 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> INF FORMULA </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 9.60000 </td>
   <td style="text-align:right;"> 9.6 </td>
   <td style="text-align:right;"> 2.430000 </td>
   <td style="text-align:right;"> 27.65 </td>
   <td style="text-align:right;"> 154 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 11.430 </td>
   <td style="text-align:right;"> 15.36 </td>
   <td style="text-align:right;"> 998 </td>
   <td style="text-align:right;"> 10.20 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:right;"> 666 </td>
   <td style="text-align:right;"> 768 </td>
   <td style="text-align:right;"> 3.84 </td>
   <td style="text-align:right;"> 0.461 </td>
   <td style="text-align:right;"> 0.026 </td>
   <td style="text-align:right;"> 9.2 </td>
   <td style="text-align:right;"> 61.0 </td>
   <td style="text-align:right;"> 0.512 </td>
   <td style="text-align:right;"> 0.768 </td>
   <td style="text-align:right;"> 5.376 </td>
   <td style="text-align:right;"> 2.304 </td>
   <td style="text-align:right;"> 0.307 </td>
   <td style="text-align:right;"> 512 </td>
   <td style="text-align:left;"> INF FORMULA, ABB NUTR, SIMIL, GO &amp; GR, PDR, W/ ARA &amp; DHA </td>
   <td style="text-align:left;"> 33871 </td>
   <td style="text-align:right;"> -3144.150 </td>
   <td style="text-align:right;"> 0.0735572 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SEA BASS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 129.00000 </td>
   <td style="text-align:right;"> 129.0 </td>
   <td style="text-align:right;"> 3.960000 </td>
   <td style="text-align:right;"> 2.00 </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:right;"> 0.511 </td>
   <td style="text-align:right;"> 18.43 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 0.29 </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:right;"> 194 </td>
   <td style="text-align:right;"> 256 </td>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:right;"> 0.019 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 36.5 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.110 </td>
   <td style="text-align:right;"> 0.120 </td>
   <td style="text-align:right;"> 1.600 </td>
   <td style="text-align:right;"> 0.750 </td>
   <td style="text-align:right;"> 0.400 </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:left;"> SEA BASS,MXD SP,RAW </td>
   <td style="text-align:left;"> 15091 </td>
   <td style="text-align:right;"> -2795.921 </td>
   <td style="text-align:right;"> 0.7392762 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> WHEAT FLR </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 125.00000 </td>
   <td style="text-align:right;"> 125.0 </td>
   <td style="text-align:right;"> 2.420000 </td>
   <td style="text-align:right;"> 0.98 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.155 </td>
   <td style="text-align:right;"> 10.33 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 1.17 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:right;"> 108 </td>
   <td style="text-align:right;"> 107 </td>
   <td style="text-align:right;"> 0.70 </td>
   <td style="text-align:right;"> 0.144 </td>
   <td style="text-align:right;"> 0.682 </td>
   <td style="text-align:right;"> 33.9 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.120 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 1.250 </td>
   <td style="text-align:right;"> 0.438 </td>
   <td style="text-align:right;"> 0.044 </td>
   <td style="text-align:right;"> 364 </td>
   <td style="text-align:left;"> WHEAT FLR,WHITE,ALL-PURPOSE,UNENR </td>
   <td style="text-align:left;"> 20481 </td>
   <td style="text-align:right;"> -3001.896 </td>
   <td style="text-align:right;"> 0.3455075 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BEANS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 179.00000 </td>
   <td style="text-align:right;"> 179.0 </td>
   <td style="text-align:right;"> 4.840000 </td>
   <td style="text-align:right;"> 0.64 </td>
   <td style="text-align:right;"> 238 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.166 </td>
   <td style="text-align:right;"> 8.97 </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 2.84 </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:right;"> 169 </td>
   <td style="text-align:right;"> 463 </td>
   <td style="text-align:right;"> 1.09 </td>
   <td style="text-align:right;"> 0.149 </td>
   <td style="text-align:right;"> 0.510 </td>
   <td style="text-align:right;"> 1.3 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.236 </td>
   <td style="text-align:right;"> 0.059 </td>
   <td style="text-align:right;"> 0.272 </td>
   <td style="text-align:right;"> 0.251 </td>
   <td style="text-align:right;"> 0.127 </td>
   <td style="text-align:right;"> 142 </td>
   <td style="text-align:left;"> BEANS,SML WHITE,MATURE SEEDS,CKD,BLD,W/SALT </td>
   <td style="text-align:left;"> 16346 </td>
   <td style="text-align:right;"> -2389.504 </td>
   <td style="text-align:right;"> 1.5162376 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MILK </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 245.00000 </td>
   <td style="text-align:right;"> 245.0 </td>
   <td style="text-align:right;"> 7.340000 </td>
   <td style="text-align:right;"> 1.98 </td>
   <td style="text-align:right;"> 59 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 1.232 </td>
   <td style="text-align:right;"> 3.95 </td>
   <td style="text-align:right;"> 143 </td>
   <td style="text-align:right;"> 0.06 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 112 </td>
   <td style="text-align:right;"> 182 </td>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 0.002 </td>
   <td style="text-align:right;"> 2.6 </td>
   <td style="text-align:right;"> 1.1 </td>
   <td style="text-align:right;"> 0.045 </td>
   <td style="text-align:right;"> 0.194 </td>
   <td style="text-align:right;"> 0.101 </td>
   <td style="text-align:right;"> 0.339 </td>
   <td style="text-align:right;"> 0.046 </td>
   <td style="text-align:right;"> 56 </td>
   <td style="text-align:left;"> MILK,RED FAT,FLUID,2% MILKFAT,W/ NONFAT MILK SOL,WO/ VIT A </td>
   <td style="text-align:left;"> 01152 </td>
   <td style="text-align:right;"> -2416.917 </td>
   <td style="text-align:right;"> 1.4638299 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BEANS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 169.00000 </td>
   <td style="text-align:right;"> 169.0 </td>
   <td style="text-align:right;"> 5.520000 </td>
   <td style="text-align:right;"> 0.49 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.126 </td>
   <td style="text-align:right;"> 9.06 </td>
   <td style="text-align:right;"> 52 </td>
   <td style="text-align:right;"> 2.30 </td>
   <td style="text-align:right;"> 65 </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:right;"> 508 </td>
   <td style="text-align:right;"> 0.96 </td>
   <td style="text-align:right;"> 0.271 </td>
   <td style="text-align:right;"> 0.548 </td>
   <td style="text-align:right;"> 1.4 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.257 </td>
   <td style="text-align:right;"> 0.063 </td>
   <td style="text-align:right;"> 0.570 </td>
   <td style="text-align:right;"> 0.299 </td>
   <td style="text-align:right;"> 0.175 </td>
   <td style="text-align:right;"> 149 </td>
   <td style="text-align:left;"> BEANS,PINK,MATURE SEEDS,CKD,BLD,WO/SALT </td>
   <td style="text-align:left;"> 16041 </td>
   <td style="text-align:right;"> -2016.445 </td>
   <td style="text-align:right;"> 2.2294253 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BEEF </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 85.00000 </td>
   <td style="text-align:right;"> 85.0 </td>
   <td style="text-align:right;"> 4.560000 </td>
   <td style="text-align:right;"> 9.04 </td>
   <td style="text-align:right;"> 64 </td>
   <td style="text-align:right;"> 64 </td>
   <td style="text-align:right;"> 3.544 </td>
   <td style="text-align:right;"> 21.22 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 1.96 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 152 </td>
   <td style="text-align:right;"> 275 </td>
   <td style="text-align:right;"> 4.89 </td>
   <td style="text-align:right;"> 0.073 </td>
   <td style="text-align:right;"> 0.073 </td>
   <td style="text-align:right;"> 21.1 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.100 </td>
   <td style="text-align:right;"> 0.269 </td>
   <td style="text-align:right;"> 5.080 </td>
   <td style="text-align:right;"> 0.540 </td>
   <td style="text-align:right;"> 0.488 </td>
   <td style="text-align:right;"> 166 </td>
   <td style="text-align:left;"> BEEF,RIB EYE STK/RST,BONE-IN,LIP-ON,LN,1/8&quot; FAT,ALL GRDS,RAW </td>
   <td style="text-align:left;"> 23150 </td>
   <td style="text-align:right;"> -3057.622 </td>
   <td style="text-align:right;"> 0.2389742 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DESSERTS </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 141.00000 </td>
   <td style="text-align:right;"> 141.0 </td>
   <td style="text-align:right;"> 8.460000 </td>
   <td style="text-align:right;"> 3.43 </td>
   <td style="text-align:right;"> 351 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.685 </td>
   <td style="text-align:right;"> 1.75 </td>
   <td style="text-align:right;"> 35 </td>
   <td style="text-align:right;"> 0.82 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 28 </td>
   <td style="text-align:right;"> 78 </td>
   <td style="text-align:right;"> 0.18 </td>
   <td style="text-align:right;"> 0.071 </td>
   <td style="text-align:right;"> 0.130 </td>
   <td style="text-align:right;"> 3.5 </td>
   <td style="text-align:right;"> 2.2 </td>
   <td style="text-align:right;"> 0.083 </td>
   <td style="text-align:right;"> 0.081 </td>
   <td style="text-align:right;"> 0.846 </td>
   <td style="text-align:right;"> 0.092 </td>
   <td style="text-align:right;"> 0.040 </td>
   <td style="text-align:right;"> 161 </td>
   <td style="text-align:left;"> DESSERTS,APPL CRISP,PREPARED-FROM-RECIPE </td>
   <td style="text-align:left;"> 19186 </td>
   <td style="text-align:right;"> -3650.814 </td>
   <td style="text-align:right;"> -0.8950487 </td>
  </tr>
</tbody>
</table>


### Simulating Solving

Cool, so we've got a mechanism for creating and solving menus. But what portion of our menus are even solvable at a minimum portion size of 1 without doing any swapping? To answer that, I set about making a way to run a some simulations.

First, a helper funciton for just `pluck`ing the status portion of our `solve_it()` response telling us whether we solved the menu or not. The result of `get_status()` should always be either a 1 for unsolvable or 0 for solved. 


```r
get_status <- function(seed = NULL, min_food_amount = 0.5, verbose = TRUE) {  
  this_menu <- build_menu(seed = seed) %>% 
    solve_it(min_food_amount = min_food_amount, verbose = verbose, only_full_servings = FALSE) %>% 
    purrr::pluck("status")
}
```


Now to the simulations: or a given minimum portion size, what proportion of a random number of simulated menus can we solve?

We'll use `map_dbl` to get the status of each solution in our simulation. Then all we need to do is specify a minimum portion size for all menus to have and the number of simulations to run. We'll shuffle the seed at which random menus are built for each simulation and then return a vector of whether each was solved or not.


```r
simulate_menus <- function(n_sims = 10, min_food_amount = 0.5, verbose = FALSE) {
  
  # Choose as many random seeds as we have simulations
  seeds <- sample(1:n_sims, size = n_sims, replace = FALSE)
  
  out <- seeds %>% map2_dbl(.y = min_food_amount, .f = get_status)
  return(out)
}
```



```r
simulate_menus(verbose = FALSE)
```

```
## Cost is $454.63.
```

```
## No optimal solution found :'(
```

```
## Cost is $56.04.
```

```
## No optimal solution found :'(
```

```
## Cost is $56.06.
```

```
## No optimal solution found :'(
```

```
## Cost is $170.53.
```

```
## No optimal solution found :'(
```

```
## Cost is $244.35.
```

```
## No optimal solution found :'(
```

```
## Cost is $98.86.
```

```
## Optimal solution found :)
```

```
## Cost is $133.71.
```

```
## No optimal solution found :'(
```

```
## Cost is $99.43.
```

```
## Optimal solution found :)
```

```
## Cost is $53.44.
```

```
## No optimal solution found :'(
```

```
## Cost is $149.91.
```

```
## Optimal solution found :)
```

```
##  [1] 1 1 1 1 1 0 1 0 1 0
```


Alright so that's kinda useful for a single portion size, but what if we wanted to see how solvability varies as we change up portion size? Presumably as we decrease the lower bound for each food's portion size we'll give ourselves more flexibility and be able to solve a higher proportion of menus. But will the percent of menus that are solvable increase linearly as we decrease portion size? 

I named this next function `simulate_spectrum()` because it allows us to take a lower and an upper bound of minimum portion sizes and see what happens at each point between those two intervals. 

We specify the lower bound for the min portion size spectrum with `from` and the upper bound with `to`. How spaced out those points are and how many of them there are are set with `n_intervals` and `n_sims`; in other words, `n_intervals` is the number of chunks we want to split the spectrum of `from` to `to` into and `n_sims` is the number of times we want to repeat the simulation at each point. 

Instead of a vector, this time we'll return a dataframe in order to be able to match up the minimim portion size (`min_amount`, which we're varying) with whether or not the menu was solvable.


```r
simulate_spectrum <- function(n_intervals = 10, n_sims = 2, from = -1, to = 1,
                              min_food_amount = NULL, verbose = FALSE, ...) {

  interval <- (to - from) / n_intervals
  spectrum <- seq(from = from, to = to, by = interval) %>% rep(n_sims) %>% sort()
  
  seeds <- sample(1:length(spectrum), size = length(spectrum), replace = FALSE)
  
  out_status <- vector(length = length(spectrum))
  
  for (i in seq_along(spectrum)) {
    this_status <- get_status(seed = seeds[i], min_food_amount = spectrum[i], verbose = verbose)
    if (!is.integer(this_status)) {
      this_status <- integer(0)     # If we don't get an integer value back, make it NA
    }
    out_status[i] <- this_status
  }
  
  out <- tibble(min_amount = spectrum, status = out_status)
  
  return(out)
}
```




```r
simulate_spectrum() %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> min_amount </th>
   <th style="text-align:right;"> status </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> -1.0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -1.0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.8 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.8 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.6 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.6 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.2 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.2 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.4 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.8 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.8 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>



# Scraping

I joked with my co-data scientist at Earlybird, Boaz Reisman, that this project so far could fairly be called "Eat, Pray, Barf." The menus we generate start off random and that's bad enough -- then, once we change up portion sizes, the menus only get less appetizing.

I figured the best way to decrease the barf factor was to look through how real menus are structured and try to suss out general patterns or rules in them. For instance, maybe we could learn that usually more than 1/3 of a dish should be dairy, or pork and apples tend to go well together.

I thought allrecipes.com would be likely to live up to its name and provide a good amount of data to work with. After a bit of poking a few recipes to try to discern if there was a pattern in how Allrecipes structures its URLs, I found that that all the recipe URLs followed this basic structure: `http://allrecipes.com/recipe/<ID>/<NAME-OF-RECIPE>/`. Omitting the `<NAME-OF-RECIPE>` parameter seemed to be fine in all cases; `http://allrecipes.com/recipe/<ID>` would redirect you to `http://allrecipes.com/recipe/<ID>/<NAME-OF-RECIPE>/`.

I couldn't figure out much of a pattern behind `ID`s save that they were always all digits and appeared to usually be between 10000 and 200000. (There's probably some pattern I'm missing here but this was good enough to start off with.)

So we know our base URL is going to be `"http://allrecipes.com/recipe/"`.


```r
base_url <- "http://allrecipes.com/recipe/"
```


Then we need to attach IDs to it, so for instance


```r
grab_urls <- function(base_url, id) {
  id <- as.character(id)
  recipe_url <- str_c(base_url, id)
  return(recipe_url)
}

urls <- grab_urls(base_url, 244940:244950)
urls
```

```
##  [1] "http://allrecipes.com/recipe/244940"
##  [2] "http://allrecipes.com/recipe/244941"
##  [3] "http://allrecipes.com/recipe/244942"
##  [4] "http://allrecipes.com/recipe/244943"
##  [5] "http://allrecipes.com/recipe/244944"
##  [6] "http://allrecipes.com/recipe/244945"
##  [7] "http://allrecipes.com/recipe/244946"
##  [8] "http://allrecipes.com/recipe/244947"
##  [9] "http://allrecipes.com/recipe/244948"
## [10] "http://allrecipes.com/recipe/244949"
## [11] "http://allrecipes.com/recipe/244950"
```


Now that we've got URLs to scrape, we'll need to do the actual scraping.

Since we're appending some random numbers to the end of our base URL, there's a good chance some of those pages won't exist. We want a helper function that can try to read HTML on a page if it exists, and if the page doesn't exist, tell us without erroring out and exiting our loop. `purrr::possibly()` will let us do that. It provides a sort of try-catch set up where we try to `read_url()` but if we can't, return "Bad URL" and go on to the next URL.



```r
read_url <- function(url) {
  page <- read_html(url)
}
try_read <- possibly(read_url, otherwise = "Bad URL", quiet = TRUE)
```

`read_html()` from the `xml2` package will return us the raw HTML for a given page. We're only interested in the recipe portion of that, so using the Chrome inspector or the [SelectorGadget Chrome extension](http://selectorgadget.com/) we can figure out what the CSS tag is of the content itself. 

The recipe's name gets the CSS class `.recipe-summary__h1` and the content gets `.checkList__line`. So, we'll pluck everything tagged with those two classes using `html_nodes()` and return text we can use with `html_text()`.


```r
get_recipe_name <- function(page) {
  recipe_name <- page %>% 
    html_nodes(".recipe-summary__h1") %>% 
    html_text() 
  return(recipe_name)
}
```

We'll need an extra couple steps when it comes to recipe content to pare out all the stray garbage left over like `\n` new lines etc.


```r
get_recipe_content <- function(page) {
  recipe <- page %>% 
    html_nodes(".checkList__line") %>% 
    html_text() %>% 
    str_replace_all("ADVERTISEMENT", "") %>% 
    str_replace_all("\n", "") %>% 
    str_replace_all("\r", "") %>% 
    str_replace_all("Add all ingredients to list", "")
  return(recipe)
}
```


Cool, so we've got three functions now, one for reading the content from a URL and turning it into a `page` and two for taking that `page` and grabbing the parts of it that we want We'll use those functions in `get_recipes()` which will take a vector of URLs and return us a list of recipes. We also include parameters for how long to wait in between requests (`sleep`) so as to avoid getting booted from allrecipes.com and whether we want the "Bad URL"s included in our results list or not. If `verbose` is TRUE we'll get a message of count of the number of 404s we had and the number of duped recipes. 


**Note on dupes**

Dupes come up because multiple IDs can point to the same recipe, that is, two different URLs could resolve to the same page. I figured there were two routes we could go to see whether a recipe is a dupe or not; one, just go off of the recipe name or two, go off of the recipe name and content. By going off of the name, we don't go through the trouble of pulling in duped recipe content if we think we've got a dupe; we just skip it. Going off of content and checking whether the recipe content exists in our list so far would be safer (we'd only skip the recipes that we definitely already have), but slower because we have to both `get_recipe_name()` and `get_recipe_content()`. I went with the faster way; in `get_recipes()` we just check the recipe name we're on against all the recipe names in our list with `if (!recipe_name %in% names(out))`.



```r
get_recipes <- function(urls, sleep = 5, verbose = TRUE, append_bad_URLs = TRUE) {
  bad_url_counter <- 0
  duped_recipe_counter <- 0
  
  if (append_bad_URLs == TRUE) {
    out <- vector(length = length(urls))    
  } else {
    out <- NULL       # In this case we don't know how long our list will be 
  }
  
  for (url in urls) {
    Sys.sleep(sleep)    # Sleep in between requests to avoid 429 (too many requests)
    recipe_page <- try_read(url)
  
    if (recipe_page == "Bad URL" ||
       (!class(recipe_page) %in% c("xml_document", "xml_node"))) { 
      recipe_list <- recipe_page    # If we've got a bad URL, recipe_df will be "Bad URL" because of the otherwise clause
      bad_url_counter <- bad_url_counter + 1
      
      if (append_bad_URLs == TRUE) { out <- append(out, recipe_list) }

    } else {
      recipe_name <- get_recipe_name(recipe_page)
      
      if (!recipe_name %in% names(out)) {
        
        if (verbose == TRUE) { message(recipe_name) }
      
        recipe <- recipe_page %>% 
          get_recipe_content() %>% 
          map(remove_whitespace) %>% as_vector()
        
        recipe_list <- list(tmp_name = recipe) %>% as_tibble()  
        names(recipe_list) <- recipe_name
        
        out <- append(out, recipe_list)
        
      } else {
        duped_recipe_counter <- duped_recipe_counter + 1
        if (verbose == TRUE) {
          message("Skipping recipe we already have")
        }
      }
    }
  }
  if (verbose == TRUE) { 
    message(paste0("Number bad URLs: ", bad_url_counter))
    message(paste0("Number duped recipes: ", duped_recipe_counter))
  }
  
  return(out)
}
```


Let's give it a shot with a couple URLs.


```r
# a_couple_recipes <- get_recipes(urls[4:5]) 
a_couple_recipes <- more_recipes_raw[1:2]
a_couple_recipes
```

```
## $`Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza`
## [1] "1 (12 inch) pre-baked pizza crust"                                                    
## [2] "1 1/2 cups shredded mozzarella cheese"                                                
## [3] "1 (14 ounce) jar pizza sauce"                                                         
## [4] "1 (12 ounce) package Johnsonville® Three Cheese Italian Style Chicken Sausage, sliced"
## [5] "1 (3.5 ounce) package sliced pepperoni"                                               
## 
## $`Ginger Fried Rice`
## [1] "3 teaspoons peanut oil, divided"                
## [2] "4 large eggs, beaten"                           
## [3] "1 bunch scallions, chopped"                     
## [4] "2 tablespoons minced fresh ginger"              
## [5] "3 cups cold cooked long-grain brown rice"       
## [6] "1 cup frozen peas"                              
## [7] "1 cup mung bean sprouts (see Note)"             
## [8] "3 tablespoons prepared stir-fry or oyster sauce"
```


Next step is tidying. We want to put this list of recipes into dataframe format with one observation per row and one variable per column. Our rows will contain items in the recipe content, each of which we'll associate with the recipe's name.


```r
dfize <- function(lst, remove_bad_urls = TRUE) {

  df <- NULL
  if (remove_bad_urls == TRUE) {
    lst <- lst[!lst == "Bad URL"]
  }

  for (i in seq_along(lst)) {
    this_df <- lst[i] %>% as_tibble()
    recipe_name <- names(lst[i])
    names(this_df) <- "ingredients"
    this_df <- this_df %>% 
      mutate(recipe_name = recipe_name)
    df <- df %>% bind_rows(this_df)
  }
  return(df)
}
```



```r
a_couple_recipes_df <- dfize(a_couple_recipes)
a_couple_recipes_df %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> ingredients </th>
   <th style="text-align:left;"> recipe_name </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 1 (12 inch) pre-baked pizza crust </td>
   <td style="text-align:left;"> Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 1/2 cups shredded mozzarella cheese </td>
   <td style="text-align:left;"> Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 (14 ounce) jar pizza sauce </td>
   <td style="text-align:left;"> Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 (12 ounce) package Johnsonville® Three Cheese Italian Style Chicken Sausage, sliced </td>
   <td style="text-align:left;"> Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 (3.5 ounce) package sliced pepperoni </td>
   <td style="text-align:left;"> Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 teaspoons peanut oil, divided </td>
   <td style="text-align:left;"> Ginger Fried Rice </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4 large eggs, beaten </td>
   <td style="text-align:left;"> Ginger Fried Rice </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 bunch scallions, chopped </td>
   <td style="text-align:left;"> Ginger Fried Rice </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2 tablespoons minced fresh ginger </td>
   <td style="text-align:left;"> Ginger Fried Rice </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 cups cold cooked long-grain brown rice </td>
   <td style="text-align:left;"> Ginger Fried Rice </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 cup frozen peas </td>
   <td style="text-align:left;"> Ginger Fried Rice </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 cup mung bean sprouts (see Note) </td>
   <td style="text-align:left;"> Ginger Fried Rice </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 tablespoons prepared stir-fry or oyster sauce </td>
   <td style="text-align:left;"> Ginger Fried Rice </td>
  </tr>
</tbody>
</table>


Great, so we've got a tidy dataframe that we can start to get some useful data out of.

One of the goals here is to see what portion of a menu tends to be devoted to, say, meat or spices or a word that appears in the receipe name etc. In order to answer that, we'll need to extract portion names and portion sizes from the text. That wouldn't be pretty simple with a fixed list of portion names ("gram", "lb") if portion sizes were always just a single number.

But, as it happens, protion sizes don't usually consist of just one number. There are a few hurdles: 

1) Complex fractions
* `2 1/3 cups` of flour should become: `2.3333` cups of flour
2) Multiple items of the same item
* `4 (12oz)` bottles of beer should become: 48 oz of beer
3) Ranges
* `6-7` tomatoes should become: `6.5` tomatoes


Here is a fake recipe to illustrate some of those cases. (Certainly falls into Eat, Pray, Barf territory.)


```r
some_recipes_tester %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> ingredients </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 1.2 ounces or maybe pounds of something with a decimal </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 (14 ounce) cans o' beef broth </td>
  </tr>
  <tr>
   <td style="text-align:left;"> around 4 or 5 eels </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5-6 cans spam </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 - 46 tbsp of sugar </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1/3 to 1/2 of a ham </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5 1/2 pounds of apples </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4g cinnamon </td>
  </tr>
  <tr>
   <td style="text-align:left;"> about 17 fluid ounces of wine </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4-5 cans of 1/2 caf coffee </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 7oz figs with 1/3 rind </td>
  </tr>
</tbody>
</table>


Rather than start doing something conditional random field-level smart to get around these problems, to start off I started writing a few rules of thumb.

First, let's consider complex fractions. Off the bat, we know we'll need a way to turn a single fraction into a decimal form. We keep them `as.character` for now and turn them into numeric later down the pipe.


```r
frac_to_dec <- function(e) {
  if (length(e) == 0) {    # If NA because there are no numbers, make the portion 0
    out <- 0
  } else {
    out <- parse(text = e) %>% eval() %>% as.character()
  }
  return(out)
}
```

`eval()`, which is what does the work inside `frac_to_dec)` only only evaluates the last string in a vector, not multiple, so as a workaround I put it into a helper that will turn all fractions into decimal strings:


```r
map_frac_to_dec <- function(e) {
  out <- NULL
  for (i in e) {
    out <- e %>% map_chr(frac_to_dec)
  }
  return(out)
}
```


For example: 

```r
map_frac_to_dec(c("1/2", "1/8", "1/3"))
```

```
## [1] "0.5"               "0.125"             "0.333333333333333"
```


Cool, so for a given ingredient we'll need to look for numbers that are occur next to other numbers, and then and add complex fractions and multiply multiples. 

We'll use this function to look two numbers separated by a " " or a " (". If the second number evaluates to a decimal less than 1, we've got a complex fraction. For example, if we're extracting digits and turning all fractions among them into decimals if we consider "4 1/2 loaves of bread" we'd end up with "4" and "0.5". We know "0.5" is less than 1, so we've got a complex fraction on our hands. We need to add 4 + 0.5 to end up with 4.5 loaves of bread.

It's true that this function doesn't address the issue of having both a complex fraction and multiples in a recipe. That would look like "3 (1 1/2 inch) blocks of cheese." I haven't run into that issue too much but it certainly could use a workaround.


```r
multiply_or_add_portions <- function(e) {
  if (length(e) == 0) {
    e <- 0    
  } else if (length(e) > 1) {
    if (e[2] < 1) {  # If our second element is a fraction, we know this is a complex fraction so we add the two
      e <- e[1:2] %>% reduce(`+`)
    } else {   # Otherwise, we multiply them
      e <- e[1:2] %>% reduce(`*`)
    }   
  }
  return(e)
}
```


```r
multiply_or_add_portions(c(4, 0.5))
```

```
## [1] 4.5
```


```r
multiply_or_add_portions(c(4, 5))
```

```
## [1] 20
```



A few regexs we'll need: 


```r
# Match any number, even if it has a decimal or slash in it
portions_reg <- "[[:digit:]]+\\.*[[:digit:]]*+\\/*[[:digit:]]*"

# Match numbers separated by " (" as in "3 (5 ounce) cans of broth" for multiplying
multiplier_reg <- "[[:digit:]]+ \\(+[[:digit:]]"   

# Match numbers separated by " "
multiplier_reg_looser <- "[0-9]+\ +[0-9]"
```


If we've got something that needs to be multiplied, like "4 (12 oz) hams" or a fraction like "1 2/3 pound of butter",
then multiply or add those numbers as appropriate. The `only_mult_after_paren` parameter is something I put in that is specific to Allrecipes. On Allrecipes, it seems that if we do have multiples, they'll always be of the form "*number_of_things* (*quantity_of_single_thing*)". There are always parentheses around *quantity_of_single_thing*. If we're only using Allrecipes data, that gives us some more security that we're only multiplying quantities that actually should be multiplied. If we want to make this extensible in the future we'd want to set `only_mult_after_paren` to FALSE to account for cases like "7 4oz cans of broth".

This function will allow us to add a new column to our dataframe called `mult_add_portion`. If we've done any multiplying or adding of numbers, we'll have a value greater than 0 there, and 0 otherwise.


```r
get_mult_add_portion <- function(e, only_mult_after_paren = FALSE) {
  if ((str_detect(e, multiplier_reg) == TRUE | str_detect(e, multiplier_reg_looser) == TRUE)
      & only_mult_after_paren == FALSE) {  # If either matches and we don't care about where there's a parenthesis there or not
      if (str_detect(e, multiplier_reg) == TRUE) {
        out <- e %>% str_extract_all(portions_reg) %>% 
          map(map_frac_to_dec) %>%   
          map(as.numeric) %>% 
          map_dbl(multiply_or_add_portions) %>%   
          round(digits = 2)
    } else {    # If we do care, and we have a parenthesis
      out <- e %>% str_extract_all(portions_reg) %>% 
        map(map_frac_to_dec) %>%   
        map(as.numeric) %>% 
        map_dbl(multiply_or_add_portions) %>%   
        round(digits = 2)
    }
  } else {
    out <- 0
  }
  return(out)
}
```




**Ranges**

Finally, ranges. If two numbers are separated by an "or" or a "-" like "4-5 teaspoons of sugar" we know that this is a range. We'll take the average of those two numbers.

We'll add a new column to our dataframe called `range_portion` for the result of any range calculations. If we don't have a range, just like `mult_add_portion`, we set this value to 0.


```r
to_reg <- "([0-9])(( to ))(([0-9]))"
or_reg <- "([0-9])(( or ))(([0-9]))"
dash_reg_1 <- "([0-9])((-))(([0-9]))"
dash_reg_2 <- "([0-9])(( - ))(([0-9]))"
```



```r
get_ranges <- function(e) {
  
  if (determine_if_range(e) == TRUE) {
    out <- str_extract_all(e, portions_reg) %>%  
      
      map(str_split, pattern = " to ", simplify = FALSE) %>%  
      map(str_split, pattern = " - ", simplify = FALSE) %>%  
      map(str_split, pattern = "-", simplify = FALSE) %>%
      
      map(map_frac_to_dec) %>%
      map(as.numeric) %>% 
      map_dbl(get_portion_means) %>% round(digits = 2)
    
  } else {
    out <- 0
  }
  return(out)
}
```


Let's make sure we get the average.


```r
get_ranges("7 to 21 peaches")
```

```
## [1] 14
```



At the end of the day, we want to end up with a single number describing how much of our recipe item we want. So, let's put all that together into one function. Either `range_portion` or `mult_add_portion` will always be 0, so we add them together to get our final portion size. If we neither need to get a range nor multiply or add numbers, we'll just take whatever the first number is in there.



```r
get_portion_values <- function(df, only_mult_after_paren = FALSE) {
  df <- df %>% 
    mutate(
      range_portion = map_dbl(ingredients, get_ranges),
      mult_add_portion = map_dbl(ingredients, get_mult_add_portion, only_mult_after_paren = only_mult_after_paren),
      portion = ifelse(range_portion == 0 & mult_add_portion == 0,
                       str_extract_all(ingredients, portions_reg) %>%
                         map(map_frac_to_dec) %>%
                         map(as.numeric) %>%
                         map_dbl(first),
                       range_portion + mult_add_portion)   # Otherwise, take either the range or the multiplied value
    )
  return(df)
}
```


Let's see what that looks like in practice.



```r
some_recipes_tester %>% get_portion_values() %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> ingredients </th>
   <th style="text-align:right;"> range_portion </th>
   <th style="text-align:right;"> mult_add_portion </th>
   <th style="text-align:right;"> portion </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 1.2 ounces or maybe pounds of something with a decimal </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 1.20 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 (14 ounce) cans o' beef broth </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 42.0 </td>
   <td style="text-align:right;"> 42.00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> around 4 or 5 eels </td>
   <td style="text-align:right;"> 4.50 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 4.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5-6 cans spam </td>
   <td style="text-align:right;"> 5.50 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 5.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 - 46 tbsp of sugar </td>
   <td style="text-align:right;"> 28.50 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 28.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1/3 to 1/2 of a ham </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 0.42 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5 1/2 pounds of apples </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 5.5 </td>
   <td style="text-align:right;"> 5.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4g cinnamon </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 4.00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> about 17 fluid ounces of wine </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 17.00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4-5 cans of 1/2 caf coffee </td>
   <td style="text-align:right;"> 4.50 </td>
   <td style="text-align:right;"> 0.0 </td>
   <td style="text-align:right;"> 4.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 7oz figs with 1/3 rind </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 21.0 </td>
   <td style="text-align:right;"> 21.00 </td>
  </tr>
</tbody>
</table>

Looks pretty solid.

Now onto easier waters: portion names. You can check out `/scripts/scrape/get_measurement_types.R` if you're interested in the steps I took to find some usual portion names and create an abbreviation dictionary, `abbrev_dict`. What we also do there is create `measures_collapsed` which is a single vector of all portion names separated by "|" so we can find all the portion names that might occur in a given item.


```r
measures_collapsed
```

```
## [1] "[[:digit:]]oz |[[:digit:]]pt |[[:digit:]]lb |[[:digit:]]kg |[[:digit:]]g |[[:digit:]]l |[[:digit:]]dl |[[:digit:]]ml |[[:digit:]] oz |[[:digit:]] pt |[[:digit:]] lb |[[:digit:]] kg |[[:digit:]] g |[[:digit:]] l |[[:digit:]] dl |[[:digit:]] ml |ounce|pint|pound|kilogram|gram|liter|deciliter|milliliter"
```

Then if there are multiple portions that match, we'll take the last one.

We'll also add `approximate` to our dataframe which is just a boolean value indicating whether this item is exact or approximate. If the item contains one of `approximate` (about ,around ,as desired ,as needed ,optional ,or so ,to taste) then we give it a TRUE.


```r
str_detect("8 or so cloves of garlic", approximate)
```

```
## [1] TRUE
```


```r
str_detect("8 cloves of garlic", approximate)
```

```
## [1] FALSE
```




```r
get_portion_text <- function(df) {
  
  df <- df %>% 
    mutate(
      raw_portion_num = str_extract_all(ingredients, portions_reg, simplify = FALSE) %>%   # Extract the raw portion numbers,
        map_chr(str_c, collapse = ", ", default = ""),   # separating by comma if multiple
      
      portion_name = str_extract_all(ingredients, measures_collapsed) %>%
        map(nix_nas) %>%  
        str_extract_all("[a-z]+") %>% 
        map(nix_nas) %>%   # Get rid of numbers
        map_chr(last),       # If there are multiple arguments that match, grab the last one

      approximate = str_detect(ingredients, approximate)
    )
  return(df)
}
```


Last thing for us for now on this subject (though there's a lot more to do here!) will be to add abbreviations. This will let us standardize things like "ounces" and "oz" which actually refer to the same thing. 

All `add_abbrevs()` will do is let us mutate our dataframe with a new column for the abbreviation of our portion size, if we've got a recognized portion size.


```r
add_abbrevs <- function(df) {

  out <- vector(length = nrow(df))
  for (i in seq_along(out)) {
    if (df$portion_name[i] %in% abbrev_dict$name) {
      out[i] <- abbrev_dict[which(abbrev_dict$name == df$portion_name[i]), ]$key
      
    } else {
      out[i] <- df$portion_name[i]
    }
  }
  
  out <- df %>% bind_cols(list(portion_abbrev = out) %>% as_tibble())
  return(out)
}
```


All together now. Get the portion text and values. If we only want our best guess as to the portion size, that is, `final_portion_size`, we'll chuck `range_portion` and `mult_add_portion`.


```r
get_portions <- function(df, add_abbrevs = FALSE, pare_portion_info = FALSE) {
  df %<>% get_portion_text() 
  if (add_abbrevs == TRUE) {
    df %<>% add_abbrevs()
  }
  df %<>% get_portion_values()
  if (pare_portion_info == TRUE) {
    df %<>% select(-range_portion, -mult_add_portion)
  }
  return(df)
}
```



```r
some_recipes_tester %>% get_portions(pare_portion_info = TRUE) %>% add_abbrevs() %>% kable(format = "html")
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> ingredients </th>
   <th style="text-align:left;"> raw_portion_num </th>
   <th style="text-align:left;"> portion_name </th>
   <th style="text-align:left;"> approximate </th>
   <th style="text-align:right;"> portion </th>
   <th style="text-align:left;"> portion_abbrev </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 1.2 ounces or maybe pounds of something with a decimal </td>
   <td style="text-align:left;"> 1.2 </td>
   <td style="text-align:left;"> pound </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 1.20 </td>
   <td style="text-align:left;"> lb </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 (14 ounce) cans o' beef broth </td>
   <td style="text-align:left;"> 3, 14 </td>
   <td style="text-align:left;"> ounce </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 42.00 </td>
   <td style="text-align:left;"> oz </td>
  </tr>
  <tr>
   <td style="text-align:left;"> around 4 or 5 eels </td>
   <td style="text-align:left;"> 4, 5 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:right;"> 4.50 </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5-6 cans spam </td>
   <td style="text-align:left;"> 5, 6 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 5.50 </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 11 - 46 tbsp of sugar </td>
   <td style="text-align:left;"> 11, 46 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 28.50 </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1/3 to 1/2 of a ham </td>
   <td style="text-align:left;"> 1/3, 1/2 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 0.42 </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5 1/2 pounds of apples </td>
   <td style="text-align:left;"> 5, 1/2 </td>
   <td style="text-align:left;"> pound </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 5.50 </td>
   <td style="text-align:left;"> lb </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4g cinnamon </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> g </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 4.00 </td>
   <td style="text-align:left;"> g </td>
  </tr>
  <tr>
   <td style="text-align:left;"> about 17 fluid ounces of wine </td>
   <td style="text-align:left;"> 17 </td>
   <td style="text-align:left;"> ounce </td>
   <td style="text-align:left;"> TRUE </td>
   <td style="text-align:right;"> 17.00 </td>
   <td style="text-align:left;"> oz </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4-5 cans of 1/2 caf coffee </td>
   <td style="text-align:left;"> 4, 5, 1/2 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 4.50 </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 7oz figs with 1/3 rind </td>
   <td style="text-align:left;"> 3, 7, 1/3 </td>
   <td style="text-align:left;"> oz </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:right;"> 21.00 </td>
   <td style="text-align:left;"> oz </td>
  </tr>
</tbody>
</table>


We've got some units! Next step will be to convert all units into grams. 

## NLP



```r
# Get a dataframe of all units (need plurals for abbrev_dict ones)
all_units <- c(units, abbrev_dict$name, abbrev_dict$key, "inch")
all_units_df <- list(word = all_units) %>% as_tibble()


# Get a sample (can't be random because we need foods that come from the same menus) and 
# unnest words
grab_words <- function(df, row_start = 1, row_stop = 100, n_grams = 1) {
  df <- df %>% 
    slice(row_start:row_stop) %>% 
    group_by(recipe_name) %>% 
    mutate(ingredient_num = row_number()) %>% 
    ungroup() %>% 
    unnest_tokens(word, ingredients, token = "ngrams", n = n_grams) %>% 
    select(recipe_name, word, everything())
  
  return(df)
}

unigrams <- grab_words(more_recipes_df)
bigrams <- grab_words(more_recipes_df, n_grams = 2)


# Logical for whether an word is a number or not
# we could have as easily done this w a regex
find_nums <- function(df) {
  df <- df %>% mutate(
    num = suppressWarnings(as.numeric(word)),    # we could have as easily done this w a regex
    is_num = case_when(
      !is.na(num) ~ TRUE,
      is.na(num) ~ FALSE
    )
  ) %>% select(-num)
  
  return(df)
}

# Filter out numbers
unigrams <- unigrams %>%
  find_nums() %>%
  filter(is_num == FALSE) %>% 
  select(-is_num)


# Looking at pairs of words within a recipe (not neccessarily bigrams), which paris tend to co-occur?
# i.e., higher frequency within the same recipe
per_rec_freq <- unigrams %>% 
  anti_join(stop_words) %>% 
  anti_join(all_units_df) %>% 
  group_by(recipe_name) %>% 
  add_count(word, sort = TRUE) %>%    # Count of number of times this word appears in this recipe
  rename(n_this_rec = n) %>% 
  ungroup() %>% 
  add_count(word, sort = TRUE) %>%    # Count of number of times this word appears in all recipes
  rename(n_all_rec = n) %>%
  select(recipe_name, word, n_this_rec, n_all_rec)
```

```
## Joining, by = "word"
## Joining, by = "word"
```

```r
# Get the total number of words per recipe
per_rec_totals <- per_rec_freq %>% 
  group_by(recipe_name) %>%
  summarise(total_this_recipe = sum(n_this_rec))

# Get the total number of times a word is used across all the recipes
all_rec_totals <- per_rec_freq %>% 
  ungroup() %>% 
  summarise(total_this_recipe = sum(n_this_rec))
  
# Join that on the sums we've found
per_rec_freq_out <- per_rec_freq %>% 
  mutate(
    total_overall = sum(n_this_rec)
  ) %>% 
  left_join(per_rec_totals) %>% 
  left_join(all_rec_totals)
```

```
## Joining, by = "recipe_name"
```

```
## Joining, by = "total_this_recipe"
```

```r
# See tfidf
per_rec_freq %>% 
  bind_tf_idf(word, recipe_name, n_this_rec) %>% 
  arrange(desc(tf_idf))
```

```
## # A tibble: 260 x 7
##                    recipe_name         word n_this_rec n_all_rec
##                          <chr>        <chr>      <int>     <int>
##  1 Tangy Cream Cheese Frosting       sifted          1         1
##  2 Tangy Cream Cheese Frosting philadelphia          1         1
##  3 Tangy Cream Cheese Frosting        greek          1         1
##  4         Blueberry Turnovers     crescent          1         1
##  5         Blueberry Turnovers        rolls          1         1
##  6         Blueberry Turnovers  blueberries          1         1
##  7         Blueberry Turnovers     frosting          1         1
##  8 Tangy Cream Cheese Frosting        cream          1         2
##  9 Tangy Cream Cheese Frosting       yogurt          1         2
## 10         Honey-Dijon Chicken        dijon          1         1
## # ... with 250 more rows, and 3 more variables: tf <dbl>, idf <dbl>,
## #   tf_idf <dbl>
```

```r
# --------- Pairwise ---------

# Get the pairwise correlation between words in each recipe
pairwise_per_rec <- per_rec_freq %>% 
  group_by(recipe_name) %>%      # <---- Not sure if we should be grouping here
  pairwise_cor(word, recipe_name, sort = TRUE) 

# Graph the correlations between a few words and their highest correlated neighbors
pairwise_per_rec %>%
  filter(item1 %in% c("cheese", "garlic", "onion", "sugar")) %>% 
  filter(correlation > .5) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = correlation), show.legend = FALSE) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), repel = TRUE) +
  theme_void()
```

![](writeup_files/figure-html/unnamed-chunk-4-1.png)<!-- -->






[^1]: If we tried to unnest this right now we'd get an error. 

```r
foods %>% unnest()
```


That's because missing values are coded as `--`. That's an issue for two of these columns, `gm` and `value`, which get coded as numeric if there are no mising values and character otherwise. 

Since a single column in a dataframe can only have values of one type, before unnesting our `nutrients` list column, we'll want to make sure all values of `gm` and `value` are of the same type across all rows. 

I'm sure there's a more elegant `purrr` solution or a better way to set types when we're taking our list to tibble, but a quick and dirty fix here is to go through and make sure these values are all character.


```r
for (i in 1:length(foods$nutrients)) {
  for (j in 1:nrow(foods$nutrients[[1]])) {
    foods$nutrients[[i]]$gm[j] <- as.character(foods$nutrients[[i]]$gm[j])
    foods$nutrients[[i]]$value[j] <- as.character(foods$nutrients[[i]]$value[j])
  }
}
```


```r
# unnest it
foods <- foods %>% unnest()
```
