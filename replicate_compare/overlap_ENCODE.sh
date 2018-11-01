## compare replicate file regarding peaks and RPKM
## to use: put 2 narrowPeak and 2 corresponding bed files in the folder
## usage: ./pipe.sh  peak1 peak2 bed1 bed2

pipe_path="/home/shaopengliu/pipe_script/ATAC-seq/"
small=$1
big=$2
echo $small
echo $big

inter1=`echo ${small#peakcall_}`
name1=`echo ${inter1%_peaks.narrowPeak}`
bed1=$3

inter2=`echo ${big#peakcall_}`
name2=`echo ${inter2%_peaks.narrowPeak}`
bed2=$4



# find the shared peak
intersectBed -a $small -b $big -f 0.1 -F 0.1 -wa -wb > shared_peak.txt

# merge the 1_multi projection peaks
python $pipe_path'compare_replicate/merge_dup_peaks.py' shared_peak.txt nodup_shared_peak.txt

# merge overlap range
python $pipe_path'compare_replicate/merge_peak_range.py' nodup_shared_peak.txt count.txt

# count the reads under peak
# file1
python $pipe_path'compare_replicate/cheng_compare/try_compare.py' $name1/ $bed1 count.txt
mv reads.txt $name1'.txt'
# file2
python $pipe_path'compare_replicate/cheng_compare/try_compare.py' $name2/ $bed2 count.txt
mv reads.txt $name2'.txt'

rm -r $name1/
rm -r $name2/


### additional part: include the non-overlap region and plot
intersectBed -a $small -b count.txt -f 0.1 -F 0.1 -v > 'non_overlap_'$name1'.narrowPeak'
intersectBed -a $big -b count.txt -f 0.1 -F 0.1 -v > 'non_overlap_'$name2'.narrowPeak'

# count
python $pipe_path'compare_replicate/cheng_compare/try_compare.py'  'non_overlap_'$name1/   $bed1  'non_overlap_'$name1'.narrowPeak'
mv reads.txt  non_overlap_peak_small_rpkm_small.txt

python $pipe_path'compare_replicate/cheng_compare/try_compare.py'  'non_overlap_'$name2/   $bed2 'non_overlap_'$name2'.narrowPeak'
mv reads.txt  non_overlap_peak_big_rpkm_big.txt

intersectBed -a $bed2 -b 'non_overlap_'$name1'.narrowPeak' -u -f 0.5  > temp
size=`wc -l $bed2 | awk '{print $1}'`
python /home/chengl/python/3_source_beta/rpkm_bin.py 'non_overlap_'$name1'.narrowPeak'  temp $size
mv reads.txt non_overlap_peak_small_rpkm_big.txt

intersectBed -a $bed1 -b 'non_overlap_'$name2'.narrowPeak' -u -f 0.5 > temp
size=`wc -l $bed1 | awk '{print $1}'`
python /home/chengl/python/3_source_beta/rpkm_bin.py  'non_overlap_'$name2'.narrowPeak'  temp $size
mv reads.txt non_overlap_peak_big_rpkm_small.txt


for file in `ls *txt`	
do
	awk '{print $1, $2, $3, $4, $5, $6}' OFS="\t" $file > temp.txt
	sort -k1,1V -k2,2n temp.txt > $file
done



# plot
python3.5  $pipe_path'compare_replicate/plot_overlap.py'   $name1'.txt'    $name2'.txt'   non_overlap_peak_small_rpkm_small.txt	non_overlap_peak_small_rpkm_big.txt	non_overlap_peak_big_rpkm_small.txt	non_overlap_peak_big_rpkm_big.txt		

 



