library(tidytext)
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
  group_by(recipe_name) %>% 
  anti_join(stop_words) %>% 
  anti_join(all_units_df) 


per_rec_freq_totals <- per_rec_freq %>% 
  count(word) %>% 
  summarise(total_this_recipe = sum(n))

per_rec_freq <- per_rec_freq %>% 
  count(recipe_name, word) %>% 
  mutate(
    n_per_recipe = n
  ) %>% select(-n) %>% 
  ungroup() %>% 
  mutate(
    total_overall = sum(n_per_recipe)
  ) %>% 
  left_join(per_rec_freq_totals)







