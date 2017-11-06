import glob
import pandas as pd
import numpy as np

table_list=glob.glob("*.csv")
total=[]

for table in table_list:
    content=pd.read_csv(table, sep=',', header=None)
    content=content[[1,2]]
    name=table[7:-19]
    content.columns=['item',name]
    total.append(content)

result=total[0]

for i in range(len(total)-1):
    result=pd.merge(result, total[i+1], on=['item'])

result.to_csv("mapping_status.csv", sep=",", header=None, index=False)
