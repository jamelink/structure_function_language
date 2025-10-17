#!/bin/sh
#$ -cwd
#$ -q multi15.q
#$ -S /bin/bash 
#$ -e /data/clusterfs/lag/users/jitame/logs/
#$ -o /data/clusterfs/lag/users/jitame/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -N flica_1_gwas_50c
#$ -m beas

#qsub /home/jitame/bin/code/FLICA_language/04_regenie/02_gwas/regenie_step_1_gwas.sh

# Store current date and time in variable and start time of the script
now=$( date )
start=`date +%s`
echo "Start at ${start}" 


#define paths, edit this
base=/data/clusterfs/lag/users/jitame/FLICA
base_reg=${base}/geno/regenie/
in_path=$base_reg/step_1/st1_in
out_path=$base_reg/step_1/st1_out
#pheno_file=$base/pheno/rs_ics_32k_gcta_N32677.tsv
pheno_file=$base/pheno/rs_50c_32k_gcta_N32677.tsv

mkdir -p $out_path/temp
cd $out_path/temp

echo "Run regenie for $pheno_file" 

#load + run regenie
#module load regenie/3.2.1
module load regenie/3.6.0

regenie \
--step 1 \
--bed $in_path/FLICA_32k_merged_regenie_step1 \
--covarFile $base/pheno/regenie_final_covs_32k.tsv \
--catCovarList "Genetic_sex,geno_array_dummy,exome_dummy,site_dummy_11025,site_dummy_11026,site_dummy_11027" \
--phenoFile $pheno_file \
--bsize 1000 \
--threads 4 \
--apply-rint \
--lowmem \
--lowmem-prefix temp \
--out $out_path/flica_st1_gwas_repl_50c_

### Creating tar

#out_file=$base/step_1_sent_all.tar.gz
#cd $out_path
#tar cfz $out_file *.loco


# Store current date and time in variable and calculate the runtime
now=$( date )
checkpoint=`date +%s`
runtime=$(((checkpoint-start)/60))
printf "\n Elapsed time is "${runtime}" minutes.\n\n"