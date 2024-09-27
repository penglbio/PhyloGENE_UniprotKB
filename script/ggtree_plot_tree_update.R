library("ape")
library(readxl)
library(dplyr)
library(tibble)
library(tidyr)
library(Biostrings)
library(treeio)
library(ggplot2)
library(stringr)
library(aplot)
library(ggtree)
library(rphylopic)
library("ggimage")
library("magick")
library("ggseqlogo")
setwd("~/Desktop/")
tree<- read.tree("INTS3/EAHb.ML.tre")
##map taxid to gene name
INTs<- read.table("INTS3/species_name.tsv",stringsAsFactors = F,sep = "\t")
INTs <- as.data.frame(INTs)
rownames(INTs) <- INTs$V1
rename<- INTs
rename[rename$V4=="Fungi",]$V3="Fungi"
rename<- rename%>%mutate(V5=paste0(rename$V2,"(",rename$V3,")"))
rename<- rename%>%mutate(V6=paste0(rename$V2,"(",rename$V4,")"))
dim(rename)



tree1 <- tree
# tree1$tip.label <- rename[match(tree1$tip.label,rename$V1),]$V2
# p1 <- ggtree(tree1,branch.length = "none")+ xlim(NA,20)+theme_tree2(legend.position = c(.1, .88))+geom_tiplab(offset = 0.2, align = F)+
#   geom_nodelab(aes(label = node), size = 3,hjust = 2,nudge_y = 0.2)
# ASV_levels <- ggtree::get_taxa_name(p1)


# tree1 <- tree
tree1$tip.label <- rename[match(tree1$tip.label,rename$V1),]$V2
##设置根节点
tree2 <- ape::root(tree1,node=63)







# 初始化一个空的数据框来存储结果
results <- data.frame()

# 假设tree1是你的树对象
for (i in tree1$tip.label) {
  tryCatch({
    # 尝试获取Phylopic的UUID
    uid <- phylopic_uid(i)
    # 如果成功，将结果添加到数据框中
    results <- rbind(results, data.frame(species = i, uid = uid))
  }, error = function(e) {
    # 检查错误消息是否表明图像资源不可用
    if (grepl("Image resource of Phylopic database is not available", e$message)) {
      print(paste("Skipping", i))
      # 跳过当前物种，不添加到数据框中
    } else {
      # 如果是其他错误，中断循环
      stop(e)
    }
  })
}
# a <- get_phylopic(results$uid.uid[1], format = "vector",height = 64)




clade <- c(Opisthokonta= 46, Fungi = 54 , Viridiplantae = 41, Amoebozoa = 62, Sar =68, Metamonada = 66, Discoba = 64)
tree2 <- groupClade(tree2, clade)
cols <- c(Opisthokonta = "#a8ddb5", Fungi = "#377eb8", Viridiplantae = "#4daf4a", Amoebozoa = "#984ea3",Sar = "#ff7f00",
          Metamonada = "#b21826", Discoba = "#2166ac")




