#r script to plot for enza
rm(list=ls())

base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/UNRELATED/"
base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/UNRELATED/FIVE_POPS"

##########################################################################################################################
# PLOT 8: DAF spectrum for different functional annotations

rm(list=ls())
base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/UNRELATED/"
#outbred
o_pops <- c("TSI","CEU")
#isolates
i_pops <- c("FVG","VBI")
all_pops <- c(i_pops,o_pops)

chr <- "22"
source('/nfs/users/nfs_m/mc14/Work/r_scripts/maf_bins_splitter.r')
# maf_classes <- c(0,0.01,0.02,0.05,0.10,0.20,0.30,0.4,0.5,0.6,0.7,0.8,0.9,1)
maf_classes <- c(0,0.05,0.10,0.20,0.30,0.4,0.5,0.6,0.7,0.8,0.9,1)
conseq_classes <- paste(base_folder,"INPUT_FILES/consequences.list",sep="")
conseq <- read.table(conseq_classes,header=F)
conseq$V1 <- as.character(conseq$V1)
# conseq <- c("missense_variant","synonymous_variant")
# cons <- conseq$V1[1]
# pop <- "FVG"

# for (cons in conseq) {
all_pop_maf_classes <- NULL
all_pop_maf_classes_fract <- NULL

for (pop in all_pops){
  pop_all_maf_classes <- NULL
  pop_all_maf_classes_fract <- NULL
  pop_maf_name <- paste(pop,"_all_cons_resume",sep="")
  pop_maf_name_fract <- paste(pop,"_all_cons_resume_fract",sep="")

  for (cons in conseq$V1) {
    # file_path <- paste(base_folder,"INPUT_FILES/CHR",chr,"_no_fixed_MAC2/",pop,"/",sep="")
    file_path <- paste(base_folder,"INPUT_FILES/CHR",chr,"_private_no_fixed/",pop,"/",sep="")
    # file_path <- paste(base_folder,"INPUT_FILES/CHR",chr,"_no_fixed/",pop,"/",sep="")
    # file_path <- paste(base_folder,"INPUT_FILES/CHR",chr,"_fixed/",pop,"/",sep="")
    # file_name <- paste(pop,".",cons,".",chr,".tab.gz",sep="")
    file_name <- paste(pop,".private.",cons,".",chr,".tab.gz",sep="")
    pop_table <- read.table(paste(file_path,file_name,sep=""),header=T,stringsAsFactors=F, comment.char="")
    #replace header because we know already how it is and we need to have a column called "CHROM", it's MANDATORY!
    colnames(pop_table) <- c("CHROM","POZ","POS","ID","REF","ALT","REC","ALC","DAC","MAC","DAF","MAF")

    if(length(pop_table$DAF) > 0) {

      pop_table$DAC <- as.numeric(as.character(pop_table$DAC))
      pop_table$MAC <- as.numeric(as.character(pop_table$MAC))
      pop_table$DAF <- as.numeric(as.character(pop_table$DAF))
      pop_table$MAF <- as.numeric(as.character(pop_table$MAF))
      
      #remove all MAC = 1
      # pop_table <- pop_table[which(pop_table$MAC > 1),]
      
      #write a cute output
      outdir <- paste(pop,"_",chr,sep="")
      system(paste("mkdir -p ",pop,"_",chr,"/summaries",sep=""))

      #remove sites without the DAF info
      dim(pop_table)
      pop_table_no_na <- pop_table[which(!is.na(pop_table$DAF)),]
      dim(pop_table_no_na)
      summary(pop_table_no_na)
      pop_table_no_mono <- pop_table_no_na[which(pop_table_no_na$DAF !=1 | pop_table_no_na$DAF != 0),]
      all_maf_classes <- split_bins(maf_classes,pop_table_no_mono,file_name,"DAF",outdir)
      gc()
      
      sink(paste(outdir,"/summaries/",file_name,'_maf_bin_resume.txt',sep=""))
      print(all_maf_classes)
      sink()
      tot <- sum(all_maf_classes)
      current_pop_conseq <- cbind(all_maf_classes,tot,cons,pop)
      current_pop_conseq_fract <- cbind(all_maf_classes/tot,tot,cons,pop)
      #concat all resumes for plotting
      pop_all_maf_classes <- rbind(pop_all_maf_classes,current_pop_conseq)
      pop_all_maf_classes_fract <- rbind(pop_all_maf_classes_fract,current_pop_conseq_fract)
    }
  assign(pop_maf_name,pop_all_maf_classes)
  assign(pop_maf_name_fract,pop_all_maf_classes_fract)
  }
  all_pop_maf_classes <- rbind(all_pop_maf_classes,pop_all_maf_classes)
  all_pop_maf_classes_fract <- rbind(all_pop_maf_classes_fract,pop_all_maf_classes_fract)
}
#write the table: all data
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

#private data
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_private_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_private_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

#Data filtered by MAC > 1 
#write the table: all data
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_MAC2_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_MAC2_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

#private data
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_private_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_private_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)


#now chose a couple of consequences and test plot
cons_to_plot <- c("missense_variant","synonymous_variant")

maf_to_plot <- c(0.05,0.10,0.20,0.30,0.4,0.5,0.6,0.7,0.8,0.9,1)
#read data for each population
#plot
all_cols <- NULL
# cats <- colnames(merged_daf_diag)

for(i in 1:length(all_pops)){
  if(all_pops[i] == "CEU"){
    cur_col <- colors()[130]
  }
  if(all_pops[i] == "FVG"){
    cur_col <- colors()[517]
  }
  if(all_pops[i] == "FVG_p"){
    cur_col <- colors()[50]
  }
  if(all_pops[i] == "FVG_s"){
    cur_col <- colors()[81]
  }
  if(all_pops[i] == "TSI"){
    cur_col <- colors()[30]
  }
  if(all_pops[i] == "VBI"){
    cur_col <- colors()[421]
  }
  if(all_pops[i] == "VBI_p"){
    cur_col <- colors()[33]
  }
  if(all_pops[i] == "VBI_s"){
    cur_col <- colors()[36]
  }
  
  pop_col <- cbind(cur_col,all_pops[i])
  all_cols <- rbind(all_cols,pop_col)
}
all_cols <- as.data.frame(all_cols)

jpeg(paste(base_folder,"PLOTS/10_conseq_daf.jpg",sep=""),width=800, height=800)
  par(lwd=2)
  for (cons in cons_to_plot) {
    # current_cat <- all_pop_maf_classes[which(all_pop_maf_classes$cons == "missense_variant"),]
    current_cat <- all_pop_maf_classes[which(all_pop_maf_classes$cons == cons),]

    plot(t(current_cat[which(current_cat$pop == "CEU"),1:11]),type="d",col=all_cols[which(all_cols$V2 == "CEU"),1])
    lines(t(current_cat[which(current_cat$pop == "FVG"),1:11]),type="l",col=all_cols[which(all_cols$V2 == "FVG"),1])
    lines(t(current_cat[which(current_cat$pop == "TSI"),1:11]),type="d",col=all_cols[which(all_cols$V2 == "TSI"),1])
    lines(t(current_cat[which(current_cat$pop == "VBI"),1:11]),type="l",col=all_cols[which(all_cols$V2 == "VBI"),1])
  }
  legend("topright",pch =c(rep(19,length(all_cols[,1]))),col=all_cols[,1],legend=all_cols[,2], ncol=4)
dev.off()


barplot(barplot7,
      beside=T,
      main="DAF in all populations",
      names.arg=all_pop_DAF_table_sp$breaks*100,
      xlab="",
      ylab="",col=all_cols[c(1,2,3,5,6,7),1],ylim=c(0,60))
      mtext(1, text = "DAF (%)", line = 4,cex=1.4)
      mtext(2, text = "Relative Frequency (N sites/Tot sites per category)(%)", line = 4,cex=1.4)
      legend("top",pch =c(rep(19,length(all_cols[,1]))),col=all_cols[c(1,2,3,5,6,7),1],legend=all_cols[c(1,2,3,5,6,7),2], ncol=6)


