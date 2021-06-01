if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("VariantAnnotation")

browseVignettes("VariantAnnotation")
library(VariantAnnotation)
fl <- system.file("extdata", "chr22.vcf.gz", package="VariantAnnotation")
vcf <- readVcf(fl, "hg19")
vcf
sample <- baselineName
which <- "transgened"
realVcf <- readVcf(paste(compareName, "mutations", which, "mutations.vcf",sep="/"), "hg38")
realVcf
