
import_scripts <- function(path, pattern = "*.R") {
  files <- list.files(path, pattern, ignore.case = TRUE)
  file_paths <- str_c(path, "/", files)
  try_source <- possibly(source, otherwise = message(paste0("Can't find this file or path: ")),
                         quiet = FALSE)
  
  for (file in file_paths) {
    try_source(file)
  }
}