
# Do mutates on per 100g menus

do_menu_mutates <- function(menu, to_keep = cols_to_keep) {
  
  if (!("score" %in% names(menu))) {
    menu <- add_ranked_foods(menu)
  }
  
  to_keep <- c(to_keep, "score", "scaled_score")
  quo_to_keep <- quo(to_keep)
  
  menu_unsolved_per_g <- menu %>% 
    select(!!quo_to_keep) %>% 
    mutate(
      shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Take only the fist word
      cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2), # Add a cost column
      serving_gmwt = GmWt_1   # Single serving gram weight
    ) %>%
    select(shorter_desc, GmWt_1, serving_gmwt, cost, !!quo_to_keep,  Shrt_Desc, NDB_No) #  serving_gmwt,
  
  return(menu_unsolved_per_g)
}