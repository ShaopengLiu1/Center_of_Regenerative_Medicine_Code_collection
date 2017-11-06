# remove all low confidence
# ignore the transcript conservation, but gene level only
# the result in ortho_ref file, with only 3 columns

# argv1 is the ortho gene ref file
# argv2 is the hg assigned peak to gene file
# argv3 is the mm assigned peak to gene file

import sys
import pandas as pd
reference=pd.read_csv(sys.argv[1], header=None, sep='\t')
hg38=pd.read_csv(sys.argv[2], header=None, sep='\t')
mm10=pd.read_csv(sys.argv[3], header=None, sep='\t')

hg=list(hg38[5])
mm=list(mm10[5])
ref0=list(reference[0])  #human genes in ortholog list
ref1=list(reference[1]) #mouse genes in ortholog list

# deal with hg38 data
# 1.1 find the genes that are in the ortholog list
hg_index=[]
hg_value=[]
ref_hg=[]
for m, i in enumerate(ref0):
    for a, b in enumerate(hg):
        if i in b:
            ref_hg.append(m)
            hg_index.append(a)
            hg_value.append(i)

hg38_inlist=hg38.iloc[list(set(hg_index)), ]   # human genes in ortholog list

mm_index=[]
mm_value=[]
ref_mm=[]
for m,i in enumerate(ref1):
    for a, b in enumerate(mm):
        if i in b:
            ref_mm.append(m)
            mm_index.append(a)
            mm_value.append(i)

mm10_inlist=mm10.iloc[list(set(mm_index)), ]   # mouse genes in ortholog list


common=list(set(ref_hg) & set(ref_mm))

orth_list=reference.iloc[common, ]
orth_list.drop_duplicates()

print(len(hg_index))
print(len(mm_index))
print(len(common))
orth_list.to_csv("orth_list.txt", header=None, sep='\t', index=False)

