#long to wide 

library(data.table)
library(tidyverse)
library(reshape2)

df<-fread("/mnt/scratch/brooke/t2d/results/hunt/score/aggregated_scores.txt.gz")
df2<-subset(df, select = -c(DENOM) ) 

df3<-df2 %>% pivot_wider(names_from=PGS,IID,values_from=c(AVG,SUM))

fwrite(df3,"/mnt/scratch/brooke/t2d/T2D_Smith_2024_scores.csv",quote=FALSE,sep=",",row.names=FALSE,col.names=TRUE)
