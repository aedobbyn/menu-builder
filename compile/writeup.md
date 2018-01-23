# All things Menus




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


```r
# some_recipes_df <- read_feather("./data/derived/some_recipes_df.feather")
status_spectrum <- read_feather("./data/derived/status_spectrum.feather")
rec_spectrum <- read_feather("./data/derived/rec_spectrum.feather")
more_recipes_df <- read_feather("./data/derived/more_recipes_df.feather")
```


## Creating and Solving Menus

#### Building

Build random menu

```r
our_random_menu <- build_menu()
```


#### Scoring


```r
our_random_menu %>% score_menu()
```

```
## [1] -2570.775
```


#### Solving

Get Solution

```r
our_menu_solution <- our_random_menu %>% solve_it()
```

```
## Cost is $168.59.
```

```
## No optimal solution found :'(
```


Solve menu

```r
our_solved_menu <- our_menu_solution %>% solve_menu()
```

```
## We've got a lot of SPICES. 8.37 servings of them.
```


Solve nutrients

```r
our_solved_nutrients <- our_menu_solution %>% solve_nutrients()
```

```
## We've overshot the most on Selenium_µg. It's 2.32 times what is needed.
```



#### Swapping

Single swap

```r
our_random_menu %>% smart_swap_single()
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 80.36758
```

```
## The worst offender in this respect is CANDIES,HERSHEY'S,ALMOND JOY BITES
```

```
## Replacing the max offender with: BEANS,BLACK TURTLE,MATURE SEEDS,CND
```

```
## Our new value of this must restrict is 67.26358
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4235.127
```

```
## The worst offender in this respect is CHEESE,ROQUEFORT
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CAVIAR,BLACK&RED,GRANULAR
```

```
## Our new value of this must restrict is 3962.2755
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 407.71
```

```
## The worst offender in this respect is CAVIAR,BLACK&RED,GRANULAR
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CHICKEN,BROILERS OR FRYERS,NECK,MEAT&SKN,CKD SIMMRD
```

```
## Our new value of this must restrict is 321.33
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 21.954694
```

```
## The worst offender in this respect is CANDIES,SEMISWEET CHOC
```

```
## Replacing the max offender with: PASTA,WHOLE-WHEAT,CKD
```

```
## Our new value of this must restrict is 19.665254
```

```
## # A tibble: 18 x 30
##                        shorter_desc solution_amounts GmWt_1 serving_gmwt
##                               <chr>            <dbl>  <dbl>        <dbl>
##  1                             LAMB                1  85.00        85.00
##  2                            BEANS                1 240.00       240.00
##  3                           SALMON                1  85.00        85.00
##  4                       BROADBEANS                1 109.00       109.00
##  5                    GELATIN DSSRT                1  85.00        85.00
##  6                         CRAYFISH                1  85.00        85.00
##  7                         CRACKERS                1  14.00        14.00
##  8                          CHICKEN                1  11.00        11.00
##  9                           SPICES                1   0.70         0.70
## 10                          RAVIOLI                1 242.00       242.00
## 11                      LUXURY LOAF                1  28.00        28.00
## 12                            PASTA                1 117.00       117.00
## 13                           ONIONS                1 210.00       210.00
## 14 "PIZZA HUT 14\" PEPPERONI PIZZA"                1 113.00       113.00
## 15                            BEANS                1 104.00       104.00
## 16                        GRAPE JUC                1 253.00       253.00
## 17                              PIE                1  28.35        28.35
## 18                             PORK                1  85.00        85.00
## # ... with 26 more variables: cost <dbl>, Lipid_Tot_g <dbl>,
## #   Sodium_mg <dbl>, Cholestrl_mg <dbl>, FA_Sat_g <dbl>, Protein_g <dbl>,
## #   Calcium_mg <dbl>, Iron_mg <dbl>, Magnesium_mg <dbl>,
## #   Phosphorus_mg <dbl>, Potassium_mg <dbl>, Zinc_mg <dbl>,
## #   Copper_mg <dbl>, Manganese_mg <dbl>, Selenium_µg <dbl>,
## #   Vit_C_mg <dbl>, Thiamin_mg <dbl>, Riboflavin_mg <dbl>,
## #   Niacin_mg <dbl>, Panto_Acid_mg <dbl>, Vit_B6_mg <dbl>,
## #   Energ_Kcal <dbl>, Shrt_Desc <chr>, NDB_No <chr>, score <dbl>,
## #   scaled_score <dbl>
```


Wholesale swap

```r
our_random_menu %>% wholesale_swap()
```

```
## Swapping out a random 50% of foods: ONIONS, LUXURY LOAF, LAMB, CRAYFISH, BROADBEANS, SALMON, RAVIOLI, SPICES, BEANS
```

```
## Swap candidate not good enough; reswapping.
```

```
## Replacing with: CEREALS RTE, CHICKEN, SOUP, INF FORMULA, Frankfurter, GAME MEAT, BEEF, CHEESECAKE COMMLY PREP, BEEF
```

```
## # A tibble: 27 x 30
##     shorter_desc solution_amounts GmWt_1 serving_gmwt  cost Lipid_Tot_g
##            <chr>            <dbl>  <dbl>        <dbl> <dbl>       <dbl>
##  1          LAMB                1  85.00        85.00  6.35       20.94
##  2       CANDIES                1  40.00        40.00  2.24       34.50
##  3        SALMON                1  85.00        85.00  9.02        7.31
##  4    BROADBEANS                1 109.00       109.00  3.93        0.60
##  5 GELATIN DSSRT                1  85.00        85.00  1.96        0.00
##  6      CRAYFISH                1  85.00        85.00  7.81        0.95
##  7      CRACKERS                1  14.00        14.00  4.19       10.71
##  8        CHEESE                1  28.35        28.35  7.25       30.64
##  9        SPICES                1   0.70         0.70  9.03        4.07
## 10       RAVIOLI                1 242.00       242.00  7.63        1.45
## # ... with 17 more rows, and 24 more variables: Sodium_mg <dbl>,
## #   Cholestrl_mg <dbl>, FA_Sat_g <dbl>, Protein_g <dbl>, Calcium_mg <dbl>,
## #   Iron_mg <dbl>, Magnesium_mg <dbl>, Phosphorus_mg <dbl>,
## #   Potassium_mg <dbl>, Zinc_mg <dbl>, Copper_mg <dbl>,
## #   Manganese_mg <dbl>, Selenium_µg <dbl>, Vit_C_mg <dbl>,
## #   Thiamin_mg <dbl>, Riboflavin_mg <dbl>, Niacin_mg <dbl>,
## #   Panto_Acid_mg <dbl>, Vit_B6_mg <dbl>, Energ_Kcal <dbl>,
## #   Shrt_Desc <chr>, NDB_No <chr>, score <dbl>, scaled_score <dbl>
```


