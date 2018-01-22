# to new_idr
# get percentage by sample size
mv nohup.out record_ratio.txt
grep "Number of peaks passing IDR cutoff of 0.05" record_ratio.txt  | awk '{print $11}' | sed 's/[^0-9]*//g' | awk '$1=$1/1000' > percent.txt
echo -e "sample_size_million\tpercent_passing_IDR_0.05" > new_idr_output.txt
paste record_seq.txt  percent.txt  | sort -k1,1n >> new_idr_output.txt



# get output
grep "Number of peaks passing IDR cutoff of 0.05" record_ratio.txt  > percent.txt
echo -e "sample_size_million\tpercent_passing_IDR_0.05" > whole_output.txt
paste record_seq.txt  percent.txt  | sort -k1,1n >> whole_output.txt
