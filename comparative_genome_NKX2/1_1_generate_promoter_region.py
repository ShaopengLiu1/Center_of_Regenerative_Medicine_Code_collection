# works for gtf file to get the promoter region 
# take 1kb +- TSS
# 1 parameter: gtf file

import pandas as pd
import sys

table=pd.read_csv(sys.argv[1], header=None, sep='\t')
sub=table.loc[table[2]=='transcript', ]
new=sub.sort_values(by=[0,3])

### merge the same gene transcript (usually overlapped)
new.to_csv("transcript_record.txt", index=False, sep='\t', header=None)
with open("temp_record.txt", 'w') as tt:
        with open("transcript_record.txt",'r') as file:
                model=''
                for i, line in enumerate(file):
                         if i == 0:
                                model = line
                         elif i != 0:
                                last = line.strip().split('\t')
                                compare=model.strip().split('\t')
                                if last[8].split(';')[0]==compare[8].split(';')[0]:
                                        merge=last
                                        merge[3]= str(min(int(last[3]), int(compare[3])))
                                        merge[4]= str(max(int(last[4]), int(compare[4])))
                                        model='\t'.join(merge)
                                else:
                                        tt.write(model.strip()+'\n')
                                        model=line



sub=pd.read_csv("temp_record.txt", header=None, sep='\t')

tss=[]
pro_start=[]
pro_end=[]

trans_left=list(sub[3])
trans_right=list(sub[4])
direction=list(sub[6])

for i in range(len(trans_right)):
    if direction[i] == '+':
        tss.append(trans_left[i])
        pro_start.append(trans_left[i]-1000)
        pro_end.append(trans_left[i]+1000)
    elif direction[i] == '-':
        tss.append(trans_right[i])
        pro_end.append(trans_right[i]+1000)
        pro_start.append(trans_right[i]-1000)

for i, value in enumerate(pro_start):
    if value < 0:
        pro_start[i] = 0

out=pd.DataFrame([list(sub[0]), pro_start, pro_end, list(sub[6]), tss, list(sub[8])])
out=out.transpose()
out.to_csv("promoter_region_from_%s.bed" %sys.argv[1], index=False, header=None, sep='\t')


