#!/bin/bash

date
mkdir update

for peak in `ls peakcall_file1_*Peak`
do
	temp=`echo ${peak#peakcall_file1_}`
	num=`echo ${temp%%0*}`
	echo $num >> record_seq.txt
	idr --samples 'peakcall_file1_'$num'000000_peaks.narrowPeak' \
	'peakcall_file1_'$num'000000_peaks.narrowPeak' --output-file  'sample_'$num'_Million'  --plot
	mv 'peakcall_file1_'$num'000000_peaks.narrowPeak' ./update
	mv 'peakcall_file2_'$num'000000_peaks.narrowPeak' ./update
done

echo "whole pipe finished....."
date
echo "!!! keep nohup file!!!"



