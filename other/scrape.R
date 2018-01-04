library(tidyverse)
library(stringr)
library(rvest)
library(hash)
library(testthat)

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
get_recipes <- function(url, sleep = 5, trace = TRUE) {
  
  Sys.sleep(sleep)    # Sleep in between requests to avoid 429 (too many requests)
  recipe_page <- try_read(url)
  
  if(recipe_page == "Bad URL" | 
     (!class(recipe_page) %in% c("xml_document", "xml_node"))) { 
    recipe_df <- recipe_page    # If we've got a bad URL, recipe_df will be "Bad URL" because of the othwersie clause
    
  } else {
    recipe <- recipe_page %>% 
      get_recipe_content() %>% 
      map(remove_whitespace) %>% as_vector()
    
    recipe_name <- get_recipe_name(recipe_page)
    if (trace == TRUE) { message(recipe_name) }
    
    recipe_df <- list(tmp_name = recipe) %>% as_tibble()   # could do with deparse(recipe_name)?
    names(recipe_df) <- recipe_name
  } 
  
  recipe_df
  # out <- append(obj, recipe_df)
}

# Get a list of recipes
some_recipes_2 <- c(urls[4:7]) %>% map(get_recipes)

# Test that our bad URL doesn't error out
expect_equal(get_recipes("foo"), "Bad URL")



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

some_recipes_df <- dfize(some_recipes_2)
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

name_measures_collapsed <- abbrev_dict$name %>% str_c(collapse = "|")

abbrev_dict$name %>% str_c(collapse = "\b") %>%
  str_split("\b") %>% str_c(collapse = "[[:digit:]]")

vec_no_spaces <- vector()
vec_w_spaces <- vector()
for (i in abbrev_dict$key) {
  out_no_spaces <- c("[[:digit:]]", i, " ") %>% str_c(collapse = "")    # using " " instead of \b for word boundary
  out_w_spaces <- c("[[:digit:]] ", i, " ") %>% str_c(collapse = "")
  vec_no_spaces <- c(vec_no_spaces, out_no_spaces) 
  vec_w_spaces <- c(vec_w_spaces, out_w_spaces)
}
vec_no_spaces <- str_c(vec_no_spaces, collapse = "|")
vec_w_spaces <- str_c(vec_w_spaces, collapse = "|")
key_all <- str_c(vec_no_spaces, vec_w_spaces, collapse = "|")
measures_collapsed <- str_c(key_all, name_measures_collapsed, collapse = "|")


# ---------------

# Match any number, even if it has a decimal or slash in it
portions_reg <- "[[:digit:]]+\\.*[[:digit:]]*+\\/*[[:digit:]]*"

# Turn fractions into decimals but keep them as character so we can put this in pipeline before 
# the as.numeric() call
frac_to_dec <- function(e) {
  if (length(e) == 0) {    # If NA, make the portion 0
    out <- 0
  } else {
    out <- parse(text = e) %>% eval() %>% as.character()
  }
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
  out <- e 
  if (length(e) == 0) {
    out <- 0    # NA to 0
  } else if (length(e) > 1) {
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
            
            map(map_frac_to_dec) %>%  # same as modify_depth(2, frac_to_dec)
            map(as.numeric) %>% 
            map_dbl(mean) %>% round(digits = 2),
          
          # Otherwise, if there are two numbers, we multiply them (i.e., 6 12oz bottles of beer)
          str_extract_all(ingredients, portions_reg) %>%  # Get all numbers in a list
            map(map_frac_to_dec) %>%   # not same as modify_depth(1, frac_to_dec)
            map(as.numeric) %>% 
            map_dbl(multiply_or_add_portions) %>% 
            round(digits = 2)  # Multiply all numbers 
      ),
      
      portion_name = str_extract_all(ingredients, measures_collapsed) %>% 
        str_extract_all("[a-z]+") %>% # Get rid of numbers
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
some_recipes_tester[5, ] <- "11 - 46 tbsp of sugar"
some_recipes_tester[6, ] <- "1/3 to 1/2 of a ham"
some_recipes_tester[7, ] <- "5 1/2 apples"
some_recipes_tester[8, ] <- "4g cinnamon"


tester_w_portions <- get_portions(some_recipes_tester) 
expect_equal(tester_w_portions[1, ]$portion_name, "ounce, pound")


get_portions(some_recipes_tester)



example_url <- "http://allrecipes.com/recipe/244950/baked-chicken-schnitzel/"
schnitzel <- example_url %>% get_recipes()
example_url %>% try_read() %>% get_recipe_name()



# ---------- Get a lot of recipes ---------

# Most IDs seem to start with 1 or 2 and be either 5 or 6 digits long
# Some 
more_urls <- grab_urls(base_url, 10000:11000)
more_recipes <- more_urls %>% map(get_recipes)




foo <- list (a = rep(1, 3), b = rep(2, 3), c = rep(3, 3))


out <- NULL
for (i in foo) {
  out <- append(out, list(i, "b"))
  print(out)
}
out



