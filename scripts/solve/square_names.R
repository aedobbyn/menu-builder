# 
# an_unsolved_menu <- build_menu()
# a_solved_menu <- an_unsolved_menu %>% do_menu_mutates() %>% solve_it(verbose = FALSE) %>% solve_menu(verbose = FALSE)
# 
# solved_names <- names(a_solved_menu)
# name_overlap <- intersect(names(an_unsolved_menu), names(a_solved_menu))
# no_overlap <- setdiff(names(a_solved_menu), names(an_unsolved_menu))
# 
# write_lines(solved_names, "./data/derived/squared_names.rds", append = FALSE)

solved_names <- read_lines("./data/derived/squared_names.rds")
