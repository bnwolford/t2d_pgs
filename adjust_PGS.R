
library(tidyverse)
library(purrr)
library(broom)

setwd("~/scratch/brooke/t2d")

df<-read_csv("t2d_pgs_wide.csv")

pc_eur<-read_tsv("/mnt/work/genotypes/HUNT/h234/samples/Masterkey_DATASET_PID105118_20221024.txt.gz")

pc_multi<-read_file("/mnt/work/genotypes/HUNT/h234_multiancestry/samples/all/Masterkey_DATASET_PID105118_20230220.txt.gz")

#merge european master key and PGS 
df2<-df %>% left_join(pc_eur,by=c("IID"="PID"))

#scores 
score_vec<-names(df2)[grepl("AVG",names(df2))]

results <- map_df(score_vec, function(y) {
  model <- lm(as.formula(paste(y, "~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6  + PC7 + PC8 + PC9 + PC10 + BatchDetailed")), data = df2)
  augment(model) |> 
    select(.resid) |> 
    mutate(outcome = paste0(y,"_adj"), PID=df2$IID)
}) |> 
    pivot_wider(names_from = c(outcome), values_from = .resid)

results 

write_csv(results,file="t2d_pgs_resid_wide.csv",col_names=TRUE)
