SRC=hcc1395
DOWNLOAD_LIST=("gerald_D1VCPACXX_6" "gerald_D1VCPACXX_1" "gerald_C1TD1ACXX_8_ACAGTG")
for BAM in "${DOWNLOAD_LIST[@]}"
do 
    if [ -f "${BAM}.bam" ]; then
          echo "$BAM exists."
        else
          wget https://xfer.genome.wustl.edu/gxfer1/project/gms/testdata/bams/${SRC}/${BAM}.bam
    fi
    java -Xmx2g -jar picard.jar CleanSam -I ${BAM}.bam -O ${BAM}.cleaned.bam
    java -Xmx2g -jar picard.jar SamToFastq -INPUT ${BAM}.cleaned.bam -FASTQ ${BAM}_R1.fastq -SECOND_END_FASTQ ${BAM}_R2.fastq
done

#DNA_TUMOR=gerald_D1VCPACXX_1
#if [ -f "${DNA_TUMOR}.bam" ]; then
#      echo "$DNA_TUMOR exists."
#    else
#      wget https://xfer.genome.wustl.edu/gxfer1/project/gms/testdata/bams/${SRC}/${DNA_TUMOR}.bam
#fi

#RNA=gerald_C1TD1ACXX_8_ACAGTG
#if [ -f "${RNA}.bam" ]; then
#      echo "$RNA exists." 
#    else 
#      wget https://xfer.genome.wustl.edu/gxfer1/project/gms/testdata/bams/${SRC}/${RNA}.bam
#fi 


