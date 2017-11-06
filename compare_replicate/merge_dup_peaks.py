import sys
peak=sys.argv[1]
new_peak=sys.argv[2]

with open(new_peak, 'w') as newf:
    with open(peak, 'r') as oldf:
        last = ''
        for index, line in enumerate(oldf.readlines()):
            if index == 0:
                last = line
            elif index != 0 and line.strip() != '':
                last_l = last.strip().split('\t')
                line_l = line.strip().split('\t')
                if last_l[1] == line_l[1] or last_l[2] == line_l[2] or last_l[11] == line_l[11] or last_l[12] == line_l[12]:
                    combination_l = last_l
                    combination_l[1] = str(min(int(last_l[1]),int(line_l[1])))
                    combination_l[11] = str(min(int(last_l[11]),int(line_l[11])))
                    combination_l[2] = str(max(int(last_l[2]),int(line_l[2])))
                    combination_l[12] = str(max(int(last_l[12]),int(line_l[12])))
                    last='\t'.join(combination_l)
                else:
                    newf.write(last.strip()+'\n')
                    last=line
                   