################################################################################################
# PLOT 8a: MAF spectrum for different functional annotations

rm(list=ls())
base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/UNRELATED/"
#outbred
o_pops <- c("TSI","CEU")
#isolates
i_pops <- c("FVG","VBI")
all_pops <- c(i_pops,o_pops)

chr <- "22"
source('/nfs/users/nfs_m/mc14/Work/r_scripts/maf_bins_splitter.r')
# maf_classes <- c(0,0.01,0.02,0.05,0.10,0.20,0.30,0.4,0.5,0.6,0.7,0.8,0.9,1)
maf_classes <- c(0,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.4,0.45,0.5)
conseq_classes <- paste(base_folder,"INPUT_FILES/consequences.list",sep="")
conseq <- read.table(conseq_classes,header=F)
conseq$V1 <- as.character(conseq$V1)
# conseq <- c("missense_variant","synonymous_variant")
# cons <- conseq$V1[1]
# pop <- "FVG"

# for (cons in conseq) {
all_pop_maf_classes <- NULL
all_pop_maf_classes_fract <- NULL

# for (pop in i_pops){
for (pop in all_pops){
  pop_all_maf_classes <- NULL
  pop_all_maf_classes_fract <- NULL
  pop_maf_name <- paste(pop,"_all_cons_resume",sep="")
  pop_maf_name_fract <- paste(pop,"_all_cons_resume_fract",sep="")

  for (cons in conseq$V1) {
    # file_path <- paste(base_folder,"INPUT_FILES/CHR",chr,"_no_fixed_MAC2/",pop,"/",sep="")
    # file_path <- paste(base_folder,"INPUT_FILES/CHR",chr,"_private_no_fixed/",pop,"/",sep="")
    file_path <- paste(base_folder,"INPUT_FILES/CHR",chr,"_no_fixed/",pop,"/",sep="")
    # file_path <- paste(base_folder,"INPUT_FILES/CHR",chr,"_fixed/",pop,"/",sep="")
    file_name <- paste(pop,".",cons,".",chr,".tab.gz",sep="")
    # file_name <- paste(pop,".private.",cons,".",chr,".tab.gz",sep="")
    pop_table <- read.table(paste(file_path,file_name,sep=""),header=T,stringsAsFactors=F, comment.char="")
    #replace header because we know already how it is and we need to have a column called "CHROM", it's MANDATORY!
    colnames(pop_table) <- c("CHROM","POZ","POS","ID","REF","ALT","REC","ALC","DAC","MAC","DAF","MAF")

    if(length(pop_table$DAF) > 0) {

      pop_table$DAC <- as.numeric(as.character(pop_table$DAC))
      pop_table$MAC <- as.numeric(as.character(pop_table$MAC))
      pop_table$DAF <- as.numeric(as.character(pop_table$DAF))
      pop_table$MAF <- as.numeric(as.character(pop_table$MAF))
      
      #remove all MAC = 1
      pop_table <- pop_table[which(pop_table$MAC > 1),]
      
      #write a cute output
      # outdir <- paste(pop,"_",chr,sep="")
      # outdir <- paste(pop,"_",chr,"_MAF",sep="")
      outdir <- paste(pop,"_",chr,"_MAF_MAC2",sep="")
      system(paste("mkdir -p ",outdir,"/summaries",sep=""))

      #remove sites without the DAF info
      dim(pop_table)
      pop_table_no_na <- pop_table[which(!is.na(pop_table$DAF)),]
      dim(pop_table_no_na)
      summary(pop_table_no_na)
      pop_table_no_mono <- pop_table_no_na[which(pop_table_no_na$DAF !=1 | pop_table_no_na$DAF != 0),]
      # for DAF
      # all_maf_classes <- split_bins(maf_classes,pop_table_no_mono,file_name,"DAF",outdir)
      # for MAF
      all_maf_classes <- split_bins(maf_classes,pop_table_no_mono,file_name,"MAF",outdir)
      gc()
      
      # for DAF
      # sink(paste(outdir,"/summaries/",file_name,'_daf_bin_resume.txt',sep=""))
      # for MAF
      sink(paste(outdir,"/summaries/",file_name,'_maf_bin_resume.txt',sep=""))
      print(all_maf_classes)
      sink()
      tot <- sum(all_maf_classes)
      current_pop_conseq <- cbind(all_maf_classes,tot,cons,pop)
      current_pop_conseq_fract <- cbind(all_maf_classes/tot,tot,cons,pop)
      #concat all resumes for plotting
      pop_all_maf_classes <- rbind(pop_all_maf_classes,current_pop_conseq)
      pop_all_maf_classes_fract <- rbind(pop_all_maf_classes_fract,current_pop_conseq_fract)
    }
  assign(pop_maf_name,pop_all_maf_classes)
  assign(pop_maf_name_fract,pop_all_maf_classes_fract)
  }
  all_pop_maf_classes <- rbind(all_pop_maf_classes,pop_all_maf_classes)
  all_pop_maf_classes_fract <- rbind(all_pop_maf_classes_fract,pop_all_maf_classes_fract)
}
###################################################
# DAF
#write the table: all data
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

#private data
# DAF
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_private_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_private_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

#Data filtered by MAC > 1 
#write the table: all data
# DAF
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_MAC2_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_MAC2_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

#private data
# DAF
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_private_MAC2_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_daf_classes_private_MAC2_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)


###########################################################
# MAF
#write the table: all data
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_maf_classes_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_maf_classes_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

#private data
# MAF
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_maf_classes_private_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_maf_classes_private_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

