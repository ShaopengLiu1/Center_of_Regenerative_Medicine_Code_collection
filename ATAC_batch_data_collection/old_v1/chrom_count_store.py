import sys
import pandas as pd
import numpy as np
                 
path=sys.argv[1]
name=sys.argv[2]
                 
table=pd.read_csv(path, sep="\t", header=None)
table.columns=['chrom','length','%s_count' %name, 'non']
content=table.loc[(table['chrom'].str.len() <7) & (table['chrom'].str.len() >1)]

content.to_csv("%s_Chromsome_count.csv" %name, sep=",", header=True, index=False)
