# use the road map epi database to build a ref
# website:  http://egg2.wustl.edu/roadmap/web_portal/chr_state_learning.html#exp_18state
# there are 98 samples from different cells, the annotation information can be found here:
# https://github.com/mdozmorov/genomerunner_web/wiki/Roadmap-cell-types

# pre request:
# 1, need a merged interval file as input
# 2, put all single bed file in same folder, no extra bed files, or change the recognition rule in step2



# linux: awk '$4' $file | awk '/7_EnhG1|8_EnhG2|9_EnhA1|10_EnhA2|11_EnhWk/' >  ./enhancer_collection/enhancer_$file
# merge all files to get a coordination list (should be a 200bp bin)


# step 1, build ref, input file is the merged bed file
import sys
import pandas as pd
table=pd.read_csv(sys.argv[1], header=None, sep='\t')
chrom=list(set(list(table[0])))

ref_interval={}
for i in chrom:
    temp=table.loc[table[0]==i, ]
    start=list(temp[1])
    end=list(temp[2])
    interval=list(set(start+end))
    interval.sort()                     # b = a.sort( ) return empty
    ref_interval[i]=interval            # if need 200bp bin, use the max / 200 to get

start={}
end={}
for i in chrom:
    start[i]=ref_interval[i][:-1]
    end[i]=ref_interval[i][1:]

print("getting ref coordination, step 1 done......")
print("start to read single files......")


# step 2, read all the single file and build the table
import glob
file_list=glob.glob("*.bed")
status_record={}
type_record={}

for i, file in enumerate(file_list):
    print("processing file %s start, %d of %d total" %(file, i+1, len(file_list)))
    status_record[file]={}
    type_record[file]={}
    single=pd.read_csv(file, header=None, sep='\t')
    for a in chrom:
        sub=single.loc[single[0]==a, ]
        sub_start=list(sub[1])
        sub_end=list(sub[2])
        sub_note=list(sub[3])
        status=[]
        type=[]
        vector=0
        for c in range(len(sub_note)):      # loop through single file for each chrom
            for d in range(vector, len(start[a])): # loop through ref for each chrom
                if start[a][d] < sub_start[c]:
                    status.append(0)
                    type.append(".")
                elif start[a][d] >= sub_start[c] and start[a][d] < sub_end[c]:
                    status.append(1)
                    type.append(sub_note[c])
                elif start[a][d] == sub_end[c]:
                    vector=d
                    break
        try:                    # because the last record may not reach the last segment of reference
            tail=start[a].index(sub_end[-1])
        except ValueError:      # in this case the last record is the last segment
            tail=len(start[a])
        except IndexError:
            tail=0
        status=status+[0]*(len(start[a])-tail)
        type=type+["."]*(len(start[a])-tail)
        status_record[file][a]=status
        type_record[file][a]=type
    print("processing file %s done, %d of %d total" % (file, i+1, len(file_list)))

print("step2 over, mergeing all the results together......")

# step 3, put all information together
print("step3 start......")
df_result={}

for i in chrom:     #most time limiting step
    chr=[i]*len(start[i])
    df_result[i]=pd.DataFrame([ chr, start[i], end[i] ] ).transpose()
    df_result[i].columns=['chrom', 'start', 'end']
    for file in file_list:
          df_result[i]["%s_status" %file]=status_record[file][i]
          df_result[i]["%s_type" %file]=type_record[file][i]


lsp=pd.concat(df_result.values(), ignore_index=True)
lsp=lsp.sort_values(by=['chrom', 'start'])
lsp.to_csv("enhancer_ref.txt", header=True, sep='\t', index=False)






