import pandas as pd
import numpy as np
import sys

path=sys.argv[1]
file=open(path)
for i in file:
    if "Filename" in i:
        name=i
file_name=name.split("\t")[1]
file.close()

content=[]
file=open(path)
for i, line in enumerate(file):
    if "Sequence Duplication Levels" in line:
        global start
        start=i
file.close()


file=open(path)
for i, line in enumerate(file):        
    if i>=start and i<= start+12:
        content.append(line.strip())
file.close()
        
# get a list with 12 lines
new=[]
for i in content:
   new.append(i.split("\t"))

result=pd.DataFrame(new)
result.columns=['item',"%s_percentage_of_deduplicated" %file_name, "%s_percentage_of_total" %file_name]
result.to_csv("duplication_%s.csv" %file_name[:-6], sep=',', header=True, index=False)
