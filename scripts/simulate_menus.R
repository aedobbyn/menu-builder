
# Helper for getting the solve_it status
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



# Simulate some number of times for each interval between two boundaries
simulate_spectrum <- function(n_intervals = 10, n_sims = 2, min_food_amount = NULL,
                              from = -1, to = 1, verbose = FALSE) {
  # browser()
  interval <- (to - from) / n_intervals
  spectrum <- seq(from = from, to = to, by = interval) %>% rep(n_sims) %>% sort()
  
  seeds <- sample(1:length(spectrum), size = length(spectrum), replace = FALSE)
  
  out_status <- vector(length = length(spectrum))
  
  for (i in seq_along(spectrum)) {
    this_status <- get_status(seed = seeds[i], min_food_amount = spectrum[i], verbose = verbose)
    out_status[i] <- this_status
  }
  # out <- map2_dbl(.x = 5, .y = spectrum, .f = simulate_menus)
  
  out <- list(min_amount = spectrum, status = out_status) %>% as_tibble()
  
  return(out)
}

status_spectrum <- simulate_spectrum(n_intervals = 100, n_sims = 10)


ggplot(data = status_spectrum, aes(min_amount, 1 - status)) +
  geom_smooth(se = FALSE, span = 0.01) +
  theme_minimal() +
  ggtitle("Curve of portion size vs. solvability") +
  labs(x = "Minimum portion size", y = "Proportion of solutions") +
  ylim(0, 1)


# ------ 10 simulations w for loop ----
# user  system elapsed 
# 2.612   0.131   2.762 
# 10 w purrr
# user  system elapsed 
# 2.654   0.165   2.845


# rsession(84324,0x7fff92310340) malloc: *** mach_vm_map(size=8000000000004096) failed (error code=3)
# *** error: can't allocate region
# *** set a breakpoint in malloc_error_break to debug
