#!/bin/bash
for i in {1..22}
do
if [ -f "variants_chr${i}_subtracted.vcf" ]; then
echo "${i} already subtracted"
else
bedtools subtract -header -a variants_opossum_rna_chr${i}.vcf -b /scratch/drkthomp/protect-index/gnomad/gnomad.chr${i}.vcf.gz > variants_chr${i}_subtracted.vcf
fi
done 
