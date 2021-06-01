#!/bin/bash
#homeDir= $(pwd)
#rm file.txt
printf "patients:" > file.txt
printf "" > sizes.txt
i=0
for filename in *.vcf
do
    maxvcf=257400
    minvcf=210600
    actualsize=$(wc -c <"${filename}")
    printf "${filename}, ${actualsize}\n" >> sizes.txt
    if (($actualsize >= $minvcf && $actualsize <= $maxvcf)); then
        i=i+1
        printf "\n    ${filename%.vcf}:\n        tumor_rna_bam: /scratch/drkthomp/chr6_only/rna_genome_sorted.bam\n        tumor_rna_bai: /scratch/drkthomp/chr6_only/rna_genome_sorted.bam.bai\n        tumor_rna_transcriptome_bam: /scratch/drkthomp/chr6_only/rna_transcriptome.bam\n        hla_haplotype_files: /scratch/drkthomp/results/CHR6/haplotypes.tar.gz\n        mutation_vcf: $(pwd)/${filename}\n        tumor_type: 'SKCM'" >> file.txt
         ~/bcftools/bcftools stats $filename > ${filename%.vcf}.txt
        echo $filename is between $minvcf and $maxvcf bytes
    else 
        rm $filename
    fi
done
echo $i variants were valid 

