Instruction:

This series of script is used to manipulate the multiple sequence alignment file. 
In general, the output of  clustalw will change the sequence order of the input fasta file by the program itself.
When we need to find the consevered motifs of the multiple sequence alignments using some species (human and mouse),
we need to reorder the sequences.

# Prepare the input files:

First, you need to prepare the fasta files which contains the sequences you want to align, the sequences may be downloaded
form Uniprot or NCBI databases, for example the INTS1.fasta file below. 
Second, you also need to give the order of the protein IDs in a separate file, for example the INTS1.txt.
Thirdly, to process tens or hunderds of alignment files, you'd better use slurm job arrays. To do job arrays you need a config 
file, each line in the file is the file name.

# Demo format of input files
INTS1.fasta:
>tr|A0A9Q0LB58|A0A9Q0LB58_ANAIG Uncharacterized protein OS=Anaeramoeba ignava OX=1746090 GN=M0811_02229 PE=4 SV=1
MQYYQQQNQKKNQQQQKEIENSIIFTAFQKAFLNEDKERIISLFKECFIFLQQEKPDKTI
FIVLLFLNQKFFKFFLNEEIVQMFINLFYSKSSILPLLACQILNRTFYNTFEWPESFVYA
>tr|M4BYZ8|M4BYZ8_HYAAE Integrator complex subunit 1 RPB2-binding domain-containing protein OS=Hyaloperonospora arabidopsidis 
MNDANEDDDDRGERSDVKVTTASASASDAGTNGDETPGQHFRGALCEATTESKMMEVLME
ACSRLLREGKSPSRLLSVGLLSAVKEDPKRFEQPAILKYLLRLLRSKHYIGKKDLLDLGN
>tr|D0MUN1|D0MUN1_PHYIT Integrator complex subunit, putative OS=Phytophthora infestans (strain T30-4) OX=403677 GN=PITG_02016 
MKRGRVATRGSTRRALRRKNVVMDEEDEEEAADASQGEEEEDEDEADEEEEQKTPPPKLT
RAQAKKREAEANKNKKSAQKKSKKVKTEVEEEDAEAEAEEEEGDEDDDDEEEADTEERRR
......

INTS1.txt:
Q8N201
A0AAA9TV32
K3W4P2
F7GD11
......

config.txt:
ArrayTaskID     SampleName
1       CCNT1
2       CCNT2
3       CDK7
4       CDK8
5       CDK9
......

# How to use these scripts
sbatch OrderAln.bash

# Now you can wait for the result.
















