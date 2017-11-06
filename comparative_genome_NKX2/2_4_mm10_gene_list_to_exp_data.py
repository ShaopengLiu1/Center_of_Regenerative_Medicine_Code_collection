# use gene list to get the expression data for mm10 expression data
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
temp=[x.split(";")[3] for x in gene]
gene=[x[12:-1] for x in temp]
total=len(set(gene))

exp=pd.read_excel(exp_data, header=0)

# need to use gene here, many id-name are mismatch, name can be found here, but id can't be
temp=list(exp['GeneSymbol.ENS'])
# remove nan value
exp_gene=[str(x) for x in temp]

record=[]
for m,n in enumerate(exp_gene):
    for b in gene:
        if n == b:
            record.append(m)

new=set(record)  #remove duplicate indices arised from multiple match
out=exp.loc[new, ]

find=len(set(list(out['GeneSymbol.ENS'])))
out.to_excel("mm10_exp_record_%d_of_%d.xlsx" %(find, total), index=False)

extra=list(set(gene)-set(list(out['GeneSymbol.ENS'])))
df_extra=pd.DataFrame(extra)
df_extra.to_csv("extra_genes_that_are_not_recorded.txt", header=None, sep='\t', index=False)

# exp_wt=list(out['WT.aveA'])
# exp_ko=list(out['KO.aveA'])
# exp_fc=list(out['FC'])
# exp_lf=list(out['log2FC'])

import matplotlib.pyplot as plt
# plot the wt and ko data
