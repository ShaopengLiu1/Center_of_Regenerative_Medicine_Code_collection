


# $1 is json file name, $2 is the file location
# used for bed and bigWig
gen_hub () {
	echo "[" > $1
	for bg in `ls *bigWig`
	do
	 echo "{" >> $1
	 echo "type:@bigwig@," >> $1
	 echo "url:@"$2"/"$bg"@," >> $1
	 echo "name:@"$bg"," >> $1
	 echo "mode:@show@," >> $1
	 echo "colorpositive:@#0000E6@," >> $1
	 echo "height:35," >> $1
	 echo "}," >> $1
	done

	for peak in `ls *Peak.gz`
	do
	 echo "{" >> $1
	  echo "type:@bed@," >> $1
	  echo "url:@"$2"/"peak"@," >> $1
	  echo "name:@"$name"_peak@," >> $1
	  echo "mode:@show@," >> $1
	  echo "colorpositive:@#336666@," >> $1
	  # echo "height:10," >> $1
	  echo "}," >> $1
	done

	 echo "]" >> $1
	 sed -i 's/@/\"/g' $1
}