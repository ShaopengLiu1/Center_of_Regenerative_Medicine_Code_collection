#!/bin/bash
file=$1
# to update the processed file from bam (ignore cutadapt and mapping)
# ignore saturation analysis
species='mm10'
types='SE'
threads=24
marker='David'
source ~/pipe_script/ATAC-seq/ATAC_library_processing/code_collection_1113/pipe_code/qc_source.sh $species

awk  '{ if ((length($1) < 6) && (length($1) > 1))  print $0}' OFS='\t' $chrom_size  > refined_chrom_size.txt
chrom_size=`pwd`"/refined_chrom_size.txt"

# start record
date >> pipe_processing.log
echo "Start from Bam file" >> pipe_processing.log
echo "Specified species is $species" >> pipe_processing.log
echo "types of reads is $types" >> pipe_processing.log
echo " " >> pipe_processing.log

name=`echo ${file#Processed_}`
echo "currently processing file $name"
mv $name'_cutadapt_SE.trimlog'  'step1.1_'$name'_cutadapt_SE.trimlog'
if [[ $types == PE ]];
	then
	temp=`grep "Total read pairs processed:" step1.1_*trimlog | awk '{print $5}'`  
	raw_reads=`echo ${temp//,}`  
	temp2=`grep "Pairs that were too short" step1.1_*trimlog | awk '{print $6}'`
	removed_reads=`echo ${temp2//,}`
elif [[ $types == SE ]];
	then
	temp=`grep "Total reads processed:" step1.1_*trimlog | awk '{print $4}'`
	raw_reads=`echo ${temp//,}` 
	temp2=`grep "Reads that were too short" step1.1_*trimlog | awk '{print $6}'`
	removed_reads=`echo ${temp2//,}`
fi
if [ $? == 0 ] 
	then
	echo "step1.1, trimming process sucessful!" >> pipe_processing.log
else 
	echo "step1.1, trimming process fail......" >> pipe_processing.log
	exit 1
fi

if [[ $types == PE ]];
then
per1=`tail -n 2 ./'data_collection_'$name/'dedup_percentage_'$name'.result' | awk '{print $2}' | sed -n '1p'`
per2=`tail -n 2 ./'data_collection_'$name/'dedup_percentage_'$name'.result' | awk '{print $2}' | sed -n '2p'`
dif=`echo "scale=2; ($per1-$per2)*200/($per1+$per2)" | bc -l`
else
dif=0
fi
if [ $? == 0 ] 
	then
	echo "step1.4, calculate replicate difference process sucessful!" >> pipe_processing.log
else 
	echo "step1.4, calculate replicate difference process fail......" >> pipe_processing.log
fi


# clean folder
find . -maxdepth 1 -name "Trimed*" ! -name "*bam" ! -name "step*" | xargs rm -r

for file in `ls *fastq 2> /dev/null`
do
if [[ $file != $R1 ]] && [[ $file != $R2 ]]
then
rm $file 2> /dev/null
fi
done


samtools view -h 'Trimed_'$name'.bam' > input.sam
awk '$5>0' input.sam | sed '/@/d' - | cat <(grep '@' input.sam) - > output.sam
rm input.sam

# only effect reads
methylQA density -S $chrom_size  output.sam
# mapping status
map_mapped=`grep 'mappable reads' output.report | awk '{print $4}'`
map_uniq=`grep '(mapQ >= 10)' output.report | awk '{print $8}'`
map_effect=`grep 'non-redundant'  output.report | awk '{print $6}'`
mapped_ratio=`echo "scale=2; $map_mapped/$raw_reads" | bc -l`
effect_ratio=`echo "scale=2; $map_effect/$raw_reads" | bc -l`
nodup_ratio=`echo "scale=2; $map_effect/$map_uniq" | bc -l`

# get chrM count in uniquely mapped reads
methylQA density -S -r -o temp $chrom_size  output.sam 
unique_chrM=`grep chrM temp.extended.bed | wc -l`
unique_chrM_ratio=`echo "scale=4; $unique_chrM / $map_uniq" | bc -l`
mv temp.extended.bed  'step2.2_Uniquely_mapped_record_'$name'.extended.bed'
rm temp*

# rm chrM and other 
awk '$3!="chrM"' output.sam | samtools view -bS - > 'Trimed_rm_mapq0_chrm_'$name'.bam'
rm output*
rm count*.txt

rm chrom_count*txt
mv 'Trimed_'$name'.bam'  'step2.1_Trimed_'$name'.bam'

# step2.3, preseq
$preseq lc_extrap -o 'yield_'$name'.result' -B  'step2.1_Trimed_'$name'.bam'
if [ $? == 0 ] 
	then
	echo "step2.3, preseq lc_extrap estimate process sucessful!" >> pipe_processing.log
else 
	echo "step2.3, preseq lc_extrap estimate process fail......" >> pipe_processing.log
