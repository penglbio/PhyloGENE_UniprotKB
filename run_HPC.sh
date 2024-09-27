## run on HPC ##
nohup /work/users/pengl24/miniconda3/envs/snakemake/bin/snakemake --executor cluster-generic --cluster-generic-submit-cmd "sbatch -p bioinfo -J blastp --get-user-env -c 4" -c 4 -j 100 -p --latency-wait 3600 >> nohup.log 2>&1 &
