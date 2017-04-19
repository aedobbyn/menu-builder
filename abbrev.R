

abbrev <- readxl::read_excel("./ABBREV.xlsx")

abbrev <- as_tibble(abbrev)


# get vector of must restricts
must_restrict <- c("Lipid_Tot_(g)", "Carbohydrt_(g)", "Sugar_Tot_(g)", 
                   "FA_Sat_(g)", "FA_Mono_(g)", "FA_Poly_(g)", "Cholestrl_(mg)",
                   "Sodium_(mg)")

# these fields are neither must_restricts nor positives
not_nuts <- c("NDB_No", "Shrt_Desc", "Water_(g)", "Energ_Kcal", 
              "GmWt_1", "GmWt_Desc1", "GmWt_2", "GmWt_Desc2", "Refuse_Pct")

# everything that's not a must_restrict or a not_nut must be a positive
positives <- names(abbrev)[c((!names(abbrev) %in% must_restrict) & (!names(abbrev) %in% not_nuts))]
positives


length(must_restrict) # 8
length(positives) # 36


library(Rfit)


# fit <- rfit(Energ_Kcal ~ must_restrict[1] + must_restrict[2] + must_restrict[3], data = abbrev)
fit <- rfit(Energ_Kcal ~ `Lipid_Tot_(g)` + `Carbohydrt_(g)` + `Sugar_Tot_(g)`, data = abbrev)
summary(fit)

# which foods have the highest kcals
abbrev$Shrt_Desc[which(abbrev$Energ_Kcal == max(abbrev$Energ_Kcal))]
# same as
abbrev %>% 
  filter(Energ_Kcal == max(Energ_Kcal)) %>% 
  select(Shrt_Desc, Energ_Kcal)



# Calcium to B6


pos_nuts <- positives[4:18]
pos_vals <- c(1000, 18, 400, 1000, 3500, 15, 2, 2, 70, 60, 2, 2, 20, 10, 2)

library(hash)
pos_hash <- hash(pos_nuts, pos_vals)
pos_hash


mr <- c("Lipid_Tot_(g)", "Sodium_(mg)", "Cholestrl_(mg)", "FA_Sat_(g)")
mr_vals <- c(65, 2400, 300, 20)
mr_hash <- hash(mr, mr_vals)
mr_hash
