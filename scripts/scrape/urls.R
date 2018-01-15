
base_url <- "http://allrecipes.com/recipe/"
urls <- grab_urls(base_url, 244940:244950)

some_urls <- grab_urls(base_url, sample(100000:200000, size = 100))
more_urls <- grab_urls(base_url, sample(100000:250000, size = 1000))
mixed_urls <- c("foo", urls[10:12], "bar")

