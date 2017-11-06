import glob
import re
import pandas as pd 
file_list=glob.glob("*.txt")
total=[]
under=[]
ratio=[]

for file in file_list:
	with open(file) as read:
		for i in read:
			if "total" in i:
				temp=i
				total.append(int(re.findall('\d+', temp)[0]))
			if "under" in i:
				temp=i
				under.append(int(re.findall('\d+', temp)[0]))
			if "ratio" in i:
				temp=i
				ratio.append(float(re.findall('\d+', temp)[0])/100)


result=pd.DataFrame([file_list, total, under, ratio]).transpose()
result.columns=['file', 'total_reads', 'reads_under_peak', 'ratio']
result.to_csv("merged_reads_under_peak.csv", header=True, sep='\t', index=False)