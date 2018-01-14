library(tidytext)
library(widyr)
library(igraph)
library(ggraph)
import_scripts(path = "./scripts/scrape")

more_recipes_df <- read_feather("./data/more_recipes_df.feather")
# Load in stopwords to remove
data(stop_words)

more_recipes_df_samp <- more_recipes_df[1:100, ] %>% 
  # sample_frac(0.1) %>% 
  select(ingredients, recipe_name) %>% 
  group_by(recipe_name) %>% 
  mutate(ingredient_num = row_number()) %>% 
  ungroup()


unnested_bigram <- more_recipes_df[1:100, ] %>% 
  # sample_frac(0.1) %>% 
  select(ingredients, recipe_name) %>% 
  group_by(recipe_name) %>% 
  mutate(ingredient_num = row_number()) %>% 
  ungroup() %>% 
  unnest_tokens(bigram, ingredients, token = "ngrams", n = 2)



unnested <- more_recipes_df_samp %>% 
  unnest_tokens(word, ingredients) %>% 
  mutate(
    num = as.numeric(word),    # we could have as easily done this w a regex
    is_num = case_when(
      !is.na(num) ~ TRUE,
      is.na(num) ~ FALSE
    )
  ) %>% select(-num)

unnested %>% count(word, sort = TRUE) %>% 
  filter(is_num == FALSE)

# Get a dataframe of all units (need plurals for abbrev_dict ones)
all_units <- c(units, abbrev_dict$name, abbrev_dict$key, "inch")
all_units_df <- list(word = all_units) %>% as_tibble()

# Looking at pairs of words within a recipe (not neccessarily bigrams), which paris tend to co-occur?
# i.e., higher frequency within the same recipe
per_rec_freq <- unnested[unnested$is_num==FALSE,] %>% 
  select(-is_num) %>% 
  ungroup() %>% group_by(recipe_name) %>% 
  anti_join(stop_words) %>% 
  anti_join(all_units_df) 

per_rec_freq_totals <- per_rec_freq %>% 
  count(word) %>% 
  summarise(total_this_recipe = sum(n))

all_rec_freq_totals <- per_rec_freq %>% 
  ungroup() %>% 
  count(word) %>%
  mutate(
    n_all_recipes = n
  ) %>% select(-n) 

per_rec_freq <- per_rec_freq %>% 
  group_by(recipe_name) %>% 
  count(word) %>% 
  mutate(
    n_this_recipe = n
  ) %>% select(-n) %>% 
  ungroup() 
  
  
per_rec_freq <- per_rec_freq %>% 
  mutate(
    total_overall = sum(n_this_recipe)
  ) %>% 
  left_join(per_rec_freq_totals) %>% 
  left_join(all_rec_freq_totals)


# See tfidf
per_rec_freq %>% 
  bind_tf_idf(word, recipe_name, n_this_recipe) %>% 
  arrange(desc(tf_idf))




# ---------

pairwise_per_rec <- per_rec_freq %>% 
  # pairwise_count(word, recipe_name, sort = TRUE) %>% 
  pairwise_cor(word, recipe_name, sort = TRUE) 

pairwise_per_rec %>%
  filter(item1 %in% c("cheese", "garlic", "onion", "sugar")) %>% 
  filter(correlation > .5) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = correlation), show.legend = FALSE) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), repel = TRUE) +
  theme_void()