fi
mv 'yield_'$name'.result'   ./'data_collection_'$name


###################################
# step3,QC and peak calling
# 3.1 QC by methylQA
echo 'methylQA processing......'
methylQA atac $chrom_size  'Trimed_rm_mapq0_chrm_'$name'.bam'

if [ $? == 0 ] 
	then
	echo "step3.1, mathylQA atac process sucessful!" >> pipe_processing.log
else 
	echo "step3.1, mathylQA atac process fail......" >> pipe_processing.log
	exit 1
fi

useful=`grep 'non-redundant'  Trimed_rm_mapq0_chrm_*.report | awk '{print $6}'`
single_end=`wc -l *open.bed | awk '{print $1}'`
uf_ratio=`echo "scale=3; $useful / $raw_reads" | bc -l`
echo -e "file\ttotal\tuseful\tuseful_ratio\tsingle_end" > 'useful_reads_'$name.result
echo -e "$name\t$raw_reads\t$useful\t$uf_ratio\t$single_end" >> 'useful_reads_'$name.result
mv 'useful_reads_'$name.result  ./'data_collection_'$name

mv 'Trimed_rm_mapq0_chrm_'$name'.bam'   'step2.2_Trimed_rm_mapq0_chrm_'$name'.bam'
mv 'Trimed_rm_mapq0_chrm_'$name'.genomeCov.pdf'  'step2.2_Trimed_rm_mapq0_chrm_'$name'.genomeCov.pdf'
awk '$1<=500'  'Trimed_'*$name'.insertdistro'  | sort -n | uniq -c | awk '{print $2,$1}' > 'insertion_distri_'$name'.result'
mv 'insertion_distri_'$name'.result'  ./'data_collection_'$name
rm 'Trimed_rm_mapq0_chrm_'$name'.insertdistro'*
rm *genomeCov  2> /dev/null



# 3.3 peak calling
echo 'peak calling......'
awk '$2 < $3' 'Trimed_rm_mapq0_chrm_'$name'.open.bed' | awk  '{ if ((length($1) < 6) && (length($1) > 1))  print $0}' OFS='\t' > temp.open.bed
intersectBed  -a temp.open.bed  -b $black_list   -v > 'Trimed_rmbl_'$name'.open.bed'
rm temp.open.bed
rm 'Trimed_rm_mapq0_chrm_'$name'.open.bed'
macs2 callpeak -t ./'Trimed_rmbl_'$name'.open.bed' -g $macs2_genome -q 0.01 -n 'peakcall_'$name  --keep-dup 1000 --nomodel --shift 0 --extsize 150

if [ $? == 0 ] 
	then
	echo "step3.3, macs2 peak calling process sucessful!" >> pipe_processing.log
else 
	echo "step3.3, macs2 peak calling process fail......" >> pipe_processing.log
	exit 1
fi

# peak length distribution:
awk '{print $3-$2+1}' 'peakcall_'$name'_peaks.narrowPeak' | sort -n | uniq -c | awk '{print $2,$1}' > 'peak_length_distri_'$name'.result'
mv 'peak_length_distri_'$name'.result'  ./'data_collection_'$name

###################################################################################################
# step4, additional analysis
# 4.1 get reads under peak data
total=`wc -l 'Trimed_rmbl_'$name'.open.bed'|awk '{print $1}'`
sum=`intersectBed -a 'Trimed_rmbl_'$name'.open.bed' -b 'peakcall_'$name'_peaks.narrowPeak' -f 0.5 -u | wc -l`
ratio=`echo "scale=2; $sum*100/$total" | bc -l`
if [ $? == 0 ] 
	then
	echo "step4.1, reads unpder peak ratio calculation process sucessful!" >> pipe_processing.log
else 
	echo "step4.1, reads unpder peak ratio calculation process fail......" >> pipe_processing.log
fi


# 4.2 enrichment ratio 
peak='peakcall_'$name'_peaks.narrowPeak'
bed='Trimed_rmbl_'$name'.open.bed'
# 4.2.1, new enrichment from RUP and 20M normalization
# e= (# of reads under peak / total peak length) / ( 20M*(1-RUP)/(genome_size-total peak length))
peak_length=`awk '{s+=$3-$2+1}END{print s}' $peak`
enrichment=`echo "scale=5; ($sum / $peak_length) / (40000000*(1- $ratio / 100) / ($genome_size - $peak_length))" | bc -l`

if [ $? == 0 ] 
	then
	echo "step4.2.1, new peak enrichment ratio process sucessful!" >> pipe_processing.log
else 
	echo "step4.2.1, new peak enrichment ratio process fail......" >> pipe_processing.log
fi

echo -e "total_reads\trupn\trup\tcoverage\tenrichment" > 'new_enrichment_'$name'.result'
echo -e "$total\t$sum\t$ratio\t$peak_length\t$enrichment"  >> 'new_enrichment_'$name'.result'
mv 'new_enrichment_'$name'.result' ./data_collection_*

