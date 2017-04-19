

abbrev <- readxl::read_excel("./ABBREV.xlsx")

abbrev <- as_tibble(abbrev)


# get vector of must restricts
must_restrict <- c("Lipid_Tot_(g)", "Carbohydrt_(g)", "Sugar_Tot_(g)", 
                   "FA_Sat_(g)", "FA_Mono_(g)", "FA_Poly_(g)", "Cholestrl_(mg)")

# these fields are neither must_restricts nor positives
not_nuts <- c("NDB_No", "Shrt_Desc", "Water_(g)", "Energ_Kcal", 
              "GmWt_1", "GmWt_Desc1", "GmWt_2", "GmWt_Desc2", "Refuse_Pct")

# everything that's not a must_restrict or a not_nut must be a positive
positives <- names(abbrev)[c((!names(abbrev) %in% must_restrict) & (!names(abbrev) %in% not_nuts))]
positives


length(must_restrict) # 7
length(positives) # 37


library(Rfit)


# fit <- rfit(Energ_Kcal ~ must_restrict[1] + must_restrict[2] + must_restrict[3], data = abbrev)
fit <- rfit(Energ_Kcal ~ `Lipid_Tot_(g)` + `Carbohydrt_(g)` + `Sugar_Tot_(g)`, data = abbrev)


# which foods have the highest kcals
abbrev$Shrt_Desc[which(abbrev$Energ_Kcal == max(abbrev$Energ_Kcal))]

abbrev %>% 
  filter(
    Energ_Kcal == max(Energ_Kcal)
  ) 
