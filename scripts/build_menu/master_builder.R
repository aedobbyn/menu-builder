

# ---------------- Build Compliant Menu ---------------
# Combine all of the above to build a menu that is compliant in all three respects

master_builder <- function(our_menu) {
  # our_menu <- build_menu(abbrev)   # seed with a random menu
  
  # define conditions
  total_cals <- sum((our_menu$Energ_Kcal * our_menu$GmWt_1), na.rm = TRUE)/100 
  
  while (test_all_compliance(our_menu) == "Not Compliant") {
    
    if (total_cals < 2300) {
      our_menu <- add_calories(our_menu)
      
    } else if (nrow(test_mr_compliance(our_menu))) {
      our_menu <- smart_swap(our_menu)
      
    } else if (nrow(test_pos_compliance(our_menu))) {
      our_menu <- adjust_portion_sizes(our_menu)
      
    } else {
      print("Something went wrong")
    }
  }
  our_menu
}
