
get_measurement_types <- function(from_file = TRUE) {
  if (from_file == TRUE) {
    units <<- read_rds(here("data", "derived", "units.rds"))
    measures_collapsed <<- read_rds(here("data", "derived", "measurement_types.rds"))
    abbrev_dict <<- read_feather(here("data", "derived", "abbrev_dict.feather"))
    abbrev_dict_w_accepted <<- read_feather(here("data", "derived", "abbrev_dict_w_accepted.feather"))
  } else {
    measures_collapsed <<- get_measurement_types_from_source_collapsed()
  }
}