#### Full Solving


```r
build_menu() %>% solve_full()
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 109.99305
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## Replacing the max offender with: COD,ATLANTIC,CKD,DRY HEAT
```

```
## Our new value of this must restrict is 109.35705
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4454.2035
```

```
## The worst offender in this respect is BEEF,CURED,CORNED BF,BRISKET,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,SHLDR TOP BLDE STK,BNS,LN & FAT,0" FAT,CHOIC,CKD,G
```

```
## Our new value of this must restrict is 4180.584
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 861.54
```

```
## The worst offender in this respect is BEEF,NZ,IMP,VAR MEATS & BY-PRODUCTS,LIVER,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CANDIES,ROLO CARAMELS IN MILK CHOC
```

```
## Our new value of this must restrict is 580.28
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 59.898697
```

```
## The worst offender in this respect is CANDIES,ROLO CARAMELS IN MILK CHOC
```

```
## Replacing the max offender with: RASPBERRIES,CND,RED,HVY SYRUP PK,SOL&LIQUIDS
```

```
## Our new value of this must restrict is 52.931337
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 109.99305
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## Replacing the max offender with: TURNIP GRNS&TURNIPS,FRZ,UNPREP
```

```
## Our new value of this must restrict is 108.80655
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4405.0035
```

```
## The worst offender in this respect is BEEF,CURED,CORNED BF,BRISKET,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,NZ,IMP,BRISKET POINT END,LN & FAT,CKD,BRSD
```

```
## Our new value of this must restrict is 4084.634
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 814.79
```

```
## The worst offender in this respect is BEEF,NZ,IMP,VAR MEATS & BY-PRODUCTS,LIVER,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,CHK EYE COUNTRY-STYLE RIBS,BNLS,LN,0" FAT,ALL GRDS, RAW
```

```
## Our new value of this must restrict is 587.27
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 55.235437
```

```
## The worst offender in this respect is CINNAMON BUNS,FRSTD (INCLUDES HONEY BUNS)
```

```
## Replacing the max offender with: PLUMS,DRIED (PRUNES),UNCKD
```

```
## Our new value of this must restrict is 47.166707
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 109.99305
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## Replacing the max offender with: CEREALS,CORN GRITS,YEL,REG & QUICK,UNENR,DRY
```

```
## Our new value of this must restrict is 108.74245
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4388.0005
```

```
## The worst offender in this respect is BEEF,CURED,CORNED BF,BRISKET,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BREAD,IRISH SODA,PREP FROM RECIPE
```

```
## Our new value of this must restrict is 4155.814
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 741.693
```

```
## The worst offender in this respect is BEEF,NZ,IMP,VAR MEATS & BY-PRODUCTS,LIVER,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CRAYFISH,MXD SP,FARMED,CKD,MOIST HEAT
```

```
## Our new value of this must restrict is 571.123
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 49.0665405
```

```
## The worst offender in this respect is CINNAMON BUNS,FRSTD (INCLUDES HONEY BUNS)
```

```
## Replacing the max offender with: CEREALS,WHEATENA,CKD W/ H2O,W/ SALT
```

```
## Our new value of this must restrict is 41.0658205
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 109.99305
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## Replacing the max offender with: CORN,SWT,WHITE,CKD,BLD,DRND,W/SALT
```

```
## Our new value of this must restrict is 109.88095
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4613.0735
```

```
## The worst offender in this respect is BEEF,CURED,CORNED BF,BRISKET,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: COOKIES,RAISIN,SOFT-TYPE
```

```
## Our new value of this must restrict is 4386.557
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 737.157
```

```
## The worst offender in this respect is BEEF,NZ,IMP,VAR MEATS & BY-PRODUCTS,LIVER,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: VEAL,SHLDR,WHL (ARM&BLD),LN&FAT,RAW
```

```
## Our new value of this must restrict is 474.8015
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 50.290352
```

```
## The worst offender in this respect is CINNAMON BUNS,FRSTD (INCLUDES HONEY BUNS)
```

```
## Replacing the max offender with: BEANS,BLACK,MATURE SEEDS,CND,LO NA
```

```
## Our new value of this must restrict is 42.248502
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 109.99305
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## Replacing the max offender with: BEVERAGES,CHOC MALT,PDR,PREP W/ FAT FREE MILK
```

```
## Our new value of this must restrict is 109.06125
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4585.0235
```

```
## The worst offender in this respect is BEEF,CURED,CORNED BF,BRISKET,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CANDIES,CAROB,UNSWTND
```

```
## Our new value of this must restrict is 4270.3385
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 741.9935
```

```
## The worst offender in this respect is BEEF,NZ,IMP,VAR MEATS & BY-PRODUCTS,LIVER,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: OKRA,FRZ,CKD,BLD,DRND,W/ SALT
```

```
## Our new value of this must restrict is 454.9735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 57.12422
```

```
## The worst offender in this respect is CANDIES,CAROB,UNSWTND
```

```
## Replacing the max offender with: LEEKS,(BULB&LOWER-LEAF PORTION),FREEZE-DRIED
```

```
## Our new value of this must restrict is 48.898175
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 109.99305
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## Replacing the max offender with: RESTAURANT,CHINESE,CHICK CHOW MEIN
```

```
## Our new value of this must restrict is 125.53805
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 6266.3435
```

```
## The worst offender in this respect is BEEF,CURED,CORNED BF,BRISKET,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: SOUP,CHICK MUSHROOM,CND,COND
```

```
## Our new value of this must restrict is 6750.884
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 843.15
```

```
## The worst offender in this respect is BEEF,NZ,IMP,VAR MEATS & BY-PRODUCTS,LIVER,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,TOP SIRLOIN,STEAK,LN & FAT,0" FAT,CHOIC,CKD,BRLD
```

```
## Our new value of this must restrict is 631.78
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 56.534077
```

```
## The worst offender in this respect is CINNAMON BUNS,FRSTD (INCLUDES HONEY BUNS)
```

```
## Replacing the max offender with: BEVERAGES,COFFEE,INST,W/ CHICORY
```

```
## Our new value of this must restrict is 48.313505
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 109.99305
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## Replacing the max offender with: PASTA,CKD,UNENR,WO/ ADDED SALT
```

```
## Our new value of this must restrict is 109.77925
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4389.1435
```

```
## The worst offender in this respect is BEEF,CURED,CORNED BF,BRISKET,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PORK,CURED,HAM -- H2O ADDED,WHL,BNLESS,LN & FAT,UNHTD
```

