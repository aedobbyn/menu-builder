library(readxl)
library(tidyverse)
library(stringr)

abbrev <- readxl::read_excel("./ABBREV.xlsx")

abbrev <- as_tibble(abbrev)

abbrev <- abbrev
names(abbrev) <- str_replace_all(names(abbrev), "\\(", "")
names(abbrev) <- str_replace_all(names(abbrev), "\\)", "")
names(abbrev) <- str_replace_all(names(abbrev), " ", "")
names(abbrev)



# get vector of must restricts
must_restrict <- c("Lipid_Tot_g", "Carbohydrt_g", "Sugar_Tot_g", 
                   "FA_Sat_g", "FA_Mono_g", "FA_Poly_g", "Cholestrl_mg",
                   "Sodium_(mg)")

# these fields are neither must_restricts nor positives
not_nuts <- c("NDB_No", "Shrt_Desc", "Water_g", "Energ_Kcal", 
              "GmWt_1", "GmWt_Desc1", "GmWt_2", "GmWt_Desc2", "Refuse_Pct")

# everything that's not a must_restrict or a not_nut must be a positive
positives <- names(abbrev)[c((!names(abbrev) %in% must_restrict) & (!names(abbrev) %in% not_nuts))]
positives


length(must_restrict) # 8
length(positives) # 36


library(Rfit)


# fit <- rfit(Energ_Kcal ~ must_restrict[1] + must_restrict[2] + must_restrict[3], data = abbrev)
# fit <- rfit(Energ_Kcal ~ Lipid_Tot_g + Carbohydrt_g + Sugar_Tot_g, data = abbrev)
# summary(fit)

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


mr <- c("Lipid_Tot_g", "Sodium_mg", "Cholestrl_mg", "FA_Sat_g")
mr_vals <- c(65, 2400, 300, 20)
mr_hash <- hash(mr, mr_vals)
mr_hash

mr_df <- as_tibble(list(must_restrict = mr, value = mr_vals))



abbrev[[(keys(mr_hash)[1])]][1:3]
abbrev$Cholestrl_mg[1:3]



# which foods are below the daily must restrict thresholds?


ab <- sample_n(abbrev, 100) %>% 
  select(
    NDB_No, Shrt_Desc,
    # mr_df$must_restrict
    Lipid_Tot_g, Sodium_mg, Cholestrl_mg, FA_Sat_g
  ) %>% 
  filter(
    Lipid_Tot_g <= mr_df$value[1],    # same as values(mr_hash)[1]
    Sodium_mg <= mr_df$value[2],
    Cholestrl_mg <= mr_df$value[3],
    FA_Sat_g <= mr_df$value[4]
  )


ab <- sample_n(abbrev, 100) %>% 
  select(
    NDB_No, Shrt_Desc,
    # mr_df$must_restrict
    `Lipid_Tot_(g)`, `Sodium_(mg)`, `Cholestrl_(mg)`, `FA_Sat_(g)`
  ) %>% 
  arrange(
    desc(`Lipid_Tot_(g)`), desc(`Sodium_(mg)`), desc(`Cholestrl_(mg)`), desc(`FA_Sat_(g)`)
  )









colors = rainbow(length(unique(iris$Species)))
names(colors) = unique(iris$Species)
ecb = function(x,y){ plot(x,t='n'); text(x,labels=iris$Species, col=colors[iris$Species]) }
tsne_iris = tsne(iris[,1:4], epoch_callback = ecb, perplexity=50)



ab <- ab %>% na.omit()
colors = rainbow(length(unique(ab$Shrt_Desc)))
names(colors) = unique(ab$Shrt_Desc)

ecb = function (x,y) { 
  plot(x,t='n'); 
  text(x, labels=ab$Shrt_Desc, col=colors[ab$Shrt_Desc]) }

tsne_ab = tsne(ab[,3:6], epoch_callback = ecb, perplexity=20)







