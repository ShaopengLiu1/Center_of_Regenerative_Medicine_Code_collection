#!/bin/bash
date

file=$1
total=`wc -l $file | awk '{print $1}'`

mkdir subsample_$file
mv $file ./subsample_$file
cd ./subsample_$file

# rup definition: at least half of reads is under the peak region
genome_size=2730871774

touch enrichment_$file'.txt'

for i in `seq 1000000 5000000 $total`
do
	echo $i
	shuf $file | head -$i > subsample_$i'_reads.open.bed'
	macs2 callpeak -t subsample_$i'_reads.open.bed' -g mm -q 0.01 -n 'peakcall_sub_'$i --keep-dup 1000 --nomodel --shift 0 --extsize 150
	rupn=`intersectBed -a subsample_$i'_reads.open.bed' -b 'peakcall_sub_'$i'_peaks.narrowPeak' -f 0.5 | wc -l`
	peak_length=`awk '{s+=$3-$2+1}END{print s}' 'peakcall_sub_'$i'_peaks.narrowPeak'`
	upper=`python -c "print(1.0*($rupn+10000000*$peak_length/$genome_size)/$peak_length)"`
	lower=`python -c "print(1.0*(10000000+$i)/($genome_size-$peak_length))"`
	enrichment=`python -c "print(1.0*$upper/$lower)"`
	echo -e "$i\t$enrichment" >> enrichment_$file'.txt'
done

echo "whole pipe done for file $file"
date

##########################################
# refresh ENCODE results
genome_size=2730871774

for file in `ls -d Processed*`
do
name=`echo ${file#Processed_}`
cd $file
mkdir test_new_enrichment
shuf step3.1*$name'.open.bed' | head -10000000  > temp.open.bed
macs2 callpeak -t temp.open.bed  -g mm -q 0.01 -n temp_peak  --keep-dup 1000 --nomodel --shift 0 --extsize 150
rupn=`intersectBed -a temp.open.bed -b 'temp_peak_peaks.narrowPeak' -f 0.5 | wc -l`
rup=`python -c "print(1.0*$rupn/10000000)"`
peak_length=`awk '{s+=$3-$2+1}END{print s}' 'temp_peak_peaks.narrowPeak'`
upper=`python -c "print(1.0*($rupn+10000000*$peak_length/$genome_size)/$peak_length)"`
lower=`python -c "print(1.0*(10000000+10000000)/($genome_size-$peak_length))"`
enrichment=`python -c "print(1.0*$upper/$lower)"`
mv temp* ./test_new_enrichment
cd ./test_new_enrichment
echo -e "name\trupn\trup\tcoverage\tenrichment" > '0116_sub10M_enrichment_'$name'.result'
echo -e "$name\t$rupn\t$rup\t$peak_length\t$enrichment" >> '0116_sub10M_enrichment_'$name'.result'
cd ../..
done