```
## Our new value of this must restrict is 4363.345
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 750.765
```

```
## The worst offender in this respect is BEEF,NZ,IMP,VAR MEATS & BY-PRODUCTS,LIVER,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,RND,BTTM RND,STEAK,LN,0" FAT,CHOIC,CKD,BRSD
```

```
## Our new value of this must restrict is 544.495
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 51.9859085
```

```
## The worst offender in this respect is CINNAMON BUNS,FRSTD (INCLUDES HONEY BUNS)
```

```
## Replacing the max offender with: BEVERAGES,GRAPE DRK,CND
```

```
## Our new value of this must restrict is 43.7640585
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 109.99305
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## Replacing the max offender with: SQUASH,WINTER,ACORN,RAW
```

```
## Our new value of this must restrict is 108.76605
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4392.1035
```

```
## The worst offender in this respect is BEEF,CURED,CORNED BF,BRISKET,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PORK,FRSH,VAR MEATS&BY-PRODUCTS,BRAIN,CKD,BRSD
```

```
## Our new value of this must restrict is 4124.434
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 2905.79
```

```
## The worst offender in this respect is PORK,FRSH,VAR MEATS&BY-PRODUCTS,BRAIN,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: TURKEY,RTL PARTS,BREAST,MEAT ONLY,W/ ADDED SOLN,CKD,RSTD
```

```
## Our new value of this must restrict is 799.49
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 50.285187
```

```
## The worst offender in this respect is CINNAMON BUNS,FRSTD (INCLUDES HONEY BUNS)
```

```
## Replacing the max offender with: BREAD,PITA,WHOLE-WHEAT
```

```
## Our new value of this must restrict is 42.157417
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 109.99305
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## Replacing the max offender with: SPINACH,FRZ,CHOPD OR LEAF,UNPREP
```

```
## Our new value of this must restrict is 109.51525
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4503.3435
```

```
## The worst offender in this respect is BEEF,CURED,CORNED BF,BRISKET,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: LEMONADE,PDR,PREP W/H2O
```

```
## Our new value of this must restrict is 4160.304
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 736.59
```

```
## The worst offender in this respect is BEEF,NZ,IMP,VAR MEATS & BY-PRODUCTS,LIVER,RAW
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CORN,SWEET,WHITE,RAW
```

```
## Our new value of this must restrict is 449.57
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 48.749757
```

```
## The worst offender in this respect is CINNAMON BUNS,FRSTD (INCLUDES HONEY BUNS)
```

```
## Replacing the max offender with: CRACKERS,SALTINES,FAT-FREE,LOW-SODIUM
```

```
## Our new value of this must restrict is 40.564507
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
##  *** Running a wholesale swap. ***
```

```
## Cost is $96.69.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## Swapping out a random 50% of foods: BEEF, BEEF, PORK, CEREALS RTE, FAST FOODS, CHEESE, NUTRITIONAL SUPP FOR PEOPLE W/ DIABETES, INFFORM
```

```
## Swap candidate not good enough; reswapping.
```

```
## Replacing with: CHICKEN, LEMON JUC, BABYFOOD, BEVERAGES, BEVERAGES, LARD, ALCOHOLIC BEV, CEREALS
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 144.63755
```

```
## The worst offender in this respect is LARD
```

```
## Replacing the max offender with: BEVER,VEG & FRUIT JUC DRK,RED CAL,W/ LOW-CAL SWTNR,ADD VIT C
```

```
## Our new value of this must restrict is 131.83755
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 5130.3045
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: DULCE DE LECHE
```

```
## Our new value of this must restrict is 5070.0145
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 887.969
```

```
## The worst offender in this respect is
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: RESTAURANT,ITALIAN,SPAGHETTI W/ POMODORO SAU (NO MEAT)
```

```
## Our new value of this must restrict is 887.969
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 57.319152
```

```
## The worst offender in this respect is
```

```
## Replacing the max offender with: PEAS&ONIONS,FRZ,CKD,BLD,DRND,WO/SALT
```

```
## Our new value of this must restrict is 57.319152
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 144.63755
```

```
## The worst offender in this respect is LARD
```

```
## Replacing the max offender with: LENTILS,MATURE SEEDS,CKD,BLD,WO/SALT
```

```
## Our new value of this must restrict is 132.58995
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 5100.9445
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEANS,CRANBERRY (ROMAN),MATURE SEEDS,CKD,BLD,WO/SALT
```

```
## Our new value of this must restrict is 5017.9145
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 882.459
```

```
## The worst offender in this respect is
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: SNACKS,RICE CRACKER BROWN RICE,PLN
```

```
## Our new value of this must restrict is 882.459
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 56.773262
```

```
## The worst offender in this respect is
```

```
## Replacing the max offender with: SQUASH,WNTR,BUTTERNUT,FRZ,CKD,BLD,W/SALT
```

```
## Our new value of this must restrict is 56.773262
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 144.63755
```

```
## The worst offender in this respect is LARD
```

```
## Replacing the max offender with: YOKAN,PREP FROM ADZUKI BNS & SUGAR
```

```
## Our new value of this must restrict is 131.85435
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 5108.6045
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CANDIES,TAFFY,PREPARED-FROM-RECIPE
```

```
## Our new value of this must restrict is 5031.6045
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 883.809
```

```
## The worst offender in this respect is
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: SALAD DRSNG,MAYO,REG
```

```
## Our new value of this must restrict is 883.809
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 56.771062
```

```
## The worst offender in this respect is
```

```
## Replacing the max offender with: YEAST EXTRACT SPREAD
```

```
## Our new value of this must restrict is 56.771062
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 144.63755
```

```
## The worst offender in this respect is LARD
```

```
## Replacing the max offender with: CAMPBELL'S,HEALTHY REQUEST,CHICK W/ RICE,COND
```

```
## Our new value of this must restrict is 133.33695
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 5506.4845
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,RND,TIP RND,RST,LN & FAT,0" FAT,SEL,RAW
```

```
## Our new value of this must restrict is 5470.9845
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 939.349
```

```
## The worst offender in this respect is
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: ALMONDS,DRY RSTD,W/SALT
```

```
## Our new value of this must restrict is 939.349
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 59.073562
```

```
## The worst offender in this respect is
```

```
## Replacing the max offender with: OLIVE GARDEN,SPAGHETTI W/ POMODORO SAU
```

```
## Our new value of this must restrict is 59.073562
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 144.63755
```

```
## The worst offender in this respect is LARD
```

