# Food for Thought




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




# Creating and Solving Menus

### Building

Now to build a menu. The only constraint we have to worry about here is that menus have to contain at least 2300 calories. Our strategy is simple; pick one serving of a food at random from our dataset and, if it doesn't yet exist in our menu, add it. We do this until we're no longer under 2300 calories. 

That's implemented in `add_calories()` below, which we'll as a helper inside `build_menu()`. The reason I've spun `add_calories()` out into its own function is so that we can easily add more foods to existing menus. It takes `menu` as its first argument, unlike `build_menu()` which takes a dataframe of all possible foods to choose from.


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
our_solved_menu %>% kable()
```



shorter_desc                     solution_amounts   GmWt_1   serving_gmwt   cost   Lipid_Tot_g   Sodium_mg   Cholestrl_mg   FA_Sat_g   Protein_g   Calcium_mg   Iron_mg   Magnesium_mg   Phosphorus_mg   Potassium_mg   Zinc_mg   Copper_mg   Manganese_mg   Selenium_µg   Vit_C_mg   Thiamin_mg   Riboflavin_mg   Niacin_mg   Panto_Acid_mg   Vit_B6_mg   Energ_Kcal  Shrt_Desc                                                  NDB_No        score   scaled_score
------------------------------  -----------------  -------  -------------  -----  ------------  ----------  -------------  ---------  ----------  -----------  --------  -------------  --------------  -------------  --------  ----------  -------------  ------------  ---------  -----------  --------------  ----------  --------------  ----------  -----------  ---------------------------------------------------------  -------  ----------  -------------
CANDIES                                         1    40.00          40.00   2.24         34.50          39             11     20.600        5.58          109      1.33             38             129            306      0.79       0.180          0.000           0.0        1.0        0.040           0.160       0.330           0.250       0.060          563  CANDIES,HERSHEY'S,ALMOND JOY BITES                         19248     -4490.352      0.0062599
SALMON                                          1    85.00          85.00   9.02          7.31          75             44      1.644       20.47          239      1.06             29             326            377      1.02       0.084          0.030          35.4        0.0        0.016           0.193       5.480           0.550       0.300          153  SALMON,SOCKEYE,CND,WO/SALT,DRND SOL W/BONE                 15182     -3913.498      1.1090489
BROADBEANS                                      1   109.00         109.00   3.93          0.60          50              0      0.138        5.60           22      1.90             38              95            250      0.58       0.074          0.320           1.2       33.0        0.170           0.110       1.500           0.086       0.038           72  BROADBEANS,IMMAT SEEDS,RAW                                 11088     -4250.264      0.4652428
GELATIN DSSRT                                   1    85.00          85.00   1.96          0.00         466              0      0.000        7.80            3      0.13              2             141              7      0.01       0.118          0.011           6.7        0.0        0.003           0.041       0.009           0.014       0.001          381  GELATIN DSSRT,DRY MIX                                      19172     -4938.439     -0.8503611
CRAYFISH                                        1    85.00          85.00   6.64          1.20          94            133      0.181       16.77           60      0.83             33             270            296      1.76       0.685          0.522          36.7        0.9        0.050           0.085       2.280           0.580       0.076           82  CRAYFISH,MXD SP,WILD,CKD,MOIST HEAT                        15146     -4266.922      0.4333988
CRACKERS                                        1    30.00          30.00   3.41         11.67        1167              0      3.333       10.00           67      4.80             22             162            141      0.90       0.118          0.517          26.2        0.0        1.087           0.750       7.170           0.528       0.044          418  CRACKERS,CHS,RED FAT                                       18965     -4906.367     -0.7890484
CHEESE                                          1    28.35          28.35   7.25         30.64        1809             90     19.263       21.54          662      0.56             30             392             91      2.08       0.034          0.030          14.5        0.0        0.040           0.586       0.734           1.731       0.124          369  CHEESE,ROQUEFORT                                           01039     -4892.506     -0.7625507
SPICES                                          1     0.70           0.70   9.03          4.07          76              0      2.157       22.98         2240     89.80            711             274           2630      7.10       2.100          9.800           3.0        0.8        0.080           1.200       4.900           0.838       1.340          233  SPICES,BASIL,DRIED                                         02003     -4643.583     -0.2866766
RAVIOLI                                         1   242.00         242.00   7.63          1.45         306              3      0.723        2.48           33      0.74             15              50            232      0.36       0.142          0.176           3.5        0.0        0.074           0.080       1.060           0.272       0.102           77  RAVIOLI,CHEESE-FILLED,CND                                  22899     -4617.693     -0.2371810
LUXURY LOAF                                     1    28.00          28.00   4.64          4.80        1225             36      1.580       18.40           36      1.05             20             185            377      3.05       0.100          0.041          21.5        0.0        0.707           0.297       3.482           0.515       0.310          141  LUXURY LOAF,PORK                                           07060     -4852.980     -0.6869870
CANDIES                                         1    14.50          14.50   9.99         30.00          11              0     17.750        4.20           32      3.13            115             132            365      1.62       0.700          0.800           4.2        0.0        0.055           0.090       0.427           0.105       0.035          480  CANDIES,SEMISWEET CHOC                                     19080     -4597.911     -0.1993645
ONIONS                                          1   210.00         210.00   4.83          0.05           8              0      0.009        0.71           27      0.34              8               2            101      0.09       0.024          0.040           0.4        5.1        0.016           0.018       0.132           0.078       0.070           28  ONIONS,FRZ,WHL,CKD,BLD,DRND,WO/SALT                        11290     -4397.386      0.1839856
PIZZA HUT 14" PEPPERONI PIZZA                   1   113.00         113.00   5.69         13.07         676             23      4.823       11.47          147      2.57             22             193            187      1.36       0.104          0.425          15.5        1.0        0.420           0.210       3.750           0.323       0.090          291  PIZZA HUT 14" PEPPERONI PIZZA,PAN CRUST                    21297     -4832.658     -0.6481376
BEANS                                           1   104.00         104.00   8.77          0.70          13              0      0.085        6.15           15      1.93            101             100            307      0.89       0.356          0.408           0.6       18.8        0.390           0.215       1.220           0.825       0.191           67  BEANS,NAVY,MATURE SEEDS,SPROUTED,RAW                       11046     -4122.162      0.7101393
GRAPE JUC                                       1   253.00         253.00   4.53          0.13           5              0      0.025        0.37           11      0.25             10              14            104      0.07       0.018          0.239           0.0        0.1        0.017           0.015       0.133           0.048       0.032           60  GRAPE JUC,CND OR BTLD,UNSWTND,WO/ ADDED VIT C              09135     -4343.103      0.2877596
PIE                                             1    28.35          28.35   1.75         12.50         211              0      3.050        2.40            7      1.12              7              28             79      0.19       0.053          0.185           7.8        1.7        0.148           0.107       1.230           0.093       0.032          265  PIE,APPL,PREP FROM RECIPE                                  18302     -4710.654     -0.4148992
PORK                                            1    85.00          85.00   2.46          2.59          63             63      0.906       22.81            9      0.56             23             251            354      1.72       0.069          0.011          37.4        0.0        0.610           0.256       7.348           0.728       0.611          121  PORK,FRSH,LOIN,SIRLOIN (CHOPS OR ROASTS),BNLESS,LN,RAW     10214     -4192.317      0.5760225
FAST FOODS                                      1   226.00         226.00   5.02         11.75         350             54      4.654       15.17           45      2.59             22             139            252      2.51       0.097          0.110          11.3        0.5        0.160           0.170       3.350           0.240       0.240          239  FAST FOODS,HAMBURGER; DOUBLE,LRG PATTY; W/ CONDMNT & VEG   21114     -4517.685     -0.0459943


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
our_solved_nutrients %>% kable()
```



