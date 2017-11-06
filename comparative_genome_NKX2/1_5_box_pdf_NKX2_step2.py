import os
os.chdir("/Users/shaopeng/Desktop")

a="403	395	684	517	2562	739	2474	486	1477".split('\t')
b="281	297	1164	885	1331	1162	2395	885	2089".split('\t')
name="super_e	enhancer	promoter	CGI	TE	exon	intron	UTR	intergenic".split('\t')
hg=[int(x) for x in a]
mm=[int(x) for x in b]

import matplotlib.pyplot as plt
import numpy as np
ind=np.arange(len(hg))
data=[hg, mm]

fig, ax=plt.subplots()
rec1=ax.bar(ind, hg, 0.35, color='r')
rec2=ax.bar(ind+0.35, mm, 0.35, color='b')

### add labels
ax.set_ylabel("number of peaks")
ax.set_xticks(ind+0.35)
ax.set_xticklabels(name)
ax.legend((rec1, rec2), ('hg38', 'mm10'), loc='upper right')
plt.setp(ax.get_xticklabels(), rotation=30, fontsize=10)
plt.savefig("result.png")

### try to use pdf
import datetime
import numpy as np
from matplotlib.backends.backend_pdf import PdfPages

with PdfPages('test.pdf') as file:
    fig, ax = plt.subplots()
    rec1 = ax.bar(ind, hg, 0.35, color='r')
    rec2 = ax.bar(ind + 0.35, mm, 0.35, color='b')

    ### add labels
    ax.set_ylabel("number of peaks")
    ax.set_xticks(ind + 0.35)
    ax.set_xticklabels(name)
    ax.legend((rec1, rec2), ('hg38', 'mm10'), loc='upper right')
    plt.setp(ax.get_xticklabels(), rotation=30, fontsize=12)

    file.savefig()
    plt.close()