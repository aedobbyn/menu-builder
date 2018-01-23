
# Artifically hard dataframe
some_recipes_tester <- list(ingredients = vector()) %>% as_tibble()
some_recipes_tester[1, ] <- "1.2 ounces or maybe pounds of something with a decimal"
some_recipes_tester[2, ] <- "3 (14 ounce) cans o' beef broth"
some_recipes_tester[3, ] <- "around 4 or 5 eels"
some_recipes_tester[4, ] <- "5-6 cans spam"
some_recipes_tester[5, ] <- "11 - 46 tbsp of sugar"
some_recipes_tester[6, ] <- "1/3 to 1/2 of a ham"
some_recipes_tester[7, ] <- "5 1/2 pounds of apples"
some_recipes_tester[8, ] <- "4g cinnamon"
some_recipes_tester[9, ] <- "about 17 fluid ounces of wine"
some_recipes_tester[10, ] <- "4-5 cans of 1/2 caf coffee"
some_recipes_tester[11, ] <- "3 7oz figs with 1/3 rind"