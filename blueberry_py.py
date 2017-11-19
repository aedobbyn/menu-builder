
import numpy as np
import pandas as pd
import pdb


abbrev = pd.read_csv("./Desktop/Earlybird/food-progress/ABBREV.csv")
abbrev.index = range(len(abbrev))   # but we do want to keep ndbno around

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
# scaled = f.read_feather("./Desktop/Earlybird/food-progress/scaled.feather")

# Read in scaled version of USDA data
scaled = pd.read_csv("./Desktop/Earlybird/food-progress/scaled.csv")


# Take out rows that don't have all the nutrients and must_restricts or are missing calories
need = all_nut_and_mr_df.nutrient.values.tolist()
need.append('Energ_Kcal'); need.append('GmWt_1')
scaled = scaled.dropna(subset = need)
abbrev = abbrev.dropna(subset = need)


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
    
# foo = ab.Shrt_Desc.map(find_butter).tolist()



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


# Test must restrict compliance
def test_mr_compliance(orig_menu):
    compliance_names = []
    compliance_vals = []
    # pdb.set_trace()

    for m in range(len(mr_df.index)):
        nut_to_restrict = mr_df.iloc[m, 0] # the name of the nutrient we're restricting
        # orig_menu_no_na = orig_menu.dropna(subset=[nut_to_restrict, 'GmWt_1'])
        val_nut_to_restrict = sum(orig_menu[nut_to_restrict] * orig_menu['GmWt_1'])/100 # the amount of that must restrict nutrient in our original menu
        
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
    """ Test all compliances once and for all """
    combined_compliance = "Undetermined"
    
    if (len(test_pos_compliance(orig_menu)) + len(test_mr_compliance(orig_menu))) == 0 and (test_calories(orig_menu) == "Calorie compliant.") :
        combined_compliance = "Compliant"
            
    elif (len(test_pos_compliance(orig_menu)) + len(test_mr_compliance(orig_menu))) > 0 or (test_calories(orig_menu) != "Calorie compliant."):
        combined_compliance = "Uncompliant"
        
    return combined_compliance
    
test_all_compliance(my_full_menu)



# Replace the worst offender on a given must restrict with a random food 
def replace_w_rand(orig_menu, max_offender):
    new_menu = orig_menu.copy()
    rand_food = abbrev.sample(n = 1)
    new_menu.iloc[max_offender, :] = rand_food.iloc[0]
    
    print("Replacing " + orig_menu[['Shrt_Desc']].iloc[max_offender, :].values + " with " + rand_food.Shrt_Desc.values)
    return new_menu

randomly_replaced = replace_w_rand(my_full_menu, 3)


# Replace the worst offender on a given must restrict with a random food below the standard deviation cutoff on that must restrict
def replace_food_w_better(orig_menu, max_offender, nutrient_to_restrict, cutoff):
    new_menu = orig_menu.copy()

    to_keep = scaled[nutrient_to_restrict] < -1*cutoff
    better_on_this_dimension = abbrev[to_keep.values]
    rand_better = better_on_this_dimension.sample(n = 1)
    
    new_menu.iloc[max_offender, :] = rand_better.iloc[0]
    
    print("Replacing " + orig_menu[['Shrt_Desc']].iloc[max_offender, :].values + " with " + rand_better.Shrt_Desc.values)
    return new_menu

replaced_menu = replace_food_w_better(my_full_menu, 2, 'Cholestrl_mg', 0.1)

# Check that replacement happened
my_full_menu[['Shrt_Desc']].iloc[2, :]
replaced_menu[['Shrt_Desc']].iloc[2, :]


def smart_swap(orig_menu):
    new_menu = orig_menu.copy(deep=True)
    orig_menu.index = range(len(orig_menu))
    # pdb.set_trace()
    
    while len(test_mr_compliance(orig_menu)) > 0:
        for m in range(len(mr_df.index)):
            nut_to_restrict = nut_to_restrict = mr_df.iloc[m, 0]
            print("------- The nutrient we're restricting is " + nut_to_restrict + ". It has to be below " + str(mr_df[['value']].iloc[m, 0]))
            val_nut_to_restrict = sum(orig_menu[nut_to_restrict] * orig_menu['GmWt_1'])/100 # the amount of that must restrict nutrient in our original menu
            print("The original total value of that nutrient in our menu is " + str(round(val_nut_to_restrict, 2)))
            
            while val_nut_to_restrict > mr_df.iloc[m, 1]:
                max_offender = max(orig_menu[[nut_to_restrict]].index)
                print("The worst offender in this respect is " + orig_menu[['Shrt_Desc']].iloc[max_offender, 0])
                
                # replacement_food = replace_food_w_better(orig_menu, max_offender, nut_to_restrict, 0.2)
                # new_menu.iloc[max_offender, :]  = replacement_food
                # print("Replacing the max offender with a better food: " + replacement_food[['Shrt_Desc']])
                new_menu = replace_food_w_better(orig_menu, max_offender, nut_to_restrict, 0.2)
                
            val_nut_to_restrict = sum(new_menu[nut_to_restrict] * new_menu['GmWt_1'])/100
            print("Our new value of this must restrict is " + val_nut_to_restrict)
    
    return new_menu

smartly_swapped = smart_swap(my_full_menu)



# smart_swap <- function(orig_menu) {
  
#   while(nrow(test_mr_compliance(orig_menu)) > 0) {
    
#     for (m in seq_along(mr_df$must_restrict)) {    # for each row in the df of must_restricts
#       nut_to_restrict <- mr_df$must_restrict[m]    # grab the name of the nutrient we're restricting
#       print(paste0("------- The nutrient we're restricting is ", nut_to_restrict, ". It has to be below ", mr_df$value[m]))
#       to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1))/100   # get the amount of that must restrict nutrient in our original menu
#       print(paste0("The original total value of that nutrient in our menu is ", to_restrict))
      
#       while (to_restrict > mr_df$value[m]) {     # if the amount of the must restrict in our current menu is above the max value it should be according to mr_df
#         max_offender <- which(orig_menu[[nut_to_restrict]] == max(orig_menu[[nut_to_restrict]]))   # get index of food that's the worst offender in this respect
        
#         print(paste0("The worst offender in this respect is ", orig_menu[max_offender, ]$Shrt_Desc))
        
#         # ------- smart swap or randomly swap in a food here --------
        
#         orig_menu[max_offender, ] <- if (inherits(try(replace_food_w_better(orig_menu, max_offender, nut_to_restrict), silent = FALSE), "try-error")) {
#           print(paste0("Replacing the max offender with a random food: ", replace_food_w_rand(orig_menu, max_offender)[["Shrt_Desc"]]))
#           replace_food_w_rand(orig_menu, max_offender) 
#         } else {
#           print(paste0("Replacing the max offender with a better food: ", replace_food_w_better(orig_menu, max_offender, nut_to_restrict)[["Shrt_Desc"]]))
#           orig_menu[max_offender, ] <- replace_food_w_better(orig_menu, max_offender, nut_to_restrict)
#         }
        
#         to_restrict <- (sum(orig_menu[[nut_to_restrict]] * orig_menu$GmWt_1))/100   # recalculate the must restrict nutrient content
#         print(paste0("Our new value of this must restrict is ", to_restrict))
#       }
#     }
#   }
#   orig_menu
# }

# # smartly_swapped <- smart_swap(menu)









