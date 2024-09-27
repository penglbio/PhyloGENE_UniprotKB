configfile: "config.yaml"

rule all:
	input:
		expand('1.Blastp_result/{sample}_blastp.tsv',sample=config['samples']),
		expand('2.Annotation/{sample}_notion.tsv',sample=config['samples']),
		expand('2.Annotation/{sample}_add_notion.tsv',sample=config['samples']),
		expand('2.Annotation/{sample}_notion_taxid.tsv',sample=config['samples']),
		expand('3.Filter/{sample}_IDuniq.tsv',sample=config['samples']),
		expand('4.Domain_ANN/{sample}_ANN.tsv',sample=config['samples']),
		expand('4.Domain_ANN/{sample}_tmp_Ann.tsv',sample=config['samples']),
		expand('4.Domain_ANN/{sample}_up5000_map_ANN.tsv',sample=config['samples']),
		expand('5.Simple/{sample}_all_simple.tsv',sample=config['samples']),
		expand('5.Simple/{sample}_all_clean.tsv',sample=config['samples']),
		expand('5.Simple/{sample}_all_simple.tsv',sample=config['samples']),
		expand('5.Simple/{sample}_up5k_simple.tsv',sample=config['samples']),
		expand('5.Simple/{sample}_all_clean.tsv',sample=config['samples']),
		expand('5.Simple/{sample}_up5k_clean.tsv',sample=config['samples']),
		expand('6.Final/Factors_merge_out_up5k.tsv'),
		expand('6.Final/Factors_merge_out_up5k.xlsx'),
		expand('6.Final/Factors_merge_out.tsv'),
		expand('6.Final/Factors_merge_out.xlsx'),
#		expand('7.select_ID/Select_result.xlsx'),
#		expand('7.select_ID/Select_tree_factor.tsv'),
#		expand('7.select_ID/Select_tree_factor.xlsx'),
#		expand('7.select_ID/all_tree_factor.tsv'),
#		expand('7.select_ID/all_tree_factor.xlsx'),
#		expand('hand_sel/species_name.tsv'),
#		expand('10.RPB1_check/CTD_check.tsv'),
#		expand('11.MultiAlign/{sel_sample}_checked.tsv',sel_sample=config['sel_samples']),
#		expand('11.MultiAlign/{sel_sample}_checked.fasta',sel_sample=config['sel_samples']),
#		expand('11.MultiAlign/{sel_sample}_checked.pdf',sel_sample=config['sel_samples'])

rule blastp:
	input:
		config['path']+'/{sample}.fasta'
	output:
		'1.Blastp_result/{sample}_blastp.tsv'
	params:
		conda=config['conda_path'],
		uniprotKB=config['uniprotKB']
	shell:
		'{params.conda}/blastp -db {params.uniprotKB} -query {input} -outfmt 6 -evalue 0.1 -num_threads 4 -max_target_seqs 200000 > {output}'

rule add_notion:
	input:
		'1.Blastp_result/{sample}_blastp.tsv'
	output:
		o1='2.Annotation/{sample}_notion.tsv',
		o2='2.Annotation/{sample}_add_notion.tsv'
	params:
		uniprotkb_name=config['uniprotkb_name']
	shell:
		'csvtk grep -tlH -P <(csvtk cut -tH -f 2 {input}) {params.uniprotkb_name} >{output.o1};csvtk join -tlH -f "2;1"  {input} {output.o1}>{output.o2}'

rule add_taxid:
	input: '2.Annotation/{sample}_add_notion.tsv'
	output:
		'2.Annotation/{sample}_notion_taxid.tsv'
	params:
		conda=config['conda_path'],
	shell:
		'csvtk mutate -tHl  -f 13  -p "OX=([0-9]+)" {input} |csvtk cut -t -H -f 14|{params.conda}/taxonkit lineage |paste {input} - >{output}'