p1 <- ggtree(tree2,aes(color = group),branch.length = "none")+ xlim(NA,17)+ 
  geom_cladelabel(46, "italic(Opisthokonta)", color = cols[["Opisthokonta"]], offset = 4, align = TRUE,offset.text = -10, barsize = 180,extend = c(0.5, 0.5), parse = TRUE,alpha=0.5)+
  geom_tiplab(offset = 0.1, align = T) +geom_treescale(x = 0, y = 1, width = 0.002) +   
  geom_cladelabel(54, "italic(Fungi)", color = cols[["Fungi"]], offset = 4, align = TRUE,offset.text = -10, barsize = 180, extend = c(0.5, 0.5), parse = TRUE,alpha=0.5)+
  geom_tiplab(offset = 0.1, align = T) +geom_treescale(x = 0, y = 1, width = 0.002)+
  geom_cladelabel(41, "italic(Viridiplantae)", color = cols[["Viridiplantae"]], offset = 4, align = TRUE,offset.text = -10, barsize = 180, extend = c(0.5, 0.5), parse = TRUE,alpha=0.5)+
  geom_tiplab(offset = 0.1, align = T) +geom_treescale(x = 0, y = 1, width = 0.002)+ 
  geom_cladelabel(62, "italic(Amoebozoa)", color = cols[["Amoebozoa"]], offset = 4, align = TRUE,offset.text = -10, barsize = 180, extend = c(0.5, 0.5), parse = TRUE,alpha=0.5)+
  geom_tiplab(offset = 0.1, align = T) +geom_treescale(x = 0, y = 1, width = 0.002)+ 
  geom_cladelabel(68, "italic(Sar)", color = cols[["Sar"]], offset = 4, align = TRUE,offset.text = -10, barsize = 180, extend = c(0.5, 0.5), parse = TRUE,alpha=0.5)+
  geom_tiplab(offset = 0.1, align = T) +geom_treescale(x = 0, y = 1, width = 0.002)+
  geom_cladelabel(66, "italic(Metamonada)", color = cols[["Metamonada"]], offset =4, align = TRUE,offset.text = -10, barsize = 180, extend = c(0.5, 0.5), parse = TRUE,alpha=0.5)+
  geom_tiplab(offset = 0.1, align = T) +geom_treescale(x = 0, y = 1, width = 0.002)+ 
  geom_cladelabel(64, "italic(Discoba)", color = cols[["Discoba"]], offset = 4, align = TRUE,offset.text = -10, barsize = 180, extend = c(0.5, 0.5), parse = TRUE,alpha=0.5)+
  geom_tiplab(offset = 0.1, align = T) +geom_treescale(x = 0, y = 1, width = 0.002)+ 
  scale_color_manual(values = c(cols, "black"), na.value = "black", name = "Lineage",breaks = c("Opisthokonta", "Fungi", "Viridiplantae", "Amoebozoa", "Sar", "Metamonada", "Metamonada"))+
  theme_tree2(legend.position = c(.1, .88))+geom_tiplab(offset = 0.1, align = T)+
  geom_tree2()+theme(axis.text.x =element_blank(),axis.line.x = element_blank(),axis.ticks.x = element_blank())

p1

##奇数行的物种画出来
UUID<-results[match(ASV_levels,results$uid.name),]

rownames(UUID) <- ASV_levels

UUID[seq(1,nrow(UUID),by=2),] <- ""
UUID[is.na(UUID$uid.uid),]<-""

p2 <- p1%<+%UUID+geom_tiplab(aes(image=uid.uid), geom="phylopic", offset=4,size=0.04)


###画偶数行的物种
UUID1<-results[match(ASV_levels,results$uid.name),]

rownames(UUID1) <- ASV_levels

UUID1[seq(2,nrow(UUID1),by=2),] <- ""
UUID1[is.na(UUID1$uid.uid),]<-""

colnames(UUID1) <- c("species","name","uid")

p3 <- p2%<+%UUID1+geom_tiplab(aes(image=uid), geom="phylopic", offset=6,size=0.04)


rename[match(ASV_levels,rename$V2),]

INTSs<- read_excel("INTS3/Select_result.xlsx",sheet= 'figure_table', col_names = TRUE)
INTS <- as.data.frame(INTSs)
INTS <- sort_by(INTS,~lineage)
rownames(INTS) <- INTS[,1]
L3<- unlist(lapply(strsplit(INTS[,3],";"),function(x){x[3]}))
head(L3)
L4<- unlist(lapply(strsplit(INTS[,3],";"),function(x){x[4]}))
table(L4=="Fungi")
L3[L4=="Fungi"]="Fungi"
table(L3)
INTS <- INTS %>% mutate(class = factor(L3,levels=rev(c("Discoba","Metamonada","Sar","Viridiplantae","Amoebozoa","Fungi","Opisthokonta"))), .after = "gene_nums")
unique(INTS$class)
INTS<- sort_by(INTS,~class)

INTS1 <- INTS[,-c(1:4)]
INTS1<- ifelse(INTS1=="NA",0,1)
colnames(INTS1) <- stringr::str_replace(colnames(INTS)[-(1:4)],"\\(.+","")

INTS2 <- INTS[,5:19]

