import sys
file=sys.argv[1]
out=sys.argv[2]

with open(out, 'w') as new:
    with open(file, 'r') as old:
        for i, line in enumerate(old.readlines()):
                infor=[]
                line_l=line.strip().split('\t')
                infor.append(str(line_l[0]))
                infor.append(str(min(int(line_l[1]),int(line_l[11]))))
                infor.append(str(max(int(line_l[2]),int(line_l[12]))))
                infor.append(str(line_l[3]+'%%'+line_l[13]))
                temp='\t'.join(infor)
                new.write(temp.strip()+'\n')




 # close           
