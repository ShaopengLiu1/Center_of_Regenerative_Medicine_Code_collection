#!/bin/bash
# from ENCODE IDR 

cutoff=0.05
name='postnatal_d0'


mkdir summarize
find . -name "*-npeaks-aboveIDR.txt" | xargs cp -t ./summarize/
cd summarize
for file in `ls replicate_idr_*npeaks-aboveIDR.txt`
do
	peak=`awk -F " " -v cutoff=$cutoff '$3==cutoff' $file | awk -F " " '{print $4}'`
	temp=`echo ${file#replicate_idr_}`
	size=`echo ${temp%%0*}`
	echo "the sample size is $size Million"
	echo -e "$size\t$peak" >> temp.txt
done

sort -k1,1n temp.txt  >> 'summarized_idr_'$name'_cutoff_'$cutoff'.txt'

# get total peak number
# cd to the peak folder
for file in `ls peakcall_file1*narrowPeak`
do
temp=`echo ${file#peakcall_file1_}`
num=`echo ${temp%%0*}`
echo $num >> record.txt
n1=`wc -l 'peakcall_file1_'$num'000000_peaks.narrowPeak' | awk '{print $1}'`
n2=`wc -l 'peakcall_file2_'$num'000000_peaks.narrowPeak' | awk '{print $1}'`
if [[ $n1 -ge $n2 ]];then
bigger=$n1
else
bigger=$n2
fi
echo $bigger >> peak_num.txt
done
paste record.txt peak_num.txt | sort -k1,1n >> peak_number_$name.txt

# put 2 results together
paste summarized_idr_$name'_cutoff_0.05.txt' peak_number_$name.txt | awk '$5=$2/$4' OFS="\t" > $name'_old_idr_output.txt'



# plot (in R)
d115=read.table("summarized_idr_d11.5_cutoff_0.25.txt", header=True, sep='\t')
#d125
#dp
plot(dp$size, dp$peak, col='red', type='b', ylab = 'peak number', xlab='library size', xlim = c(0, 60), ylim=c(0, 60000))
lines(d115$size, d115$peak, col='blue', type='b')
lines(d125$size, d125$peak, col='black', type='b')
legend('topleft', legend=c('postnatal_d0', 'embryo_d11.5', 'embryo_d12.5'), col=c('red', 'blue', 'black'), lty=c(2,2))
title("peak number against sample size")

