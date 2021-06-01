
chromosomes=(11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y")
#chromosomes=(8 9 10)
for chr in "${chromosomes[@]}"
do 
    ~/bcftools/bcftools view -Oz -o gnomad.chr${chr}.vcf.gz gnomad.subtracted.chr${chr}.vcf.bgz
    ~/bcftools/bcftools index gnomad.chr${chr}.vcf.gz

done 