nutrient        is_must_restrict    required_value   solution_nutrient_value
--------------  -----------------  ---------------  ------------------------
Lipid_Tot_g     TRUE                            65                 91.337680
Sodium_mg       TRUE                          2400               4269.667000
Cholestrl_mg    TRUE                           300                399.285000
FA_Sat_g        TRUE                            20                 38.956894
Protein_g       FALSE                           56                143.787350
Calcium_mg      FALSE                         1000               1019.891500
Iron_mg         FALSE                           18                 21.990730
Magnesium_mg    FALSE                          400                432.931500
Phosphorus_mg   FALSE                         1000               2032.328000
Potassium_mg    FALSE                         3500               3677.960000
Zinc_mg         FALSE                           15                 16.206145
Copper_mg       FALSE                            2                  2.316085
Manganese_mg    FALSE                            2                  3.516592
Selenium_µg     FALSE                           70                173.897050
Vit_C_mg        FALSE                           60                 70.397550
Thiamin_mg      FALSE                            2                  2.861833
Riboflavin_mg   FALSE                            2                  2.313175
Niacin_mg       FALSE                           20                 34.651609
Panto_Acid_mg   FALSE                           10                  5.334605
Vit_B6_mg       FALSE                            2                  2.381441
Energ_Kcal      FALSE                         2300               2681.570000



