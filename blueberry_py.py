
import numpy as np
import pandas as pd
import pdb


abbrev = pd.read_csv("./Desktop/Earlybird/food-progress/ABBREV.csv")

# Bit of cleaning
abbrev.rename(columns = {'\xef\xbb\xbfNDB_No':"NDB_No"}, inplace = True)
abbrev.columns = abbrev.columns.str.replace("[() ]", "")

# Condense dataframe down to a few key columns
ab = abbrev[["NDB_No", "Shrt_Desc", "Energ_Kcal", "Protein_g", "Sugar_Tot_g", "GmWt_1"]]

# Read in nutrients and must restricts
all_nut_and_mr_df = pd.read_csv("./Desktop/Earlybird/food-progress/all_nut_and_mr_df.csv")

must_restricts = ['Lipid_Tot_g', 'Sodium_mg', 'Cholestrl_mg', 'FA_Sat_g']
mr_df = all_nut_and_mr_df[all_nut_and_mr_df.nutrient.isin(must_restricts)]
pos_df = all_nut_and_mr_df[~all_nut_and_mr_df.nutrient.isin(must_restricts)]

# import feather as f
# scaled = pd.read_feather("./Desktop/Earlybird/food-progress/")


# Getting acquainted
def find_butter(df, colnum):
    butters = []
    for e in df[colnum]:
        if "BUTTER" in e:
            print(e)
            butters.append(e)
        else:
            pass
    return(butters)

all_butters = find_butter(ab, "Shrt_Desc")

# def find_butter(e):
#     butters = []
#     if "BUTTER" in e:
#         butters.append(e)
#     else:
#         pass
#     return butters
    
# foo = ab.Shrt_Desc.apply(find_butter)



# Build a random menu; one serving per food until we hit 2300 calories.
def menu_builder(df):
    cals = 0
    menu = df.sample(n=1)
    while cals < 2300:
        this_food = df.sample(n=1)
        this_food_cals = this_food['Energ_Kcal'].values
        
        menu = menu.append(this_food)
        cals = cals + this_food_cals
        
    return menu

my_little_menu = menu_builder(ab)
my_full_menu = menu_builder(abbrev)

# test_calories <- function(our_menu) {
#   total_cals <- sum((our_menu$Energ_Kcal * our_menu$GmWt_1))/100 
#   if (total_cals < 2300) {
#     cal_compliance <- "Calories too low"
#   } else {
#     cal_compliance <- "Calorie compliant"
#   }
#   cal_compliance
# }

# Test must restrict compliance
def test_mr_compliance(orig_menu):
    compliance_names = []
    compliance_vals = []
    # pdb.set_trace()

    for m in range(len(mr_df.index)):
        nut_to_restrict = mr_df.iloc[m, 0] # the name of the nutrient we're restricting
        orig_menu_no_na = orig_menu.dropna(subset=[nut_to_restrict, 'GmWt_1'])
        val_nut_to_restrict = sum(orig_menu_no_na[nut_to_restrict] * orig_menu_no_na['GmWt_1'])/100 # the amount of that must restrict nutrient in our original menu
        
        if val_nut_to_restrict > mr_df.iloc[m, 1]:
            compliance_names.append(nut_to_restrict)
            compliance_diff = round(val_nut_to_restrict - mr_df.iloc[m, 1], 2)
            compliance_vals.append(compliance_diff)
            
    compliance_dict = dict(zip(compliance_names, compliance_vals))
    return compliance_dict

my_mr_compliance = test_mr_compliance(my_full_menu)



# Test positive compliance
def test_pos_compliance(orig_menu):
    # pdb.set_trace()
    compliance_dict = {}

    for m in range(len(pos_df.index)):
        nut_to_augment = pos_df.iloc[m, 0]
        orig_menu_no_na = orig_menu.dropna(subset=[nut_to_augment, 'GmWt_1'])
        
        val_nut_our_menu = sum(orig_menu_no_na[nut_to_augment] * orig_menu_no_na['GmWt_1'])/100
        val_nut_should_be = pos_df.iloc[m, 1]
        
        if val_nut_our_menu > val_nut_should_be:
            compliance_diff = round(val_nut_should_be - val_nut_our_menu, 2)
            compliance_dict[nut_to_augment] = compliance_diff
            
    return compliance_dict

my_pos_compliance = test_pos_compliance(my_full_menu)



def test_calories(orig_menu):
    sum_cals = sum(orig_menu['Energ_Kcal'])
    if sum_cals < 2300:
        compliance = "Calories too low."
    elif sum_cals >= 2300:
        compliance = "Calorie compliant."
    else:
        compliance = "Something went wrong."
    return compliance
    
test_calories(my_full_menu)



def test_all_compliance(orig_menu):
    combined_compliance = "Undetermined"
    
    if (len(test_pos_compliance(orig_menu)) + len(test_mr_compliance(orig_menu))) == 0 and 
            (test_calories(orig_menu) == "Calorie compliant.") :
        combined_compliance = "Compliant"
            
    elif (len(test_pos_compliance(orig_menu)) + len(test_mr_compliance(orig_menu))) > 0 or 
            (test_calories(orig_menu) != "Calorie compliant."):
        combined_compliance = "Uncompliant"
        
    return combined_compliance
    
test_all_compliance(my_full_menu)










