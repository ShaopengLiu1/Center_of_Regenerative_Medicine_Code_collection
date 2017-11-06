
import sys
import pandas as pd
import numpy as np
import re
                 
path=sys.argv[1]
name=sys.argv[2]

file=open(path)
for i in file:
    if "total reads" in i:
                 total=i
    if "mappable reads" in i:
                 mapped=i
    if "mapQ" in i:
                 unique=i
    if "non-redundant" in i:
                 non_redundant=i


total=int(re.findall('\d+', total)[0])
mapped=mapped[22:]
mapped=int(re.findall('\d+', mapped)[0])
unique=int(re.findall('\d+', unique)[1])
non_redundant=int(re.findall('\d+', non_redundant)[0])

result=[['total','mapped','unique','non_redundant'],[total, mapped, unique, non_redundant]]

result=pd.DataFrame(result)
result=result.transpose()

result.columns=['item',name]
result.to_csv("%s_mapping_report.csv" %name,  sep=',', header=True)
        
