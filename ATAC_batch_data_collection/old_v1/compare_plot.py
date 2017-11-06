# to compare a given results data with existing data and plot

import sys
import pandas as pd 
import matplotlib
matplotlib.use('Agg')
import pylab as pl
import matplotlib.pyplot as plt
import seaborn as sns

# chrM
chrm=pd.read_csv("plot_chrM.txt", header=None, sep='\t')
chrm.columns=['file', 'chrM_ratio', 'marker']
sns.boxplot(x='marker', y='chrM_ratio', data=chrm)
plt.savefig("chrM_comparison.png")
plt.close()

# dedup level
dedup=pd.read_csv("plot_dedup.txt", header=0, sep='\t')
sns.boxplot(x='marker', y='deduplication_percentage', data=dedup)
plt.savefig("deduplication_percentage_comparison.png")
plt.close()


# mapping and others
mapping=pd.read_csv("plot_mapping.txt", header=0, sep='\t')

# rup:
sns.boxplot(x='marker', y='rup_ratio', data=mapping)
plt.ylim([0, 100])
plt.savefig("reads_under_peak_ratio_compare.png")
plt.close()

fig1=plt.figure()
# total reads
ax1=fig1.add_subplot(121)
ax1=sns.boxplot(x='marker', y='total', data=mapping)
# mapping ratio
ax2=fig1.add_subplot(122)
ax2=sns.boxplot(x='marker', y='mapped_ratio', data=mapping)
ax2.set_ylim([0,1])
fig1.savefig("total_reads.png")
plt.close()


fig2=plt.figure()
# effect ratio
ax4=fig2.add_subplot(122)
ax4=sns.boxplot(x='marker', y='effect_ratio', data=mapping)
ax4.set_ylim([0,1])
# effect reads
ax3=fig2.add_subplot(121)
ax3=sns.boxplot(x='marker', y='non-redundant_uniq_mapped', data=mapping)
fig2.savefig("non-redundant_unique_mapped.png")
plt.close()


# PBC
sns.boxplot(x='marker', y='PBC', data=mapping)
plt.ylim([0,1])
plt.savefig("PBC_compare.png")
plt.close()