### Swapping

Single swap


```r
our_random_menu %>% do_single_swap() %>% kable()
```



shorter_desc                     solution_amounts   GmWt_1   serving_gmwt   cost   Lipid_Tot_g   Sodium_mg   Cholestrl_mg   FA_Sat_g   Protein_g   Calcium_mg   Iron_mg   Magnesium_mg   Phosphorus_mg   Potassium_mg   Zinc_mg   Copper_mg   Manganese_mg   Selenium_µg   Vit_C_mg   Thiamin_mg   Riboflavin_mg   Niacin_mg   Panto_Acid_mg   Vit_B6_mg   Energ_Kcal  Shrt_Desc                                                  NDB_No        score   scaled_score
------------------------------  -----------------  -------  -------------  -----  ------------  ----------  -------------  ---------  ----------  -----------  --------  -------------  --------------  -------------  --------  ----------  -------------  ------------  ---------  -----------  --------------  ----------  --------------  ----------  -----------  ---------------------------------------------------------  -------  ----------  -------------
RUTABAGAS                                       1   170.00         170.00   2.26          0.18           5              0      0.029        0.93           18      0.18             10              41            216      0.12       0.029          0.097           0.7       18.8        0.082           0.041       0.715           0.155       0.102           30  RUTABAGAS,CKD,BLD,DRND,WO/SALT                             11436     -2861.039      0.6147894
SALMON                                          1    85.00          85.00   9.02          7.31          75             44      1.644       20.47          239      1.06             29             326            377      1.02       0.084          0.030          35.4        0.0        0.016           0.193       5.480           0.550       0.300          153  SALMON,SOCKEYE,CND,WO/SALT,DRND SOL W/BONE                 15182     -3913.498      1.1090489
BROADBEANS                                      1   109.00         109.00   3.93          0.60          50              0      0.138        5.60           22      1.90             38              95            250      0.58       0.074          0.320           1.2       33.0        0.170           0.110       1.500           0.086       0.038           72  BROADBEANS,IMMAT SEEDS,RAW                                 11088     -4250.264      0.4652428
GELATIN DSSRT                                   1    85.00          85.00   1.96          0.00         466              0      0.000        7.80            3      0.13              2             141              7      0.01       0.118          0.011           6.7        0.0        0.003           0.041       0.009           0.014       0.001          381  GELATIN DSSRT,DRY MIX                                      19172     -4938.439     -0.8503611
COWPEAS                                         1   171.00         171.00   2.77          0.71         255              0      0.185        8.13           26      3.05             96             142            375      1.87       0.271          0.473           2.5        0.4        0.162           0.046       0.714           0.386       0.092          117  COWPEAS,CATJANG,MATURE SEEDS,CKD,BLD,W/SALT                16361     -2687.950      0.9456888
CRACKERS                                        1    30.00          30.00   3.41         11.67        1167              0      3.333       10.00           67      4.80             22             162            141      0.90       0.118          0.517          26.2        0.0        1.087           0.750       7.170           0.528       0.044          418  CRACKERS,CHS,RED FAT                                       18965     -4906.367     -0.7890484
PORK                                            1   113.00         113.00   8.52         32.93          94            100     11.311       22.83           20      1.15             19             192            280      2.58       0.038          0.013          38.0        0.0        0.341           0.488       7.522           0.984       0.508          393  PORK,GROUND,72% LN / 28% FAT,CKD,CRUMBLES                  10974     -2981.649      0.3842142
SPICES                                          1     0.70           0.70   9.03          4.07          76              0      2.157       22.98         2240     89.80            711             274           2630      7.10       2.100          9.800           3.0        0.8        0.080           1.200       4.900           0.838       1.340          233  SPICES,BASIL,DRIED                                         02003     -4643.583     -0.2866766
RAVIOLI                                         1   242.00         242.00   7.63          1.45         306              3      0.723        2.48           33      0.74             15              50            232      0.36       0.142          0.176           3.5        0.0        0.074           0.080       1.060           0.272       0.102           77  RAVIOLI,CHEESE-FILLED,CND                                  22899     -4617.693     -0.2371810
LUXURY LOAF                                     1    28.00          28.00   4.64          4.80        1225             36      1.580       18.40           36      1.05             20             185            377      3.05       0.100          0.041          21.5        0.0        0.707           0.297       3.482           0.515       0.310          141  LUXURY LOAF,PORK                                           07060     -4852.980     -0.6869870
BEVERAGES                                       1   240.00         240.00   7.47          1.04          63              0      0.000        0.42          188      0.30              7               8             50      0.63       0.017          0.033           0.1        0.0        0.015           0.177       0.075           0.009       0.003           38  BEVERAGES,ALMOND MILK,SWTND,VANILLA FLAVOR,RTD             14016     -2916.226      0.5092852
ONIONS                                          1   210.00         210.00   4.83          0.05           8              0      0.009        0.71           27      0.34              8               2            101      0.09       0.024          0.040           0.4        5.1        0.016           0.018       0.132           0.078       0.070           28  ONIONS,FRZ,WHL,CKD,BLD,DRND,WO/SALT                        11290     -4397.386      0.1839856
PIZZA HUT 14" PEPPERONI PIZZA                   1   113.00         113.00   5.69         13.07         676             23      4.823       11.47          147      2.57             22             193            187      1.36       0.104          0.425          15.5        1.0        0.420           0.210       3.750           0.323       0.090          291  PIZZA HUT 14" PEPPERONI PIZZA,PAN CRUST                    21297     -4832.658     -0.6481376
BEANS                                           1   104.00         104.00   8.77          0.70          13              0      0.085        6.15           15      1.93            101             100            307      0.89       0.356          0.408           0.6       18.8        0.390           0.215       1.220           0.825       0.191           67  BEANS,NAVY,MATURE SEEDS,SPROUTED,RAW                       11046     -4122.162      0.7101393
GRAPE JUC                                       1   253.00         253.00   4.53          0.13           5              0      0.025        0.37           11      0.25             10              14            104      0.07       0.018          0.239           0.0        0.1        0.017           0.015       0.133           0.048       0.032           60  GRAPE JUC,CND OR BTLD,UNSWTND,WO/ ADDED VIT C              09135     -4343.103      0.2877596
PIE                                             1    28.35          28.35   1.75         12.50         211              0      3.050        2.40            7      1.12              7              28             79      0.19       0.053          0.185           7.8        1.7        0.148           0.107       1.230           0.093       0.032          265  PIE,APPL,PREP FROM RECIPE                                  18302     -4710.654     -0.4148992
PORK                                            1    85.00          85.00   2.46          2.59          63             63      0.906       22.81            9      0.56             23             251            354      1.72       0.069          0.011          37.4        0.0        0.610           0.256       7.348           0.728       0.611          121  PORK,FRSH,LOIN,SIRLOIN (CHOPS OR ROASTS),BNLESS,LN,RAW     10214     -4192.317      0.5760225
FAST FOODS                                      1   226.00         226.00   5.02         11.75         350             54      4.654       15.17           45      2.59             22             139            252      2.51       0.097          0.110          11.3        0.5        0.160           0.170       3.350           0.240       0.240          239  FAST FOODS,HAMBURGER; DOUBLE,LRG PATTY; W/ CONDMNT & VEG   21114     -4517.685     -0.0459943