#Data filtered by MAC > 1 
#write the table: all data
# MAF
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_maf_classes_MAC2_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_maf_classes_MAC2_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
#private data
# MAF
write.table(all_pop_maf_classes,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_maf_classes_private_MAC2_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(all_pop_maf_classes_fract,file=paste(base_folder,"RESULTS/CONSEQUENCES/all_pop_conseq_maf_classes_private_MAC2_fract_chr",chr,".txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

##########################################
#now chose a couple of consequences and test plot
cons_to_plot <- c("missense_variant","synonymous_variant")

maf_to_plot <- c(0.05,0.10,0.20,0.30,0.4,0.5,0.6,0.7,0.8,0.9,1)
#read data for each population
#plot
all_cols <- NULL
# cats <- colnames(merged_daf_diag)

for(i in 1:length(all_pops)){
  if(all_pops[i] == "CEU"){
    cur_col <- colors()[130]
  }
  if(all_pops[i] == "FVG"){
    cur_col <- colors()[517]
  }
  if(all_pops[i] == "FVG_p"){
    cur_col <- colors()[50]
  }
  if(all_pops[i] == "FVG_s"){
    cur_col <- colors()[81]
  }
  if(all_pops[i] == "TSI"){
    cur_col <- colors()[30]
  }
  if(all_pops[i] == "VBI"){
    cur_col <- colors()[421]
  }
  if(all_pops[i] == "VBI_p"){
    cur_col <- colors()[33]
  }
  if(all_pops[i] == "VBI_s"){
    cur_col <- colors()[36]
  }
  
  pop_col <- cbind(cur_col,all_pops[i])
  all_cols <- rbind(all_cols,pop_col)
}
all_cols <- as.data.frame(all_cols)

jpeg(paste(base_folder,"PLOTS/10_conseq_daf.jpg",sep=""),width=800, height=800)
  par(lwd=2)
  for (cons in cons_to_plot) {
    # current_cat <- all_pop_maf_classes[which(all_pop_maf_classes$cons == "missense_variant"),]
    current_cat <- all_pop_maf_classes[which(all_pop_maf_classes$cons == cons),]

    plot(t(current_cat[which(current_cat$pop == "CEU"),1:11]),type="d",col=all_cols[which(all_cols$V2 == "CEU"),1])
    lines(t(current_cat[which(current_cat$pop == "FVG"),1:11]),type="l",col=all_cols[which(all_cols$V2 == "FVG"),1])
    lines(t(current_cat[which(current_cat$pop == "TSI"),1:11]),type="d",col=all_cols[which(all_cols$V2 == "TSI"),1])
    lines(t(current_cat[which(current_cat$pop == "VBI"),1:11]),type="l",col=all_cols[which(all_cols$V2 == "VBI"),1])
  }
  legend("topright",pch =c(rep(19,length(all_cols[,1]))),col=all_cols[,1],legend=all_cols[,2], ncol=4)
dev.off()


###############################################################
# PLOT 8b: count load of mutation for each sample by category

rm(list=ls())
source("/nfs/users/nfs_m/mc14/Work/r_scripts/col_pop.r")

#INGI
# pops <- sort(c("VBI","FVG","CARL"))
categs <- c("private","shared","novel")
#OUTBRED
pops <- c("CEU","TSI","CAR","VBI","FVG")
# categs <- c("all")
# csqs <- c("CHR22","miss","syn")

csqs <- c("CHR22","miss","syn","polyphen.benign","polyphen.possibly.damaging","polyphen.probably.damaging","sift.deleterious","sift.tolerated")


for(csq in csqs){
  for(cat in categs){
    print(cat)
    print(csq)
    base_folder <- paste("/lustre/scratch113/projects/esgi-vbseq/20140430_purging/UNRELATED/RESULTS/CONSEQUENCES/",csq,"/",cat,"/VCF",sep="")
    print(base_folder)
    setwd(base_folder)
    #upload files with format: CHR POS REF ALT AC AN [SAMPLES/GT]
    # we need to convert all genotypes to 1 0 2, we can create a function to apply to our data for genotype conversion...
    for (pop in pops) {
      current_region_current_current_pop <- NULL
      for(chr in 1:22) {
        if (cat == "all"){
          current_region_file <- paste(base_folder,"/",chr,".",pop,".chr",chr,".tab.gz.",csq,".regions.vcf.gz.tab",sep="")
        } else {
          # 1.INGI_chr1.merged_maf.tab.gz.VBI.shared.tab.gz.miss.regions.vcf.gz.tab
          if (pop == "CAR" && cat != "novel"){
            pop <- "CARL"
          }
          print(pop)
          current_region_file <- paste(base_folder,"/",chr,".INGI_chr",chr,".merged_maf.tab.gz.",pop,".",cat,".tab.gz.",csq,".regions.vcf.gz.tab",sep="")
        }
        print(current_region_file)
        if (file.exists(current_region_file)){
          current_region_current_chr_current_pop <- read.table(current_region_file,header=T)
          if (dim(current_region_current_chr_current_pop)[1] > 0 ){
            #we need to convert our genotypes, now!
            for(j in 7:length(colnames(current_region_current_chr_current_pop))){
                levels(current_region_current_chr_current_pop[,j])[levels(current_region_current_chr_current_pop[,j]) == "0|0"] <- "0" 
                levels(current_region_current_chr_current_pop[,j])[levels(current_region_current_chr_current_pop[,j]) == "0|1"] <- "1" 
                levels(current_region_current_chr_current_pop[,j])[levels(current_region_current_chr_current_pop[,j]) == "1|0"] <- "1" 
                levels(current_region_current_chr_current_pop[,j])[levels(current_region_current_chr_current_pop[,j]) == "1|1"] <- "2" 
                levels(current_region_current_chr_current_pop[,j])[levels(current_region_current_chr_current_pop[,j]) == "2|0"] <- "1" 
                levels(current_region_current_chr_current_pop[,j])[levels(current_region_current_chr_current_pop[,j]) == "0|2"] <- "1" 
                levels(current_region_current_chr_current_pop[,j])[levels(current_region_current_chr_current_pop[,j]) == "2|1"] <- "1" 
                levels(current_region_current_chr_current_pop[,j])[levels(current_region_current_chr_current_pop[,j]) == "1|2"] <- "1" 
                levels(current_region_current_chr_current_pop[,j])[levels(current_region_current_chr_current_pop[,j]) == "2|2"] <- "2" 
                current_region_current_chr_current_pop[,j] <- as.numeric(as.character(current_region_current_chr_current_pop[,j]))
                
            }
            # EGAN00001172162
            current_region_current_chr_current_pop_samples <- current_region_current_chr_current_pop[,7:length(colnames(current_region_current_chr_current_pop))]
            current_region_current_current_pop <- rbind(current_region_current_current_pop,current_region_current_chr_current_pop_samples)
          }
        }
      }
      #current_region_current_current_pop contains ALL SNP variants for that category for each sample across all chromosome
      #so if I want to caculate the frequency instead of a simple count, I need to divide by this number of variants

      if (!is.null(current_region_current_current_pop)){
        #sum across al variants on all chromosomes
        current_pop_current_cat_current_type <- apply(current_region_current_current_pop,2,sum)
        #   FORMAT IN THIS WAY: sample num pop
        current_pop_current_cat_current_type_df <- as.data.frame(current_pop_current_cat_current_type)
        current_pop_current_cat_current_type_df$samples <- row.names(current_pop_current_cat_current_type_df)
        if (pop == "CARL"){
          current_pop_current_cat_current_type_df$pop <- "CAR"
        }else{
          current_pop_current_cat_current_type_df$pop <- pop
        }
        if(csq == "miss") {
          current_pop_current_cat_current_type_df$cons <- "Missense"
        }else if(csq == "syn"){
          current_pop_current_cat_current_type_df$cons <- "Synonymous"
            
        }else {
          current_pop_current_cat_current_type_df$cons <- csq
          
        }
        current_pop_current_cat_current_type_df$cat <- cat
        colnames(current_pop_current_cat_current_type_df)[1] <- "value"
        row.names(current_pop_current_cat_current_type_df) <- NULL

        #since I want a frequecy, now I've to divide all samples count by the number of variants for that category
        tot_current_cat_var_num <- dim(current_region_current_current_pop)[1]
        current_pop_current_cat_current_type_df$freq <- current_pop_current_cat_current_type_df$value/tot_current_cat_var_num
        
        if (pop == "CARL"){
            pop <- "CAR"
        }
        assign(paste(pop,"_",cat,"_",csq,"_df",sep=""),current_pop_current_cat_current_type_df)
        assign(paste(pop,"_",cat,"_",csq,sep=""),current_pop_current_cat_current_type)
        write.table(current_pop_current_cat_current_type_df,file=paste(base_folder,pop,"_",cat,"_",csq,sep=""),sep="\t",col.names=T,quote=F,row.names=F)
      }
    }
  }
}

#box plot
###### REPLOT with ggplot
require(ggplot2)
require(reshape2)
all_cols <-col_pop(pops)

ylab <- "Number of mutations per individual"

#for ALL the variant classes together
# all_pop_merged <- NULL
# for(pop in pops){
#   current_syn <- get(paste(pop,"_all_syn_df",sep=''))
#   current_miss <- get(paste(pop,"_all_miss_df",sep=''))
#   current_merged <- rbind(current_miss,current_syn)
#   assign(paste(pop,"_all_merged_df",sep=""),current_merged)
#   all_pop_merged <- rbind(all_pop_merged,current_merged)
# }

#for splitted variant classes
shared_private_all_pop_merged <- NULL

for(pop in pops){
  all_csq_all_cat_current_pop <- NULL
  for (cat in categs){
    all_csq_current_cat_current_pop <- NULL
    for(csq in csqs){
      # if (pop == "CARL" && cat == "novel"){
      #   pop <- "CAR"
      # }
      all_obj_name <- paste(pop,"_",cat,"_",csq,"_df",sep="")
      # alt_obj_name <- paste(pop,"_alt_",cat,"_",csq,"_df",sep="")
      if(exists(all_obj_name)){
        current_csq_current_cat_current_pop <- get(all_obj_name)
        all_csq_current_cat_current_pop <- rbind(all_csq_current_cat_current_pop,current_csq_current_cat_current_pop)
      }
    }
    all_csq_all_cat_current_pop <- rbind(all_csq_all_cat_current_pop,all_csq_current_cat_current_pop)
  }
  assign(paste(pop,"_all_csq_all_cat_merged_df",sep=""),all_csq_all_cat_current_pop)
  shared_private_all_pop_merged <- rbind(shared_private_all_pop_merged,all_csq_all_cat_current_pop)
}

data_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/UNRELATED/RESULTS/CONSEQUENCES/"
# write.table(shared_private_all_pop_merged,file=paste(data_folder,"shared_private_all_pop_merged.txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(shared_private_all_pop_merged,file=paste(data_folder,"shared_private_all_pop_merged_others.txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

shared_private_all_pop_merged$pop2 <- factor(shared_private_all_pop_merged$pop,pops)

pl <- ggplot(shared_private_all_pop_merged)
pl <- pl + geom_boxplot()
# pl <- pl + aes(x = factor(pop2), y = value, fill=pop2)
pl <- pl + aes(x = factor(pop2), y = freq, fill=pop2)
pl <- pl + ylab(ylab)
pl <- pl + xlab("")
pl <- pl + guides(fill=guide_legend(title="Cohorts"))
pl <- pl + scale_fill_manual("Cohorts", values=all_cols)
pl <- pl + theme_bw(18)
pl <- pl + facet_grid(cat~cons, scales="free")
ggsave(filename=paste(data_folder,"/8b_shared_private_novel_pop_conseq_carriers_ggplot_freq.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
# ggsave(filename=paste(data_folder,"/8b_shared_private_novel_pop_conseq_carriers_ggplot.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)


########################################################
#alternative plot with sum private and novel
pops_ingi <- sort(c("VBI","FVG","CARL"))
shared_private_plus_novel_all_pop_merged <- NULL

for(pop in pops){
  all_csq_all_cat_current_pop <- NULL
  # for (cat in categs){
    # all_csq_current_cat_current_pop <- NULL
    for(csq in csqs){
      shared_obj_name <- paste(pop,"_shared_",csq,"_df",sep="")
      private_obj_name <- paste(pop,"_private_",csq,"_df",sep="")
      novel_obj_name <- paste(pop,"_novel_",csq,"_df",sep="")
      # alt_obj_name <- paste(pop,"_alt_",cat,"_",csq,"_df",sep="")
      if(exists(shared_obj_name)){
        current_csq_current_shared_current_pop <- get(shared_obj_name)
      }
      if(exists(private_obj_name)){
        current_csq_current_private_current_pop <- get(private_obj_name)
      }
      if(exists(novel_obj_name)){
        current_csq_current_novel_current_pop <- get(novel_obj_name)
      }
      if (exists(private_obj_name) && exists(novel_obj_name)){
        #merge private and novel and sum value columns
        current_csq_current_private_novel_current_pop <- merge(current_csq_current_private_current_pop,current_csq_current_novel_current_pop[,c(1,2)],by="samples",sort=F)
        #now sum values and remove useless columns
        current_csq_current_private_novel_current_pop$value <- current_csq_current_private_novel_current_pop$value.x + current_csq_current_private_novel_current_pop$value.y
        current_csq_current_private_novel_current_pop$value.x <- NULL
        current_csq_current_private_novel_current_pop$value.y <- NULL
        current_csq_current_private_novel_current_pop$cat <- "private+novel"
      }else{
        current_csq_current_private_novel_current_pop <- NULL
      }
      #now rbind shared and private+novel
      current_csq_current_cat_current_pop <- rbind(current_csq_current_shared_current_pop,current_csq_current_private_novel_current_pop)
      all_csq_all_cat_current_pop <- rbind(all_csq_all_cat_current_pop,current_csq_current_cat_current_pop)
      # }
    }
    # all_csq_all_cat_current_pop <- rbind(all_csq_all_cat_current_pop,all_csq_current_cat_current_pop)
  # }
  assign(paste(pop,"_all_csq_all_cat_merged_df",sep=""),all_csq_all_cat_current_pop)
  shared_private_plus_novel_all_pop_merged <- rbind(shared_private_plus_novel_all_pop_merged,all_csq_all_cat_current_pop)
}


data_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/UNRELATED/RESULTS/CONSEQUENCES/"
# write.table(shared_private_plus_novel_all_pop_merged,file=paste(data_folder,"shared_private_plus_novel_all_pop_merged.txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)
write.table(shared_private_plus_novel_all_pop_merged,file=paste(data_folder,"shared_private_plus_novel_all_pop_merged_others.txt",sep=""),sep="\t",col.names=T,quote=F,row.names=F)

#sort factors for plot in right order
shared_private_plus_novel_all_pop_merged$pop2 <- factor(shared_private_plus_novel_all_pop_merged$pop,pops)

pl <- ggplot(shared_private_plus_novel_all_pop_merged)
pl <- pl + geom_boxplot()
pl <- pl + aes(x = factor(pop2), y = value, fill=pop2)
pl <- pl + ylab(ylab)
pl <- pl + xlab("")
pl <- pl + guides(fill=guide_legend(title="Cohorts"))
pl <- pl + scale_fill_manual("Cohorts", values=all_cols)
pl <- pl + theme_bw(18)
pl <- pl + facet_grid(cat~cons, scales="free")
ggsave(filename=paste(data_folder,"/8b_shared_private_plus_novel_pop_conseq_carriers_ggplot.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)

###############################################
#we should split all villages in fvg
#read keeplist, than change population name and replot
fvg_pops <- c("Erto","Illegio","Resia","Sauris")
pop_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/UNRELATED/listpop"
shared_private_plus_novel_all_pop_merged_fvg_split <- shared_private_plus_novel_all_pop_merged
shared_private_all_pop_merged_fvg_split <- shared_private_all_pop_merged

for(f_pop in fvg_pops){
  current_pop_list <- read.table(paste(pop_folder,"/",f_pop,"_unrelated.list",sep=""))
  colnames(current_pop_list) <- c("samples")
  if (f_pop =="Resia"){
    current_pop_list$samples <- gsub("(^\\d+)","X\\1",current_pop_list$samples)
  }
  if(f_pop=="Illegio"){ c_pop <- "FVI"}
  if(f_pop=="Resia"){ c_pop <- "FVR"}
  if(f_pop=="Erto"){ c_pop <- "FVE"}
  if(f_pop=="Sauris"){ c_pop <- "FVS"}
  shared_private_all_pop_merged_fvg_split[which(shared_private_all_pop_merged_fvg_split$samples %in% current_pop_list$samples),]$pop <- c_pop
  # shared_private_plus_novel_all_pop_merged_fvg_split[which(shared_private_plus_novel_all_pop_merged_fvg_split$samples %in% current_pop_list$samples),]$pop <- c_pop
}

all_pops <- c("CEU","TSI","CAR","VBI","FVE","FVI","FVR","FVS")
all_cols <-col_pop(all_pops)

csqs1 <- c("CHR22","Missense","Synonymous")
csqs2 <- c("CHR22","Missense","polyphen.possibly.damaging","polyphen.probably.damaging","sift.deleterious","Synonymous","polyphen.benign","sift.tolerated")
csqs3 <- c("polyphen.benign","polyphen.possibly.damaging","polyphen.probably.damaging","sift.deleterious","sift.tolerated")

shared_private_all_pop_merged_fvg_split$pop2 <- factor(shared_private_all_pop_merged_fvg_split$pop,all_pops)

#extract data for different categories
shared_private_all_pop_merged_fvg_split_csqs1 <- shared_private_all_pop_merged_fvg_split[shared_private_all_pop_merged_fvg_split$cons %in% csqs1,]
shared_private_all_pop_merged_fvg_split_csqs2 <- shared_private_all_pop_merged_fvg_split[shared_private_all_pop_merged_fvg_split$cons %in% csqs2,]
shared_private_all_pop_merged_fvg_split_csqs3 <- shared_private_all_pop_merged_fvg_split[shared_private_all_pop_merged_fvg_split$cons %in% csqs3,]

#fix the factor order
shared_private_all_pop_merged_fvg_split_csqs1$pop2 <- factor(shared_private_all_pop_merged_fvg_split_csqs1$pop,all_pops)
shared_private_all_pop_merged_fvg_split_csqs2$pop2 <- factor(shared_private_all_pop_merged_fvg_split_csqs2$pop,all_pops)
shared_private_all_pop_merged_fvg_split_csqs3$pop2 <- factor(shared_private_all_pop_merged_fvg_split_csqs3$pop,all_pops)

#fix the freq by dividing by 2
shared_private_all_pop_merged_fvg_split_csqs1$freq <- (shared_private_all_pop_merged_fvg_split_csqs1$freq)/2
shared_private_all_pop_merged_fvg_split_csqs2$freq <- (shared_private_all_pop_merged_fvg_split_csqs2$freq)/2
shared_private_all_pop_merged_fvg_split_csqs3$freq <- (shared_private_all_pop_merged_fvg_split_csqs3$freq)/2
# shared_private_plus_novel_all_pop_merged_fvg_split$pop2 <- factor(shared_private_plus_novel_all_pop_merged_fvg_split$pop,all_pops)

#first plot
pl <- ggplot(shared_private_all_pop_merged_fvg_split)
pl <- pl + geom_boxplot()
# pl <- pl + aes(x = factor(pop2), y = value, fill=pop2)
pl <- pl + aes(x = factor(pop2), y = freq, fill=pop2)
pl <- pl + ylab(ylab)
pl <- pl + xlab("")
pl <- pl + guides(fill=guide_legend(title="Cohorts"))
pl <- pl + scale_fill_manual("Cohorts", values=all_cols)
pl <- pl + theme_bw(18)
pl <- pl + facet_grid(cat~cons, scales="free")
pl <- pl + theme(axis.text.x = element_text(angle = 45, hjust = 1))
# ggsave(filename=paste(data_folder,"/8b_shared_private_novel_pop_conseq_carriers_fvg_split_ggplot.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
# ggsave(filename=paste(data_folder,"/8b_shared_private_novel_pop_conseq_carriers_fvg_split_ggplot_chr22.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
# ggsave(filename=paste(data_folder,"/8b_shared_private_novel_pop_conseq_carriers_fvg_split_ggplot_others.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
ggsave(filename=paste(data_folder,"/8b_shared_private_novel_pop_conseq_carriers_fvg_split_ggplot_chr22_freq.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
ggsave(filename=paste(data_folder,"/8b_shared_private_novel_pop_conseq_carriers_fvg_split_ggplot_others_freq.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)

#plot for the different set of categories
ylab <- "Frequency of mutations per individual"
for(i in 1:3){
  current_to_plot <- get(paste("shared_private_all_pop_merged_fvg_split_csqs",i,sep=""))
  pl <- ggplot(current_to_plot)
  pl <- pl + geom_boxplot()
  # pl <- pl + aes(x = factor(pop2), y = value, fill=pop2)
  pl <- pl + aes(x = factor(pop2), y = freq, fill=pop2)
  pl <- pl + ylab(ylab)
  pl <- pl + xlab("")
  pl <- pl + guides(fill=guide_legend(title="Cohorts"))
  pl <- pl + scale_fill_manual("Cohorts", values=all_cols)
  pl <- pl + theme_bw(14)
  pl <- pl + facet_grid(cat~cons, scales="free")
  pl <- pl + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggsave(filename=paste(data_folder,"/8b_shared_private_novel_pop_conseq_carriers_fvg_split_ggplot_freq_csqs",i,".jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
  
}

# VBI
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "VBI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),])
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "VBI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),])
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "VBI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),])

# syn
vbi_novels_s <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "VBI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),]
vbi_private_s <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "VBI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),]

merged_vbi_np_s <- merge(vbi_novels_s,vbi_private_s,by="samples")
merged_vbi_np_s$np_c <- merged_vbi_np_s$value.x + merged_vbi_np_s$value.y
summary(merged_vbi_np_s)

# miss
vbi_novels_m <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "VBI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),]
vbi_private_m <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "VBI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),]

merged_vbi_np_m <- merge(vbi_novels_m,vbi_private_m,by="samples")
merged_vbi_np_m$np_c <- merged_vbi_np_m$value.x + merged_vbi_np_m$value.y
summary(merged_vbi_np_m)

# chr22
vbi_novels_22 <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "VBI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),]
vbi_private_22 <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "VBI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),]

merged_vbi_np_22 <- merge(vbi_novels_22,vbi_private_22,by="samples")
merged_vbi_np_22$np_c <- merged_vbi_np_22$value.x + merged_vbi_np_22$value.y
summary(merged_vbi_np_22)

# CAR
car_novels <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CAR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),]
car_private <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CAR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),]

merged_car_np <- merge(car_novels,car_private,by="samples")
merged_car_np$np_c <- merged_car_np$value.x + merged_car_np$value.y
summary(merged_car_np)

car_novels_m <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CAR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),]
car_private_m <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CAR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),]

merged_car_np_m <- merge(car_novels_m,car_private_m,by="samples")
merged_car_np_m$np_c <- merged_car_np_m$value.x + merged_car_np_m$value.y
summary(merged_car_np_m)

summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CAR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),])
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CAR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),])
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CAR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),])

