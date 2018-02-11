
# I was just about to ask this question when I figured out less hacky solution (as inevitably happens when you
# make a reproducible example), but figured I'd ask anyway in case someone has a better solution or knows
# if there's a way to set types in a `jsonlite::fromJSON()`` call.
# My situation is a nested list column in which a certain column arrives in different types per row.
# This happens because the API I'm hitting codes missing values as "--".
# That means that the type of the column (here, `a`) is
# numeric when there are no missing values and character otherwise.
# In this example, the `a` is mismatched between the first and second row;
# in the first row it is numeric because there are no missing values and in the second it is
# character.
# Of course, a column can't have values of more than one type. For both rows, I'd like
# to take a down to its lowest common denominator, character, and then unnest the rows.

library(tidyverse)

# Set up the tibble we'd like to unnest, which is z
nester_x <- tibble(a = seq(1, 3, 1), b = letters[1:3])    # a is numeric
nester_y <- tibble(a = c(4, "--", 6), b = letters[4:6])   # a is character

x <- tibble(non_nested = "foo", nested = nester_x %>% list())
y <- tibble(non_nested = "bar", nested = nester_y %>% list())

z <- bind_rows(x, y) 

# # A tibble: 2 x 2
# non_nested           nested
#      <chr>           <list>
#   1   foo     <tibble [3 x 2]>
#   2   bar     <tibble [3 x 2]>

# > z$nested
# [[1]]
# # A tibble: 3 x 2
#       a     b
#     <dbl> <chr>
# 1     1     a
# 2     2     b
# 3     3     c
# 
# [[2]]
# # A tibble: 3 x 2
#       a     b
#    <chr>  <chr>
# 1     4     d
# 2    --     e
# 3     6     f

# Change the "--"s to NAs without affecting any column types
z$nested <- z$nested %>% map(na_if, "--")

# ------- What I'd like to do is straight up unnest z ------
testthat::expect_error(z %>% unnest())

# The solution I'd forgotten about uses `modify_depth()`
z$nested <- z$nested %>% modify_depth(2, as.character)

z %>% unnest()


# # A tibble: 6 x 3
#    non_nested     a     b
#         <chr>  <chr>  <chr>
# 1        foo     1      a
# 2        foo     2      b
# 3        foo     3      c
# 4        bar     4      d
# 5        bar    <NA>    e
# 6        bar     6      f



# Before, I put together this pretty hacky workaround:
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

