

source("./abbrev_shiny.R")


# means and standard deviations
abbrev_st_dev <- apply(abbrev[, 3:which(names(abbrev)=="Cholestrl_mg")],  # everything after cholesterol is not necc numeric
                       2, sd, na.rm = TRUE)

abbrev_mean <- apply(abbrev[, 3:which(names(abbrev)=="Cholestrl_mg")],  
                     2, mean, na.rm = TRUE)

abbrev_st_dev_names <- names(abbrev_st_dev)

abbrev_st_dev_df <- as_tibble(list(nut_name = abbrev_st_dev_names,
                                   mean = abbrev_mean,
                                   std_dev = abbrev_st_dev))


# must restrict standard devs
mr_st_dev <- abbrev_st_dev_df[(abbrev_st_dev_df$nut_name %in% mr), ]

mr_st_dev_join <- left_join(mr_st_dev, mr_df, 
                            by = c("nut_name" = "must_restrict"))

mr_st_dev_join <- mr_st_dev_join %>% 
  mutate(
    one_above = mean + std_dev,
    one_below = mean - std_dev
  )



# z-score everything
scaled <- abbrev %>% 
  drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1))) %>% 
  select(
    3:which(names(abbrev)=="Cholestrl_mg")
  ) %>% 
  mutate_all(
    scale
  )


abbrev_sans_na <- abbrev %>% 
  drop_na_(all_nut_and_mr_df$nutrient) %>% filter(!(is.na(Energ_Kcal)) & !(is.na(GmWt_1)))


# cbind the ndbno and description
scaled <- bind_cols(abbrev_sans_na[, 1:2], scaled, abbrev_sans_na[, 49:ncol(abbrev_sans_na)]) # cbind freaks out for some tibble reason so going with bind_cols




# three ways of finding foods containing high sodium 
high_sodium <- abbrev %>% 
  filter(Sodium_mg > mr_st_dev_join$one_above[mr_st_dev_join$nut_name=="Sodium_mg"])

high_sodium_2 <- abbrev[(abbrev$NDB_No %in% scaled[scaled$Sodium_mg > 1, ]$NDB_No), ]

high_sodium_3 <- abbrev %>% 
  filter(NDB_No %in% scaled[scaled$Sodium_mg > 1, ][["NDB_No"]])







