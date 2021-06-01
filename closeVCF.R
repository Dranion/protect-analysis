library(VariantAnnotation)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library("org.Hs.eg.db") # remember to install it if you don't have it already
library(tidyverse)
library(eulerr)
library(gridExtra)
library(dplyr)


txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
baselineName <- "CHR6_NOVAR"
compareName <- "CHR6_SUBTRACTED"

###### EVALUATING BINDING PREDICTIONS ######

bindingMHCI <- bind_rows("base" = mhciBindingList[[paste0("binding", "mhci", ".", baselineName)]],"comp" = mhciBindingList[[paste0("binding", "mhci", ".", compareName)]] , .id = "src")


bindingMHCII <- bind_rows("base" = mhciiBindingList[[paste0("binding", "mhcii", ".", baselineName)]],"comp" = mhciiBindingList[[paste0("binding", "mhcii", ".", compareName)]] , .id = "src")

binding <- bind_rows("mhci" = bindingMHCI, "mhcii" = bindingMHCII, .id="mhc")
binding <- separate_rows(binding,ENST, sep=",")

enstSearch <- read_csv("enstSearch-2021-02-19.csv")

for(i in 1:nrow(binding)){
  binding[i,"Status"] <- enstSearch[enstSearch$ENST == binding[i,]$ENST, 'ENST Status']
}
binding <- binding %>% separate(ENST, c("ENST", "ENST.detail"), sep="_")

binding %>%  summarize(uniqueGenes = n_distinct(gene),uniqueENST= n_distinct(ENST))
binding %>%  group_by(src,Status) %>%  summarize(uniqueGenes = n_distinct(gene),uniqueENST= n_distinct(ENST))


## For the pie chart 
bindingMHCII %>% group_by(id, gene) %>% summarize(uniqueENST= n_distinct(ENST))

somatics <- filter(binding, Status=="Somatic") %>% group_by(src) 
somatic <- list(baseline = filter(somatics, src=="base"), compare = filter(somatics, src=="comp"))
fullList <- somatic
comparison <- "ENST"

uniqueSomatic <- somatic
for( i in seq_along(uniqueSomatic)){
  uniqueSomatic[i] <- unique(uniqueSomatic[[i]][comparison])
}
test <- euler(uniqueSomatic, shape = "ellipse")
grid.arrange(grobs = list(
  plot(euler(uniqueSomatic, shape = "ellipse"), quantities = TRUE, legend = TRUE )),
  top = paste("Somatics Only", comparison, "Comparison"))



#THESE ARE THE ONES WE'RE WORRIED ABOUT AND NEED TO EXAMINE IN THE VCF:
#missingSomaticENST <- filter(somatic$baseline, ENST %in% setdiff(uniqueSomatic$baseline, uniqueSomatic$compare))
#though we need to remove the extra 
#missingSomaticENST <- separate(missingSomaticENST,ENST, c("ENST", "ENST.detail"), sep="_")

###### VCF GETTING ######
getVCF = function(sample, which){
  mutations <- read.delim(paste(sample, "mutations", which, "mutations.vcf",sep="/"), header=FALSE, comment.char="#")
  names(mutations) <- c("CHROM",	"POS",	"ID",	"REF",	"ALT",	"QUAL",	"FILTER",	"INFO")
  return(mutations)
}
which <- "transgened"
baseline <- getVCF(baselineName, which)
compare <- getVCF(compareName, which)



baselineVCFInterest <- baseline[FALSE,]
for(variant in 1:nrow(baseline)) {
  for(testENST in unique(binding$ENST)){
    if(grepl(testENST, baseline[variant,"INFO"])){
      baseline[variant,"ENST"] <- testENST
      # is mhci or mhcii 
      baseline[variant,"isMHCI"] <- testENST %in% filter(binding, mhc == "mhci")$ENST
      baseline[variant,"isMHCII"] <- testENST %in% filter(binding, mhc == "mhcii")$ENST
      baseline[variant,"isBase"] <- testENST %in% filter(binding, src == "base")$ENST
      baseline[variant,"isComp"] <- testENST %in% filter(binding, src == "comp")$ENST
      baseline[variant,"status"] <- enstSearch[enstSearch$ENST == testENST, 'ENST Status']
      baselineVCFInterest <- rbind(baselineVCFInterest, baseline[variant,])
    }
  }
}

compareVCFInterest <- compare[FALSE,]
for(variant in 1:nrow(compare)) {
  for(testENST in unique(binding$ENST)){
    if(grepl(testENST, compare[variant,"INFO"])){
      compare[variant,"ENST"] <- testENST
      # is mhci or mhcii 
      compare[variant,"isMHCI"] <- testENST %in% filter(binding, mhc == "mhci")$ENST
      compare[variant,"isMHCII"] <- testENST %in% filter(binding, mhc == "mhcii")$ENST
      compare[variant,"isBase"] <- testENST %in% filter(binding, src == "base")$ENST
      compare[variant,"isComp"] <- testENST %in% filter(binding, src == "comp")$ENST
      compareVCFInterest <- rbind(compareVCFInterest, compare[variant,])
    }
  }
}


# 'low hanging fruit' -> transcripts in the compare transgene, that are in baseline bp but NOT the compare bp




# 
# rd <- rowRanges(baseline)
# baseMHC <- mhciBindingList[[paste0("binding", "mhci", ".", baselineName)]]$gene
# compMHC <- mhciBindingList[[paste0("binding", "mhci", ".", compareName)]]$gene
# geneDiff <- setdiff(baseMHC, compMHC) #appears in BASE but not in COMP 
# 
# baseLoc <- locateVariants(rowRanges(baseline), txdb, AllVariants())
# compLoc <- locateVariants(rowRanges(compare), txdb, AllVariants())
# 
# #baseInBase <- filter(baseMHC, )
# #baseInComp
# #compInBase
# #compInComp <<- 
# 
# 
# grabVCFGenes = function(loc, diff, txdb) {
#   ## Summarize the number of coding variants by gene ID.
#   splt <- split(mcols(loc)$QUERYID, mcols(loc)$GENEID)
#   numVariants <- sapply(splt, function(x) length(unique(x)))
#   numVariants
#   byGene <- as.data.frame(numVariants)
#   
#   byGene$ENTREZID <- rownames(byGene)
#   byGene$ALIAS <- mapIds(org.Hs.eg.db, keys = byGene$ENTREZID, keytype = "ENTREZID", column="ALIAS")
#   
#   return(filter(byGene, ENTREZID %in% diff)) 
# }
# 
# baselineGene <- grabVCFGenes(baseLoc, entrezDiff, txdb) 
# compareGene <- grabVCFGenes(compLoc, entrezDiff, txdb) 
# head(baselineGene)
# head(compareGene)
# baselineGene %>% summarise(num=n(), mean=mean(numVariants))
# compareGene %>% summarise(num=n(), mean=mean(numVariants))
# 
# 
# #library(biomaRt)
# 
# #ensembl <- useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl")
# #filters = listFilters(ensembl)

