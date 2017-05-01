# Menu Builder

Various forays into daily menu planning and optimization using the [USDA food database](https://ndb.nal.usda.gov/ndb/doc/index).


## Main Files
* `abbrev.R`
    * Reads in the abbreviated version of the USDA food database and prepares it a bit
        * Adds daily guidelines for
            * "Must restricts" (i.e. macros that have an daily upper limit)
            * "Positive nutrients" (i.e. micronutrients that have a daily lower bound)
* `menu_builder.R`
	* Sources from `abbrev.R`
	* Adds random foods recursively (1 serving size per food) until we reach 2300 calories (the daily minimum)
    * Then tests for compliance on the three dimensions we care about: must restricts, positives, and calorie content
    * Then creates a USDA-compliant menu by staying above 2300 calories while:
        * Looping through must restricts
            * If the daily value of that must restrict is over the max limit, swap out a random food for the "worst offender" until we're compliant
        * Looping through positives
            * If the combined amount of that nutrient in our menu is below the minimum, find the food in our menu that is highest in this positive nutrient per gram and increase its amount by 10% until we're above that nutrient threshold

* Potential future improvements
    * Implement a calorie ceiling in addition to the floor of 2300
    * Balance menus by food group
    * Restrictor function: smart swaps rather than random swaps
        * Maybe foods containing <= 1 standard deviation below the mean per gram of the must restrict
    * Spread the portion adjustment across multiple foods once we hit a certain threshold rather than increasing only the best food incrementally by 10%
    * Build three distinct meals per menu
        * Incorporate food flavor profiles to increase flavor consistency within a meal

***


* `add_to_db.R`
	* Recursively sends GET requests to the USDA API (in chunks of max 1500 rows at a time), getting JSON in return
	* Tidies the JSON and that single chunk to a database (Postgres first, MySQL later)
	    * Using this method only one chunk is kept in memory at once
