import glob
import matplotlib
matplotlib.use('Agg')
import pandas as pd
import pylab as pl
import matplotlib.pyplot as plt
import sys
cutoff=int(sys.argv[1])

plt.clf()
file=glob.glob("*.txt")
read1=[]
read2=[]
peak1=[]
peak2=[]
ratio1=[]
ratio2=[]
name1=[]
name2=[]

for i in file:
    table=pd.read_csv(i, sep='\t', header=None)
    table.columns=table.iloc[0,]
    table=table[1:]
    table=pd.DataFrame(table, dtype='float')
    if max(table['read']) > cutoff:
	    read1.append(table['read'])
	    ratio1.append(table['ratio'])
	    peak1.append(table['peak'])
	    name1.append(i)
    else:
	    read2.append(table['read'])
	    ratio2.append(table['ratio'])
	    peak2.append(table['peak'])
	    name2.append(i)

    

for i in range(0, len(name1)):
    plt.plot(read1[i],ratio1[i])
    plt.ylim=([0,1])
    plt.axhline(y=0.8)
    plt.xlabel("Million reads")
    plt.ylabel("peak_ratio_to_original")

plt.savefig("greater%d_ratio_by_reads.png" %cutoff)
plt.clf()

for i in range(0, len(name1)):
    plt.plot(read1[i],peak1[i])
    plt.xlabel("Million reads")
    plt.ylabel("peak_number")

plt.savefig("greater%d_peak_by_reads.png" %cutoff)
plt.clf()



for i in range(0, len(name2)):
    plt.plot(read2[i],ratio2[i])
    plt.ylim=([0,1])
    plt.axhline(y=0.8)
    plt.xlabel("Million reads")
    plt.ylabel("peak_ratio_to_original")

plt.savefig("smaller%d_ratio_by_reads.png" %cutoff)
plt.clf()


for i in range(0, len(name2)):
    plt.plot(read2[i],peak2[i])
    plt.xlabel("Million reads")
    plt.ylabel("peak_number")

plt.savefig("smaller%d_peak_by_reads.png" %cutoff)
plt.clf()

table1=pd.DataFrame()
table2=pd.DataFrame()

for i in range(0, len(name1)):
    table1["%s_read" %name1[i][7:-22]]=read1[i]
    table1["%s_peak" %name1[i][7:-22]]=peak1[i]
    table1["%s_ratio" %name1[i][7:-22]]=ratio1[i]

for i in range(0, len(name2)):
    table2["%s_read" %name2[i][7:-22]]=read2[i]
    table2["%s_peak" %name2[i][7:-22]]=peak2[i]
    table2["%s_ratio" %name2[i][7:-22]]=ratio2[i]

table1.to_csv("greater%d_collection.csv" %cutoff, sep=',', header=True)
table2.to_csv("smaller%d_collection.csv" %cutoff, sep=',', header=True)
