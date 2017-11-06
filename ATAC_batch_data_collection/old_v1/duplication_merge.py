import glob
import pandas as pd
import numpy as np
table_list=glob.glob("*.csv")
total=[]

for table in table_list:
    content=pd.read_csv(table, sep=',', header=0)
    name=table[19:-4]
    content.columns=['list',name,name]
    total.append(content)

result=total[0]

for i in range(len(total)-1):
    result=pd.merge(result, total[i+1], on=['list'])

result.to_csv("merged_dup_level.csv", sep=",", header=True, index=False)
