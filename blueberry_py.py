
import numpy as np
import pandas as pd


abbrev = pd.read_csv("./Desktop/Earlybird/food-progress/ABBREV.csv")
abbrev.rename(columns = {'\xef\xbb\xbfNDB_No':"NDB_No"}, inplace = True)

abbrev.columns = abbrev.columns.str.replace("[() ]", "")

ab = abbrev[["NDB_No", "Shrt_Desc", "Energ_Kcal", "Protein_(g)", "Sugar_Tot_(g)", "GmWt_1"]]


all_nut_and_mr_df = pd.read_csv("./Desktop/Earlybird/food-progress/all_nut_and_mr_df.csv")


# import feather as f
# scaled = pd.read_feather("./Desktop/Earlybird/food-progress/")


# def find_butter(e):
#     butters = []
#     if "BUTTER" in e:
#         butters.append(e)
#     else:
#         pass
#     return butters
    
# foo = ab.Shrt_Desc.apply(find_butter)
    
    
def find_butter(df, colnum):
    butters = []
    for e in df[colnum]:
        if "BUTTER" in e:
            print(e)
            butters.append(e)
        else:
            pass
    return(butters)
    # print(butters)
    
all_butters = find_butter(ab, "Shrt_Desc")



def menu_builder(df):
    cals = 0
    menu = df.sample(n=1)
    while cals < 2300:
        this_food = df.sample(n=1)
        this_food_cals = this_food['Energ_Kcal'].values
        
        menu = menu.append(this_food)
        cals = cals + this_food_cals
        
    return menu

my_menu = menu_builder(ab)
my_full_menu = menu_builder(abbrev)
orig_menu = menu_builder(abbrev)

        
        
# test_mr_compliance <- function(orig_menu, capitalize_colname = TRUE) {
#   compliance_df <- list(must_restricts_uncompliant_on = vector(), 
#                         `difference_(g)` = vector()) %>% as_tibble()
  
#   for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
#     nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
#     to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1))/100   # get the amount of that must restrict nutrient in our original menu
    
#     if (to_restrict > mr_df$value[m]) {
#       this_compliance <- list(must_restricts_uncompliant_on = nut_to_restrict,
#                               `difference_(g)` = (to_restrict - mr_df$value[m]) %>% round(digits = 2)) %>% as_tibble()
#       compliance_df <- bind_rows(compliance_df, this_compliance)
#     }
#   }
#   if (capitalize_colname == TRUE) {
#     compliance_df <- compliance_df %>% cap_df()
#   }
#   return(compliance_df)
# }


must_restricts = ['Lipid_Tot_g', 'Sodium_mg', 'Cholestrl_mg', 'FA_Sat_g']
mr_df = all_nut_and_mr_df[all_nut_and_mr_df.nutrient.isin(mrs)]


def test_mr_compliance(orig_menu):
    compliance_dict = []
    
    for m in mr_df.iterrows():
        nut_to_restrict = mr_df.iloc[m, :].values[0]
        to_restrict = sum(orig_menu[ntr][~np.isnan(orig_menu[ntr])] * orig_menu['GmWt_1'][~np.isnan(orig_menu['GmWt_1'])])/100
        
        if to_restrict > mr_df.value[m]:
            compliance_dict = compliance_dict.append(mr_df.nutrient[m])
    
    return compliance_dict

test_mr_compliance(my_full_menu)



for m in mr_df:
    print(m)





