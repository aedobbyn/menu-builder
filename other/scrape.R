library(tidyverse)
library(rvest)
library(hash)

example_url <- "http://allrecipes.com/recipe/244950/baked-chicken-schnitzel/"
schnitzel <- example_url %>% get_recipes()
example_url %>% try_read() %>% get_recipe_name()

base_url <- "http://allrecipes.com/recipe/"
urls <- grab_urls(base_url, 244940:244950)

grab_urls <- function(base_url, id) {
  id <- as.character(id)
  recipe_url <- str_c(base_url, id)
  return(recipe_url)
}

remove_whitespace <- function(str) {
  str <- str %>% str_split(" ") %>% as_vector()
  str <- str[!str == ""]
  str <- str_c(str, collapse = " ")
  return(str)
}

# Get the recipe title
# Takes a page (a url that's been read_html'd)
get_recipe_name <- function(page) {
  recipe_name <- page %>% 
    html_nodes(".recipe-summary__h1") %>% 
    html_text() 
  return(recipe_name)
}

# Get the recipe content
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

# Safe reading -- don't error if we've got a bad URL, just tell us, don't exit the loop
read_url <- function(url) {
  page <- read_html(url)
}
try_read <- possibly(read_url, otherwise = "Bad URL", quiet = TRUE)

# Get recipe content and name it with the recipe title
get_recipes <- function(url, obj) {
  
  recipe_page <- try_read(url)
  
  if(recipe_page == "Bad URL" | 
     (!class(recipe_page) %in% c("xml_document", "xml_node"))) { 
    recipe_df <- recipe_page
    
  } else {
    recipe <- recipe_page %>% 
      get_recipe_content() %>% 
      map(remove_whitespace) %>% as_vector()
    
    recipe_name <- get_recipe_name(recipe_page)
    
    recipe_df <- list(this_name = recipe) %>% as_tibble()   # could do with deparse(recipe_name)?
    names(recipe_df) <- recipe_name
  } 
  
  out <- append(obj, recipe_df)
}

some_recipes <- c(urls[1:3], bad_url) %>% map(get_recipes)

# Test that our bad URL doesn't error out
expect_equal(get_recipes(bad_url), "Bad URL")



# Most IDs seem to start with 1 or 2 and be either 5 or 6 digits long
# Some 
more_urls <- grab_urls(base_url, 10000:15000)
more_recipes <- more_urls %>% map(get_recipes)


# Take our list of recipes and make them into a dataframe with 
dfize <- function(lst) {
  df <- NULL
  lst <- lst[!lst == "Bad URL"]
  
  for (i in seq_along(lst)) {
      recipe_name <- names(lst[[i]])
      names(lst[[i]]) <- "ingredients"
      this_df <- lst[[i]] %>% 
        mutate(recipe_name = recipe_name)
      df <- df %>% bind_rows(this_df)
  }
  return(df)
}

some_recipes_df <- dfize(some_recipes)
# write_feather(some_recipes_df, "./data/some_recipes_df.feather")


# ---------------
# Measurement types
measurement_url <- "https://www.convert-me.com/en/convert/cooking/"

measurement_types_raw <- measurement_url %>% 
  read_html() %>% 
  html_nodes(".usystem") %>% 
  html_text()

measurement_types <- measurement_types_raw %>% 
  str_replace_all("\n", "") %>% 
  str_replace_all("/", "") %>%
  str_replace_all("Units:" , "")  %>% 
  str_replace_all("U.S." , "")  %>% 
  str_replace_all("British" , "")  %>% 
  str_replace_all("\\(" , "") %>% 
  str_replace_all("\\)" , "")

measurement_types <- measurement_types[1:2] # third contains no more information

for (i in seq_along(measurement_types)) {
  measurement_types[i] <- substr(measurement_types[i], 42, nchar(measurement_types[i]))
}

measurement_types <- measurement_types %>% remove_whitespace() %>% 
  str_split(" ") %>% unlist() %>% map_chr(str_replace_all, "[[:space:]]", "") 
measurement_types <- measurement_types[which(measurement_types != " " | measurement_types != "")] 
measurement_types <- list(name = measurement_types) %>% as_tibble() %>% 
  distinct() %>% 
  filter(! name %in% c("dessert", "spoon", "fluid", "fl") & nchar(name) > 0) 

measurement_types %>% print(n = nrow(.))
measures_collapsed <- measurement_types$name %>% str_c(collapse = "|")


needs_abbrev <- c("tablespoon", "teaspoon", "cup")
abbrevs_needed <- c("tbsp", "tsp", "c")
extra_measurements <- list(name = needs_abbrev, key = abbrevs_needed) %>% as_tibble()

measurement_types <- measurement_types %>% filter(!name %in% needs_abbrev) 
abbrev_dict <- measurement_types %>%  mutate(
  rownum = 1:nrow(.),
  key = ifelse(rownum %% 2 != 0, lead(name), name)
  ) %>% 
  filter(!name == key) %>% 
  select(-rownum) 
abbrev_dict <- abbrev_dict %>% bind_rows(extra_measurements)

# measurement_types <- c(measurement_types, "fluid oz", "fl oz", "fluid ounce")


# ---------------

