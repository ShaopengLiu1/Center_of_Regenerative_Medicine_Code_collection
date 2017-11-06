import pandas as pd
import numpy as np
import sys
import glob

table_list=glob.glob("*.csv")


total=[]

for table in table_list:
    content=pd.read_csv(table, sep=',', header=None)
    name=table[8:-10]
    content=content.iloc[:, [1,2]]
    content.columns=[name,'test']
    total.append(content)

result=total[0]

for i in range(len(total)-1):
    result=pd.merge(result, total[i+1], left_on='test', right_on='test', how='outer')

result.to_csv("merged_qc_summary.csv", sep=",", header=True, index=False)

