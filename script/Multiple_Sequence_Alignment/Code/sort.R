#!/bin/R
args = commandArgs(trailingOnly=TRUE)

library(dplyr)

data <- read.table(args[1], sep="\t", header=FALSE) # fasta file
ordered_id <- read.table(args[2], header=FALSE) # protein ID file

split_string <- function(x){
	res <- strsplit(x, split="\\|")
	return(res)
}

a <- lapply(data[,1],split_string)

sequence_id <- c()
for(i in 1:length(a)){
	sequence_id[i] <- a[[i]][[1]][2]
}

data_changed_id <- cbind(sequence_id, data[,2])
data_changed_id <- as.data.frame(data_changed_id)
colnames(data_changed_id) <- c("sequence_id","seq")
# sort sequence order based on ids
#sort by player with custom order
data_changed_id <- arrange(data_changed_id,factor(sequence_id, levels = ordered_id[,1]))
# add header to the alignment file
seq_number <- dim(data_changed_id)[1]
max_length <- nchar(data_changed_id[1,2])
colnames(data_changed_id) <- c(seq_number, max_length)
write.table(data_changed_id,file=args[3],sep=" ",quote=FALSE,row.names=FALSE)