# chr22
car_novels_22 <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CAR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),]
car_private_22 <- shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CAR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),]

merged_car_np_22 <- merge(car_novels_22,car_private_22,by="samples")
merged_car_np_22$np_c <- merged_car_np_22$value.x + merged_car_np_22$value.y
summary(merged_car_np_22)

# FVG
summary(rbind(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVE" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVS" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),]))

summary(rbind(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVE" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVS" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),]))

summary(rbind(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVE" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVS" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),]))

# syn
fvg_novels_s <- rbind(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVE" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVS" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),])

fvg_private_s <- rbind(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVE" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVS" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),])


merged_fvg_np_s <- merge(fvg_novels_s,fvg_private_s,by="samples")
merged_fvg_np_s$np_c <- merged_fvg_np_s$value.x + merged_fvg_np_s$value.y
summary(merged_fvg_np_s)

# miss
fvg_novels_m <- rbind(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVE" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVS" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),])

fvg_private_m <- rbind(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVE" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVS" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),])

merged_fvg_np_m <- merge(fvg_novels_m,fvg_private_m,by="samples")
merged_fvg_np_m$np_c <- merged_fvg_np_m$value.x + merged_fvg_np_m$value.y
summary(merged_fvg_np_m)

# chr22
fvg_novels_22 <- rbind(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVE" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVS" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="novel" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),])

