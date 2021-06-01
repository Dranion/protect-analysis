
chromosomes=(7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y")
for chr in "${chromosomes[@]}"
do 
    wget https://gnomad-public-us-east-1.s3.amazonaws.com/release/3.1/vcf/genomes/gnomad.genomes.v3.1.sites.chr${chr}.vcf.bgz
    ~/bcftools/bcftools annotate -x ID,INFO gnomad.genomes.v3.1.sites.chr${chr}.vcf.bgz > gnomad.subtracted.chr${chr}.vcf.bgz
done 
