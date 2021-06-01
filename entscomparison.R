library(readr)
library(tidyverse)
falseNegs <- read_csv("falseNegativesGermline - Sheet3.csv")$novarENST


original <- 'CHR6_NOVAR'
compareWith <- 'CHR6_SUBTRACTED'


originalTransgene <- read.delim( paste(original, "mutations/transgened/mutations.vcf", sep="/"), header=TRUE, skip=8)
compareTransgene <- read.delim( paste(compareWith, "mutations/transgened/mutations.vcf", sep="/"), header=FALSE, comment.char="#")
names(compareTransgene) <- names(originalTransgene)

for(falseNeg in falseNegs){
  if(length(grep(falseNeg, originalTransgene$INFO))>0){
    assign(paste0(falseNeg, "_original"), grep(falseNeg, originalTransgene$INFO, value=TRUE))
  }
  if(length(grep(falseNeg, compareTransgene$INFO))>0){
    assign(paste0(falseNeg, "_compare"), grep(falseNeg, compareTransgene$INFO, value=TRUE))
  }
}


# sapply(originalTransgene, function(x) {grep(paste(falseNegs,collapse="|"), originalTransgene$INFO, value=TRUE)})
# lapply(xlist, function(x) { x$b <- rep(8,10);return(x)})
# 
# originalFalse <- originalTransgene %>% filter(grepl(paste(falseNegs,collapse="|"), INFO))
# compareFalse <- compareTransgene %>% filter(grepl(paste(falseNegs,collapse="|"), INFO))
# get(falseNeg)
# grep(falseNeg, originalTransgene$INFO, value=TRUE)
# 
# filter(originalTransgene, falseNegs == TRUE)
# 
# falseNegs
# sapply(originalTransgene, )f
# df$C <- ifelse(grepl("D", df$A), "yes", "no")
# 
# grep(falseNeg, originalTransgene$INFO, value=TRUE)