Wholesale swap

```r
our_random_menu %>% wholesale_swap() %>% kable()
```

```
## Swapping out a random 50% of foods: LUXURY LOAF, CRACKERS, CANDIES, SPICES, PORK, GRAPE JUC, PIE, PIZZA HUT 14" PEPPERONI PIZZA, FAST FOODS
```

```
## Swap candidate is good enough. Doing the wholesale swap.
```



shorter_desc     solution_amounts   GmWt_1   serving_gmwt   cost   Lipid_Tot_g   Sodium_mg   Cholestrl_mg   FA_Sat_g   Protein_g   Calcium_mg   Iron_mg   Magnesium_mg   Phosphorus_mg   Potassium_mg   Zinc_mg   Copper_mg   Manganese_mg   Selenium_µg   Vit_C_mg   Thiamin_mg   Riboflavin_mg   Niacin_mg   Panto_Acid_mg   Vit_B6_mg   Energ_Kcal  Shrt_Desc                                                      NDB_No        score   scaled_score
--------------  -----------------  -------  -------------  -----  ------------  ----------  -------------  ---------  ----------  -----------  --------  -------------  --------------  -------------  --------  ----------  -------------  ------------  ---------  -----------  --------------  ----------  --------------  ----------  -----------  -------------------------------------------------------------  -------  ----------  -------------
POTATOES                        1   245.00         245.00   2.14          3.68         335             12      2.255        2.87           57      0.57             19              63            378      0.40       0.163          0.166           1.6       10.6        0.069           0.092       1.053           0.514       0.178           88  POTATOES,SCALLPD,HOME-PREPARED W/BUTTER                        11372     -2927.267      0.4881786
TURKEY BREAST                   1    85.00          85.00   6.73          3.46         397             42      0.980       22.16            9      0.66             21             214            248      1.53       0.041          0.015          25.7        0.0        0.053           0.133       9.067           0.489       0.320          126  TURKEY BREAST,PRE-BASTED,MEAT&SKN,CKD,RSTD                     05293     -3281.581     -0.1891749
SNACKS                          1    28.35          28.35   5.17         49.60        1531            133     20.800       21.50           68      3.40             21             180            257      2.42       0.130          0.086            NA        6.8        0.141           0.436       4.540           0.328       0.205          550  SNACKS,BF STKS,SMOKED                                          19407     -3705.245     -0.9991068
BEEF                            1    85.00          85.00   3.65          7.67          81             70      3.419       20.87           15      2.31             18             195            330      7.86       0.092          0.014          21.9        0.0        0.070           0.190       4.097           0.680       0.355          152  BEEF,CHUCK EYE COUNTRY-STYLE RIBS,BNLESS,LN,0" FAT,CHOIC,RAW   23072     -2987.803      0.3724493
WHEAT FLR                       1       NA             NA   8.78          1.45           2             NA      0.268       11.50           20      5.06             30             112            138      0.84       0.161          0.679          27.5        0.0        0.736           0.445       5.953           0.405       0.032          363  WHEAT FLR,WHITE (INDUSTRIAL),11.5% PROT,UNBLEACHED,ENR         20636     -3374.000     -0.3658548
OKARA                           1   122.00         122.00   7.81          1.73           9              0      0.193        3.52           80      1.30             26              60            213      0.56       0.200          0.404          10.6        0.0        0.020           0.020       0.100           0.088       0.115           76  OKARA                                                          16130     -2904.295      0.5320946
CHICKEN                         1   140.00         140.00   3.23         13.60          82             88      3.790       27.30           15      1.26             23             182            223      1.94       0.066          0.020          23.9        0.0        0.063           0.168       8.487           1.030       0.400          239  CHICKEN,BROILERS OR FRYERS,MEAT&SKN,CKD,RSTD                   05009     -2925.658      0.4912538
FISH                            1       NA             NA   8.00         12.95         870             67      2.440       23.19           55      0.55             29             270            390      0.77       0.148          0.037          30.5        0.0        0.043           0.201       8.610           0.822       0.378          209  FISH,SALMON,KING,W/ SKN,KIPPERED,(ALASKA NATIVE)               35168     -3374.000     -0.3658548
KRAFT                           1    28.00          28.00   8.65          4.10        1532              4      0.800       12.60           63      4.32             NA             129            267        NA          NA             NA            NA        3.3        0.390           0.290       3.840              NA          NA          381  KRAFT,STOVE TOP STUFFING MIX CHICKEN FLAVOR                    18567     -3670.005     -0.9317363


