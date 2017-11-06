mkdir saturation_result_collection
cd ./saturation_result_collection
mkdir single_record
cd ./single_record


pipe_path="/home/shaopengliu/pipe_script/ATAC-seq/"
for file in `find ../../ -name "*saturation_report*"`
do
	cp $file .
done


if [[ -z "$1" ]]
	then 
		python3.5 $pipe_path'/ATAC_batch_data_collection/multi_plot_saturation.py' 
	else
		python3.5 $pipe_path'/ATAC_batch_data_collection/cutoff_multi_plot_saturation.py' $1
fi

mv *collection*csv ../
mv *png ../


cd ../..

