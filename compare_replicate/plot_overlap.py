import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import sys

file1=sys.argv[1]
file2=sys.argv[2]

table1=pd.read_csv(file1, sep='\t', header=None)
table2=pd.read_csv(file2, sep='\t', header=None)
r1=list(table1[5])
r2=list(table2[5])

a=list(range(0,31))



## add the separate plot
table3=pd.read_csv(sys.argv[3], sep='\t', header=None)
table4=pd.read_csv(sys.argv[4], sep='\t', header=None)
table5=pd.read_csv(sys.argv[5], sep='\t', header=None)
table6=pd.read_csv(sys.argv[6], sep='\t', header=None)
non_p1r1=list(table3[5])
non_p1r2=list(table4[5])
non_p2r1=list(table5[5])
non_p2r2=list(table6[5])




plt.clf()
plt.plot(r1, r2, 'ro', label="overlap peaks")
plt.plot(non_p1r1, non_p1r2, 'bs', label="x-specifc peaks")
plt.plot(non_p2r1, non_p2r2, 'g^', label="y-specific peaks")

plt.plot(a,a)
plt.axis([0,30,0,30])
plt.ylabel(file2)
plt.xlabel(file1)
plt.legend(loc='upper right')
plt.savefig("%s_%s.png" %(file1[:-5], file2[:-5]))

