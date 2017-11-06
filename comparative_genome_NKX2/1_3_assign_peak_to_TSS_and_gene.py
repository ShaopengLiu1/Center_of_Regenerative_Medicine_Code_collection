# update 04/18, now would include chrom, start, end, and name from peak file
import sys
import os

#argv[1]: is the promoter file generated from previous code: chrom, start, end, direction, TSS, annotation
#argv[2]: the the peak file (or summits file) in bed format: chrom, start, end, name, 'summit_start', summit


import pandas as pd
reference=pd.read_csv(sys.argv[1], header=None, sep='\t')  # the promoter file with TSS
target=pd.read_csv(sys.argv[2], header=None, sep='\t') # the peak file with peak range or summits range


ref_dict={} # to store all the TSS points for each chrom
sub_ref=set(reference[0])
for i in sub_ref:
    temp_ref=reference.loc[reference[0]==i, ]
    ref_dict[i]=list(temp_ref[4])

tar_dict={} # to store all summits point of peak
sub_tar=set(target[0])
for i in sub_tar:
    temp_tar=target.loc[target[0]==i, ]
    tar_dict[i]=list(temp_tar[5])

# here we have 2 dicts for seperate chrom, one for TSS and one for summits
# then is to assign each summit value to a TSS
# these 2 steps can be merged together


def allocate(database, search, subsample):
    match=[]
    distance=[]
    for i in search:
        near=min(enumerate(database), key=lambda x:abs(x[1]-i))
        match.append(near[0])  #store the position
        distance.append(abs(near[1]-i))
    ref=reference.loc[reference[0]==subsample, ]
    output=ref.iloc[match,  ]        # must use iloc instead of loc, iloc is pure intergenic index
    tar=target.loc[target[0]==subsample, ]
    output[7] = list(tar[0])        # every peak would be assigned to 1 gene, so it's okay to directly use
    output[8] = list(tar[1])
    output[9] = list(tar[2])
    output[10]=list(tar[3])
    output[11]=list(tar[5])
    output[12]=distance
    return output


result_dict={}
for a in sub_tar:
    result_dict[a]=allocate(ref_dict[a], tar_dict[a], a)

fss=pd.concat(result_dict.values(), ignore_index=True)
fss.loc[ fss[12] > 10000, 'relation'] = 'far'
fss.loc[ (fss[12] >= 2000) & (fss[12] <= 10000), 'relation'] = 'middle'
fss.loc[ fss[12] < 2000, 'relation'] = 'close'
fss.to_csv("result.txt", sep='\t', header=None, index=False)










