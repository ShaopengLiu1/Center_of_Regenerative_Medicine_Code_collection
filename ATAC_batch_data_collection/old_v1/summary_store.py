import pandas as pd
import numpy as np
import sys

path=sys.argv[1]
table=pd.read_csv("%s" %path, sep="\t", header=None)

name=table.loc[0,2]
newtable=table[[0,1]]

newtable.to_csv("summary_%s.csv" %name, sep=",", header=None)
