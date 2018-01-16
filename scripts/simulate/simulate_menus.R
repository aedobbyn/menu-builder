### Run some simulations to see how often we're able to solve random menus without 
# doing any swapping at a certain minimum portion size ###

# source("./scripts/solve.R")

# --- Helper for getting the solve_it() status from a menu that has just been solved ---
get_status <- function(seed = NULL, min_food_amount = 0.5, verbose = TRUE) {  
  this_menu <- build_menu(seed = seed) %>% do_menu_mutates() %>% 
    solve_it(min_food_amount = min_food_amount, verbose = verbose, only_full_servings = FALSE) %>% 
    purrr::pluck("status")
}

simulate_swaps <- function(seed = NULL, min_food_amount = 0.5, n_swaps = 3, verbose = TRUE) {  
  counter <- 0
  this_solution <- build_menu(seed = seed) %>% do_menu_mutates() %>% 
    solve_it(min_food_amount = min_food_amount, verbose = verbose, only_full_servings = FALSE) 

  this_status <- this_solution %>% purrr::pluck("status")
  
  this_menu <- this_solution %>% solve_menu()
  
  while (counter < n_swaps & this_status == 1) {
    this_solution <- this_menu %>% do_single_swap() %>% 
      solve_it(min_food_amount = min_food_amount, verbose = verbose, only_full_servings = FALSE)
    this_status <- this_solution %>% purrr::pluck("status")
    
    if (this_status == 0) {
      message(paste0("Solution found in ", counter, " steps"))
      this_menu <- this_solution %>% solve_menu()
      return(this_menu)
    }
    counter <- counter + 1
  }
  message(paste0("No solution found in ", counter, " steps :/"))
  # this_menu
}

simulate_swaps(min_food_amount = 1)


# --- For a given minimum portion size, what proportion of a random number of simulated menus can we solve? ---
# 0 means that an optimal solution was found (because canonicalize_status is false)
simulate_menus <- function(n_sims = 10, min_food_amount = 0.5, verbose = FALSE) {
  
  # Choose as many random seeds as we have simulations
  seeds <- sample(1:n_sims, size = n_sims, replace = FALSE)
  
  out <- seeds %>% map2_dbl(.y = min_food_amount, .f = get_status)
  return(out)
}


# --- Simulate some number of times for each of some number of interval between two boundaries ---
# from is the lower bound for portion size and to is the upper bound
# n_intervals is the number of chunks we want to split the spectrum of from to to into
# n_sims is the number of times we want to repeat the simulation for each discrete interval
# Return a df showing the relationship between our minimum portion size (min_amount) vs. whether the menu could be solved
simulate_spectrum <- function(n_intervals = 10, n_sims = 2, from = -1, to = 1,
                              min_food_amount = NULL, verbose = FALSE) {

  interval <- (to - from) / n_intervals
  spectrum <- seq(from = from, to = to, by = interval) %>% rep(n_sims) %>% sort()
  
  seeds <- sample(1:length(spectrum), size = length(spectrum), replace = FALSE)
  
  out_status <- vector(length = length(spectrum))
  
  for (i in seq_along(spectrum)) {
    this_status <- get_status(seed = seeds[i], min_food_amount = spectrum[i], verbose = verbose)
    if (!is.integer(this_status)) {
      this_status <- integer(0)     # If we don't get an integer value back, make it NA
    }
    out_status[i] <- this_status
  }
  
  out <- list(min_amount = spectrum, status = out_status) %>% as_tibble()
  
  return(out)
}



# --- Summarise a spectrum ---
summarise_status_spectrum <- function(spec) {
  
  spec_summary <- spec %>% 
    group_by(min_amount) %>% 
    summarise(
      sol_prop = mean(status)
    )
  
  return(spec_summary)
}


