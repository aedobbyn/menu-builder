library(tidyverse)
library(readr)
library(tidytext)
library(widyr)
library(igraph)
library(ggraph)
library(feather)
library(dobtools)
library(here)
import_scripts(here("scripts", "scrape"))

abbrev_dict <- read_feather("./data/derived/abbrev_dict.feather")
more_recipes_df <- read_feather("./data/derived/more_recipes_df.feather")
units <- read_rds("./data/derived/units.rds")
# Load in stopwords to remove
data(stop_words)

# Get a dataframe of all units (need plurals for abbrev_dict ones)
all_units <- c(units, abbrev_dict$name, abbrev_dict$key, "inch")
all_units_df <- tibble(word = all_units) %>% unnest()


# Get a sample (can't be random because we need foods that come from the same menus) and 
# unnest words
grab_words <- function(df, n_recipes = 5, n_grams = 1) {
  
  df <- df %>% 
    group_by(recipe_name) %>% 
    nest() %>% 
    mutate(    # Give each recipe a recipe number
      recipe_num = 1:nrow(.)
    ) %>% 
    sample_n(n_recipes) %>% 
    unnest() %>% 
    mutate(
      ingredient_num = row_number()) %>% 
    ungroup() %>% 
    unnest_tokens(word, ingredients, token = "ngrams", n = n_grams) %>% 
    select(recipe_name, word, everything())
  
  return(df)
}

unigrams <- grab_words(more_recipes_df)
bigrams <- grab_words(more_recipes_df, n_grams = 2)

# Filter out numbers
unigrams <- unigrams %>%
  dobtools::find_nums(add_contains_num = FALSE) %>%   # Add a column showing whether 
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



# --------

more_recipes_df %>% 
  select(-range_portion, - mult_add_portion, -portion_name) %>% 
  arrange(desc(portion))





# --------- Topic Models ----------


# -------- Topic Models -------
library(tm)
library(topicmodels)

# # Cast to term-document matrix
# hts_dtm <- hts_words_tfidf %>% 
#   cast_dtm(document = chapter, term = word, value = n_word)
# 
# # Do topic modeling on dtm
# hts_dtm_lda <- LDA(hts_dtm, k = 99, control = list(seed = 1234))
# 
# # saveRDS(hts_dtm_lda, file = "./data/derived/hts/hts_dtm_lda.rds")
# 
# # Tidy 
# hts_dtm_topics <- hts_dtm_lda %>% tidytext::tidy(matrix = "beta")
# 
# # Top words per topic
# hts_top_terms <- hts_dtm_topics %>%
#   group_by(topic) %>%
#   top_n(10, beta) %>%
#   ungroup() %>%
#   arrange(topic, -beta)
# 
# # write_feather(hts_dtm_topics, "./data/derived/hts/hts_dtm_topics.feather")
# 
# 
# # Get estimated proportion of words from that document that are generated from that topic
# hts_gamma <- tidy(hts_dtm_lda, matrix = "gamma")
# 
# # How do documents align with topics
# hts_chapter_classifications <- hts_gamma %>%
#   group_by(document) %>%
#   top_n(1, gamma) %>%
#   ungroup()
# 

