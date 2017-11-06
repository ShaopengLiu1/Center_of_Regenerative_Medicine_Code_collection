# to check the peak interaction that is more than "intersect"
# need to assign threshold
# input file1 is the original narrowPeak file, with columns:  chrom  start  end  peakname  'summit'  summit_position
# input file2 is the liftover peak file, with columns: chrom start end peakname 'summit'  summit_position
# sys.argv[3] is the threshold value

import pandas as pd
import sys
import os

reference=pd.read_csv(sys.argv[1], header=None, sep='\t')  # the narrowPeak file
target=pd.read_csv(sys.argv[2], header=None, sep='\t')   # the lift over file
threshold=int(sys.argv[3])

ref_dict={} # to store all the summits points for each chrom
sub_ref=set(reference[0])
for i in sub_ref:
    temp_ref=reference.loc[reference[0]==i, ]
    ref_dict[i]=list(temp_ref[5])

tar_dict={} # to store all summits point for each chrom in liftover file
sub_tar=set(target[0])
for i in sub_tar:
    temp_tar=target.loc[target[0]==i, ]
    tar_dict[i]=list(temp_tar[5])

def allocate(database, search, subsample):
    match=[]
    distance=[]
    for i in search:
        near=min(enumerate(database), key=lambda x:abs(x[1]-i))
        dis=abs(near[1]-i)
        match.append(near[0])  #store the position
        distance.append(dis)
    ref=reference.loc[reference[0]==subsample, ]
    output=ref.iloc[match,  ]        # must use iloc instead of loc, iloc is pure intergenic index
    tar=target.loc[target[0]==subsample, ]
    output['lo_peak_right']='lo_peak_right'
    output['start']=list(tar[1])
    output['end']=list(tar[2])
    output['peak_name']=list(tar[3])
    output['distance']='distance'
    output['dis']=distance
    final=output.loc[output['dis'] <= threshold, ]
    return final

result_dict={}
for a in sub_tar:
    result_dict[a]=allocate(ref_dict[a], tar_dict[a], a)

fss=pd.concat(result_dict.values(), ignore_index=True)
fss.to_csv("result.txt", sep='\t', header=None, index=False)


