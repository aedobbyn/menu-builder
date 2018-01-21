### Test increase in bad URLs as we grab more and more pages ###
# We try to grab recipe names; if we've got a bad URL, the name is "Bad URL"

import_scripts("./scripts/scrape")

# --- Count the number of bad URLs (404s) we've got in a sample ---
# percent_to_use is the percent of our URLs we want to sample from
# If return_percent_bad is FALSE, return the whole list of recipe names. Otherwise, just return the percent of URLs that were bad.
count_bad <- function(urls, n_to_use = NULL, percent_to_use = 1, return_percent_bad = TRUE, seed = NULL) {

  set.seed(seed)
  
  urls <- urls[complete.cases(urls)]   # Remove NAs
  if (is.null(n_to_use)) {
    n_to_use <- (length(urls) * percent_to_use) %>% round(digits = 0)   # Get an integer value of URLs to sample
  }
  
  urls <- sample(urls, size = n_to_use, replace = FALSE)
  
  out <- urls %>% map(try_read)
  
  if (return_percent_bad == FALSE) {
    return(out)
    
  } else {
    percent_bad <- length(which(out == "Bad URL")) / length(out)
    return(percent_bad)
  }
  
}

# --- For some URLs, if we scrape some percent of them from 0 to 100%, what percent will tend to be bad? ---
# Note: this function never actually run to completion because we got kicked out of allrecipes.com for too many requests
# because each iteration we are actually scraping a random sample of URLs and seeing how many of them were bad
# Take a vector of URLs and a sequence of what percent of those URLs we want to scrape
# Request that percent of URLs and count how many are bad
# Return a df of the percent of total URLs we chose to scrape compared to the percent of that pool that were bad
simulate_scrape <- function(urls, n_intervals = 4, n_sims = 3, from = 0, to = 1, 
                            verbose = TRUE, v_v_verbose = FALSE,
                            sleep = 3) {
  
  interval <- (to - from) / n_intervals
  
  percents_to_scrape <- seq(from = from, to = to, by = interval) %>% rep(n_sims) %>% sort()
  percents_to_scrape <- percents_to_scrape[!percents_to_scrape == 0]  # Remove 0s
  
  if (v_v_verbose == TRUE) {
    message(paste0("Testing on: ", str_c(percents_to_scrape, collapse = ", ")))   
  }
  
  seeds <- sample(1:length(percents_to_scrape), size = length(percents_to_scrape), replace = FALSE)
  percents_bad <- vector("numeric", length = length(percents_to_scrape))
  
  for (i in seq_along(percents_to_scrape)) {
    if (!is.null(sleep)) { Sys.sleep(sleep) }
    
    this_bad <- urls %>% count_bad(percent_to_use = percents_to_scrape[i], seed = seeds[i])
    if (verbose == TRUE) {
      message(paste0((this_bad*100) %>% round(digits = 2), "% of URLs were bad out of a pool of ", round((percents_to_scrape[i]*100), digits = 1), "% of all URLs."))
    }
    percents_bad[i] <- this_bad
  }
  
  out <- list(percents_scraped = percents_to_scrape, percents_bad = percents_bad) %>% as_tibble()
  return(out)
}


# --- For some menus, had scraped some percent of them from 0 to 100%, what percent would have been bad? ---
# Take an existing list of scraped menus (the product of get_recipes() before it has gone through dfize()) with "Bad URL"s included 
# and simulate what percent of Bad URLs we get in different sample sizes of that list
# This way we are not requestion new data on every sample; we're using existing data
simulate_scrape_on_lst <- function(lst, n_intervals = 4, n_sims = 3, from = 0, to = 1, 
                            verbose = TRUE, v_v_verbose = FALSE,
                            sleep = 3) {
  interval <- (to - from) / n_intervals
  
  percents_to_scrape <- seq(from = from, to = to, by = interval) %>% rep(n_sims) %>% sort()
  percents_to_scrape <- percents_to_scrape[!percents_to_scrape == 0]  # Remove 0s
  
  if (v_v_verbose == TRUE) {
    message(paste0("Testing on: ", str_c(percents_to_scrape, collapse = ", ")))   
  }
  
  seeds <- sample(1:length(percents_to_scrape), size = length(percents_to_scrape), replace = FALSE)
  percents_bad <- vector("numeric", length = length(percents_to_scrape))

  for (i in seq_along(percents_to_scrape)) {
    set.seed(i)
    this_samp <- sample(lst, size = round(percents_to_scrape[i]*length(lst), digits = 0))
    this_bad <- length(this_samp[this_samp == "Bad URL"]) / length(this_samp)
    
    if (verbose == TRUE) {
      message(paste0((this_bad*100) %>% round(digits = 2), "% of URLs were bad out of a pool of ", round((percents_to_scrape[i]*100), digits = 1), "% of all URLs."))
    }
    percents_bad[i] <- this_bad
  }
  
  out <- list(percents_scraped = percents_to_scrape, percents_bad = percents_bad) %>% as_tibble()
  return(out)
}




