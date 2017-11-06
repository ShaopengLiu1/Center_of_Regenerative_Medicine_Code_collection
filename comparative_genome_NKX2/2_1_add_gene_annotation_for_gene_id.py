# for the 251 ortholog genes
# add the annotation from gencode promoter file
# argu1 is the gencode annotation file
# argu2 is the ortho list
# argu3 is the col indicator

import sys
import pandas as pd

ref=pd.read_csv(sys.argv[1], header=None, sep='\t')
query=pd.read_csv(sys.argv[2], header=None, sep='\t')

anno=list(ref[5])
id=list(query[int(sys.argv[3])])

record=[]
for i in id:
    for a in set(anno):
        if i in a:
            record.append(a)

query['anno']=record
query.to_csv("add_anno.txt", header=None, sep='\t', index=False)