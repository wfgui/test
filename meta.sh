```shell
output_dir=Run_results
mkdir -p $output_dir/cleanData
mkdir -p $output_dir/humann3
cat samples.list | while read id
do 
        arr=($id)
        sample=${arr[0]}
        fq1=${arr[1]}
        fq2=${arr[2]}
        
        ##QC
        mkdir -p $output_dir/cleanData/$sample
        trim_galore $fq1 $fq2 --paired \
                -o $output_dir/cleanData/$sample --length 60 
    
        fastp -i $output_dir/cleanData/$sample/*_val_1.fq.gz \
                        -I $output_dir/cleanData/$sample/*_val_2.fq.gz \
                        -o $output_dir/cleanData/$sample/${sample}_clean_R1.fq.gz \
                        -O $output_dir/cleanData/$sample/${sample}_clean_R2.fq.gz \
                        -q 20 -u 20 -n 10 \
                        -h $output_dir/cleanData/$sample/${sample}.html \
                        -j $output_dir/cleanData/$sample/${sample}.json \
                        -l 60
                        
        bowtie2 -1 $output_dir/cleanData/$sample/${sample}_clean_R1.fq.gz \
                        -2 $output_dir/cleanData/$sample/${sample}_clean_R2.fq.gz \
                        -x database/hg38/index-bt2/hg38  \
                        --un-conc-gz $output_dir/cleanData/$sample/${sample}_clean.bt.gz \
                        -I 150 -X 500
        ##humann
        cat $output_dir/cleanData/$sample/${sample}_clean.bt* > $sample.fq.gz
        humann --input $sample.fq.gz \
                --output $output_dir/humann3/$sample  \
                --nucleotide-database database/humann3/chocophlan \
                --protein-database database/humann3/uniref90_v201901
        rm $sample.fq.gz
done
```