
import numpy as np
import pandas as pd


abbrev = pd.read_csv("./Desktop/Earlybird/food-progress/ABBREV.csv")

abbrev.rename(columns = {'\xef\xbb\xbfNDB_No':"NDB_No"}, inplace = True)

ab = abbrev[["NDB_No", "Shrt_Desc", "Energ_Kcal", "Protein_(g)", "Sugar_Tot_(g)", "GmWt_1"]]


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


import feather as f
scaled = pd.read_feather("./Desktop/Earlybird/food-progress/")

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
        


# ! pip install feather






N = 100
df = pd.DataFrame({
    'A': pd.date_range(start='2016-01-01',periods=N,freq='D'),
    'x': np.linspace(0,stop=N-1,num=N),
    'y': np.random.rand(N),
    'C': np.random.choice(['Low','Medium','High'],N).tolist(),
    'D': np.random.normal(100, 10, size=(N)).tolist()
    })
df.head()


df.describe





