import glob
import matplotlib
matplotlib.use('Agg')
import pandas as pd
import pylab as pl
import matplotlib.pyplot as plt

plt.clf()
file=glob.glob("*.txt")
peak=[]
read=[]
ratio=[]

for i in file:
    table=pd.read_csv(i, sep='\t', header=None)
    table.columns=table.iloc[0,]
    table=table[1:]
    table=pd.DataFrame(table, dtype='float')
    read.append(table['read'])
    peak.append(table['peak'])
    ratio.append(table['ratio'])


    
for i in range(0, len(file)):
    plt.plot(read[i],peak[i])
    plt.text(x=read[i][10], y=peak[i][10], s=file[i][7:-22])

plt.savefig("peak_by_reads_mark.png")
plt.clf()

for i in range(0, len(file)):
    plt.plot(read[i],peak[i])

plt.savefig("peak_by_reads.png")
plt.clf()

for i in range(0, len(file)):
    plt.plot(read[i],ratio[i])
    plt.ylim=([0,1])
    plt.axhline(y=0.8)

plt.savefig("ratio_by_reads.png")
plt.clf()

table=pd.DataFrame()
for i in range(0, len(file)):
    table["%s_read" %file[i][7:-22]]=read[i]
    table["%s_peak" %file[i][7:-22]]=peak[i]
    table["%s_ratio" %file[i][7:-22]]=ratio[i]

table.to_csv("collection.csv", sep=',', header=True)
