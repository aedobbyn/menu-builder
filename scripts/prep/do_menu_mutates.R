
# Do mutates on per 100g menus

do_menu_mutates <- function(menu, to_keep = cols_to_keep) {
  
  # if (!("score" %in% names(menu))) {
  #   menu <- add_ranked_foods(menu)
  # }
  
  # to_keep <- c(to_keep, "score", "scaled_score")
  quo_to_keep <- quo(to_keep)
  
  menu <- menu %>% 
    # select(!!quo_to_keep) %>% 
    mutate(
      shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Take only the fist word
      cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2) # Add a cost column
    ) 
  
  if (!("serving_gmwt" %in% names(menu))) {
    menu <- menu %>% mutate(
      serving_gmwt = GmWt_1   # Single serving gram weight
    )
  }
  
  if (!("solution_amounts" %in% names(menu))) {
    menu <- menu %>% mutate(
      solution_amounts = 1   # Single serving gram weight
    )
  }
  
  menu <- menu %>%
    select(shorter_desc, solution_amounts, GmWt_1, serving_gmwt, cost, !!quo_to_keep,  Shrt_Desc, NDB_No)
  
  return(menu)
}