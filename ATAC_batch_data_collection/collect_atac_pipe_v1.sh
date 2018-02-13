#!/bin/bash
date_now=`date +"%m-%d-%y"`
mkdir 'result_summary_'$date_now
find . -name "data_collection*"  -type d | xargs cp -r -t 'result_summary_'$date_now
cd 'result_summary_'$date_now


# 1, enrichment
# 1.1 all peak enrichment
echo -e "name\trup_reads\trup\tcoverage\tsub10M_peak_enrichment" > merged_sub10M_enrichment.txt
for file in `find . -name "sub10M_enrichment*result"`
do
	sed -n '2p' $file >> merged_sub10M_enrichment.txt
	rm $file
done

# 1.2, coding promoter peak enrichment
echo -e "name\ttotal_reads\tpromoter_number\treads_in_promoter_peak\tenrichment_ratio" > merged_coding_promoter_peak_enrichment.txt
for file in `find . -name "enrichment_ratio_in_promoter*.result"`
do
	sed -n '2p' $file >> merged_coding_promoter_peak_enrichment.txt
	rm  $file
done


# 2, mapping status
find . -name "mapping_status*result" | xargs mv -t .
sed -n '1p'  `ls mapping_status*result | head -1` > merged_mapping_status.txt
for file in `ls mapping_status*result`
do
sed -n '2p' $file >> merged_mapping_status.txt
rm $file
done

# 2.2, unique_chrM
find . -name "unique_chrM_ratio*result" | xargs mv -t .
echo -e "name\tunique_mapped_reads\tunique_chrM\tratio" > merged_unique_chrM_ratio.txt
for file in `ls unique_chrM_ratio*result`
do
	temp=`echo ${file##unique_chrM_ratio_}`
	name=`echo ${temp%%.result}`
	echo -e "$name\t`sed -n '2p' $file`" >> merged_unique_chrM_ratio.txt
	rm $file
done

# 2.3, useful reads
find . -name "useful_reads*result" | xargs mv -t .
sed -n '1p'  `ls useful_reads*result | head -1` > merged_useful_reads.txt
for file in `ls useful_reads*result`
do
sed -n '2p' $file >> merged_useful_reads.txt
rm $file
done




# 3, background
# 3.1, random bg
find . -name "background_*.result" | xargs mv -t .
for file in `ls background_*.result`
do
temp=`echo ${file##background_}`
name=`echo ${temp%%.result}`
awk '{print $6}' $file > temp.txt
echo "$name" | cat - temp.txt  > $file
done
paste background_*result > merged_background.txt
rm background_*result

# 3.2, dichoto count
find . -name "dichoto_bg_*.result" | xargs mv -t .
echo -e "file\tlt_0.188\tlt_0.377\tgt_0.377" > merged_bg_dichoto.txt
for file in `ls dichoto_bg_*.result`
do
	temp=`echo ${file#dichoto_bg_}`
	name=`echo ${temp%.result}`
	echo $name
	add=`cat $file`
	echo -e "$name\t$add" >> merged_bg_dichoto.txt
	rm $file
done


# 4, promoter status
# 4.1, promoter percentage
find . -name "promoter_percentage_*.result" | xargs mv -t  .
for file in `ls promoter_percentage_*.result`
do
temp=`echo ${file##promoter_percentage_}`
name=`echo ${temp%%.result}`
awk -v name=$name '{if(NR==1) print "file",$0; if(NR==2) print name,$0}' OFS='\t' $file > temp.txt
mv temp.txt $file
done
cat promoter_percentage_*.result  | sort | uniq > merged_promoter_percentage.txt
rm promoter_percentage_*.result

# 4.2 100bin count
find . -name "bin_*.result" | xargs mv -t  .
for file in `ls bin_*.result`
do
temp=`echo ${file##bin_}`
name=`echo ${temp%%.result}`
echo -e "bin_seq\t$name" > temp.txt
sed -i 's/^-e //' temp.txt
cat temp.txt $file  > temp2.txt
mv temp2.txt $file
done
paste bin_*result  > temp.txt
awk '{line=$1;for(i=2;i<=NF;i+=2) line=line"\t"$i; print line}' temp.txt >  merged_bin_result.txt
rm bin_*.result
rm temp.txt

# 5, deduplication percentage
find . -name "dedup_percentage*.result" | xargs mv -t .
sed -n '1p'  `ls dedup_percentage*.result | head -1` > merged_dedup_percentage.txt
for file in `ls dedup_percentage*.result`
do
sed -n '2p' $file >> merged_dedup_percentage.txt
rm $file
done

# 6, by python:
# 6.1, chrom count
find . -name "chrom_count*result" | xargs mv -t .
#6.2, dedup summary
find . -name "duplication_summary*result" | xargs mv -t .
#6.3, fastqc
find . -name "fastqc_summary*result" | xargs mv -t .
#6.4, saturation
mkdir saturation
find . -name "saturation*result" | xargs mv -t saturation/
python3.5  /home/shaopengliu/pipe_script/ATAC-seq/ATAC_batch_data_collection/collection_atac_pipe_v1.py
rm *result
cp ./saturation/merged_saturation_collection.txt  .


mkdir peak_length_distri
find . -name "peak_length*result" | xargs mv -t ./peak_length_distri

mkdir insertion_size
find . -name "insertion*result" | xargs mv -t ./insertion_size

cd saturation
mkdir single_record
mv saturation*result  ./single_record
cd ..

mkdir preseq_estimate
find . -name "yield_*result" | xargs mv -t  ./preseq_estimate

rmdir data_collection*
cd ..

date
echo "process finished......."









