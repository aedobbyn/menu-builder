

get_status <- function(seed = NULL, min_food_amount = 0.5, verbose = TRUE) {  
  this_menu <- build_menu(seed = seed) %>% do_menu_mutates() %>% 
    solve_it(min_food_amount = min_food_amount, verbose = verbose, only_full_servings = FALSE) %>% 
    pluck("status")
}

# 0 means that an optimal solution was found
simulate_menus <- function(n_sims = 10, min_food_amount = 0.5, verbose = FALSE) {
  
  # Choose as many random seeds as we have simulations
  seeds <- sample(1:n_sims, size = n_sims, replace = FALSE)
  
  out <- seeds %>% map2_dbl(.y = min_food_amount, .f = get_status)
  return(out)
}
# simulate_menus()

half_portions <- simulate_menus(n_sims = 1000)
full_portions <- simulate_menus(n_sims = 1000, 
                                min_food_amount = 1)
double_portions <- simulate_menus(n_sims = 100,
                                  min_food_amount = 1)



simulate_spectrum <- function(n_sims = 10, min_food_amount = NULL,
                              from = 0, to = 1) {
  interval <- (to - from) / n_sims
  
  spectrum <- seq(from = from, to = to, by = interval)
  out <- vector(length = length(spectrum))
  for (prop in seq_along(spectrum)) {
    this_status <- get_status(min_food_amount = prop)
  }
  # out <- spectrum %>% map2_dbl(.y = min_food_amount, .f = simulate_menus
  
  out <- c(out, this_status)
  return(out)
}

simulate_spectrum(n_sims = 20)


# ------ 10 simulations w for loop ----
# user  system elapsed 
# 2.612   0.131   2.762 
# 10 w purrr
# user  system elapsed 
# 2.654   0.165   2.845


# rsession(84324,0x7fff92310340) malloc: *** mach_vm_map(size=8000000000004096) failed (error code=3)
# *** error: can't allocate region
# *** set a breakpoint in malloc_error_break to debug