### Full Solving


```r
fully_solved <- build_menu() %>% solve_full(verbose = FALSE)
fully_solved %>% kable()
```



shorter_desc      solution_amounts       GmWt_1   serving_gmwt        cost   Lipid_Tot_g   Sodium_mg   Cholestrl_mg   FA_Sat_g   Protein_g   Calcium_mg   Iron_mg   Magnesium_mg   Phosphorus_mg   Potassium_mg   Zinc_mg   Copper_mg   Manganese_mg   Selenium_µg   Vit_C_mg   Thiamin_mg   Riboflavin_mg   Niacin_mg   Panto_Acid_mg   Vit_B6_mg   Energ_Kcal  Shrt_Desc                                                      NDB_No        score   scaled_score
---------------  -----------------  -----------  -------------  ----------  ------------  ----------  -------------  ---------  ----------  -----------  --------  -------------  --------------  -------------  --------  ----------  -------------  ------------  ---------  -----------  --------------  ----------  --------------  ----------  -----------  -------------------------------------------------------------  -------  ----------  -------------
LAMB                             1    114.00000          114.0    8.510000          4.73          73             76      1.857       23.42            2      2.27             26             210            311      2.32       0.128          0.006           8.1        0.0        0.147           0.380       8.490           0.880       0.556          136  LAMB,AUSTRALIAN,IMP,FRSH,TENDERLOIN,BNLESS,LN,1/8" FAT,RAW     17443     -2872.275      0.5933092
CHI FORMU                        1     31.00000           31.0    5.410000          4.70          36              2      1.256        2.80           92      1.32             19              80            124      0.56       0.106          0.144           3.0        9.6        0.256           0.200       0.960           0.960       0.248           99  CHI FORMU,ABBT NUTR,PEDIASU,RTF,W/ IRON & FIB (FORMER ROSS)    03870     -3283.729     -0.1932802
PUMPKIN LEAVES                   1    360.87918           39.0   15.175432          0.40          11              0      0.207        3.15           39      2.22             38             104            436      0.20       0.133          0.355           0.9       11.0        0.094           0.128       0.920           0.042       0.207           19  PUMPKIN LEAVES,RAW                                             11418     -3130.351      0.0999373
TANGERINES                       1   2958.09865          252.0   90.973272          0.10           6              0      0.012        0.45            7      0.37              8              10             78      0.24       0.044          0.032           0.4       19.8        0.053           0.044       0.445           0.125       0.042           61  TANGERINES,(MANDARIN ORANGES),CND,LT SYRUP PK                  09220     -3074.289      0.2071124
CEREALS RTE                      1     39.30006           27.0    7.132233          4.50         639              0      1.000        8.80          370     16.70             89             222            230     13.90       0.253          2.320          18.5       22.2        1.400           1.600      18.500           0.749       1.852          378  CEREALS RTE,GENERAL MILLS,BERRY BURST CHEERIOS,TRIPLE BERRY    08239     -3273.216     -0.1731829
EGG CUSTARDS                     1    141.00000          141.0    1.490000          2.83          87             49      1.475        4.13          146      0.33             17             137            214      0.61       0.012          0.016           4.9        0.2        0.056           0.235       0.135           0.683       0.066          112  EGG CUSTARDS,DRY MIX,PREP W/ 2% MILK                           19205     -2831.054      0.6721117
PUDDINGS                         1    140.00000          140.0    7.760000          2.90         156              9      1.643        2.80           99      0.04              9              74            119      0.33       0.025          0.005           3.3        0.0        0.036           0.149       0.078           0.326       0.028          113  PUDDINGS,VANILLA,DRY MIX,REG,PREP W/ WHL MILK                  19207     -3179.996      0.0050279
INF FORMULA                      1      9.60000            9.6    7.950000         27.65         154              0     11.430       15.36          998     10.20             46             666            768      3.84       0.461          0.026           9.2       61.0        0.512           0.768       5.376           2.304       0.307          512  INF FORMULA, ABB NUTR, SIMIL, GO & GR, PDR, W/ ARA & DHA       33871     -3144.150      0.0735572
SEA BASS                         1    129.00000          129.0    7.590000          2.00          68             41      0.511       18.43           10      0.29             41             194            256      0.40       0.019          0.015          36.5        0.0        0.110           0.120       1.600           0.750       0.400           97  SEA BASS,MXD SP,RAW                                            15091     -2795.921      0.7392762
WHEAT FLR                        1    125.00000          125.0    2.590000          0.98           2              0      0.155       10.33           15      1.17             22             108            107      0.70       0.144          0.682          33.9        0.0        0.120           0.040       1.250           0.438       0.044          364  WHEAT FLR,WHITE,ALL-PURPOSE,UNENR                              20481     -3001.896      0.3455075
BEANS                            1    179.00000          179.0    8.910000          0.64         238              0      0.166        8.97           73      2.84             68             169            463      1.09       0.149          0.510           1.3        0.0        0.236           0.059       0.272           0.251       0.127          142  BEANS,SML WHITE,MATURE SEEDS,CKD,BLD,W/SALT                    16346     -2389.504      1.5162376
MILK                             1    245.00000          245.0    1.140000          1.98          59              8      1.232        3.95          143      0.06             15             112            182      0.41       0.011          0.002           2.6        1.1        0.045           0.194       0.101           0.339       0.046           56  MILK,RED FAT,FLUID,2% MILKFAT,W/ NONFAT MILK SOL,WO/ VIT A     01152     -2416.917      1.4638299
BEANS                            1    169.00000          169.0    9.960000          0.49           2              0      0.126        9.06           52      2.30             65             165            508      0.96       0.271          0.548           1.4        0.0        0.257           0.063       0.570           0.299       0.175          149  BEANS,PINK,MATURE SEEDS,CKD,BLD,WO/SALT                        16041     -2016.445      2.2294253
BEEF                             1     85.00000           85.0    3.950000          9.04          64             64      3.544       21.22            9      1.96             21             152            275      4.89       0.073          0.073          21.1        0.0        0.100           0.269       5.080           0.540       0.488          166  BEEF,RIB EYE STK/RST,BONE-IN,LIP-ON,LN,1/8" FAT,ALL GRDS,RAW   23150     -3057.622      0.2389742
DESSERTS                         1    141.00000          141.0    3.140000          3.43         351              0      0.685        1.75           35      0.82              8              28             78      0.18       0.071          0.130           3.5        2.2        0.083           0.081       0.846           0.092       0.040          161  DESSERTS,APPL CRISP,PREPARED-FROM-RECIPE                       19186     -3650.814     -0.8950487


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
simulate_menus()
```

```
## Cost is $387.15.
```

```
## No optimal solution found :'(
```

```
## Cost is $157.15.
```

```
## No optimal solution found :'(
```

```
## Cost is $47.58.
```

```
## No optimal solution found :'(
```

```
## Cost is $180.36.
```

```
## No optimal solution found :'(
```

```
## Cost is $222.55.
```

```
## No optimal solution found :'(
```

```
## Cost is $206.2.
```

```
## Optimal solution found :)
```

```
## Cost is $248.6.
```

```
## No optimal solution found :'(
```

```
## Cost is $88.22.
```

```
## Optimal solution found :)
```

```
## Cost is $41.9.
```

```
## No optimal solution found :'(
```

```
## Cost is $117.17.
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
simulate_spectrum() %>% kable()
```



 min_amount   status
-----------  -------
       -1.0        0
       -1.0        0
       -0.8        0
       -0.8        0
       -0.6        0
       -0.6        0
       -0.4        1
       -0.4        0
       -0.2        1
       -0.2        0
        0.0        0
        0.0        0
        0.2        0
        0.2        0
        0.4        1
        0.4        0
        0.6        1
        0.6        1
        0.8        1
        0.8        1
        1.0        1
        1.0        1



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
a_couple_recipes_df %>% kable()
```