```
## Replacing the max offender with: PEACHES,DRIED,SULFURED,STWD,W/ SUGAR
```

```
## Our new value of this must restrict is 132.43155
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 5102.3845
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,BRISKET,POINT HALF,LN,0"FAT,ALL GRDS,CKD,BRSD
```

```
## Our new value of this must restrict is 5083.0345
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 959.809
```

```
## The worst offender in this respect is
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PORK,CURED,HAM W/ NAT JUICES,SHANK,BONE-IN,LN & FAT,HTD,RSTD
```

```
## Our new value of this must restrict is 959.809
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 60.925492
```

```
## The worst offender in this respect is
```

```
## Replacing the max offender with: ORANGE-GRAPEFRUIT JUC,CND OR BTLD,UNSWTND
```

```
## Our new value of this must restrict is 60.925492
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 144.63755
```

```
## The worst offender in this respect is LARD
```

```
## Replacing the max offender with: COWPEAS,YOUNG PODS W/SEEDS,CKD,BLD,DRND,WO/SALT
```

```
## Our new value of this must restrict is 132.12255
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 5099.8345
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: TURKEY  WHITE  ROTISSERIE  DELI CUT
```

```
## Our new value of this must restrict is 5591.0345
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 908.859
```

```
## The worst offender in this respect is
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: VEAL,SHLDR,BLADE CHOP,LN,CKD,GRILLED
```

```
## Our new value of this must restrict is 908.859
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 56.589382
```

```
## The worst offender in this respect is
```

```
## Replacing the max offender with: ALCOHOLIC BEV,DISTILLED,ALL (GIN,RUM,VODKA,WHISKEY) 86 PROOF
```

```
## Our new value of this must restrict is 56.589382
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 144.63755
```

```
## The worst offender in this respect is LARD
```

```
## Replacing the max offender with: TARO LEAVES,RAW
```

```
## Our new value of this must restrict is 132.04475
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 5097.8245
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PORK,CURED,HAM,WHL,LN&FAT,UNHTD
```

```
## Our new value of this must restrict is 6810.6245
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 960.859
```

```
## The worst offender in this respect is
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,NZ,IMP,CUBE ROLL,LN & FAT,RAW
```

```
## Our new value of this must restrict is 960.859
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 65.767972
```

```
## The worst offender in this respect is
```

```
## Replacing the max offender with: FROSTINGS,GLAZE,PREPARED-FROM-RECIPE
```

```
## Our new value of this must restrict is 65.767972
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 144.63755
```

```
## The worst offender in this respect is LARD
```

```
## Replacing the max offender with: GELATIN DSSRT,DRY MIX,PREP W/ H2O
```

```
## Our new value of this must restrict is 131.83755
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 5198.2345
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CAKE,ANGELFOOD,DRY MIX
```

```
## Our new value of this must restrict is 5425.7945
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 882.459
```

```
## The worst offender in this respect is
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PEAS,GRN,CND,SEASONED,SOL&LIQUIDS
```

```
## Our new value of this must restrict is 882.459
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 56.472512
```

```
## The worst offender in this respect is
```

```
## Replacing the max offender with: PUDDINGS,VANILLA,DRY MIX,REG
```

```
## Our new value of this must restrict is 56.472512
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 144.63755
```

```
## The worst offender in this respect is LARD
```

```
## Replacing the max offender with: GRAVY,MUSHROOM,CANNED
```

```
## Our new value of this must restrict is 138.28735
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 6453.5845
```

```
## The worst offender in this respect is CHEESE,PARMESAN,SHREDDED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,NZ,IMP,BRISKET POINT END,LN,RAW
```

```
## Our new value of this must restrict is 6426.9245
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 944.019
```

```
## The worst offender in this respect is
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CRACKERS,STD SNACK-TYPE,SNDWCH,W/CHS FILLING
```

```
## Our new value of this must restrict is 944.019
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 59.288412
```

```
## The worst offender in this respect is
```

```
## Replacing the max offender with: SQUASH,SMMR,CROOKNECK&STRAIGHTNECK,CKD,BLD,DRND,W/SALT
```

```
## Our new value of this must restrict is 59.288412
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantlogical(0)c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
##  *** Running a wholesale swap. ***
```

```
## Cost is $134.35.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PORK. 1 servings of it.
```

```
## Swapping out a random 50% of foods: CHEESE, BABYFOOD, BEEF, FAST FOODS, BEEF, INFFORM, BEVERAGES, CHEESE, ARTICHOKES, BEEF, PORK, BABYFOOD
```

```
## Swap candidate is good enough. Doing the wholesale swap.
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of PEACHES. 2.69 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 55.0765610878661
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1476.00724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 305.5735
```

```
## The worst offender in this respect is BEEF,CHUCK,ARM POT RST,LN,0"FAT,SEL,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,LOIN,TENDERLOIN RST,BNLESS,LN,0" FAT,SEL,RAW
```

```
## Our new value of this must restrict is 274.9735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 17.091813248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 55.0765610878661
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1476.00724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 305.5735
```

```
## The worst offender in this respect is BEEF,CHUCK,ARM POT RST,LN,0"FAT,SEL,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,TENDERLOIN,RST,LN & FAT,1/8" FAT,ALL GRDS,CKD,RSTD
```

```
## Our new value of this must restrict is 294.5235
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 23.903713248954
```

```
## The worst offender in this respect is KEEBLER,CHIPS DELUXE,ORIGINAL CHOC CHIP COOKIES
```

```
## Replacing the max offender with: ROLLS,HAMBURGER OR HOTDOG,RED-CAL
```

```
## Our new value of this must restrict is 20.665850748954
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 55.0765610878661
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1476.00724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 305.5735
```

```
## The worst offender in this respect is BEEF,CHUCK,ARM POT RST,LN,0"FAT,SEL,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PORK,CURED,HAM W/ NAT JUICES,WHL,BNLESS,LN,UNHTD
```

```
## Our new value of this must restrict is 237.299
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 15.906502248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 55.0765610878661
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1476.00724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 305.5735
```

```
## The worst offender in this respect is BEEF,CHUCK,ARM POT RST,LN,0"FAT,SEL,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: SALAD DRSNG,FRENCH DRSNG,RED CAL
```

```
## Our new value of this must restrict is 222.2735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 15.941233248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 55.0765610878661
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1476.00724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 305.5735
```

```
## The worst offender in this respect is BEEF,CHUCK,ARM POT RST,LN,0"FAT,SEL,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CEREALS RTE,GENERAL MILLS,COCOA PUFFS
```

```
## Our new value of this must restrict is 222.2735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 15.911713248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 55.0765610878661
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1476.00724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 305.5735
```