fvg_private_22 <- rbind(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVE" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVR" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),],
shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "FVS" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="private" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),])


merged_fvg_np_22 <- merge(fvg_novels_22,fvg_private_22,by="samples")
merged_fvg_np_22$np_c <- merged_fvg_np_22$value.x + merged_fvg_np_22$value.y
summary(merged_fvg_np_22)

# CEU
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CEU" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),])
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CEU" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),])
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "CEU" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),])

# TSI
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "TSI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Synonymous"),])
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "TSI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="Missense"),])
summary(shared_private_all_pop_merged_fvg_split_csqs1[which(shared_private_all_pop_merged_fvg_split_csqs1$pop == "TSI" & shared_private_all_pop_merged_fvg_split_csqs1$cat=="shared" & shared_private_all_pop_merged_fvg_split_csqs1$cons=="CHR22"),])


#second plot
pl <- ggplot(shared_private_plus_novel_all_pop_merged_fvg_split)
pl <- pl + geom_boxplot()
pl <- pl + aes(x = factor(pop2), y = value, fill=pop2)
pl <- pl + ylab(ylab)
pl <- pl + xlab("")
pl <- pl + guides(fill=guide_legend(title="Cohorts"))
pl <- pl + scale_fill_manual("Cohorts", values=all_cols)
pl <- pl + theme_bw(18)
pl <- pl + facet_grid(cat~cons, scales="free")
pl <- pl + theme(axis.text.x = element_text(angle = 45, hjust = 1))
# ggsave(filename=paste(data_folder,"/8b_shared_private_plus_novel_pop_conseq_carriers_fvg_split_ggplot.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
# ggsave(filename=paste(data_folder,"/8b_shared_private_plus_novel_pop_conseq_carriers_fvg_split_ggplot_chr22.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
ggsave(filename=paste(data_folder,"/8b_shared_private_plus_novel_pop_conseq_carriers_fvg_split_ggplot_others.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)

############# 29052015 ##################################
#replot everything with ancestral alleles count
rm(list=ls())
all_pops <- c("CARL","VBI","FVG-E","FVG-I","FVG-R","FVG-S","CEU","TSI")
all_pops_e <- c("CEU","TSI","CARL","VBI","Erto","Illegio","Resia","Sauris")
categories <- c("Missense","Synonymous","Intergenic","LoF")
# categories <- c("Missense","Synonymous")
# categories <- c("Missense")
# categories <- c("Synonymous")
# categories <- c("Neutral")
# categories <- c("Missense","Synonymous")
# base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/HOMCOUNT/05292015/shared/"
# base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/ALTCOUNT/05302015_ALT/shared/"

#first we need to create the sample file for each pupulation for each category
all_pop_all_cat <- NULL
all_pop_all_cat_hom <- NULL
for (hum_cat in categories){
  # cat <- "miss"
  # hum_cat="Missense"
  if(hum_cat=="Intergenic"){
     cat <- "inter"
     base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/HOMCOUNT/06052015_filt/shared"
     # base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/HOMCOUNT/06012015_filt/shared/"
  }
  if(hum_cat=="Lof"){
     cat <- "lof"
     base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/HOMCOUNT/06102015_filt/shared/"
     # base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/ALTCOUNT/05302015_ALT/shared/"
  }
  if(hum_cat=="Missense"){
    cat <- "miss"
    base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/HOMCOUNT/06052015_filt/shared"
    # base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/HOMCOUNT/06012015_filt/shared/"
  }
  if(hum_cat=="Synonymous"){
    cat <- "syn"
    base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/HOMCOUNT/06052015_filt/shared"
    # base_folder <- "/lustre/scratch113/projects/esgi-vbseq/20140430_purging/46_SAMPLES/RESULTS/ALTCOUNT/06012015_ALT/shared/"
  }
  print(cat)
  for(pop in all_pops_e){
      # pop<- "CEU"
      print(pop)
      current_cat_pop_name <- paste(base_folder,"/",cat,"/",pop,"/All_samples_",cat,"_",pop,".tab",sep="")
      current_cat_pop <- read.table(current_cat_pop_name,header=F)
      colnames(current_cat_pop) <- c("ID","CHR","HOM_DA_COUNT","DAC","cohort","shared","cat_shared","tot_chr","tot_hom_sample")
      # head(current_cat_pop)
      sample_current_cat_pop_sum <- by(current_cat_pop$DAC,current_cat_pop$ID,sum)
      sample_current_cat_pop_sum_hom <- by(current_cat_pop$HOM_DA_COUNT,current_cat_pop$ID,sum)
      sample_current_cat_pop_sum_ALL_hom <- by(current_cat_pop$tot_hom_sample,current_cat_pop$ID,sum)
    

    #get the sum of all homozygous genotype per sample in a dataframe
    all_sample_current_cat_pop_ALL_hom <- NULL
    for( id in 1:dim(sample_current_cat_pop_sum_ALL_hom)) {
      sample_current_cat_pop_ALL_hom <- as.data.frame(cbind(ID=names(sample_current_cat_pop_sum_ALL_hom[id]),ALL_HOM_SUM=sample_current_cat_pop_sum_ALL_hom[id]))
      all_sample_current_cat_pop_ALL_hom <- rbind(all_sample_current_cat_pop_ALL_hom,sample_current_cat_pop_ALL_hom)
    }
    rownames(all_sample_current_cat_pop_ALL_hom) <- NULL
    
    #get the sum of all DAC per sample in a dataframe
    all_sample_current_cat_pop <- NULL

    for( id in 1:dim(sample_current_cat_pop_sum)) {
      sample_current_cat_pop <- as.data.frame(cbind(ID=names(sample_current_cat_pop_sum[id]),DAC_SUM=sample_current_cat_pop_sum[id]))
      all_sample_current_cat_pop <- rbind(all_sample_current_cat_pop,sample_current_cat_pop)
    }

    #get the sum of all derived allele homozygous genotype per sample in a dataframe
    all_sample_current_cat_pop_hom <- NULL

    for( id in 1:dim(sample_current_cat_pop_sum_hom)) {
      sample_current_cat_pop_hom <- as.data.frame(cbind(ID=names(sample_current_cat_pop_sum_hom[id]),HOM_SUM=sample_current_cat_pop_sum_hom[id]))
      all_sample_current_cat_pop_hom <- rbind(all_sample_current_cat_pop_hom,sample_current_cat_pop_hom)
    }

    rownames(all_sample_current_cat_pop) <- NULL
    all_sample_current_cat_pop$DAC_SUM <- as.numeric(as.character(all_sample_current_cat_pop$DAC_SUM))
    all_sample_current_cat_pop$category <- hum_cat
      

    rownames(all_sample_current_cat_pop_hom) <- NULL
    all_sample_current_cat_pop_hom$HOM_SUM <- as.numeric(as.character(all_sample_current_cat_pop_hom$HOM_SUM))
    all_sample_current_cat_pop_hom$category <- hum_cat
    
    # all_sample_current_cat_pop_hom <- merge(all_sample_current_cat_pop_hom,all_sample_current_cat_pop_ALL_hom,by="ID")



    # tot_shared <- sum(current_cat_pop$shared)/46
    # tot_cat_shared <- sum(current_cat_pop$cat_shared)/46
    # tot_shared <- all_sample_current_cat_pop_hom$tot_chr*2
    # tot_cat_shared <- all_sample_current_cat_pop_hom$tot_chr*2

    # all_sample_current_cat_pop_hom$HDAC_shared <- all_sample_current_cat_pop_hom$HOM_SUM/tot_shared
    # all_sample_current_cat_pop_hom$HDAC_cat <- all_sample_current_cat_pop_hom$HOM_SUM/tot_cat_shared
    current_pop_cat_shared <- sum(current_cat_pop$cat_shared)/46
    all_sample_current_cat_pop_hom$pop_cat_shared <- current_pop_cat_shared 
   
    all_sample_current_cat_pop$cohort <- pop
    all_sample_current_cat_pop_hom$cohort <- pop
    if(pop=="Erto"){
      all_sample_current_cat_pop$cohort <- "FVG-E"
      all_sample_current_cat_pop_hom$cohort <- "FVG-E"
    }
    if(pop=="Illegio"){
      all_sample_current_cat_pop$cohort <- "FVG-I"
      all_sample_current_cat_pop_hom$cohort <- "FVG-I"
    }
    if(pop=="Resia"){
      all_sample_current_cat_pop$cohort <- "FVG-R"
      all_sample_current_cat_pop_hom$cohort <- "FVG-R"
    }
    if(pop=="Sauris"){
      all_sample_current_cat_pop$cohort <- "FVG-S"
      all_sample_current_cat_pop_hom$cohort <- "FVG-S"
    }


    all_sample_current_cat_pop_hom_merged <- merge(all_sample_current_cat_pop_hom,all_sample_current_cat_pop_ALL_hom,by="ID")
    all_pop_all_cat <- rbind(all_pop_all_cat,all_sample_current_cat_pop)
    all_pop_all_cat_hom <- rbind(all_pop_all_cat_hom,all_sample_current_cat_pop_hom_merged)

  }

}

all_pop_all_cat$category <-as.factor(all_pop_all_cat$category)
all_pop_all_cat$category <-factor(all_pop_all_cat$category,categories)
all_pop_all_cat$cohort <-factor(all_pop_all_cat$cohort,all_pops)

all_pop_all_cat_hom$category <-as.factor(all_pop_all_cat_hom$category)
all_pop_all_cat_hom$category <-factor(all_pop_all_cat_hom$category,categories)
all_pop_all_cat_hom$cohort <-factor(all_pop_all_cat_hom$cohort,all_pops)

all_pop_all_cat_hom$ALL_HOM_SUM <-as.numeric(as.character(all_pop_all_cat_hom$ALL_HOM_SUM))

#calculate the number of homozygous sites in the three categories by sample per sample
all_variants_pop_cat_all_hom_persample <- by(all_pop_all_cat_hom$HOM_SUM,all_pop_all_cat_hom$ID,sum)
all_pop_all_variants_all_hom_persample <-  NULL
for( id in 1:dim(all_variants_pop_cat_all_hom_persample)) {
  current_pop_all_variants_all_hom_persample <- as.data.frame(cbind(ID=names(all_variants_pop_cat_all_hom_persample[id]),ALL_CAT_HOM_SUM=all_variants_pop_cat_all_hom_persample[id]))
  all_pop_all_variants_all_hom_persample <- rbind(all_pop_all_variants_all_hom_persample,current_pop_all_variants_all_hom_persample)
}
rownames(all_pop_all_variants_all_hom_persample) <- NULL



#calculate the number of homozygous sites in the three categories by sample
all_variants_pop_cat_all_hom <- by(all_pop_all_cat_hom$ALL_HOM_SUM,all_pop_all_cat_hom$ID,sum)

all_pop_all_variants_all_hom <-  NULL
for( id in 1:dim(all_variants_pop_cat_all_hom)) {
  current_pop_all_variants_all_hom <- as.data.frame(cbind(ID=names(all_variants_pop_cat_all_hom[id]),ALL_CAT_HOM_SUM=all_variants_pop_cat_all_hom[id]))
  all_pop_all_variants_all_hom <- rbind(all_pop_all_variants_all_hom,current_pop_all_variants_all_hom)
}
rownames(all_pop_all_variants_all_hom) <- NULL

#calculate the number of variants in all the three categories by populations
all_variants_pop_cat <- by(all_pop_all_cat_hom$pop_cat_shared,all_pop_all_cat_hom$cohort,sum)

all_pop_all_variants <-  NULL
for( id in 1:dim(all_variants_pop_cat)) {
  current_pop_all_variants <- as.data.frame(cbind(ID=names(all_variants_pop_cat[id]),tot_variants=all_variants_pop_cat[id]))
  all_pop_all_variants <- rbind(all_pop_all_variants,current_pop_all_variants)
}

rownames(all_pop_all_variants) <- NULL
all_pop_all_variants$tot_variants <- as.numeric(as.character(all_pop_all_variants$tot_variants))/46

all_pop_all_cat_hom$tot_variants <- 0
for (cohort in all_pop_all_variants$ID){
  all_pop_all_cat_hom[all_pop_all_cat_hom$cohort == cohort,]$tot_variants <- all_pop_all_variants[all_pop_all_variants$ID == cohort,]$tot_variants
}

all_pop_all_cat_hom$HDAC_shared <- all_pop_all_cat_hom$HOM_SUM/all_pop_all_cat_hom$tot_variants
all_pop_all_cat_hom$HDAC_cat <- all_pop_all_cat_hom$HOM_SUM/all_pop_all_cat_hom$pop_cat_shared

all_pop_all_cat_hom_merged <- merge(all_pop_all_cat_hom,all_pop_all_variants_all_hom,by="ID")

all_pop_all_cat_hom_merged$HDAC_ALL_cat <- all_pop_all_cat_hom$HOM_SUM/all_pop_all_cat_hom$ALL_HOM_SUM
all_pop_all_cat_hom_merged$ALL_CAT_HOM_SUM <- as.numeric(as.character(all_pop_all_cat_hom_merged$ALL_CAT_HOM_SUM))
all_pop_all_cat_hom_merged$HDAC_ALL_cat_sum <- all_pop_all_cat_hom_merged$HOM_SUM/all_pop_all_cat_hom_merged$ALL_CAT_HOM_SUM
all_pop_all_cat_hom_merged$HDAC_ALL_cat_sum <- all_pop_all_cat_hom_merged$HOM_SUM/all_pop_all_cat_hom_merged$ALL_CAT_HOM_SUM
#I need to dived by the number of TOTAL DERIVED SITES IN THAT CATEGORY, or BY the number of TOTAL HOM SITES IN THAT CATEGORY
all_pop_all_cat_hom_merged_persample <- merge(all_pop_all_cat_hom_merged,all_pop_all_variants_all_hom_persample,by="ID")
all_pop_all_cat_hom_merged_persample$ALL_CAT_HOM_SUM.y <- as.numeric(as.character(all_pop_all_cat_hom_merged_persample$ALL_CAT_HOM_SUM.y))
all_pop_all_cat_hom_merged_persample$HDAC_ALL_cat_sum_persample <- all_pop_all_cat_hom_merged_persample$HOM_SUM/all_pop_all_cat_hom_merged_persample$ALL_CAT_HOM_SUM.y


source("/nfs/users/nfs_m/mc14/Work/r_scripts/col_pop.r")
require(ggplot2)
require(reshape2)

all_cols <-col_pop(all_pops)
# test_sample <- all_pop_all_cat[all_pop_all_cat$ID == "EGAN00001061979"]
# test_sample_miss <- test_sample[test_sample$category== "Missense",]
# test_sample_neut <- test_sample[test_sample$category== "Neutral",]
# test_sample_syn <- test_sample[test_sample$category== "Synonymous",]

# pop_sample <- all_pop_all_cat[all_pop_all_cat$cohort == "CARL" & all_pop_all_cat$category == "Neutral" ,]

# sum(test_sample_miss$HOM_DA_COUNT)
# sum(test_sample_neut$HOM_DA_COUNT)
# sum(test_sample_syn$HOM_DA_COUNT)

#first plot
# pl <- ggplot(all_pop_all_cat)
pl <- ggplot(all_pop_all_cat)
pl <- pl + geom_boxplot()
pl <- pl + aes(x = cohort, y = DAC_SUM, fill=cohort)
pl <- pl + ylab("Counts")
pl <- pl + ggtitle("Derived allele counts")
pl <- pl + xlab("")
pl <- pl + scale_fill_manual("", values=all_cols,guide=FALSE)
pl <- pl + theme_bw()
pl <- pl + facet_grid(category~.,scales="free")
pl <- pl + theme_bw()
pl <- pl + theme(axis.text.x=element_text(size = rel(1.2)))
pl <- pl + theme(axis.text.y=element_text(size = rel(1.2)))
pl <- pl + theme(axis.title= element_text(size=rel(1.2)))
pl <- pl + theme(legend.text= element_text(size = rel(1.2)), legend.title = element_text(size = rel(1.2)))
# ggsave(filename=paste(base_folder,"/figure4bRev.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
# ggsave(filename=paste(base_folder,"/figure4bRev_ALT.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
ggsave(filename=paste(base_folder,"/figure4bRev_filt.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)

#second plot
# pl <- ggplot(all_pop_all_cat_hom_merged)
pl <- ggplot(all_pop_all_cat_hom_merged_persample)
pl <- pl + geom_boxplot()
pl <- pl + aes(x = cohort, y = HDAC_ALL_cat_sum_persample,fill=cohort)
# pl <- pl + aes(x = cohort, y = HDAC_ALL_cat,fill=cohort)
# pl <- pl + aes(x = cohort, y = HDAC_shared,fill=cohort)
pl <- pl + ylab("Fraction (HOM_sites per sample/sum of sites shared in population)")
pl <- pl + ggtitle("Derived homozygous genotypes")
pl <- pl + xlab("")
pl <- pl + scale_fill_manual("", values=all_cols,guide=FALSE)
pl <- pl + theme_bw()
pl <- pl + facet_grid(category~.,scales="free")
pl <- pl + theme_bw()
pl <- pl + theme(axis.text.x=element_text(size = rel(1.2)))
pl <- pl + theme(axis.text.y=element_text(size = rel(1.2)))
pl <- pl + theme(axis.title= element_text(size=rel(1.2)))
pl <- pl + theme(legend.text= element_text(size = rel(1.2)), legend.title = element_text(size = rel(1.2)))
# ggsave(filename=paste(base_folder,"/figure4aRev.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
# ggsave(filename=paste(base_folder,"/figure4aRev_ALT.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
# ggsave(filename=paste(base_folder,"/figure4aRev_filt.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
ggsave(filename=paste(base_folder,"/figure4aRev_filt_persample.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)

#second plot
pl <- ggplot(all_pop_all_cat_hom)
pl <- pl + geom_boxplot()
pl <- pl + aes(x = cohort, y = HDAC_shared,fill=cohort)
pl <- pl + ylab("Fraction (HOM_sites per sample/sum of sites shared in population)")
pl <- pl + ggtitle("Derived homozygous genotypes")
pl <- pl + xlab("")
pl <- pl + scale_fill_manual("", values=all_cols,guide=FALSE)
pl <- pl + theme_bw()
pl <- pl + facet_grid(category~.,scales="free")
pl <- pl + theme_bw()
pl <- pl + theme(axis.text.x=element_text(size = rel(1.2)))
pl <- pl + theme(axis.text.y=element_text(size = rel(1.2)))
pl <- pl + theme(axis.title= element_text(size=rel(1.2)))
pl <- pl + theme(legend.text= element_text(size = rel(1.2)), legend.title = element_text(size = rel(1.2)))
# ggsave(filename=paste(base_folder,"/figure4aRev.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
# ggsave(filename=paste(base_folder,"/figure4aRev_ALT.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
ggsave(filename=paste(base_folder,"/figure4a2Rev_filt.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)

#third plot
pl <- ggplot(all_pop_all_cat_hom)
pl <- pl + geom_boxplot()
pl <- pl + aes(x = cohort, y = HDAC_cat,fill=cohort)
pl <- pl + ylab("Fraction (HOM_sites per sample/sum of sites shared in a category)")
pl <- pl + ggtitle("Derived homozygous genotypes")
pl <- pl + xlab("")
pl <- pl + scale_fill_manual("", values=all_cols,guide=FALSE)
pl <- pl + theme_bw()
pl <- pl + facet_grid(category~.,scales="free")
pl <- pl + theme_bw()
pl <- pl + theme(axis.text.x=element_text(size = rel(1.2)))
pl <- pl + theme(axis.text.y=element_text(size = rel(1.2)))
pl <- pl + theme(axis.title= element_text(size=rel(1.2)))
pl <- pl + theme(legend.text= element_text(size = rel(1.2)), legend.title = element_text(size = rel(1.2)))
# ggsave(filename=paste(base_folder,"/figure4cRev.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)
ggsave(filename=paste(base_folder,"/figure4cRev_filt.jpeg",sep=""),width=12, height=7,dpi=300,plot=pl)



#################################################
#FROM ENZA
#test for differences 
#myd=read.table("figure4_raw.data", header=T, sep=",") 
myd=read.table("figure4_formatted.data.nona", header=T, sep=",") 

myd$pop=factor(myd$pop, levels=c("CAR","VBI", "FVG-E", "FVG-I", "FVG-R", "FVG-S","CEU","TSI") )
myd$type=factor(myd$type , levels= c("loss of function", "missense", "synonymous") )

########################### 4a counts 

png("figure4aRev.png", width=700 ,height=700) 
ggplot(myd) +geom_boxplot(aes(pop, dercount), fill=c("#F54E4E", "#CA8A1A" , "#10DFBC",  "#48867F", "#16C224", "#00631F"
  , "#619FE0", "#13256F") ) +
facet_grid(type ~ . , scale="free_y" ) + theme_bw()+ylab("Counts of derived allele/individual ")+ xlab("")+
 theme (axis.text=element_text(size = 16),
  axis.title =element_text(size = 18), 
  legend.title=element_text(size = 18),
  legend.text=element_text(size = 16),
  strip.text.x = element_text(size=12) ) 
 +theme(strip.text.x = element_text(size=8), strip.text.y = element_text(size=12, face="bold"))

dev.off()

source("/nfs/users/nfs_m/mc14/Work/r_scripts/col_pop.r")
require(ggplot2)
require(reshape2)
all_pops <- c("CAR","VBI", "FVG-E", "FVG-I", "FVG-R", "FVG-S","CEU","TSI")
all_cols <-col_pop(all_pops)
base_folder <- getwd()

pl <- ggplot(myd)
pl <- pl + geom_boxplot()
pl <- pl + aes(x = pop, y = dercount,fill=pop)
pl <- pl + ylab("Counts of derived allele/individual ")
pl <- pl + xlab("")
pl <- pl + scale_fill_manual("", values=all_cols,guide=FALSE)
pl <- pl + theme_bw()
pl <- pl + facet_grid(type~.,scales="free")
pl <- pl + theme_bw()
pl <- pl + theme(axis.text.x=element_text(size = 16))
pl <- pl + theme(axis.text.y=element_text(size = 18))
pl <- pl + theme(axis.title= element_text(size=16))
pl <- pl + theme(legend.text= element_text(size = rel(1.6)), legend.title = element_text(size = rel(1.6)))
pl <- pl + theme(strip.text.x = element_text(size=8), strip.text.y = element_text(size=12, face="bold"))
ggsave(filename=paste(base_folder,"/figure4aRev.jpeg",sep=""),width=8, height=10,dpi=400,plot=pl)


mypops=levels(myd$pop) 
 for ( ref in c("TSI", "CEU") )  {
 for ( t in levels(myd$type)  ) {
for (p in levels(myd$pop) ) { 
mydsp=subset(myd, pop==p  & type==t)
 mydsref=subset(myd, pop==ref & type==t)
 a=mydsp$dercount
 b=mydsref$dercount
 myp=(format(wilcox.test(a,b)$p.val, scientific=FALSE, digits=3) )
 print(paste ("dercount", t,p, ref,  myp, sep=" " ))
}
}
}


##################################################### 4b frac tions 

# png("figure4bRev.png", width=700 ,height=700) 
# ggplot(myd) +geom_boxplot(aes(pop,derhomgen/inter_derhomgen ),
#  fill=c("#F54E4E", "#CA8A1A" , "#10DFBC",  "#48867F", "#16C224", "#00631F", "#619FE0", "#13256F")) 
# +facet_grid(type ~ . , scale="free_y" )
#  + theme_bw()+ylab("# derived homozygous genotypes/# intergenic derived homozygous genotypes")+
#  xlab("")+ 
#  theme (axis.text=element_text(size = 16), axis.title =element_text(size = 18), legend.title=element_text(size = 18),legend.text=element_text(size = 16), strip.text.x = element_text(size=12) )+theme(strip.text.x = element_text(size=8), strip.text.y = element_text(size=12, face="bold"))
# dev.off()

pl <- ggplot(myd)
pl <- pl + geom_boxplot()
pl <- pl + aes(x = pop, y = derhomgen/inter_derhomgen,fill=pop)
pl <- pl + ylab("# derived homozygous genotypes/# intergenic derived homozygous genotypes")
pl <- pl + xlab("")
pl <- pl + scale_fill_manual("", values=all_cols,guide=FALSE)
pl <- pl + theme_bw()
pl <- pl + facet_grid(type~.,scales="free")
pl <- pl + theme_bw()
pl <- pl + theme(axis.text.x=element_text(size = 16))
pl <- pl + theme(axis.text.y=element_text(size = 18))
pl <- pl + theme(axis.title= element_text(size=16))
pl <- pl + theme(legend.text= element_text(size = rel(1.2)), legend.title = element_text(size = rel(1.2)))
pl <- pl + theme(strip.text.x = element_text(size=8), strip.text.y = element_text(size=12, face="bold"))
ggsave(filename=paste(base_folder,"/figure4bRev.jpeg",sep=""),width=8, height=10,dpi=400,plot=pl)

mypops=levels(myd$pop) 
 for ( ref in c("TSI", "CEU") )  {
 for ( t in levels(myd$type)  ) {
for (p in levels(myd$pop) ) { 
mydsp=subset(myd, pop==p  & type==t)
 mydsref=subset(myd, pop==ref & type==t)
 a=mydsp$derhomgen/mydsp$inter_derhomgen
 b=mydsref$derhomgen/mydsref$inter_derhomgen
 myp=(format(wilcox.test(a,b)$p.val, scientific=FALSE, digits=3) )
 print(paste ("derhomgen", t,p, ref,  myp, sep=" " ))
}
}
}

