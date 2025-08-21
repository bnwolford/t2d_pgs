#long to wide

print(Sys.time())
print(sessionInfo())

library(optparse)
library(data.table)
library(tidyverse)
library(reshape2)

option_list <- list(
  make_option("--file", type="character",default="",
    help="input file"),
      make_option("--out", type="character",default="",
    help="output file"))

parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

df<-fread(opt$file)
#df2<-subset(df, select = -c(DENOM) )

df2<-df %>% pivot_wider(names_from=PGS,id_cols=IID,values_from=c(AVG,SUM))

fwrite(df2,opt$out,quote=FALSE,sep=",",row.names=FALSE,col.names=TRUE)
