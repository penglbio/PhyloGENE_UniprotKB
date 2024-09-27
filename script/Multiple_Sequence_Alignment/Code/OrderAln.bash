#!/bin/bash
#SBATCH --job-name=MSA
#SBATCH --output=TestJob.out
#SBATCH --array=1-35
#SBATCH --cpus-per-task=6

#SBATCH -o %j.out               # File to which standard output will be written
#SBATCH -e %j.err               # File to which standard error will be written

source ~/.bash_profile
# Define the code path
code=/work/users/zhangy24/INTS_Project/Multiple_Sequence_Alignment/Code
fasta=/work/users/zhangy24/INTS_Project/Multiple_Sequence_Alignment/Fasta
alignment=$fasta/Alignment
# get config file
config=/work/users/zhangy24/INTS_Project/Multiple_Sequence_Alignment/Code/config.txt
sample=$(awk -v ArrayTaskID=${SLURM_ARRAY_TASK_ID} '$1==ArrayTaskID {print $2}' $config)
echo "This is array task ${SLURM_ARRAY_TASK_ID}, the sample name is ${sample}"

# Step1: Run clustalw to get the alignment file in phylip format
bash $code/TreeBuild_from_fasta.bash $fasta/${sample}.fasta
# Move the phylip alignment format into Alignment folder
mv $fasta/${sample}.aln $alignment/
# Remove the .dnd and .aln file, because these files are not used in this project  
rm -rf $fasta/*.phy $fasta/*.dnd

# Step2: Convert .aln file to fasta file format 
any2fasta $alignment/${sample}.aln > $alignment/${sample}.fa

# Step3: Convert the aligned fasta file to phylip format
seqkit seq $alignment/${sample}.fa -s -w 0 > $alignment/${sample}_seq.txt
seqkit seq $alignment/${sample}.fa -n -i > $alignment/${sample}_header.txt
paste $alignment/${sample}_header.txt $alignment/${sample}_seq.txt > $alignment/${sample}_new.fasta
rm -rf $alignment/${sample}.aln $alignment/${sample}.fa $alignment/${sample}_header.txt $alignment/${sample}_seq.txt

# Step4: Reorder the sequence of multiple sequence alignment
Rscript $code/sort.R $alignment/${sample}_new.fasta $fasta/${sample}.txt $alignment/${sample}_changedID.phy
# Step5: Convert the phylip file to clustaw file format
seqconverter --informat phylip --outformat clustal --width 70 -i $alignment/${sample}_changedID.phy > $alignment/${sample}_changedID.aln

# Step6: Remove unrelated files
rm -rf $alignment/${sample}_changedID.phy $alignment/${sample}_new.fasta

# End of script

<< 'MULTILINE-COMMENT'
any2fasta CCNT1.aln > CCNT1.fa
seqkit seq CCNT1.fa -s -w 0 > b.txt
MULTILINE-COMMENT






