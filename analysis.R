if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
#BiocManager::install(version = "3.12")
#BiocManager::install("Biostrings")
install.packages("tidyverse")                            
library("dplyr")  
library("Biostrings")
library("rjson")
library("readr")

base1 <- "variants_higherQual_chr6"
base2 <- "variants_noDups_higherQual_chr6"

checkOne=function(base1,base2,subtype,type){
  getFunc <- get(paste0("get",type))
  v1 <- getFunc(base1, subtype)
  v2 <- getFunc(base2, subtype)
  check(v1,v2,subtype,type)
}
#checkOne(base1, base2, "mhci", "Binding")


comparisons <- c("Binding", "Expression", "Haplotype", 'Rank')

check=function(v1,v2,what, name){
  if(identical(v1, v2)){
    print(paste(what, name, "for", base1, "and",base2,"are identical."))
    return(TRUE)
  }
  else {
    print(paste("WARNING:",what, name, "for", base1, "and",base2,"are NOT identical. Mismatches: "))
    return(FALSE)
  }
}

# get binding predictions 
getBinding=function(base, fileType) {
  binding <- read.delim(paste(base, "binding_predictions", paste0(fileType, "_merged_files.list"), sep="/"), header=FALSE)
  names(binding) <- c("allele", "pept", "normal_pept", "pname", "core", "zero", "tumor_pred","normal_pred", "ENSG", "gene", "ENST")
  return(arrange_all(binding))
}

checkBinding=function(base1,base2){
  return(checkOne(base1,base2,"mhci", "Binding")&
  checkOne(base1,base2,"mhcii", "Binding")
  )
}

checkBinding(base1, base2)

# get expression
getExpression=function(base,fileType){
  return(arrange_all(read.delim(paste(base, "expression", paste("rsem", fileType, "results", sep="."), sep="/"))))
}
checkOneExpression=function(base1, base2, what){
  v1 <- getExpression(base1, what)
  v2 <- getExpression(base2, what)
  check(v1,v2,what,"expressions")
}

checkExpression=function(base1, base){
  return(checkOne(base1,base2,"genes", "Expression")&
  checkOne(base1,base2,"isoforms", "Expression"))
}

checkExpression(base1, base2)

# get haplotyping 
getHaplotype=function(base,fileType){
  return(arrange_all(read.table(paste(base, "haplotyping", paste0(fileType, "_alleles.list"), sep="/"), quote="\"", comment.char="")))
}
checkOneHaplotype=function(base1, base2, what){
  v1 <- getHaplotype(base1, what)
  v2 <- getHaplotype(base2, what)
  check(v1,v2,what,"haplotype alleles")
}
checkHaplotype=function(base1, base2){
  return(checkOneHaplotype(base1, base2, "mhci")&
  checkOneHaplotype(base1, base2, "mhcii"))
}

checkHaplotype(base1,base2)
# get peptides 
getPeptide=function(base,tumor,number){
  file <- paste(base, "peptides", paste("transgened",tumor, number, "mer_peptides.faa", sep="_"), sep="/")
  table <- read_csv(toString(gsub(">", "\n",  readLines(file))),col_names=FALSE)[1:2]
  return(arrange_all(table))
}
checkPep=function(base1, base2, tumor, number){
  v1 <- getPeptide(base1, tumor, number)
  v2 <- getPeptide(base2, tumor,number)
  check(v1,v2,paste(tumor, number),"transgened peptides")
}
checkPeptides=function(base1, base2){
  return(checkPep(base1, base2, "normal", "9")&
  checkPep(base1, base2, "normal", "10")&
  checkPep(base1, base2, "normal", "15")&
  checkPep(base1, base2, "tumor", "9")&
  checkPep(base1, base2, "tumor", "10")&
  checkPep(base1, base2, "tumor", "15"))
}

# peptide map
getPeptideMap=function(base,tumor,number){
  file <- paste(base1, "peptides", paste("transgened",tumor, number, "mer_peptides.faa", sep="_"), sep="/")
}
#checkPeptides(base1, base2)

# get rankboost
getRank=function(base,fileType, detail, fileEnd){
  return(arrange_all(read.delim(paste(base, "rankboost", paste(fileType, "rankboost", detail, paste0("results.",fileEnd),sep="_"), sep="/"))))
}
checkRank=function(base1, base2, what, detail, fileEnd){
  v1 <- getRank(base1, what, detail, fileEnd)
  v2 <- getRank(base2, what,detail, fileEnd)
  check(v1,v2,what,paste(detail, "rankboost results"))
}

checkRank(base1, base2, "mhci", "concise", "tsv")
checkRank(base1, base2, "mhcii", "concise", "tsv")
checkRank(base1, base2, "mhci", "detailed", "txt")
checkRank(base1, base2, "mhcii", "detailed", "txt")

### uwuu
library(ggplot2)
base1 <- getBinding(base1, "mhci")
base2 <- getBinding(base2, "mhci")
compare <- bind_rows(base1, base2, .id = "id")
compare_diff <- compare %>% filter(tumor_pred)

ggplot(compare, aes(x=allele, y=tumor_pred, color=id)) + 
  geom_boxplot()
