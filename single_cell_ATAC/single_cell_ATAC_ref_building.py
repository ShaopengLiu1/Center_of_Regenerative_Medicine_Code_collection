# Build Peak occupancy reference for Single cell ATAC reference
# input: merged peak file

import sys
import os
import pandas as pd
import glob

file=sys.argv[1]
os.system("mkdir chrom_sub_sample")

table=pd.read_csv(file, header=None, sep='\t')
new=table.loc[(table[0].str.len() <7) & (table[0].str.len() >1)]
keep=list(set(new[0]))
new.to_csv('modefied_'+file, sep='\t', header=None, index=False)


# sub sampling
# seperate modefied file into seperate chromosome
with open('modefied_'+file, 'r') as f:
    for seq, line in enumerate(f):
        l=line.split()[ :4]         ## keep the SE/PE information
        if l[0] in keep:
            with open('chrom_sub_sample/'+l[0]+'.bed','a') as subsample:
                subsample.write('\t'.join(l)+'\n')



# loop through each chrom
os.chdir("./chrom_sub_sample")
all_chrom=glob.glob("*.bed")
for peak_file in all_chrom:
    cc=pd.read_csv(peak_file, header=None, sep='\t')
    cc1=list(cc[1])
    cc2=list(cc[2])
    name=list(cc[3])
    position=cc1+cc2
    position=list(set(position))
    position.sort()                     # create a list with all value-change points
    peak_number=[0]*(len(position)-1)   # len(position)-1 fragments
    PE_peak=[0]*(len(position)-1)       # count for PE peaks
    SE_peak=[0]*(len(position)-1)       # count for SE peaks
    vector=0                            # starting point for the search in position list
    for i in range(len(cc1)):
        for b in range(vector, len(position)-1):
            if position[b+1] <= cc1[i]:
                vector=b
            if position[b] >= cc1[i] and position[b+1] <= cc2[i]:
                peak_number[b]+=1
                if "pair" in name[i]:
                    PE_peak[b]+=1
                elif "single" in name[i]:
                    SE_peak[b]+=1
            if position[b] >= cc2[i]:
                break
    start=position[0:len(position)-1]
    end=position[1:len(position)]
    peak=peak_number
    chromosome=[peak_file[:-4]]*(len(position)-1)
    result=pd.DataFrame([chromosome, start, end, peak, SE_peak, PE_peak])
    result=result.transpose()
    result=result[result[3] != 0]
    result.to_csv(peak_file[:-4]+'_peak_count.bed', sep='\t', header=None, index=False)



# combine all the result s together
os.system(" cat *peak_count.bed > peak_count_final.bed")
os.system(" bedtools sort -i peak_count_final.bed > sorted_final_peak_count.bed")
os.system(" mv sorted_final_peak_count.bed ../")
os.chdir("../")

                
            

        
        


    
    