```
## The worst offender in this respect is BEEF,CHUCK,ARM POT RST,LN,0"FAT,SEL,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: ALMONDS,OIL RSTD,W/SALT
```

```
## Our new value of this must restrict is 222.2735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 22.248273248954
```

```
## The worst offender in this respect is KEEBLER,CHIPS DELUXE,ORIGINAL CHOC CHIP COOKIES
```

```
## Replacing the max offender with: SOY SAU MADE FROM SOY&WHEAT (SHOYU),LO NA
```

```
## Our new value of this must restrict is 18.923243248954
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 55.0765610878661
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1476.00724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 305.5735
```

```
## The worst offender in this respect is BEEF,CHUCK,ARM POT RST,LN,0"FAT,SEL,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,RND,BTTM RND,RST,LN & FAT,0" FAT,ALL GRDS,CKD,RSTD
```

```
## Our new value of this must restrict is 289.4235
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 17.998763248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 55.0765610878661
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1476.00724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 305.5735
```

```
## The worst offender in this respect is BEEF,CHUCK,ARM POT RST,LN,0"FAT,SEL,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PORK,FRSH,LOIN,CNTR LOIN (CHOPS),BONE-IN,LN,CKD,PAN-FRIED
```

```
## Our new value of this must restrict is 288.5735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 17.849163248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 55.0765610878661
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1476.00724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 305.5735
```

```
## The worst offender in this respect is BEEF,CHUCK,ARM POT RST,LN,0"FAT,SEL,CKD,BRSD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: FRUIT BUTTERS,APPLE
```

```
## Our new value of this must restrict is 222.2735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 15.650723248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Magnesium_mg", "Manganese_mg", "Vit_C_mg", "Thiamin_mg", "Panto_Acid_mg", "Vit_B6_mg")Cholestrl_mg
```

```
## Uncomplinat here: Not Compliant
```

```
##  *** Running a wholesale swap. ***
```

```
## Cost is $92.72.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## Swapping out a random 50% of foods: BF, PEACHES, BABYFOOD, EGG, BABYFOOD, CAMPBELL'S CHNKY
```

```
## Swap candidate not good enough; reswapping.
```

```
## Replacing with: BEEF, COWPEAS, BEEF, CHICKEN, BROCCOLI, ONIONS
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 95.0283610878661
```

```
## The worst offender in this respect is CHICKEN,BROILERS OR FRYERS,SKN ONLY,RAW
```

```
## Replacing the max offender with: TILEFISH,RAW
```

```
## Our new value of this must restrict is 81.7873610878661
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1689.72724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 511.2735
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: EGG ROLLS,PORK,REFR,HTD
```

```
## Our new value of this must restrict is 410.9735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 21.344573248954
```

```
## The worst offender in this respect is KEEBLER,CHIPS DELUXE,ORIGINAL CHOC CHIP COOKIES
```

```
## Replacing the max offender with: KALE,CKD,BLD,DRND,W/SALT
```

```
## Our new value of this must restrict is 18.082173248954
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 95.0283610878661
```

```
## The worst offender in this respect is CHICKEN,BROILERS OR FRYERS,SKN ONLY,RAW
```

```
## Replacing the max offender with: SQUASH,SMMR,ZUCCHINI,ITALIAN STYLE,CND
```

```
## Our new value of this must restrict is 80.0735610878661
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 2493.65724686192
```

```
## The worst offender in this respect is EGG,WHITE,DRIED,FLAKES,STABILIZED,GLUCOSE RED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: LINGCOD,RAW
```

```
## Our new value of this must restrict is 2216.08124686192
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 512.9735
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: SOUP,CRM OF MUSHROOM,CND,PREP W/ EQ VOLUME LOFAT (2%) MILK
```

```
## Our new value of this must restrict is 410.8535
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 22.651903248954
```

```
## The worst offender in this respect is KEEBLER,CHIPS DELUXE,ORIGINAL CHOC CHIP COOKIES
```

```
## Replacing the max offender with: CABBAGE,SAVOY,CKD,BLD,DRND,W/SALT
```

```
## Our new value of this must restrict is 19.339303248954
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 95.0283610878661
```

```
## The worst offender in this respect is CHICKEN,BROILERS OR FRYERS,SKN ONLY,RAW
```

```
## Replacing the max offender with: APPLES,RAW,WITH SKIN
```

```
## Our new value of this must restrict is 80.0363610878661
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1645.92724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 468.7735
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BREAD, FRENCH OR VIENNA, TSTD (IND SOURDOUGH)
```

```
## Our new value of this must restrict is 356.5735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 19.797240248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 95.0283610878661
```

```
## The worst offender in this respect is CHICKEN,BROILERS OR FRYERS,SKN ONLY,RAW
```

```
## Replacing the max offender with: CELERY,CKD,BLD,DRND,W/SALT
```

```
## Our new value of this must restrict is 80.0638610878661
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 2135.17724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 468.7735
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CORN,SWT,WHITE,CND,VACUUM PK,REG PK
```

```
## Our new value of this must restrict is 356.5735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 19.841623248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 95.0283610878661
```

```
## The worst offender in this respect is CHICKEN,BROILERS OR FRYERS,SKN ONLY,RAW
```

```
## Replacing the max offender with: CEREALS RTE,KELLOGG,KELLOGG'S CORN POPS
```

```
## Our new value of this must restrict is 80.2138610878661
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1751.77724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 468.7735
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: FAST FOODS,FRIED CHICK,WING,MEAT & SKN & BREADING
```

```
## Our new value of this must restrict is 422.6935
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 22.877563248954
```

```
## The worst offender in this respect is KEEBLER,CHIPS DELUXE,ORIGINAL CHOC CHIP COOKIES
```

```
## Replacing the max offender with: PEAS&CARROTS,CND,REG PK,SOL&LIQUIDS
```

```
## Our new value of this must restrict is 19.672513248954
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 95.0283610878661
```

```
## The worst offender in this respect is CHICKEN,BROILERS OR FRYERS,SKN ONLY,RAW
```

```
## Replacing the max offender with: CEREALS RTE,WHEAT,PUFFED,FORT
```

```
## Our new value of this must restrict is 79.9678610878661
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1645.15724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 468.7735
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CUTTLEFISH,MXD SP,CKD,MOIST HEAT
```

```
## Our new value of this must restrict is 546.9735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 19.844523248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 95.0283610878661
```

```
## The worst offender in this respect is CHICKEN,BROILERS OR FRYERS,SKN ONLY,RAW
```

```
## Replacing the max offender with: TOMATOES,RED,RIPE,CND,PACKED IN TOMATO JUC
```

