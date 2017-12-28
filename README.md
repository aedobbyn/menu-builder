# Menu Builder

Daily menu planning and optimization using the [USDA food database](https://ndb.nal.usda.gov/ndb/doc/index).



## Structure
* `api`
   * Grab data from the USDA API
	* Recursively sends GET requests to the USDA API (in chunks of max 1500 rows at a time)
	* Tidy the JSON and send that chunk to a database (Postgres, MySQL) such that only one chunk is kept in memory at a time
* `data`
    * Raw abbreviated data in `ABBREV.csv`
        * Normalized in `scaled.csv`
    * Daily nutrient constraints in `all_nut_and_mr_df.csv`
* `menu-builder`
    * Shiny app for building a random menu and tweaking it into compliance
* `scripts`
    * `prep`
        * Read in, clean, and standardize data
        * Adds daily guidelines for
            * "Must restricts" (i.e. macros that have an daily upper limit)
            * "Positive nutrients" (i.e. micronutrients that have a daily lower bound)
    * `build.R` sources all scripts in `build_menu`
        * `build_menu.R` adds random foods (1 serving size per food) until we reach 2300 calories (the daily minimum)
        * `test_compliance.R` tests for compliance on the three dimensions we care about: must restricts, positives, and calorie content
        * `smart_swap.R` loops through must restricts; if the daily value of that must restrict is over the max limit, until we're compliant, swap out the "worst offender" that respect and replace it  
               * if possible, with a food from our corpus that is < 0.5 standard deviations below the mean per gram on that nutrient
               * else, with a random food 
        * `adjust_portion_sizes.R` is a brute force alternative to a linear programming solver that only addresses positive nutrients
            * If the combined amount of a nutrient in our menu is below the minimum, find the food in our menu that is highest in this positive nutrient per gram and increase its amount by 10% until we're above that particular nutrient threshold
            * `adjust_portion_sizes_and_square_calories.R` does the same while decreasing the total calorie count in the amount that it was increased by the adjustment
        * `master_builder.R` does all the above while staying above the 2300 calorie minimum
    * `solve.R` sources all scripts in `solve`
        * `solve_it.R` uses the GNU lienar programming solver from the `Rglpk` package to minimize cost while satisfying each nutritional and calorie constraint 
            * First argument is a menu -- with either nutrients in nutrient values per 100g of food or raw gram weight of nutrients, as specified by the `df_is_per_100g` boolean flag
            * Second is a dataframe of nutritional constraints
            * Other levers 
                * Should this be solved with only full portion sizes (integer coefficients on the original portion sizes provided)
                * Upper and lower bounds for each portion size
                * Should you be told the cost and whether we arrived at a feasible solution
         * `solve_menu.R` 
             * Take a solution (from `solve_it()`) and return a menu with the newly solved portion sizes (GmWt_1)
             * Optionally be told which food we've got the most of (largest number of portions) -- something we might want to decrease
         * `solve_nutrients.R`
             * Take a solution and get the raw values of each of the nutrients in the solved menu
             * Optionally be told which nutrient we've overshot the most on 
         * `smart_swap_single.R` loops through must restricts only once and, if we're uncompliant, uses the swapping mechanism in `smart_swap()` to find a suitable replacement

    * `score`
        * Give a given menu a score on must-restricts, positive nutrients, and a combined measure
    * Helpers
        * `get_raw_vals()` and `get_per_g_vals()`, which both take dataframes and a dataframe of nutrients, allow us to go back and forth between nutrients per 100g and raw weight of nutrients using the helper functions 
        * `transpose_menu()` makes foods into columns and nutrients into rows, leaving us with something that looks more like our constraint matrix and can be read left to right
     * `full_scripts` are the legacy scripts containing all building and solving functions; will likely be deprecated soon 
        
            


* Potential future improvements
    * Implement a calorie ceiling in addition to the floor of 2300
    * Balance menus by food group
    * Spread the portion adjustment across multiple foods once we hit a certain threshold rather than increasing only the best food incrementally by 10%
    * Build three distinct meals per menu
        * Incorporate food flavor profiles to increase flavor consistency within a meal
    * Cluster analyses
        * Can we reverse-engineer food groups?
    * Supermenus
        * Take the randomness out: what are the best menus overall? (Lowest in must restricts, highest in nutrients, any serving size)

***