# 4.2.2, coding promoter enrichment
# coding enrichment = ( reads in promoter / promoter length)  /  (total reads / genome size)
denominator=`echo "scale=10; $total / $genome_size" | bc -l`
intersectBed -a $peak -b $coding_promoter -u > promoter_peak.bed
reads_in_promoter=`intersectBed -a $bed -b promoter_peak.bed -f 0.5 -u | wc -l | awk '{print $1}'`
promoter_number=`intersectBed -a $coding_promoter -b promoter_peak.bed -F 0.5 -u | wc -l | awk '{print $1}'`
promoter_length=`echo "$promoter_number * 2000" | bc -l`
enrichment_ratio=`echo "scale=3; $reads_in_promoter / $promoter_length / $denominator" | bc -l`
if [ $? == 0 ] 
	then
	echo "step4.2.2, coding promoter enrichment ratio process sucessful!" >> pipe_processing.log
else 
	echo "step4.2.2, coding promoter enrichment ratio process fail......" >> pipe_processing.log
fi
echo -e "name\ttotal_reads\tpromoter_number\treads_in_promoter\tenrichment_ratio" > 'enrichment_ratio_in_promoter_'$name'.result'
echo -e "$name\t$total\t$promoter_number\t$reads_in_promoter\t$enrichment_ratio" >> 'enrichment_ratio_in_promoter_'$name'.result'
mv 'enrichment_ratio_in_promoter_'$name'.result'  'data_collection_'$name
unset peak bed


# 4.3 PBC calculation
PBC=1.0
if [ -z $name ] || [ -z $raw_reads ] || [ -z $map_mapped ] || [ -z $mapped_ratio ] || [ -z $map_uniq ] || [ -z $useful ] || [ -z $map_effect ] || [ -z $effect_ratio ] || [ -z $PBC ] || [ -z $nodup_ratio ] || [ -z $sum ]|| [ -z $ratio ]|| [ -z $dif ]
then
	echo "step4.3, sumarizing result process fail......" >> pipe_processing.log
else
	echo "step4.3, sumarizing result process sucessful!" >> pipe_processing.log
fi

# bg dichoto
cd data_collection_$name
bg_total=`wc -l background*.result | awk '{print $1}'`  
bg_half_thres=`awk '$6<=0.188 {print $0}' background*.result | wc -l`  
bg_less=`awk '$6<=0.377 {print $0}' background*.result | wc -l`  
bg_more=`awk '$6>0.377 {print $0}' background*.result | wc -l` 
ra_half_thres=`echo "scale=2; $bg_half_thres*100 / $bg_total" | bc -l`  
ra_less=`echo "scale=2; $bg_less*100 / $bg_total" | bc -l`  
ra_more=`echo "scale=2; $bg_more*100 / $bg_total" | bc -l`  
echo -e "$ra_half_thres\t$ra_less\t$ra_more" > 'dichoto_bg_'$name'.result'  


# step 4.7, plot on results
# clean result
find . -name "*.result" | xargs sed -i 's/^-e //'
Rscript $pipe_path'/visualization.R' $name $pipe_path'/../atac_ref/mm10_encode_pe'  $species  $removed_reads $unique_chrM_ratio
if [ $? == 0 ] 
	then
	echo "step4.7, plot process sucessful!" >> ../pipe_processing.log
else 
	echo "step4.7, plot process fail......" >> ../pipe_processing.log
fi
sed 's|    "\(.*\[\)|    //\1|' $name'_report.json' | \
sed 's/": \[//g' | sed 's/\],/,/g' | sed '/\]/d' | sed 's/^  }/  \]/g' |\
sed 's/: {/: \[/g' | sed 's/"!/{/g' | sed 's/!"/}/g' | sed 's/@/"/g' > $name'.json'
rm $name'_report.json'
mv $name'.json' ../

mkdir 'plots_collection_'$name
mv *png 'plots_collection_'$name
cp 'dedup_percentage_'$name'.result'   ../'step1.3_dedup_percentage_'$name'.result'
cp 'chrom_count_'$name'.result'  ../'step2.2_chrom_count_'$name'.result'
cp 'insertion_distri_'$name'.result'   ../'step3.1_insertion_distri_'$name'.result'
mv 'plots_collection_'$name  ../
mv *_report.txt ../
cd ..

rm promoter_peak.bed
rm chr.peak
rm -r 'saturation_'$name
rm temp.txt
rm refined_chrom_size.txt
rm pesudo_bl.txt 2> /dev/null

rename 's/Trimed_/step3.1_Trimed_/' Trimed_*
rename 's/peakcall_/step3.3_peakcall_/' peakcall_*

echo "Processing $name done"
echo "Processing $name done"
echo "Processing $name done"
cd ..
date