ingredients                                                                             recipe_name                                                            
--------------------------------------------------------------------------------------  -----------------------------------------------------------------------
1 (12 inch) pre-baked pizza crust                                                       Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza 
1 1/2 cups shredded mozzarella cheese                                                   Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza 
1 (14 ounce) jar pizza sauce                                                            Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza 
1 (12 ounce) package Johnsonville® Three Cheese Italian Style Chicken Sausage, sliced   Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza 
1 (3.5 ounce) package sliced pepperoni                                                  Johnsonville® Three Cheese Italian Style Chicken Sausage Skillet Pizza 
3 teaspoons peanut oil, divided                                                         Ginger Fried Rice                                                      
4 large eggs, beaten                                                                    Ginger Fried Rice                                                      
1 bunch scallions, chopped                                                              Ginger Fried Rice                                                      
2 tablespoons minced fresh ginger                                                       Ginger Fried Rice                                                      
3 cups cold cooked long-grain brown rice                                                Ginger Fried Rice                                                      
1 cup frozen peas                                                                       Ginger Fried Rice                                                      
1 cup mung bean sprouts (see Note)                                                      Ginger Fried Rice                                                      
3 tablespoons prepared stir-fry or oyster sauce                                         Ginger Fried Rice                                                      


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
some_recipes_tester %>% kable()
```



|ingredients                                            |
|:------------------------------------------------------|
|1.2 ounces or maybe pounds of something with a decimal |
|3 (14 ounce) cans o' beef broth                        |
|around 4 or 5 eels                                     |
|5-6 cans spam                                          |
|11 - 46 tbsp of sugar                                  |
|1/3 to 1/2 of a ham                                    |
|5 1/2 pounds of apples                                 |
|4g cinnamon                                            |
|about 17 fluid ounces of wine                          |
|4-5 cans of 1/2 caf coffee                             |
|3 7oz figs with 1/3 rind                               |


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
some_recipes_tester %>% get_portion_values() %>% kable()
```



