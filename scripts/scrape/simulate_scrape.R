
# Test increase in bad URLs as we grab more and more pages
# We try to grab recipe names; if we've got a bad URL, the name is "Bad URL"

# percent_to_use is the percent of our URLs we want to sample from
# If return_percent_bad is FALSE, return the whole list of recipe names. Otherwise, just return the percent of URLs that were bad.
count_bad <- function(urls, percent_to_use = 1, return_percent_bad = TRUE, seed = NULL) {
  # browser()
  set.seed(seed)
  
  urls <- urls[complete.cases(urls)]   # Remove NAs
  n_to_use <- (length(urls) * percent_to_use) %>% round(digits = 0)   # Get an integer value of URLs to sample
  urls <- sample(urls, size = n_to_use, replace = FALSE)
  
  out <- urls %>% map(try_read)
  
  if (return_percent_bad == FALSE) {
    return(out)
    
  } else {
    percent_bad <- length(which(out == "Bad URL")) / length(out)
    return(percent_bad)
  }
  
}

mixed_urls <- c("foo", urls[10:12], "bar")
mixed_urls %>% count_bad(percent_to_use = 0.75, seed = NULL)


mixed_urls %>% count_bad()


simulate_scrape <- function(n_sims = 10, verbose = FALSE, ...) {
  
  # Choose as many random seeds as we have simulations
  seeds <- sample(1:n_sims, size = n_sims, replace = FALSE)
  
  out <- seeds %>% map2_dbl(.y = min_food_amount, .f = get_status)
  return(out)
}



simulate_scrape <- function(n_intervals = 10, n_sims = 2, min_food_amount = NULL,
                              from = -1, to = 1, verbose = FALSE) {
  
  
  seeds <- sample(1:length(spectrum), size = length(spectrum), replace = FALSE)
  
  out_status <- vector(length = length(spectrum))
  
  for (i in seq_along(spectrum)) {
    this_status <- count_bad(seed = seeds[i], min_food_amount = spectrum[i], verbose = verbose)
    out_status[i] <- this_status
  }
  
  out <- list(min_amount = spectrum, status = out_status) %>% as_tibble()
  
  return(out)
}






