# for Twist1 data
# use gene name to get the region
# argv1 is annotation file I generated
# argv2 is the gene list
# argv3 is the threshold within TSS
# argv4 is the species hg/mm

import pandas as pd
import sys

if sys.argv[4]=='hg':
    loc=4
elif sys.argv[4]=='mm':
    loc=3


ref=pd.read_csv(sys.argv[1], header=None, sep='\t') #annotation file
anno=list(ref[5])
temp=[x.split(";")[loc] for x in anno]
gene=[x[12:-1] for x in temp]   # extract the gene name only from the annotation file

check=pd.read_csv(sys.argv[2], header=None, sep='\t')  #inquiry file
inq=list(check[0])

record=[]
found=[]
for i in inq:
    for a,b in enumerate(gene):
        if i == b:
            record.append(a)
            found.append(i)

new=ref.iloc[record, ]
dis=int(sys.argv[3])

tss=list(new[4])
start=[x-dis for x in tss]
end=[x+dis for x in tss]
chrom=list(new[0])

final=pd.DataFrame([chrom, start,end, found])
final=final.transpose()
final=final.sort_values(by=[0,1])

final.to_csv("tss_%d_region_of_input_gene.txt" %dis, header=None, sep='\t', index=False)
print("%d of %d total are found in annotation file" %(len(found), len(inq)))