
# 0 means that an optimal solution was found
simulate_menus <- function(n_sims = 10, min_food_amount = 0.5) {
  
  # browser()
  
  seeds <- sample(1:n_sims**5, size = n_sims)
  out <- vector(length = n_sims)
  
  get_status <- function(s, min_food_amount) {
    this_menu <- build_menu(seed = s) %>% do_menu_mutates() %>% 
      solve_it(min_food_amount = min_food_amount) %>% 
      pluck("status")
  }
  
  # for (seed in seq_along(seeds)) {
  #   this_status <- get_status()
  #   out <- c(out, this_status)
  # }
  out <- seeds %>% map2_dbl(.y = min_food_amount, .f = get_status)
  
  out
  # proportion_solved <- seeds %>% map_chr()
}

simulate_menus()
