# use gene list to get the expression data for hg38 expression data
# argv[1] is the gene list (df)
# argv[2] is the expression data
# argv[3] is the column indicator

import sys
import pandas as pd

gene_list=sys.argv[1]
exp_data=sys.argv[2]
gene_col=int(sys.argv[3])

gene=pd.read_csv(gene_list, header=None, sep='\t')
gene=list(gene[gene_col])
#substract the gene name from Gencode annotation for perfect match by name
temp=[x.split(";")[4] for x in gene]
gene=[x[12:-1] for x in temp]
total=len(set(gene))

exp=pd.read_csv(exp_data, header=0, sep='\t')
exp_gene=list(exp['gene'])

record=[]
for m,n in enumerate(exp_gene):
    for b in gene:
        if n == b:
            record.append(m)

new=set(record)
out=exp.loc[new, ]   # hg data doesn't have duplicate gene name
find=len(new)

extra=list(set(gene)-set(list(out['gene'])))
df_extra=pd.DataFrame(extra)
df_extra.to_csv("extra.txt", header=None, index=False)

out.to_csv("hg38_exp_record_%d_of_%d.txt" %(find, total), index=False, header=True, sep='\t')


