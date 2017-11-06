# to transfer fimo.txt back to the peak file for intersect or else
# input is fimo.txt

import sys
import pandas as pd
table=pd.read_csv(sys.argv[1], header=0, sep='\t')
info=list(table['sequence name'])
strand=list(table['strand'])

chrom=[]
start=[]
end=[]
value=[]

for i in info:
    chrom.append((i.split(":")[0]))
    start.append(int(i.split(":")[1].split("-")[0]))
    end.append(int(i.split(":")[1].split("-")[1]))

peak=['sudo_peak_name']*len(chrom)
summit=['summit_by_mean']*len(chrom)
for i in range(len(chrom)):
    value.append(int( (start[i]+end[i])/2  ))


out=pd.DataFrame([chrom, start, end, peak, summit, value ])
out=out.transpose()

out=out.drop_duplicates()
out=out.sort_values(by=[0,1])
out.to_csv("fimo_2_peak.txt", header=None, sep='\t', index=False)