```
## Our new value of this must restrict is 80.4238610878661
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1920.67724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 468.7735
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: WAFFLES,GLUTEN-FREE,FRZ,RTH
```

```
## Our new value of this must restrict is 356.5735
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 20.052973248954
```

```
## The worst offender in this respect is KEEBLER,CHIPS DELUXE,ORIGINAL CHOC CHIP COOKIES
```

```
## Replacing the max offender with: BABYFOOD,H2O,BTLD,GERBER,WO/ ADDED FLUORIDE.
```

```
## Our new value of this must restrict is 16.722973248954
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 95.0283610878661
```

```
## The worst offender in this respect is CHICKEN,BROILERS OR FRYERS,SKN ONLY,RAW
```

```
## Replacing the max offender with: MILK,CHOC,FLUID,COMM,RED FAT,W/ ADDED CA
```

```
## Our new value of this must restrict is 84.5738610878661
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 1809.67724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 488.7735
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,COMP OF RTL CUTS,LN,0"FAT,CHOIC,CKD
```

```
## Our new value of this must restrict is 452.2235
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 25.430323248954
```

```
## The worst offender in this respect is KEEBLER,CHIPS DELUXE,ORIGINAL CHOC CHIP COOKIES
```

```
## Replacing the max offender with: SYRUPS,TABLE BLENDS,PANCAKE,W/2% MAPLE
```

```
## Our new value of this must restrict is 22.103923248954
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 95.0283610878661
```

```
## The worst offender in this respect is CHICKEN,BROILERS OR FRYERS,SKN ONLY,RAW
```

```
## Replacing the max offender with: CORN,SWT,WHITE,CND,WHL KERNEL,REG PK,SOL&LIQUIDS
```

```
## Our new value of this must restrict is 81.1038610878661
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 2189.95724686192
```

```
## We're all good on this nutrient.
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 468.7735
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BABYFOOD,TURKEY,RICE&VEG,TODD
```

```
## Our new value of this must restrict is 358.558
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 19.958793248954
```

```
## We're all good on this nutrient.
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantc("Calcium_mg", "Thiamin_mg", "Panto_Acid_mg")c("Lipid_Tot_g", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
##  *** Running a wholesale swap. ***
```

```
## Cost is $129.53.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## Swapping out a random 50% of foods: BF, BROCCOLI, BABYFOOD, BEEF, COOKIES, CHICORY, BEEF, KEEBLER, CAMPBELL'S CHNKY
```

```
## Swap candidate not good enough; reswapping.
```

```
## Replacing with: ALMOND BUTTER, TUNA, LAMB, PORK, BALSAM-PEAR (BITTER GOURD), FAST FOODS, BEEF, CHEESE, BABYFOOD
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 239.922446087866
```

```
## The worst offender in this respect is ALMOND BUTTER,PLN,W/SALT
```

```
## Replacing the max offender with: SOUP,BEAN W/ PORK,CND,PREP W/ EQ VOLUME H2O
```

```
## Our new value of this must restrict is 236.788046087866
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 4130.59474686192
```

```
## The worst offender in this respect is EGG,WHITE,DRIED,FLAKES,STABILIZED,GLUCOSE RED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: CRACKERS,WHEAT,LOW SALT
```

```
## Our new value of this must restrict is 3829.84874686193
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 998.454
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: INF FORMULA, ABBOTT NUTRIT, SIMILAC, FOR SPIT UP, POW
```

```
## Our new value of this must restrict is 886.254
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 80.020111748954
```

```
## The worst offender in this respect is CHEESE,CHESHIRE
```

```
## Replacing the max offender with: LENTILS,SPROUTED,RAW
```

```
## Our new value of this must restrict is 74.542839248954
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 239.922446087866
```

```
## The worst offender in this respect is ALMOND BUTTER,PLN,W/SALT
```

```
## Replacing the max offender with: PEPPERS,SWEET,YELLOW,RAW
```

```
## Our new value of this must restrict is 231.433046087866
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 3205.97474686192
```

```
## The worst offender in this respect is EGG,WHITE,DRIED,FLAKES,STABILIZED,GLUCOSE RED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: TURKEY FROM WHL,LT MEAT,MEAT & SKN,RAW
```

```
## Our new value of this must restrict is 2967.49874686192
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 1052.744
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: LAMB,VAR MEATS&BY-PRODUCTS,HEART,CKD,BRSD
```

```
## Our new value of this must restrict is 1152.194
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 80.428990748954
```

```
## The worst offender in this respect is CHEESE,CHESHIRE
```

```
## Replacing the max offender with: BEANS,KIDNEY,ALL TYPES,MATURE SEEDS,RAW
```

```
## Our new value of this must restrict is 75.128628248954
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 239.922446087866
```

```
## The worst offender in this respect is ALMOND BUTTER,PLN,W/SALT
```

```
## Replacing the max offender with: SWEET POTATO LEAVES,CKD,STMD,WO/ SALT
```

```
## Our new value of this must restrict is 231.260046087866
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 3206.73474686192
```

```
## The worst offender in this respect is EGG,WHITE,DRIED,FLAKES,STABILIZED,GLUCOSE RED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: LAMB,DOM,SHLDR,ARM,LN,1/4"FAT,CHOIC,CKD,BRLD
```

```
## Our new value of this must restrict is 2948.70874686192
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 1073.994
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: SESAME SD KRNLS,DRIED (DECORT)
```

```
## Our new value of this must restrict is 961.794
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 92.619280748954
```

```
## The worst offender in this respect is CHEESE,CHESHIRE
```

```
## Replacing the max offender with: APPLE JUC,FRZ CONC,UNSWTND,UNDIL,W/ VIT C
```

```
## Our new value of this must restrict is 87.224718248954
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 239.922446087866
```

```
## The worst offender in this respect is ALMOND BUTTER,PLN,W/SALT
```

```
## Replacing the max offender with: POTATOES,MICROWAVED,CKD,IN SKN,SKN W/SALT
```

```
## Our new value of this must restrict is 231.100446087866
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 3348.41474686192
```

```
## The worst offender in this respect is EGG,WHITE,DRIED,FLAKES,STABILIZED,GLUCOSE RED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,RND,TOP RND STEAK,LN & FAT,1/8" FAT,ALL GRDS,CKD,BRLD
```

```
## Our new value of this must restrict is 3055.53874686192
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 1072.294
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEEF,LN,TP LN STK,BNLESS,LIPON,L & F,1/8" FAT,SeL, CK GRLED
```

```
## Our new value of this must restrict is 1028.944
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 84.153610748954
```

