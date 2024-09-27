# Phylogenetics
This is a Pipeline for protein evolution analysis. In order to determine the evolutionary status of genes of interest across all species in the biological world, we have developed this process. This process utilizes all protein information from the UniProt database, and through comparison, annotation, filtering, and selection, it ultimately integrates the data into a diagram.

# PhyloGene Workflow Tutorial

### 1. Make project directory
```
# the project directory contains specific GROUP name and current DATE
GROUP=XXX
DATE=`date +"%Y%m%d"`
mkdir ~/Project/${GROUP}_${DATE}
```

### 2. Clone the repository
```
cd ~/Project/${GROUP}_${DATE}
git clone https://github.com/penglbio/PhyloGene_UniprotKB
cd PhyloGene_UniprotKB
```

### 3. Copy/Download the raw data
```
#prepare interested genes with fasta format. for example INTS3.fasta, then store the file in a fasta directory
mkdir fasta
vi INTS3.fasta
#copy the fasta format file to INTS3.fasta file,and save
cd ..
```


### 4. Create *config.yaml* and *Snakefile* based on the examples
```
# edit config.yaml and design_table.tsv
##change config.yaml the data path,samples,sel_sample and so on....

```
### 5. Dry run the workflow to check any mistakes
```
./dry_run.sh
```

### 6. Run the workflow
```
# if you are working on the HPC
./run_HPC.sh

# check the workflow progress in nohup.out file
tail nohup.log 

# check the jobs on HPC
qstat

# if you get the error: Directory cannot be locked.
snakemake --unlock 
```

### 7. Remove the temporary files
```
./clean.sh
```


