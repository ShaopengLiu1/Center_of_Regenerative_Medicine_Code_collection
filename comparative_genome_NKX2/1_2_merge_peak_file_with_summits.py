# pre-sorted bed file
# chr start end peak_name  "summits_start"  summits, total 6 cols

import sys
file=sys.argv[1]
result="range_merge_final_peak_with_summits.txt"

with open(file, 'r') as old:
    with open(result, 'w') as new:
        temp=''
        for i, line in enumerate(old):
            if i==0:
                temp=line
            elif i != 0:
                line_l=line.strip().split('\t')
                temp_l=temp.strip().split('\t')
                if  (line_l[0]==temp_l[0])  and (int(line_l[1]) <= int(temp_l[2])) :          #2 peaks overlap
                    merge=line_l
                    weight = int((len(temp_l[3]) + 1) / len(line_l[3]))
                    merge[1]=temp_l[1]
                    merge[2]=str(max(int(temp_l[2]), int(line_l[2])))
                    merge[3]=temp_l[3]+'and'+line_l[3]
                    merge[5]=str(int((weight*int(temp_l[5])+int(line_l[5])) / (weight+1) ))  # weighted average
                    temp='\t'.join(merge)
                else:
                    new.write(temp.strip()+'\n')
                    temp=line


