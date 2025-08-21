library(data.table)
library(tidyverse)

path<-"~/scratch/brooke/t2d/bnmf-clustering/Smith_Deutsch_NatureMedicine_2024/MultiAncestry/hg38_score_info/"
files<-list.files(path)
files2<-unlist(strsplit(files,".csv"))
files2<-gsub(" ","_",files2)

for (f in 1:length(files)){
  df<-fread(paste0(path,files[f]))
  header<-paste0("#pgs_name=",files2[f],"\n#pgs_id=",files2[f],"\n#trait_reported=",files2[f],"_T2D\n#genome_build=GRCh38")
  new_file<-paste0("~/scratch/brooke/t2d/",files2[f],"_formatted.tsv")
  writeLines(header,new_file)
  df2<-df %>% mutate(effect_weight=Weight) %>% mutate(chr_position=Pos) %>% 
    mutate(other_allele=case_when(Effect_Allele==Ref~Alt,Effect_Allele==Alt~Ref)) %>%
    mutate(chr_name=Chr) %>% mutate(effect_allele=Effect_Allele) %>%
    select(chr_name,chr_position,effect_allele, other_allele, effect_weight) %>% 
    arrange(chr_name,chr_position,effect_allele,other_allele,effect_weight)
    fwrite(df2,new_file,col.names=TRUE,sep="\t",append=TRUE)
}


## now run pgs calc 
#./nextflow run pgscatalog/pgscalc -profile conda --input samplesheet.csv --scorefile "*_formatted.csv" --target_build GRCh38 --min-overlap 0


###Update 
#format results
res<-fread("zcat /home/bwolford/scratch/brooke/breast_cancer/results/hunt/score/aggregated_scores.txt.gz")
sum<-res %>% filter(PGS=="sum")
com<-res %>% filter(PGS=="combined")
mean<-res %>% filter(PGS=="mean")

left_join(sum,mean,by="IID") %>% mutate("PRS_sum_z_score"=AVG.x) %>% mutate("PRS_mean_z_score"=AVG.y) %>%
  left_join(com) %>% mutate("PRS_combined_z_score"=AVG) %>% 
  select(IID,PRS_sum_z_score,PRS_mean_z_score,PRS_combined_z_score) %>% 
  fwrite("output.csv",sep=",",quote=FALSE,row.names=FALSE,col.names=TRUE)

############ August 2025 Run on European files #######

path<-"/home/bwolford/scratch/brooke/t2d/bnmf-clustering/Smith_Deutsch_NatureMedicine_2024/EUR/hg38_score_info/"
files<-list.files(path)
files2<-unlist(strsplit(files,".csv"))
files2<-gsub(" ","_",files2)

for (f in 1:length(files)){
  df<-fread(paste0(path,files[f]))
  header<-paste0("#pgs_name=",files2[f],"\n#pgs_id=",files2[f],"\n#trait_reported=",files2[f],"_T2D\n#genome_build=GRCh38")
  new_file<-paste0("~/scratch/brooke/t2d/",files2[f],"_EUR_formatted.tsv")
  writeLines(header,new_file)
  df2<-df %>% mutate(effect_weight=Weight) %>% mutate(chr_position=Pos) %>% 
    mutate(other_allele=case_when(Effect_Allele==Ref~Alt,Effect_Allele==Alt~Ref)) %>%
    mutate(chr_name=Chr) %>% mutate(effect_allele=Effect_Allele) %>%
    select(chr_name,chr_position,effect_allele, other_allele, effect_weight) %>% 
    arrange(chr_name,chr_position,effect_allele,other_allele,effect_weight)
    fwrite(df2,new_file,col.names=TRUE,sep="\t",append=TRUE)
}

