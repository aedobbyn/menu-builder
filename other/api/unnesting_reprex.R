
# Does anyone have a good way of unnesting list columns that arrive in different types per row?
# An API I'm using codes missing values as "--". That means that the type of the column is
# numeric when there are no missing values and character otherwise. 
# In this example, the column `a` is mismatched between the first and second row;
# in the first row it is numeric because there are no missing values and in the second it is 
# character.
# Of course, a column can't have values of more than one type. For both rows, I'd like 
# to take nested_a down to its lowest common denominator, character, and then unnest the rows.

library(tidyverse)

# Set up the tibble we'd like to unnest, which is z
nester_x <- tibble(a = seq(1, 3, 1), b = letters[1:3])    # nested_a is numeric
nester_y <- tibble(a = c(4, "--", 6), b = letters[4:6])   # nested_a is character

x <- tibble(non_nested = "foo", nested = nester_x %>% list())
y <- tibble(non_nested = "bar", nested = nester_y %>% list())

z <- bind_rows(x, y) 

# Change the "--"s to NAs without affecting any column types
z$nested <- z$nested %>% map(na_if, "--")

# ------- What I'd like to do is straight up unnest z ------
testthat::expect_error(z %>% unnest())


# ------- My workaround -------
characterify <- function(i) {
  i <- i %>% flatten() %>% 
    map(as.character) %>% as_tibble() %>% list()
  i  
}
# I figure we could have as made `numerify()` instead with a map_at("a", as.numeric) 

for (i in seq_along(z$nested)) {
  z$nested[i] <- z$nested[i] %>% characterify()
}

z %>% unnest()



# --------- Better -------
z$nested <- z$nested %>% modify_depth(2, as.character)

z %>% unnest()

