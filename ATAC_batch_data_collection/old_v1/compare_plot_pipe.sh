# for addtional analysis of comparison plot of single-pipe processing

# 0 parameter: compare current wd results with default
# 1 parameter: merge current results to default (keep the old version in backup folder)
# 2 parameter: compare 

# Currently there is no action for saturation, IDR, and length distribution 


if [ $# -eq 0 ]
then
rename 's/merged_/merged_single_/' *.csv
cp /home/shaopengliu/resources/ATAC_reference/merged_all/*.csv  .

elif [ $# -eq 1 ]
then
date_now=`date +"%m-%d-%y"`
mkdir '/home/shaopengliu/resources/ATAC_reference/merged_all/backup_'$date_now
mv  /home/shaopengliu/resources/ATAC_reference/merged_all/*    '/home/shaopengliu/resources/ATAC_reference/merged_all/backup_'$date_now
rename 's/merged_/merged_single_/' *.csv
mv *  /home/shaopengliu/resources/ATAC_reference/merged_all/
cd /home/shaopengliu/resources/ATAC_reference/merged_all/
exit 1

elif [ $# -eq 2 ]
then
mkdir compare_result_plot
cd compare_result_plot
cp $1"/*.csv"  .
rename 's/merged_/merged_single_/' *.csv
cp $2"/*.csv"  .

else
echo "this pipe can only compare 2 results, or 1 with the default reference..."
echo "for more results, please use merge pipe to reduce the number"
fi


cat merged*_chrM_ratio.csv  | sort | uniq > temp1.txt
head -n -1 temp1.txt > plot_chrM.txt
cat merged*_dedup_percentage.csv   | sort | uniq > plot_dedup.txt
cat merged*_mapping_status.csv  | sort | uniq > plot_mapping.txt

python3.5  /home/shaopengliu/pipe_script/ATAC-seq/ATAC_library_processing/ref_compare_plot.py  

rm *.csv
rm *txt
