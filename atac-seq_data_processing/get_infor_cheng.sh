#!/bin/bash
# summarize 5 QA from data (temp)
mkdir update

echo "pipe start"
date
awk '!/random/ && !/Un/' /home/Resource/Genome/mm10/mm10.chrom.sizes > chrom_size.txt

for file in `ls -d Processed*`
do
        # get chrM ratio, as $ratio
        cd $file
        name=`echo ${file#Processed_}`
        echo "processing file is $name"
        bam=`ls step2.1*bam`
        echo "the bam file is $bam"
        methylQA density -r -o temp ../chrom_size.txt $bam
        unique_chrM=`grep chrM temp.extended.bed | wc -l`
        mv temp.extended.bed  'step2.2_Uniquely_mapped_record_'$name'.extended.bed'
        map_uniq=`grep '(mapQ >= 10)' temp*report | awk '{print $8}'`
        rm temp*
        echo -e "name\ttotal_unique\tunique_chrM\tratio" > 'unique_chrM_'$name'.result'
        ratio=`python -c "print($unique_chrM*1.0 / $map_uniq)"`
        echo -e "$name\t$map_uniq\t$unique_chrM\t$ratio" >> 'unique_chrM_'$name'.result'

        # get nodup ratio as $nodup: effect / uniquely mapped
        cd data_collection_$name
        nodup=`cut -f 10 'mapping_status_'$name'.result'  | sed -n '2p'`

        # get rup ratio as $rup
        rup=`cut -f 12 'mapping_status_'$name'.result'  | sed -n '2p'`

        # get normalized enrich as $nor_en
        nor_en=`cut -f 5 'new_enrichment_'$name'.result' | sed -n '2p'`

        # get background as $ng: RPKM < 0.377
        bg=`cut -f 2 'dichoto_bg_'$name'.result' `
        cd ..

        # merge together:
        echo -e "file_name\tchrM_ratio_uniq\tPCR_nodup\tRUP_percentage\tnormalized_enrichmen\tbg_0.377" > 'ameng_'$name'.txt'
        echo -e "$name\t$ratio\t$nodup\t$rup\t$nor_en\t$bg" >> 'ameng_'$name'.txt'

        cd ..
        echo "processing $name done"
        date
        mv $file ./update
done
rm chrom_size.txt

echo "whole pipe done"
date
