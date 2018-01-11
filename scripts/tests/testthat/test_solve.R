

test_that("The building and solving in full works correctly", {
  # Test that our min solution amount gets carried through 
  x <- suppressMessages(build_menu(abbrev, seed = 9) %>% 
                          do_menu_mutates() %>% 
                          solve_it(nutrient_df, min_food_amount = 0.5) %>% solve_menu() %>%
                          solve_full(min_food_amount = 0.5, percent_to_swap = 1)) 
  expect_equal(min(x$solution_amounts), 0.5)
  
  # Test that we're not touching menus that are already compliant
  expect_equal(solve_full(out), out)
  
          })

wholesale_out <- wholesale_swap(out)
setdiff(wholesale_out, out)


suppressMessages(solve_full(solved_menu, silent = TRUE))
