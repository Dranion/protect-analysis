RNA=/scratch/drkthomp/results/FULLBAM_NOVAR/alignments/rna_genome_sorted.bam
for i in {1..22}
do
	echo "Starting chromosome ${i}" 
if [ -f rna_chr${i}_R1.fastq ]; then
echo "exists."
else
	samtools view ${RNA} -b chr${i} > rna_chr${i}.bam 
fi
done 
