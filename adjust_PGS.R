
library(tidyverse)
library(purrr)
library(broom)

setwd("~/scratch/brooke/t2d")

####### original scores
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

################################################ Smith et al partitioned scores

smith_eur<-read_csv("T2D_Smith_2024_EUR_scores.csv")
smith_multi<-read_csv("T2D_Smith_2024_scores.csv")

#purr doesn't seem to like the hyphens, so replace with underscores
smith_eur <- smith_eur %>% rename_with(~ gsub("-", "_", .x))
smith_multi<- smith_multi %>% rename_with(~ gsub("-", "_", .x))

smith_eur_scores<-names(smith_eur)[grepl("AVG",names(smith_eur))]
smith_multi_scores<-names(smith_multi)[grepl("AVG",names(smith_multi))]

#merge with PCs (keep europea PCs because we are only estimating in European individuals)
smith_eur<-smith_eur %>% left_join(pc_eur,by=c("IID"="PID"))
smith_multi<-smith_multi %>% left_join(pc_eur,by=c("IID"="PID"))

### european
eur_res <- map_df(smith_eur_scores, function(y) {
  model <- lm(as.formula(paste(y, "~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6  + PC7 + PC8 + PC9 + PC10 + BatchDetailed")), data = smith_eur)
  augment(model) |> 
    select(.resid) |> 
    mutate(outcome = paste0(y,"_EUR_adj"), PID=smith_eur$IID)
}) |> 
  pivot_wider(names_from = c(outcome), values_from = .resid)

write_csv(eur_res,file="T2D_Smith_2024_EUR_resid_wide.csv",col_names=TRUE)

### multi ancestry

m_res <- map_df(smith_multi_scores, function(y) {
  model <- lm(as.formula(paste(y, "~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6  + PC7 + PC8 + PC9 + PC10 + BatchDetailed")), data = smith_multi)
  augment(model) |> 
    select(.resid) |> 
    mutate(outcome = paste0(y,"_MULTIANC_adj"), PID=smith_multi$IID)
}) |> 
  pivot_wider(names_from = c(outcome), values_from = .resid)

write_csv(m_res,file="T2D_Smith_2024_multiancestry_resid_wide.csv",col_names=TRUE)
