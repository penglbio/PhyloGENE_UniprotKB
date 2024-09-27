library(Biostrings)
library(ggmsa)
library(ggseqlogo)
library(msa)
library(gridExtra)
library(stringr)
library(aplot)
library(dplyr)
library(ggplot2)
library(Cairo)
# 读取fasta文件
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("No filename provided.")
}
fasta_file <- args[1] # 请将文件路径替换为实际的文件路径
basename<-sub(".fasta","",fasta_file)
sequences <- readAAStringSet(fasta_file)

rena<-sub("(.).+ ","\\1.",sub("OS=","",str_extract_all(names(sequences), "OS=(\\S+ \\S+)")))

names(sequences)<-rena


# 使用ClustalW进行多序列比对
alignment <- msa(sequences, method = "ClustalW")

alignment <- as(alignment, "XStringSet")

writeXStringSet(alignment, paste0(basename,"_aligned.fasta"), format = "fasta")

aligned_sequences<- readAAStringSet(paste0(basename,"_aligned.fasta"))
inx<-c("H.sapiens","M.musculus","M.domestica","L.chalumnae","D.rerio","D.melanogaster","C.savignyi","N.vectensis","C.elegans","S.cerevisiae","S.pombe","A.lentulus","L.edodes","R.ochroleuca","B.dendrobatidis","C.confervae","D.discoideum","A.castellanii","P.fungivorum","Z.mays","A.thaliana","S.bicolor","G.max","S.lemnae","M.crassus","T.annulata","C.parvum","H.arabidopsidis","P.infestans","T.vaginalis","T.foetus","G.lamblia","L.major","T.brucei","E.gymnastica")
inx<-inx[inx%in%names(aligned_sequences)]
aligned_sequences<-aligned_sequences[inx]

aa_per_page <- 200

sequence_length <- width(aligned_sequences)[1]

num_pages <- floor(sequence_length %/% aa_per_page)

print(paste("seq_length:",sequence_length,"num_pages:",num_pages))




# 逐页拼接多个图形
aa_per_page=ceiling(sequence_length/(num_pages))

fvalue=ceiling(aa_per_page/4)

width_value=round((fvalue)/60*7,digits=2)
height_value=round(length(rena)/12*7,digits=2)

print(aa_per_page)

print(fvalue)

print(height_value)
print(width_value)
pdf(paste0(basename,".pdf"),width = width_value, height = height_value)
for (i in 1:num_pages) {
    start_pos <- (i - 1) * aa_per_page + 1
    end_pos <- min(i * aa_per_page, sequence_length)
    # 生成ggmsa图像
    p <- ggmsa(aligned_sequences,start = start_pos, end = end_pos,color = "Chemistry_AA", char_width = 0.5,seq_name = TRUE,border = "white",by_conservation=F)+facet_msa(field=fvalue)+theme(axis.text = element_text(size = 5),text= element_text(size = 5,family="sans"),panel.spacing=unit(1,"lines"))+scale_size(range=c(0.2,4))
    # 将图形添加到列表中
    # 调整图形位置，确保最后一页居中显示
    print(p)
}
# 关闭设备，保存PDF文件
dev.off()
