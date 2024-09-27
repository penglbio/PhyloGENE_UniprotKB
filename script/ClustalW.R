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
aa_per_row <- 100
rows_per_page <- 3 
sequence_length <- width(aligned_sequences)[1]

num_rows <- ceiling(sequence_length / aa_per_row)

num_pages <- ceiling(num_rows / rows_per_page)
print(paste("seq_length:",sequence_length,"num_rows:", num_rows,"num_pages:",num_pages))

pdf(paste0(basename,"_aligned.pdf"),width = 12, height = 7)
# 逐页拼接多个图形
for (i in 1:num_pages) {
  plots <- list()  # 存储每页的多个图
  for (j in 1:rows_per_page) {
    row_num <- (i - 1) * rows_per_page + j
    if (row_num > num_rows) break  # 超过总行数时退出循环
    
    start_pos <- (row_num - 1) * aa_per_row + 1
    end_pos <- min(row_num * aa_per_row, sequence_length)
    
    # 生成ggmsa图像
    p <- ggmsa(aligned_sequences,font="TimesNewRoman",start = start_pos, end = end_pos,color = "Chemistry_AA", char_width = 0.8,seq_name = TRUE,border = "white",by_conservation=F,none_bg=T)+geom_seqlogo()+theme(axis.text = element_text(size = 5),text= element_text(size = 5))+scale_size(range=c(0.2,4))
    # 将图形添加到列表中
    plots[[j]] <- p
  }
    print(length(plots))
    # 调整图形位置，确保最后一页居中显示
if (length(plots) > 0) {
  if (length(plots) == 1) {
    # 如果最后一页只有一个图，占据页面中央1/3
    grid.arrange(plots[[1]], heights = unit(c(1, 1, 1), "null"))
  } else if (length(plots) == 2) {
    # 如果最后一页有两个图，占据页面的上半部分和中间
    grid.arrange(plots[[1]], plots[[2]], heights = unit(c(1, 1, 1), "null"))
  } else {
    # 否则正常排列3个图
    do.call("grid.arrange", c(plots, ncol = 1)) # ncol=1表示垂直排列
  }
}
}
# 关闭设备，保存PDF文件
dev.off()
