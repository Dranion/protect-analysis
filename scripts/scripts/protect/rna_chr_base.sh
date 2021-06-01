echo "patients:"
for i in {1..22}
do
echo "    CHR${i}_VARIANTS_100QUAL:"
echo "        tumor_rna_fastq_1: /scratch/drkthomp/fullbams/rna_chr${i}_R1.fastq"
echo "        tumor_rna_fastq_2: /scratch/drkthomp/fullbams/rna_chr${i}_R2.fastq"  
echo "        mutation_vcf: /scratch/drkthomp/fullbams/100qual_variants_chr${i}_subtracted.vcf"
echo "        hla_haplotype_files: /scratch/drkthomp/results/FULLBAM_NOVAR/haplotypes.tar.gz"
echo "        tumor_type: 'SKCM'"

done