```
## The worst offender in this respect is CHEESE,CHESHIRE
```

```
## Replacing the max offender with: CEREALS,OATS,INST,FORT,PLN,PREP W/ H2O
```

```
## Our new value of this must restrict is 79.161288248954
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 239.922446087866
```

```
## The worst offender in this respect is ALMOND BUTTER,PLN,W/SALT
```

```
## Replacing the max offender with: CEREALS RTE,RALSTON CRISP RICE
```

```
## Our new value of this must restrict is 231.458246087866
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 3382.10474686192
```

```
## The worst offender in this respect is EGG,WHITE,DRIED,FLAKES,STABILIZED,GLUCOSE RED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: TILEFISH,COOKED,DRY HEAT
```

```
## Our new value of this must restrict is 3142.87874686192
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 1091.794
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: COWPEAS (BLACKEYES),IMMTRE SEEDS,FRZ,CKD,BLD,DRND,WO/SALT
```

```
## Our new value of this must restrict is 979.594
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 77.806480748954
```

```
## The worst offender in this respect is CHEESE,CHESHIRE
```

```
## Replacing the max offender with: MUSHROOMS,PORTABELLA,EXPOSED TO UV LT,RAW
```

```
## Our new value of this must restrict is 72.336918248954
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 239.922446087866
```

```
## The worst offender in this respect is ALMOND BUTTER,PLN,W/SALT
```

```
## Replacing the max offender with: MILK,CHOC,LOWFAT,W/ ADDED VIT A & VITAMIN D
```

```
## Our new value of this must restrict is 233.542446087866
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 3364.75474686192
```

```
## The worst offender in this respect is EGG,WHITE,DRIED,FLAKES,STABILIZED,GLUCOSE RED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: ASPARAGUS,RAW
```

```
## Our new value of this must restrict is 3039.70874686192
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 1008.294
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PUDDINGS,TAPIOCA,DRY MIX,PREP W/ WHL MILK
```

```
## Our new value of this must restrict is 911.454
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 79.808500748954
```

```
## The worst offender in this respect is CHEESE,CHESHIRE
```

```
## Replacing the max offender with: SQUASH,WNTR,BUTTERNUT,FRZ,CKD,BLD,WO/SALT
```

```
## Our new value of this must restrict is 74.320938248954
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 239.922446087866
```

```
## The worst offender in this respect is ALMOND BUTTER,PLN,W/SALT
```

```
## Replacing the max offender with: Puddings, rice, ready-to-eat
```

```
## Our new value of this must restrict is 233.471946087866
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 3311.86474686192
```

```
## The worst offender in this respect is EGG,WHITE,DRIED,FLAKES,STABILIZED,GLUCOSE RED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PORK,FRSH,LOIN,CNTR RIB (CHOPS),BONE-IN,LN,CKD,BRLD
```

```
## Our new value of this must restrict is 3032.58874686192
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 1065.454
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BREAD,REDUCED-CALORIE,RYE
```

```
## Our new value of this must restrict is 953.254
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 79.951148748954
```

```
## The worst offender in this respect is CHEESE,CHESHIRE
```

```
## Replacing the max offender with: BEANS,SNAP,GRN,CND,NO SALT,SOL&LIQUIDS
```

```
## Our new value of this must restrict is 74.457586248954
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 239.922446087866
```

```
## The worst offender in this respect is ALMOND BUTTER,PLN,W/SALT
```

```
## Replacing the max offender with: CHIVES,RAW
```

```
## Our new value of this must restrict is 231.064346087866
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 3202.34474686192
```

```
## The worst offender in this respect is EGG,WHITE,DRIED,FLAKES,STABILIZED,GLUCOSE RED
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: BEVERAGES,ENERGY DRK,MONSTER,FORT W/ VITAMINS C,B2,B3,B6,B12
```

```
## Our new value of this must restrict is 3059.41874686192
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 995.794
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: PORK,FRSH,LOIN,CNTR RIB (CHOPS),BNLESS,LN&FAT,CKD,PAN-FRIED
```

```
## Our new value of this must restrict is 945.644
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 81.804560748954
```

```
## The worst offender in this respect is CHEESE,CHESHIRE
```

```
## Replacing the max offender with: RICE,WHITE,LONG-GRAIN,PARBLD,UNENR,DRY
```

```
## Our new value of this must restrict is 76.827298248954
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Doing a single swap on all must restricts
```

```
## ------- The nutrient we're restricting is Lipid_Tot_g. It has to be below 65
```

```
## The original total value of that nutrient in our menu is 239.922446087866
```

```
## The worst offender in this respect is ALMOND BUTTER,PLN,W/SALT
```

```
## Replacing the max offender with: SAUCE,TERIYAKI,RTS
```

```
## Our new value of this must restrict is 231.046046087866
```

```
## ------- The nutrient we're restricting is Sodium_mg. It has to be below 2400
```

```
## The original total value of that nutrient in our menu is 3892.19474686192
```

```
## The worst offender in this respect is SAUCE,TERIYAKI,RTS
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: COOKIES,BUTTER,COMMLY PREP,ENR
```

```
## Our new value of this must restrict is 3282.20174686192
```

```
## ------- The nutrient we're restricting is Cholestrl_mg. It has to be below 300
```

```
## The original total value of that nutrient in our menu is 1028.9635
```

```
## The worst offender in this respect is BEEF,VAR MEATS&BY-PRODUCTS,TONGUE,CKD,SIMMRD
```

```
## No better foods at this cutoff; choosing a food randomly.
```

```
## Replacing the max offender with: APPLE JUC,FRZ CONC,UNSWTND,DIL W/3 VOLUME H2O,W/ VIT C
```

```
## Our new value of this must restrict is 916.7635
```

```
## ------- The nutrient we're restricting is FA_Sat_g. It has to be below 20
```

```
## The original total value of that nutrient in our menu is 79.264159248954
```

```
## The worst offender in this respect is CHEESE,CHESHIRE
```

```
## Replacing the max offender with: PERCH,MXD SP,CKD,DRY HEAT
```

```
## Our new value of this must restrict is 73.852016748954
```

```
## Cost is $179.32.
```

```
## No optimal solution found :'(
```

```
## We've got a lot of COOKIES. 1 servings of them.
```

```
## No solution found -- menu not currently compliant
```

```
## Calorie compliantCalcium_mgc("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
```

```
## Uncomplinat here: Not Compliant
```

```
## Time out; returning menu as is
```

