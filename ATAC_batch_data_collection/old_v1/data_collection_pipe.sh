# to collection all the result within a folder
# for ATAC seq
# run this script in current target folder
# if want to use saturation collection to plot under certain reads number cutoff, e.g 10Million, use parameter 1 as "10"

pipe_path="/home/shaopengliu/pipe_script/ATAC-seq/"

# step1, collect all mapping status
echo "collecting mapping status......"
date

for file in `find . -name "*.report"`;
do
	var1=`echo ${file##./Processed_}`
	var2=`echo ${var1%/*}`
	name=`echo ${var2%_*}`
	python3.5 $pipe_path'/ATAC_batch_data_collection/mapping_store.py' $file $name
done

mkdir mapping_status_result
for result in `find . -mmin -120 -name "*.csv" | grep "report"`;
do
	mv $result ./mapping_status_result/.
done

echo "step1 over......"



# step2, collect all chrom_count
echo "collecting chrom count......"
date

for file in `find . -name  "*Chromsome*txt"`;
do
	var1=`echo ${file##./Processed_}`
	var2=`echo ${var1%/*}`
	name=`echo ${var2%_*}`
	python3.5 $pipe_path'/ATAC_batch_data_collection/chrom_count_store.py' $file $name
done

mkdir chrom_count_result
for result in `find . -mmin -120 -name "*.csv" | grep "Chromsome"`;
do
	mv $result ./chrom_count_result/.
done

echo "step2 over......"



# step3, collect qc summary;
echo "collecting qc summary......"
date

for file in `find . -name "summary.txt"`;
do
	python3.5 $pipe_path'/ATAC_batch_data_collection/summary_store.py' $file
done

mkdir qc_summary_result
for result in `find . -mmin -120 -name "*.csv" | grep "summary"`;
do
	mv $result ./qc_summary_result/.
done

echo "step3 over......"




# step 4, collect duplication level
echo "collecting duplication_level......"
date

for file in `find . -name "fastqc_data.txt"`;
do
	python3.5 $pipe_path'/ATAC_batch_data_collection/duplication_store.py' $file
done

mkdir duplication_level_result
echo "file numbers:"
find . -mmin 120 -name "*.csv" | grep "duplication" | wc -l


for result in   `find . -mmin -30 -name "*.csv" | grep "duplication"`;
do
	mv $result ./duplication_level_result/.
done

echo "step4 over"
date


# step 5, merge all the data in 4 folders
cd ./mapping_status_result
python3.5 $pipe_path'/ATAC_batch_data_collection/mapping_merge.py'
cd ..

cd ./chrom_count_result
python3.5 $pipe_path'/ATAC_batch_data_collection/chrom_count_merge.py'
cd ..

cd ./qc_summary_result
python3.5 $pipe_path'/ATAC_batch_data_collection/summary_merge.py'
cd ..

cd ./duplication_level_result
python3.5 $pipe_path'/ATAC_batch_data_collection/duplication_merge.py'
cd ..


# step 6, merge all saturation reports
$pipe_path'ATAC_batch_data_collection/saturation_merge.sh'

# step 7, collect IDR and PBC, and reads under peak
mkdir PBC_results
mkdir IDR_collection_results
mkdir reads_under_peak_results

for file in `find . -name "PBC*txt"`
do
	cp $file  ./PBC_results
done

for file in `find . -name "*self_IDR"`
do
	cp -r $file ./IDR_collection_results
done

for file in `find . -name "*reads_under_peak.txt"`
do
	cp $file  ./reads_under_peak_results
done


cd ./PBC_results
cat * > merged_PBC_results.txt
cd ..

cd ./reads_under_peak
python3.5 $pipe_path'/ATAC_batch_data_collection/merge_rup.py'


# step 8, collect everything together
sss=`date +"%m-%d-%y"`
mkdir batch_outcome_collection_$sss
mv *result*  ./batch_outcome_collection_$sss
mv merged*.csv ./batch_outcome_collection_$sss
