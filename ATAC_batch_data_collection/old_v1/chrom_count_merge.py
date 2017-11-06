import pandas as pd
import numpy as np
import sys
import glob

table_list=glob.glob("*.csv")

total=[]

for table in table_list:
    content=pd.read_csv(table, sep=',', header=None)
    content=content[[0,1,2]]
    name=table[10:-4]
    content.columns=['chrom','length',name]
    total.append(content)

result=total[0]

for i in range(len(total)-1):
    result=pd.merge(result, total[i+1], on=['chrom','length'])

result.to_csv("merged_chrom_count.csv", sep=",", header=True, index=False)

