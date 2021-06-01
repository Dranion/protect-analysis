for i in {1..22}
do
if [ -f "rna_chr${i}_R1.fastq" ]; then
echo "${i} exists"
else
picard SamToFastq -I rna_chr${i}.bam -F rna_chr${i}_R1.fastq --SECOND_END_FASTQ rna_chr${i}_R2.fastq
fi
done 
