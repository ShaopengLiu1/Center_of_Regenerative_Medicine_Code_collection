# reverse direction: from gene ID to get the peak
# argv1: gene id file
# argv2: hg assign peak to TSS
# argv3: mm assign peak to TSS file
# argv4: hg distance indicator
# argv5: mm distance indicator

import pandas as pd
import sys
table=pd.read_csv(sys.argv[1], header=None, sep='\t')
hg_gene=list(table[0])
mm_gene=list(table[1])
hg_anno=pd.read_csv(sys.argv[2], header=None, sep='\t')
mm_anno=pd.read_csv(sys.argv[3], header=None, sep='\t')

#generate the peak assign file with special relationship only

hg_sub=hg_anno.loc[hg_anno[12]==sys.argv[4], ]
hg_list=list(hg_sub[5])
mm_sub=mm_anno.loc[mm_anno[12]==sys.argv[5], ]
mm_list=list(mm_sub[5])

# abstract the hg peaks and assigned genes
hg=[]
for i in hg_gene:
    for m, n in enumerate(hg_list):
        if i in n:
            hg.append(m)
hg_out=hg_sub.iloc[hg, ]
hg_out.to_csv("hg_result_%s" %sys.argv[1], header=None, sep='\t', index=False)
hg_peak=hg_out.loc[:, [6, 7, 8, 9]]
hg_peak.to_csv("hg_peak_only_%s" %sys.argv[1], header=None, sep='\t', index=False)


# mm peaks and genes
mm=[]
for i in mm_gene:
    for m, n in enumerate(mm_list):
        if i in n:
            mm.append(m)
mm_out=mm_sub.iloc[mm, ]
mm_out.to_csv("mm_result_%s" %sys.argv[1], header=None, sep='\t', index=False)
mm_peak=mm_out.loc[:, [6, 7, 8, 9]]
mm_peak.to_csv("mm_peak_only_%s" %sys.argv[1], header=None, sep='\t', index=False)



