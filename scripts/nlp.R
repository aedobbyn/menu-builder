library(tidytext)
library(widyr)
library(igraph)
library(ggraph)
import_scripts(path = "./scripts/scrape")

more_recipes_df <- read_feather("./data/derived/more_recipes_df.feather")
# Load in stopwords to remove
data(stop_words)

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


# See tfidf
per_rec_freq %>% 
  bind_tf_idf(word, recipe_name, n_this_rec) %>% 
  arrange(desc(tf_idf))




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