rule Filter_ID:
	input:
		'2.Annotation/{sample}_notion_taxid.tsv'
	output:
		'3.Filter/{sample}_IDuniq.tsv'
	shell:
		'csvtk sort -tHl  -k 11:n -k12:nr {input} |csvtk -tH uniq -f 2|csvtk filter -tHl -f "11<=1e-10" >{output}'	
rule Add_ANN:
	input:
		'3.Filter/{sample}_IDuniq.tsv'
	output:
		o1='4.Domain_ANN/{sample}_tmp_Ann.tsv',
		o2='4.Domain_ANN/{sample}_ANN.tsv'
	params:
		uniprot_Ann=config['Uniprot_Ann']
	shell:
		'csvtk -tHl mutate --at 1 -f 2 -p ".+\|(.+)\|.+" {input} | csvtk -tHl cut -f 1|csvtk grep -tHl -f 1 -P -  {params.uniprot_Ann} >{output.o1};csvtk -tHl mutate --at 1 -f 2 -p ".+\|(.+)\|.+" {input}| csvtk join -tHl -f "1;1" -  {output.o1} >{output.o2}'

rule Filter_Species5k:
	input:
		'4.Domain_ANN/{sample}_ANN.tsv'
	output:
		'4.Domain_ANN/{sample}_up5000_map_ANN.tsv'
	params:
		uniprot_taxid_up5000=config['Uniprot_taxid_up5000']
	shell:
		'csvtk join -tHl -f "15;1" {input} {params.uniprot_taxid_up5000} |csvtk cut -tHl -f 1-14,23,15-22 >{output}'	


rule simple_file_all:
	input:
		'4.Domain_ANN/{sample}_ANN.tsv'
	output:
		'5.Simple/{sample}_all_simple.tsv',
	shell:
		'paste <(csvtk -tHl cut -f 15,16 {input}) <(csvtk -tHl cut -f 1,12,13,14,17-22 {input} -D ";"|sed "s/\\"//g") >{output}'


rule clean_file_all:
	input:
		'5.Simple/{sample}_all_simple.tsv',
	output:
		'5.Simple/{sample}_all_clean.tsv'
	shell:
		'csvtk summary -tHl -g 1,2 -f 3:collapse {input} -s "|---|">{output}'


rule simple_file:
	input:
		'4.Domain_ANN/{sample}_up5000_map_ANN.tsv'
	output:
		'5.Simple/{sample}_up5k_simple.tsv',
	shell:
		'paste <(csvtk -tHl cut -f 16,15,17 {input}) <(csvtk -tHl cut -f 1,12,13,14,18-23 {input} -D ";"|sed "s/\\"//g") >{output}'

rule clean_file:
	input:
		'5.Simple/{sample}_up5k_simple.tsv',
	output:
		'5.Simple/{sample}_up5k_clean.tsv'
	shell:
		'csvtk summary -tHl -g 1,2,3 -f 4:collapse {input} -s "|---|">{output}'

rule merge_all:
	input:
		['5.Simple/{sample}_all_clean.tsv'.format(sample=x) for x in config['samples']]
	output:
		o1='6.Final/Factors_merge_out.tsv',
		o2='6.Final/Factors_merge_out.xlsx'
	shell:
		'sh script/merge.sh  {input} {output.o1};csvtk csv2xlsx -tHl {output.o1} -o {output.o2}'

rule merge_5k:
	input:
		['5.Simple/{sample}_up5k_clean.tsv'.format(sample=x) for x in config['samples']]
	output:
		o1='6.Final/Factors_merge_out_up5k.tsv',
		o2='6.Final/Factors_merge_out_up5k.xlsx'
	params:
		uniprot_taxid_up5000=config['Uniprot_taxid_up5000']
	shell:
		'sh script/merge_5k.sh {params.uniprot_taxid_up5000} {input} {output.o1};csvtk csv2xlsx -tHl {output.o1} -o {output.o2}'
