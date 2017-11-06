#!/bin/bash
pipe_path="/home/shaopengliu/pipe_script/ATAC-seq/"

date_now=`date +"%m-%d-%y"`
mkdir 'result_summary_'$date_now
find . -name "data_collection*"  -type d | xargs cp -r -t 'result_summary_'$date_now
cd 'result_summary_'$date_now


# 1, enrichment
# 1.1 all peak enrichment
echo -e "name\ttotal_reads\tcoverage\treads_under_peak\tall_peak_enrichment" > merged_all_peak_enrichment.txt
for file in `find . -name "all_peak_enrichment*result"`
do
	sed -n '2p' $file >> merged_all_peak_enrichment.txt
	rm $file
done

# 1.2, coding promoter peak enrichment
echo -e "name\ttotal_reads\tpromoter_number\treads_in_promoter_peak\tenrichment_ratio" > merged_coding_promoter_peak_enrichment.txt
for file in `find . -name "enrichment_ratio_in_promoter*.result"`
do
	sed -n '2p' $file >> merged_coding_promoter_peak_enrichment.txt
	rm  $file
done

# 1.3, top 20k enrichment
find . -name "enrichment*result" | xargs mv -t .
cat enrichment*result | sort | uniq > merged_top20k_enrichment_ratio.txt
rm enrichment*result



# 2, mapping status
find . -name "mapping_status*result" | xargs mv -t .
cat mapping_status*result  | sort | uniq > merged_mapping_status.txt
rm mapping_status*result

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
paste background_*result > merged_background_result.txt
rm background_*result

# 3.2, dichoto count
find . -name "dichoto_bg_*.result" | xargs mv -t .
echo -e "lt_0.188\tlt_0.377\tgt_0.377" |  cat -  dichoto_bg_*.result  > merged_bg_dichoto.result
rm dichoto_bg_*.result

echo -e "file\tlt_0.188\tlt_0.377\tgt_0.377" > merged_bg_dichoto.result
for file in `ls dichoto_bg_*.result`
do
	temp=`echo ${file#dichoto_bg_}`
	name=`echo ${temp%.result}`
	echo $name
	add=`cat $file`
	echo -e "$name\t$add" >> merged_bg_dichoto.result
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
find . -name "idr*ps" | xargs rm

# 5, deduplication percentage
find . -name "dedup_percentage*.result" | xargs mv -t .
cat dedup_percentage*result  | sort | uniq > merged_dedup_percentage.txt
rm dedup_percentage*result

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
python3.5  /home/shaopengliu/pipe_script/ATAC-seq/ATAC_batch_data_collection/collection_v3.py
rm *result


mkdir peak_length_distri
find . -name "peak_length*result" | xargs mv -t ./peak_length_distri

mkdir insertion_size
find . -name "insertion*result" | xargs mv -t ./insertion_size

mkdir self_idr_plot
find . -name "idr_plot*ps" | xargs mv -t self_idr_plot/

cd saturation
mkdir single_record
mv saturation*result  ./single_record
cd ..

rmdir data*
cd ..

date
echo "process finished......."