ingredients                                               range_portion   mult_add_portion   portion
-------------------------------------------------------  --------------  -----------------  --------
1.2 ounces or maybe pounds of something with a decimal             0.00                0.0      1.20
3 (14 ounce) cans o' beef broth                                    0.00               42.0     42.00
around 4 or 5 eels                                                 4.50                0.0      4.50
5-6 cans spam                                                      5.50                0.0      5.50
11 - 46 tbsp of sugar                                             28.50                0.0     28.50
1/3 to 1/2 of a ham                                                0.42                0.0      0.42
5 1/2 pounds of apples                                             0.00                5.5      5.50
4g cinnamon                                                        0.00                0.0      4.00
about 17 fluid ounces of wine                                      0.00                0.0     17.00
4-5 cans of 1/2 caf coffee                                         4.50                0.0      4.50
3 7oz figs with 1/3 rind                                           0.00               21.0     21.00

Looks pretty solid.

Now onto easier waters: portion names. You can check out `/scripts/scrape/get_measurement_types.R` if you're interested in the steps I took to find some usual portion names and create an abbreviation dictionary, `abbrev_dict`. What we also do there is create `measures_collapsed` which is a single vector of all portion names separated by "|" so we can find all the portion names that might occur in a given item.


```r
measures_collapsed
```