```
## # A tibble: 27 x 30
##        shorter_desc solution_amounts   GmWt_1 serving_gmwt     cost
##               <chr>            <dbl>    <dbl>        <dbl>    <dbl>
##  1          COOKIES                1  28.3500        28.35  4.92000
##  2          KEEBLER                1  30.0000        30.00  8.65000
##  3         BABYFOOD                1  28.3500        28.35  9.30000
##  4          CATFISH                1  87.0000        87.00  5.07000
##  5             BEEF                1  85.0000        85.00  9.88000
##  6          CHICORY                1  53.0000        53.00  2.63000
##  7          PEACHES                1 430.9107       160.00 19.25632
##  8 CAMPBELL'S CHNKY                1 245.0000       245.00  8.21000
##  9             BEEF                1  85.0000        85.00  8.04000
## 10         BABYFOOD                1 163.0000       163.00  3.12000
## # ... with 17 more rows, and 25 more variables: Lipid_Tot_g <dbl>,
## #   Sodium_mg <dbl>, Cholestrl_mg <dbl>, FA_Sat_g <dbl>, Protein_g <dbl>,
## #   Calcium_mg <dbl>, Iron_mg <dbl>, Magnesium_mg <dbl>,
## #   Phosphorus_mg <dbl>, Potassium_mg <dbl>, Zinc_mg <dbl>,
## #   Copper_mg <dbl>, Manganese_mg <dbl>, Selenium_µg <dbl>,
## #   Vit_C_mg <dbl>, Thiamin_mg <dbl>, Riboflavin_mg <dbl>,
## #   Niacin_mg <dbl>, Panto_Acid_mg <dbl>, Vit_B6_mg <dbl>,
## #   Energ_Kcal <dbl>, Shrt_Desc <chr>, NDB_No <chr>, score <dbl>,
## #   scaled_score <dbl>
```


#### Simulating Solving


```r
simulate_menus()
```

```
## Cost is $96.98.
```

```
## No optimal solution found :'(
```

```
## Cost is $104.25.
```

```
## Optimal solution found :)
```

```
## Cost is $248.82.
```

```
## No optimal solution found :'(
```

```
## Cost is $64.27.
```

```
## No optimal solution found :'(
```

```
## Cost is $49.8.
```

```
## No optimal solution found :'(
```

```
## Cost is $90.21.
```

```
## Optimal solution found :)
```

```
## Cost is $286.44.
```

```
## No optimal solution found :'(
```

```
## Cost is $69.93.
```

```
## No optimal solution found :'(
```

```
## Cost is $206.3.
```

```
## No optimal solution found :'(
```

```
## Cost is $104.17.
```

```
## Optimal solution found :)
```

```
##  [1] 1 0 1 1 1 0 1 1 1 0
```


```r
simulate_spectrum()
```

```
## # A tibble: 22 x 2
##    min_amount status
##         <dbl>  <int>
##  1       -1.0      0
##  2       -1.0      0
##  3       -0.8      0
##  4       -0.8      0
##  5       -0.6      1
##  6       -0.6      0
##  7       -0.4      0
##  8       -0.4      0
##  9       -0.2      0
## 10       -0.2      0
## # ... with 12 more rows
```



## Scraping


```r
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


```r
some_recipes <- get_recipes(urls[4:5]) 
```

```
## Banana, Orange, and Ginger Smoothie
```

```
## Alabama-Style White Barbecue Sauce
```

```
## Number bad URLs: 0
```

```
## Number duped recipes: 0
```



```r
some_recipes %>% get_recipes(sleep = 3)
```

```
## Number bad URLs: 2
```

```
## Number duped recipes: 0
```

```
## [1] "Bad URL" "Bad URL"
```

Fake recipe to illustrate some cases

```r
some_recipes_tester
```

```
## # A tibble: 11 x 1
##                                               ingredients
##  *                                                  <chr>
##  1 1.2 ounces or maybe pounds of something with a decimal
##  2                        3 (14 ounce) cans o' beef broth
##  3                                     around 4 or 5 eels
##  4                                          5-6 cans spam
##  5                                  11 - 46 tbsp of sugar
##  6                                    1/3 to 1/2 of a ham
##  7                                 5 1/2 pounds of apples
##  8                                            4g cinnamon
##  9                          about 17 fluid ounces of wine
## 10                             4-5 cans of 1/2 caf coffee
## 11                               3 7oz figs with 1/3 rind
```



```r
some_recipes <- some_recipes[!some_recipes == "Bad URL"]
some_recipes_df <- dfize(some_recipes)
```


```r
some_recipes_df %>% get_portions() 
```

```
## # A tibble: 15 x 8
##                                           ingredients
##                                                 <chr>
##  1                                   1 orange, peeled
##  2                                         1/2 banana
##  3                                        3 ice cubes
##  4                                  2 teaspoons honey
##  5 1/2 teaspoon grated fresh ginger root, or to taste
##  6                               1/2 cup plain yogurt
##  7                                  2 cups mayonnaise
##  8                        1/2 cup apple cider vinegar
##  9             1/4 cup prepared extra-hot horseradish
## 10                    2 tablespoons fresh lemon juice
## 11        1 1/2 teaspoons freshly ground black pepper
## 12                2 teaspoons prepared yellow mustard
## 13                             1 teaspoon kosher salt
## 14                        1/2 teaspoon cayenne pepper
## 15                         1/4 teaspoon garlic powder
## # ... with 7 more variables: recipe_name <chr>, raw_portion_num <chr>,
## #   portion_name <chr>, approximate <lgl>, range_portion <dbl>,
## #   mult_add_portion <dbl>, portion <dbl>
```


```r
some_recipes_df %>% get_portions() %>% add_abbrevs()
```

```
## # A tibble: 15 x 9
##                                           ingredients
##                                                 <chr>
##  1                                   1 orange, peeled
##  2                                         1/2 banana
##  3                                        3 ice cubes
##  4                                  2 teaspoons honey
##  5 1/2 teaspoon grated fresh ginger root, or to taste
##  6                               1/2 cup plain yogurt
##  7                                  2 cups mayonnaise
##  8                        1/2 cup apple cider vinegar
##  9             1/4 cup prepared extra-hot horseradish
## 10                    2 tablespoons fresh lemon juice
## 11        1 1/2 teaspoons freshly ground black pepper
## 12                2 teaspoons prepared yellow mustard
## 13                             1 teaspoon kosher salt
## 14                        1/2 teaspoon cayenne pepper
## 15                         1/4 teaspoon garlic powder
## # ... with 8 more variables: recipe_name <chr>, raw_portion_num <chr>,
## #   portion_name <chr>, approximate <lgl>, range_portion <dbl>,
## #   mult_add_portion <dbl>, portion <dbl>, portion_abbrev <chr>
```


## NLP



