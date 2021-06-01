# variant size analysis 
library(tidyverse)
library(readr)
library(stringr)
library(scales)

variant_sizes <- read_csv("variant-sizes.txt", col_names = FALSE)
names(variant_sizes) <- c("id", "size")
vars <- c("mmq", "minFlank", "mgqb", "mbq", "mr", "d")
varNames <- c("minMapQual", "minFlank", "minGoodQualBases", "minBaseQual", "minReads", "filterDuplicates")
modComplete <- variant_sizes %>%
  separate(id, into = c("junk1", "value", "junk2"), sep="_", convert=TRUE) %>%
  mutate(x = str_remove_all(value, "[variants_mmqmfmgqbd]")) %>%
  separate(x, into = vars, sep = "-", convert = TRUE) %>% select(-c("junk1", "junk2")) %>%  mutate_at(vars(d), ~replace_na(., 1))

stats <- modComplete %>% summarise(
  numGenerated = n(),
  minSize = min(size),
  maxSize = max(size), 
  meanSize = mean(size),
  minMapQual = cor(size, mmq),
  minFlank = cor(size, minFlank), 
  minGoodQualBases = cor(size, mgqb),
  minBaseQual = cor(size, mbq),
  minReads = cor(size, mr), 
  filterDuplicates = cor(size,d)
)
#ggplot(modComplete,aes(x=d, y=size)) + geom_boxplot() + scale_x_discrete(labels=c("0" = "Duplicates Included", "1" = "Duplicates Filtered"))  +geom_hine(yintercept=3400000) +  geom_hline(yintercept=genvcf,color="darkgreen") + geom_hline(linetype="dotted",color="darkgreen", yintercept=maxvcf)  + geom_hline(linetype="dotted",color="darkgreen", yintercept=minvcf) 

toKb <- function(x){
  x/1000
}


genvcf <- 234000
maxvcf <- genvcf * 1.3
minvcf <- genvcf * 1.1
mod <- filter(modComplete, size<maxvcf, size>minvcf, d==0)
mod %>% summarise(
  min = min(size),
  max = max(size), 
  mean = mean(size),
  mmq = cor(size, mmq),
  minFlank = cor(size, minFlank), 
  mgqb = cor(size, mgqb),
  mbq = cor(size, mbq),
  mr = cor(size, mr)
)
print(paste0(count(mod), " (",round(count(mod)/count(modComplete)*100), "%) of variants are within the size range"))
ggplot(modComplete, aes(x=reorder(value,size), y=size, color=size)) + annotate("rect", xmin=-Inf, xmax=Inf, ymin=minvcf, ymax=maxvcf, alpha=0.2, fill="darkgreen") + geom_jitter(alpha=0.9) +
  geom_hline(yintercept=genvcf,color="darkgreen") + geom_hline(linetype="dotted",color="darkgreen", yintercept=maxvcf)  + geom_hline(linetype="dotted",color="darkgreen", yintercept=minvcf) +
  theme_bw() + theme(legend.position = "none",
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_y_continuous(labels = label_bytes())
ggplot(mod, aes(x=reorder(value,size), y=size, color=size)) + annotate("rect", xmin=-Inf, xmax=Inf, ymin=minvcf, ymax=maxvcf, alpha=0.2, fill="darkgreen")+ geom_jitter(alpha=0.9) +
  geom_hline(yintercept=genvcf,color="darkgreen") + geom_hline(linetype="dotted",color="darkgreen", yintercept=maxvcf)  + geom_hline(linetype="dotted",color="darkgreen", yintercept=minvcf) +
  theme_bw() + theme(legend.position = "none",
                     axis.text.x=element_blank(),
                     axis.ticks.x=element_blank()) +
  scale_y_continuous(labels = label_bytes())

ggplot(modComplete, aes(x=mbq,y=size,color=mmq)) + annotate("rect", xmin=-Inf, xmax=Inf, ymin=minvcf, ymax=maxvcf, alpha=0.2, fill="darkgreen")  + geom_jitter(alpha=0.9) + geom_hline(yintercept=genvcf,color="darkgreen")   + geom_hline(linetype="dotted",color="darkgreen", yintercept=maxvcf)  + geom_hline(linetype="dotted",color="darkgreen", yintercept=minvcf) + scale_y_continuous(labels = label_bytes())
ggplot(modComplete, aes(x=mmq,y=size,color=mr)) + geom_jitter(alpha=0.9) + geom_hline(yintercept=genvcf,color="darkgreen") + geom_hline(linetype="dotted",color="darkgreen", yintercept=maxvcf)  + geom_hline(linetype="dotted",color="darkgreen", yintercept=minvcf) + scale_y_continuous(labels = label_bytes())

ggplot(modComplete, aes(x=mr,y=size,color=mgqb)) + geom_jitter(alpha=0.9) + geom_hline(yintercept=genvcf,color="darkgreen") + geom_hline(linetype="dotted",color="darkgreen", yintercept=genvcf*1.5)  + geom_hline(linetype="dotted",color="darkgreen", yintercept=genvcf*.5) + scale_y_continuous(labels = label_bytes())
# unlikely to want mr <20 
ggplot(modComplete, aes(x=mgqb,y=size,color=mr)) + geom_jitter(alpha=0.9) + geom_hline(yintercept=genvcf,color="darkgreen") + geom_hline(linetype="dotted",color="darkgreen", yintercept=genvcf*1.5)  + geom_hline(linetype="dotted",color="darkgreen", yintercept=genvcf*.5) + scale_y_continuous(labels = label_bytes())


combos <- expand.grid(vars, vars, stringsAsFactors=FALSE)
forplot <- mutate_at(mod, vars, factor)
for(i in 1:nrow(combos)) {       # for-loop over rows
  ggplot(forplot, aes_string(x=combos[i,1], y="size",color=combos[i,2])) + geom_boxplot() + geom_jitter(alpha=0.5) + geom_hline(yintercept=genvcf)
  ggsave(paste0(paste(combos[i,1],combos[i,2]),".png"))
}
p.mod <- cor_pmat(mod)
head(p.mat[, 1:4])


ggplot(mod, aes(minFlank, mbq)) +                           
  geom_tile(aes(fill = size))
           
if (!require(devtools)) install.packages("devtools")

bind_cols(unique(notSharedNOVAR['gene']),unique(notSharedVAR['gene']),unique(notSharedNOVAR['gene']))

devtools::install_github("gaospecial/ggVennDiagram")

library("ggVennDiagram")
grid.newpage() 
draw.pairwise.venn(
  area1 = 20,
  area2 = 48,
  cross.area = 7,
  category = c("Regular", "Platypus"),
  fill = c("#e06666ff", "#6fa8dcff"),
)


#mr > 30 
