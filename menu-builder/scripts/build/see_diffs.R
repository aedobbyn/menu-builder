# ------------ Find the differences between starting and ending menus -------------

# food desriptions and weights that differ between two menus

see_diffs <- function(menu_1, menu_2) {
  diff <- setdiff(menu_1, menu_2) %>% 
    select(Shrt_Desc, GmWt_1)
  diff
}