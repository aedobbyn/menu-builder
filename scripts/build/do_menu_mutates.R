
do_menu_mutates <- function(menu) {
  
  menu_unsolved_per_g <- menu[, which(names(menu) %in% cols_to_keep)] %>% 
    mutate(
      shorter_desc = map_chr(Shrt_Desc, grab_first_word, splitter = ","), # Take only the fist word
      cost = runif(nrow(.), min = 1, max = 10) %>% round(digits = 2), # Add a cost column
      serving_gmwt = GmWt_1   # Single serving gram weight
    ) %>%
    select(shorter_desc, GmWt_1, serving_gmwt, cost, !!quo_nutrient_names,  Shrt_Desc, NDB_No) #  serving_gmwt,
  
  return(menu_unsolved_per_g)
}