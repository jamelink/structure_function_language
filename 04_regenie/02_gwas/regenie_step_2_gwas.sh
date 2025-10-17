#!/bin/sh
#$ -cwd
#$ -q single15.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs/
#$ -o /home/jitame/bin/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -m beas

usage()
{
   echo -e "\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

   echo "Script for runninng regenie step 2 on local GWAS data"
   echo " "
   echo " "
   echo "Usage: bash /home/jitame/bin/code/FLICA_language/04_regenie/02_gwas/regenie_step_2_gwas.sh -c <chrom_number>"
   echo -e "\t-c chromosome number - REQUIRED "
   echo " "
   echo "-- Cluster use (single15.q) --"
   echo "When running the script on the cluster (through gridmaster), you might want to provide specific qsub arguments, such as the location where a standard"
   echo "log file is stored, or the email address to which a message should be sent when the script is finished."
   echo "In this case, provide the qsub arguments before the script name, and the arguments specific to the script after the script name:"
   echo "qsub -N regenie_step2_sent regenie_step2_sent.sh -c <chrom_number>"
   echo -e "------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n"
   exit 1 # Exit script after printing usage
}

### EVALUATE SOFTWARE AND SET INPUT ###

while getopts "c:" opt
do
   case "$opt" in
	 c ) chr="$OPTARG" ;;
	 ? ) usage ;; # Print usage in case parameter is non-existent
   esac
done

# Store current date and time in variable and start time of the script
now=$( date )
start=`date +%s`
echo "Start at ${start}" 

#define paths
base=/data/clusterfs/lag/users/jitame/FLICA
pred_path=$base/geno/regenie/step_1/st1_out
in_path=$base/geno/regenie/st2_in_gwas
out_path=$base/geno/regenie/st2_out_gwas_50c/c${chr}

#Set up path and move to path
mkdir -p $out_path 
cd $out_path

#create list
awk -F " " '{print $2 }' $in_path/FLICA_32k_st2_chr${chr}.snpstats_mfi_hrc.compact.snps2keep > $in_path/FLICA_32k_st2_chr${chr}.snplist

#load + run regenie
module load regenie/3.6.0

regenie \
--step 2 \
--bgen $in_path/FLICA_32k_st2_chr${chr}.bgen \
--sample $in_path/FLICA_32k_st2_chr${chr}.sample \
--covarFile $base/pheno/regenie_final_covs_32k.tsv \
--phenoFile $base/pheno/rs_50c_32k_gcta_N32677.tsv \
--pred $pred_path/flica_st1_gwas_repl_50c__pred.list \
--keep $base/pheno/subs_list_FID_IID_N32677.txt  \
--extract $in_path/FLICA_32k_st2_chr${chr}.snplist \
--catCovarList "Genetic_sex,geno_array_dummy,exome_dummy,site_dummy_11025,site_dummy_11026,site_dummy_11027" \
--minMAC 266 \
--bsize 500 \
--threads 4 \
--apply-rint \
--ref-first \
--verbose \
--lowmem \
--lowmem-prefix temp \
--out $out_path/FLICA_32k_gwas_c${chr}


#--pred $pred_path/flica_st1_gwas__pred.list \ #UPDATE (!!) flica_st1_gwas_repl_50c__pred.list
#--phenoFile $base/pheno/rs_ics_32k_gcta_N32677.tsv \

# Store current date and time in variable and calculate the runtime
now=$( date )
checkpoint=`date +%s`
runtime=$(((checkpoint-start)/60))
printf "\n Elapsed time is "${runtime}" minutes.\n\n"