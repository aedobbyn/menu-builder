
# -------- Compliance Tests ---------
# Now that we've built our menu, we need to see how to tweak it so that it's in compliance with the guidelines.
# we'll test whether it's in compliance with the must restricts (not in compliance if it's over the max in in any way)
# and also with the positive nutrients.
# Finally, it should contain >= 2300 calories.


# Must restrict compliance
test_mr_compliance <- function(orig_menu, capitalize_colname = TRUE) {
  compliance_df <- list(must_restricts_uncompliant_on = vector(), 
                        `difference_(g)` = vector()) %>% as_tibble()
  
  for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
    nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
    to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1, na.rm = TRUE))/100   # get the amount of that must restrict nutrient in our original menu
    
    if ((to_restrict - mr_df$value[m]) > 0.01) {    # account for rounding error
      this_compliance <- list(must_restricts_uncompliant_on = nut_to_restrict,
                              `difference_(g)` = (to_restrict - mr_df$value[m]) %>% round(digits = 2)) %>% as_tibble()
      compliance_df <- bind_rows(compliance_df, this_compliance)
    }
  }
  if (capitalize_colname == TRUE) {
    compliance_df <- compliance_df %>% cap_df()
  }
  return(compliance_df)
}


# Positive nutrients compliance
test_pos_compliance <- function(orig_menu, capitalize_colname = TRUE) {
  orig_menu <- orig_menu %>% drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))
  compliance_df <- list(nutrients_uncompliant_on = vector(),
                        `difference_(g)` = vector()) %>% as_tibble()
  
  for (p in seq_along(pos_df$positive_nut)) {    # for each row in the df of positives
    nut_to_augment <- pos_df$positive_nut[p]     # grab the name of the nutrient we're examining
    val_nut_to_augment <- (sum(orig_menu[[nut_to_augment]] * 
                                 orig_menu$GmWt_1, na.rm = TRUE))/100   # get the total amount of that nutrient in our original menu
    
    if ((pos_df$value[p] - val_nut_to_augment) > 0.01) {     # account for rounding error (instead of if val_nut_to_augment < pos_df$value[p])
      this_compliance <- list(nutrients_uncompliant_on = nut_to_augment,
                              `difference_(g)` = (pos_df$value[p] - val_nut_to_augment) %>% 
                                round(digits = 2)) %>%
        as_tibble()
      compliance_df <- bind_rows(compliance_df, this_compliance)
    }
  }
  if (capitalize_colname == TRUE) {
    compliance_df <- compliance_df %>% cap_df()
  }
  return(compliance_df)
}


# Calories
test_calories <- function(our_menu) {
  total_cals <- sum((our_menu$Energ_Kcal * our_menu$GmWt_1), na.rm = TRUE)/100 
  if (total_cals < 2300) {
    cal_compliance <- "Calories too low"
  } else {
    cal_compliance <- "Calorie compliant"
  }
  cal_compliance
}


# Omnibus test
test_all_compliance <- function(orig_menu) {
  combined_compliance <- "Undetermined"
  
  if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) > 0 |
      test_calories(orig_menu) == "Calories too low") {
    combined_compliance <- "Not Compliant"
    
  } else if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) == 0 &
             test_calories(orig_menu) == "Calorie compliant") {
    combined_compliance <- "Compliant"
    
  } else {
    combined_compliance <- "Undetermined"
  }
  combined_compliance
}



# Verbose omnibus test: 
test_all_compliance_verbose <- function(orig_menu) {
  combined_compliance <- "Undetermined"
  uncompliant_message <- NULL
  
  if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) == 0 &
      test_calories(orig_menu) == "Calorie compliant") {
    combined_compliance <- "Compliant"
    uncompliant_message <- NULL
  } else if (nrow(test_mr_compliance(orig_menu)) + nrow(test_pos_compliance(orig_menu)) > 0 |
             test_calories(orig_menu) == "Calories too low") {
    combined_compliance <- "Not Compliant"
    uncompliant_message <- c(uncompliant_message, 
                             test_calories(orig_menu), 
                             test_pos_compliance(orig_menu)[, 1], 
                             test_mr_compliance(orig_menu)[, 1])
  } else {
    combined_compliance <- "Undetermined"
  }
  print(uncompliant_message)
  combined_compliance
}
