
# Test increase in bad URLs as we grab more and more pages
# We try to grab recipe names; if we've got a bad URL, the name is "Bad URL"

# percent_to_use is the percent of our URLs we want to sample from
# If return_percent_bad is FALSE, return the whole list of recipe names. Otherwise, just return the percent of URLs that were bad.
count_bad <- function(urls, n_to_use = NULL, percent_to_use = 1, return_percent_bad = TRUE, seed = NULL) {
  # browser()
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

mixed_urls <- c("foo", urls[10:12], "bar")
mixed_urls %>% count_bad(percent_to_use = 0.75, seed = NULL)
mixed_urls %>% count_bad(n_to_use = 2)


percents_to_scrape <- seq(from = 0, to = 1, by = 0.3)

for (p in percents_to_scrape) {
  this_out <- mixed_urls %>% count_bad(percent_to_use = p)
  print(this_out)
}






simulate_scrape <- function(urls, n_sims = 10, verbose = FALSE, ...) {
  
  browser()
  out <- NULL
  
  # Choose as many random seeds as we have simulations
  seeds <- sample(1:n_sims, size = n_sims, replace = FALSE)
  
  for (i in seq_along(n_sims)) {
    set.seed(seeds[i])
    n_to_use <- (length(urls) / i) %>% round(digits = 0)
    this_out <- count_bad(urls, n_to_use = n_to_use)
    out <- c(out, this_out)
  }
  
  return(out)
}

mixed_urls %>% simulate_scrape(n_sims = 3)

