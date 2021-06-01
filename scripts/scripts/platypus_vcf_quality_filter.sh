for i in {1..22}
do
	echo "Starting chromosome ${i}" 
        name="variants_chr${i}_subtracted.vcf"
	bcftools filter --include 'QUAL>100' ${name} > "100qual_${name}"	
done 
