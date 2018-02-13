


# $1 is json file name, $2 is the file location
# used for bed and bigWig
gen_hub () {
	echo "[" > $1
	for bg in `ls *bigWig`
	do
		name=`echo ${bg%.bigWig}`
		echo "processing $name"
	 echo "{" >> $1
	 echo "type:@bigwig@," >> $1
	 echo "url:@"$2""$bg"@," >> $1
	 echo "name:@"$name"@," >> $1
	 echo "mode:@show@," >> $1
	 echo "colorpositive:@#0000E6@," >> $1
	 echo "height:35," >> $1
	 echo "}," >> $1

	 echo "{" >> $1
	  echo "type:@bed@," >> $1
	  echo "url:@"$2""$name"_peaks.narrowPeak.gz@," >> $1
	  echo "name:@peak_"$name"@," >> $1
	  echo "mode:@show@," >> $1
	  echo "colorpositive:@#336666@," >> $1
	  # echo "height:10," >> $1
	  echo "}," >> $1
	done

	 echo "]" >> $1
	 sed -i 's/@/\"/g' $1
}

gen_hub $1 $2