replace_function <- function(x) {
  ifelse(grepl("N-terminal", x) | grepl("C-terminal", x), 
         ifelse(grepl("N-terminal", x), "N", "C"),"")
}
df <- as.data.frame(sapply(INTS2, replace_function))

rownames(df) <- INTS[,1]

colnames(df) <- stringr::str_replace(colnames(INTS2),"\\(.+","")

heatmap1<- INTS1[,c("INTS1","INTS2","INTS7","INTS12","INTS3","INTS6","INTS4","INTS9","INTS11","INTS5","INTS8","INTS10","INTS13","INTS14","INTS15")]

heatmap2<- INTS1[,c("SPT4","SPT5","PAF1","CDK7","CDK8","CDK9","CCNT1","CCNT2","NELFA","NELFB","NELFCD","NELFE","PPP2CA","PPP2CB","MEPCE","HEXI1","HEXI2","LARP7")]




rename$V1%in%rownames(heatmap1)
heatmap1 <- as.data.frame(heatmap1)
heatmap1$ASV <- rename[rownames(heatmap1),]$V2
rownames(heatmap1) <- rename[rownames(heatmap1),]$V2
##
heatmap2 <- as.data.frame(heatmap2)
heatmap2$ASV <-  rename[rownames(heatmap2),]$V2
rownames(heatmap2) <- rename[rownames(heatmap2),]$V2


RPB_df<- INTS1[,"RPB1",drop=F]
RPB_df <- as.data.frame(RPB_df)
RPB_df$ASV <-  rename[rownames(RPB_df),]$V2
rownames(RPB_df) <- rename[rownames(RPB_df),]$V2
# heatmap1

heatmap_plot1 <- heatmap1%>%
  tidyr::pivot_longer(cols = contains("INTS"),
                      names_to = "Type",
                      values_to = "Value") %>%
  dplyr::mutate(ASV = factor(ASV, levels = rev(ASV_levels), ordered = T)) %>%
  dplyr::mutate(Type = factor(Type, levels = colnames(heatmap1), ordered = T)) %>%dplyr::mutate(Value = case_when(
    Value > 0 ~ "1",
    Value <= 0 ~ "0")) %>%
  ggplot() + 
  geom_tile(aes(x = Type, y = ASV, fill = Value), color = "#b2182b", height = 0.85, width = 0.85) + 
  scale_fill_manual(values = c("1" = "#f46d43",
                               "0" = "#ffffff")) + 
  scale_x_discrete(position = "top")  + 
  labs(x = "", y = "") + 
  theme(axis.text.x.top = element_text(angle = 90, size = 8,vjust = 1),
        axis.line.x.top = element_blank(),
        axis.ticks.x.top = element_blank(),
        axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(), 
        axis.line.y = element_blank(),  
        panel.background = element_rect(fill = "#ffffff")
        )

heatmap_plot1


heatmap_plot2 <- heatmap2%>%
  tidyr::pivot_longer(cols = colnames(heatmap2)[-length(colnames(heatmap2))],
                      names_to = "Type",
                      values_to = "Value") %>%
  dplyr::mutate(ASV = factor(ASV, levels =  rev(ASV_levels), ordered = T)) %>%
  dplyr::mutate(Type = factor(Type, levels = colnames(heatmap2), ordered = T)) %>%dplyr::mutate(Value = case_when(
    Value > 0 ~ "1",
    Value <= 0 ~ "0")) %>%
  ggplot() + 
  geom_tile(aes(x = Type, y = ASV, fill = Value), color = "#4393c3", height = 0.85, width = 0.85) + 
  scale_fill_manual(values = c("1" = "#4393c3",
                               "0" = "#ffffff")) + 
  scale_x_discrete(position = "top")  +
  labs(x = "", y = "") +
  theme(axis.text.x.top = element_text(angle = 90, size = 8,vjust = 1),
        axis.line.x.top = element_blank(),
        axis.ticks.x.top = element_blank(),
        axis.text.y = element_blank(),
        # axis.text.y = element_text( hjust = 3),
        axis.ticks.y = element_blank(),
        axis.line.y = element_blank(),
        panel.background = element_rect(fill = "#ffffff")
        )