```
## [1] "[[:digit:]]oz |[[:digit:]]pt |[[:digit:]]lb |[[:digit:]]kg |[[:digit:]]g |[[:digit:]]l |[[:digit:]]dl |[[:digit:]]ml |[[:digit:]] oz |[[:digit:]] pt |[[:digit:]] lb |[[:digit:]] kg |[[:digit:]] g |[[:digit:]] l |[[:digit:]] dl |[[:digit:]] ml |ounce|pint|pound|kilogram|gram|liter|deciliter|milliliter"
```

Then if there are multiple portions that match, we'll take the last one.

We'll also add `approximate` to our dataframe which is just a boolean value indicating whether this item is exact or approximate. If the item contains one of `approximate` then we give it a TRUE.


```r
approximate
```

```
## [1] "about|around|as desired|as needed|optional|or so|to taste"
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
some_recipes_tester %>% get_portions() %>% add_abbrevs() %>% kable()
```



ingredients                                              raw_portion_num   portion_name   approximate    range_portion   mult_add_portion   portion  portion_abbrev 
-------------------------------------------------------  ----------------  -------------  ------------  --------------  -----------------  --------  ---------------
1.2 ounces or maybe pounds of something with a decimal   1.2               pound          FALSE                   0.00                0.0      1.20  lb             
3 (14 ounce) cans o' beef broth                          3, 14             ounce          FALSE                   0.00               42.0     42.00  oz             
around 4 or 5 eels                                       4, 5                             TRUE                    4.50                0.0      4.50                 
5-6 cans spam                                            5, 6                             FALSE                   5.50                0.0      5.50                 
11 - 46 tbsp of sugar                                    11, 46                           FALSE                  28.50                0.0     28.50                 
1/3 to 1/2 of a ham                                      1/3, 1/2                         FALSE                   0.42                0.0      0.42                 
5 1/2 pounds of apples                                   5, 1/2            pound          FALSE                   0.00                5.5      5.50  lb             
4g cinnamon                                              4                 g              FALSE                   0.00                0.0      4.00  g              
about 17 fluid ounces of wine                            17                ounce          TRUE                    0.00                0.0     17.00  oz             
4-5 cans of 1/2 caf coffee                               4, 5, 1/2                        FALSE                   4.50                0.0      4.50                 
3 7oz figs with 1/3 rind                                 3, 7, 1/3         oz             FALSE                   0.00               21.0     21.00  oz             


We've got some units! Next step will be to convert all units into grams. 

## NLP







