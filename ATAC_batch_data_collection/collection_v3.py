# python code to merge
import pandas as pd
import glob
import os
import sys

#1, merge all qc summary
qc_list=glob.glob("fastqc_summary*result")
total=[]
for i in qc_list:
	content=pd.read_csv(i, header=0, sep='\t')
	total.append(content)

result=total[0]
for i in range(len(total)-1):
    result=pd.merge(result, total[i+1], left_on='fastqc_test', right_on='fastqc_test', how='outer')

result.to_csv("merged_qc_summary.txt", sep="\t", header=True, index=False)


#2, merge all chrom count and generate chrM ratio
chrom_list=glob.glob("chrom_count*result")
total=[]
ratio=[]

for i in chrom_list:
    content=pd.read_csv(i, sep='\t', header=None)
    name=i[12:-7]
    content.columns=['chrom', '%s_mapped' %name, '%s_effect' %name, '%s_marker' %name]
    mapped=content['%s_mapped' %name].sum()/100
    effected=content['%s_effect' %name].sum()/100
    content['%s_mapped_distri' %name]=content['%s_mapped' %name].divide(mapped, axis=0)
    content['%s_effect_distri' %name]=content['%s_effect' %name].divide(effected, axis=0)
    content=content[['chrom', '%s_marker' %name, '%s_mapped' %name, '%s_mapped_distri' %name, '%s_effect' %name, '%s_effect_distri' %name]]
    total.append(content)


result=total[0]
for i in range(len(total)-1):
    result=pd.merge(result, total[i+1], on=['chrom'])

# merged data
result.to_csv("merged_chrom_count.txt", sep="\t", header=True, index=False)


#3, merge duplication summary
dup_list=glob.glob("duplication_summary*result")
total=[]
for i in dup_list:
	content=pd.read_csv(i, sep='\t', header=0)
	total.append(content)

result=total[0]

for i in range(len(total)-1):
    result=pd.merge(result, total[i+1], on=['item'])

result.to_csv("merged_dup_level.txt", sep="\t", header=True, index=False)


#4, saturation
os.chdir("./saturation")
import matplotlib
matplotlib.use('Agg')
import pylab as pl
import matplotlib.pyplot as plt
file=glob.glob("saturation*result")
peak=[]
read=[]
ratio=[]
label=[]
for i in file:
    table=pd.read_csv(i, sep='\t', header=0)
    table.columns=['sample', 'read', 'peak', 'ratio', 'marker']
    table=table.loc[:, ['read', 'peak','ratio']]
    table=pd.DataFrame(table, dtype='float')
    read.append(table['read'])
    peak.append(table['peak'])
    ratio.append(table['ratio'])
    name=i[11:-7]
    label.append(name)

for i in range(0, len(file)):
    plt.plot(read[i],peak[i], label=label[i])

plt.legend(loc='upper left', bbox_to_anchor=(-0.15, 1.1), ncol=1, fancybox=True, shadow=True, fontsize=10)
plt.xlabel("million_reads")
plt.ylabel("peak_numbers")
plt.savefig("peak_by_reads_mark.png")
plt.close()

for i in range(0, len(file)):
    plt.plot(read[i],ratio[i], label=label[i])

plt.legend(loc='upper left', bbox_to_anchor=(-0.15, 1.1), ncol=1, fancybox=True, shadow=True, fontsize=10)
plt.ylim=([0,1])
plt.axhline(y=0.8)
plt.xlabel("Million_reads")
plt.ylabel("ratio_of_peaks")
plt.savefig("ratio_by_reads.png")
plt.close()

# store merged file
table=pd.DataFrame()
for i in range(0, len(file)):
    table["%s_read" %label[i]]=read[i]
    table["%s_peak" %label[i]]=peak[i]
    table["%s_ratio" %label[i]]=ratio[i]

table.to_csv("merged_saturation_collection.txt", sep='\t', header=True)





