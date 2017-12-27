
# Now in dobtools
grab_first_word <- function(e, splitter = " ") {
  stopifnot(is.character(e))
  
  e <- e %>% stringr::str_split(pattern = splitter, simplify = TRUE) %>% first()
  return(e)
}

is_plural <- function(word, return_bool = FALSE) {
  
  if(substr(word, nchar(word), nchar(word)) %>% tolower() == "s") {
    is_plural_bool <- TRUE
    word_to_say <- "them"
  } else {
    is_plural_bool <- FALSE
    word_to_say <- "it"
  }
  
  if(return_bool == TRUE) {
    return(is_plural_bool)
  } else {
    return(word_to_say)
  }
  
}