heatmap_plot2

# barplot

CTD1<- read.table("INTS3/select_RBP1_CTD_check.tsv",sep="\t",stringsAsFactors = F)
CTD1$ASV <- factor(rename[as.character(CTD1$V1),]$V2,levels =  rev(ASV_levels), ordered = T)

CTD2<- read.table("INTS3/select_RBP1_CTD_check_SPxSP.tsv",sep="\t",stringsAsFactors = F)
CTD2$ASV <- factor(rename[as.character(CTD2$V1),]$V2,levels =  rev(ASV_levels), ordered = T)
CTD<-merge(CTD1,CTD2,by="ASV",all=T)
CTD$V3.x[is.na(CTD$V3.x)]<-0
CTD$V3.y <- CTD$V3.y-CTD$V3.x

CTD_merge<- CTD[,c("ASV","V3.x","V3.y")]
colnames(CTD_merge) <-c("ASV","YSTPSPS","xSPxSPx") 


RPB_heatmap <- RPB_df %>%
  dplyr::mutate(ASV = factor(ASV, levels =  rev(ASV_levels), ordered = T)) %>%dplyr::mutate(RPB1 = case_when(
    RPB1 > 0 ~ "1",
    RPB1 <= 0 ~ "0"))%>%ggplot() + 
  geom_tile(aes(x = RPB1, y = ASV,fill=RPB1), color = "#4393c3", height = 0.85, width = 0.85)  + 
  scale_fill_manual(values = c("1" = "#4393c3",
                               "0" = "#ffffff")) +
  scale_x_discrete(position = "top")  + 
  labs(x = "", y = "") + 
  theme(axis.text.x.top = element_text(angle =0, size = 3,vjust = 1),
        axis.line.x.top = element_blank(),
        axis.ticks.x.top = element_blank(),
        axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(), 
        axis.line.y = element_blank(),  
        panel.background = element_rect(fill = "#ffffff")
  )

RPB_heatmap


bar_plot <- CTD_merge%>%pivot_longer(cols = contains("SP"),names_to ="Type",values_to = "Value")%>%
  ggplot() + 
  geom_bar(aes(x = ASV, y = Value,fill=Type), stat = "identity") + 
  scale_fill_manual(values = c("#4daf4a","darkgreen"))+
  coord_flip() + 
  theme_tree()+
  theme(strip.text = element_text(size = 15),axis.text.y = element_blank(),plot.title = element_text(hjust = 0.5, face = "bold", size = 10, vjust = -3))

ggseqlogo( seqs_dna$MA0001.1,col_scheme=cs1 )

##
library(ggseqlogo)

cs1 = make_col_scheme(chars=c('Y', 'S', 'P', 'T','A','F','K','N'), 
                      cols=c('#984ea3', 'darkgreen', '#ff7f00', '#4daf4a','#b21826','#f46d43','#a8ddb5','#377eb8'))

data_source = read.table('INTS3/xSPxSPx_motif.tsv')
data_source = as.vector(data_source$V1)

seqlogo_plot<- ggseqlogo(data_source,V1,method='bits',seq_type="aa",col_scheme=cs1) +
  theme_logo() +
  theme(legend.position = 'none') +
  theme(plot.title=element_text(hjust=0.5, size=15, face="bold")) +
  ggtitle('sequence')
ggsave("INTS3/seqlog.png",seqlogo_plot)

bar_plot+geom_image(aes("INTS3/seqlog.png"),x=1,y=2)



heatmap_plot3 <- RPB_heatmap %>%
  insert_right(., bar_plot, width = 4) %>% 
  insert_right(., heatmap_plot1, width = 15) %>% 
  insert_right(., heatmap_plot2, width = 15) %>% 
  insert_left(., p1, width = 70)

ggsave("INTS3/plot3.pdf", heatmap_plot3, width = 18, height = 12, units = "in")


ggtree(tree2) %<+% renames1+geom_tiplab(aes(image=uid,colour=body_mass), geom="phylopic", offset=0.2)
