# aim: to retain certain part from enhance ref
# parameter 1: the ref file
# parameter 2: the keyword of library:  EXXX, seperated by comma
# usage:   my.py   ref.txt  E001,E002,E003

import sys
import pandas as pd
table=pd.read_csv(sys.argv[1], header=0, sep='\t')
sub=sys.argv[2].split(',')

new=['chrom','start', 'end'] + [ x+'_status' for x in sub]

new_table=table.loc[:, new ]

a1=len(new_table.columns)

new_table=new_table.dropna(axis=1, how='all')
a2=len(new_table.columns)
ss=int(a1-a2)
pp=int(a2-3)
new_table['merged_status_%d' %pp]=new_table.iloc[:, 3:].sum(axis=1)

print("there are %d libraries that DO NOT have enhancer data in the ref" %ss)

result=new_table[['chrom','start','end','merged_status_%d' %pp]]
result=result.loc[result['merged_status_%d' %pp]>0, ]


result.to_csv("sub_ref.txt", header=True, sep='\t', index=False)