# Match any number, even if it has a decimal or slash in it
portions_reg <- "[[:digit:]]+\\.*[[:digit:]]*+\\/*[[:digit:]]*"

# Turn fractions into decimals but keep them as character so we can put this in pipeline before 
# the as.numeric() call
frac_to_dec <- function(e) {
  out <- parse(text = e) %>% eval() %>% as.character()
  return(out)
}

# We need this because eval() in frac_to_dec() only evaluates the last string in a vector, not both
map_frac_to_dec <- function(e) {
  out <- NULL
  for (i in e) {
      out <- e %>% map_chr(frac_to_dec)
  }
  return(out)
}


# Multiply all numbers by each other, unless they're a range or a complex fraction
# e.g., if we've got 3 (14 ounce) cans beef broth we want to know we need 42 oz
multiply_or_add_portions <- function(e) {
  out <- e %>% map_chr(frac_to_dec) %>% as.numeric() 
  if (length(e) > 1) {
    if (e[2] < 1) {  # If our second element is a fraction, we know this is a complex fraction so we add the two
      out <- out %>% reduce(`+`)
    } else {   # Otherwise, we multiply them
      out <- out %>% reduce(`*`)
    }   
  }
  return(out)
}

# If two numbers are separated by an "or" or a "-" we know that this is a range,
# e.g., 4-5 teaspoons of sugar. So we want to say that this

# Regex for " or ", "-", " - " appearing between two numbers
to_reg <- "([0-9])(( to ))(([0-9]))"
or_reg <- "([0-9])(( or ))(([0-9]))"
dash_reg_1 <- "([0-9])((-))(([0-9]))"
dash_reg_2 <- "([0-9])(( - ))(([0-9]))"

# --- Attempt to combine these, but lookaheads/behinds don't work
# is_range_reg <- "(?<=[0-9])((-)*\n?)(( - )*\n?)(( to )*\n?)(?=([0-9]))" 
# range_splitters <- c(" to ",  or ", "-", " - ") %>% 
#   str_c(collapse = "|")

# Logical indicating whether the amount is exact or not
approximate <- c("about", "around", "as desired", "as needed", "optional",  "or so", "to taste") %>% 
  str_c(collapse = "|")


# Putting it together, we get portion names and amounts
get_portions <- function(df) {
  df <- df %>% 
    mutate(
      raw_portion_num = str_extract_all(ingredients, portions_reg, simplify = FALSE) %>%   # Extract the raw portion numbers,
        map_chr(str_c, collapse = ", ", default = ""),   # separating by comma if multiple
      
      
      portion_num = if_else(str_detect(ingredients, pattern = to_reg) | 
                              str_detect(ingredients, pattern = or_reg) |
                                str_detect(ingredients, pattern = dash_reg_1) |
                                   str_detect(ingredients, pattern = dash_reg_2),  
                            
          # If we've got a range, (e.g., 3-4 cloves of garlic) take the average of the two, so 3.5                  
          str_extract_all(ingredients, portions_reg) %>%  
            
            map(str_split, pattern = " to ", simplify = FALSE) %>%  # Split out numbers
            map(str_split, pattern = " - ", simplify = FALSE) %>%  # See if we can find a more elegant way of doing this, maybe with range_splitters
            map(str_split, pattern = "-", simplify = FALSE) %>%
            
            modify_depth(2, frac_to_dec) %>%  # same as map(map_frac_to_dec)
            map(as.numeric) %>% 
            map_dbl(mean) %>% round(digits = 2),
          
          # Otherwise, if there are two numbers, we multiply them (i.e., 6 12oz bottles of beer)
          str_extract_all(ingredients, portions_reg) %>%  # Get all numbers in a list
            map(map_frac_to_dec) %>%   # not same as modify_depth(1, frac_to_dec)
            map(as.numeric) %>%   # Convert fractions to decimals
            map_dbl(multiply_or_add_portions) %>% round(digits = 2)  # Multiply all numbers 
      ),
      
      portion_name = str_extract_all(ingredients, measures_collapsed) %>% 
        map_chr(str_c, collapse = ", ", default = ""),   # If there are multiple arguments that match, separate them with a ,
      
      portion_abbrev = ifelse(portion_name %in% abbrev_dict$name, 
                            abbrev_dict[which(abbrev_dict$name == portion_name), ]$key, 
                            portion_name),  
      
      approximate = str_detect(ingredients, approximate)
    )
  return(df)
}

get_portions(some_recipes_df) %>% View()



# Test it
some_recipes_tester <- list(ingredients = vector()) %>% as_tibble()
some_recipes_tester[1, ] <- "1.2 ounces or maybe pounds of something with a decimal"
some_recipes_tester[2, ] <- "3 (14 ounce) cans o' beef broth"
some_recipes_tester[3, ] <- "around 4 or 5 eels"
some_recipes_tester[4, ] <- "5-6 cans spam"
some_recipes_tester[5, ] <- "11 - 46 tablespoons of sugar"
some_recipes_tester[6, ] <- "1/3 to 1/2 of a ham"
some_recipes_tester[7, ] <- "5 1/2 apples"



tester_w_portions <- get_portions(some_recipes_tester) 
expect_equal(tester_w_portions[1, ]$portion_name, "ounce, pound")


get_portions(some_recipes_tester)





