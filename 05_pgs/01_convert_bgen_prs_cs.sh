#!/bin/sh
#$ -cwd
#$ -q single15.q
#$ -S /bin/bash 
#$ -e /data/clusterfs/lag/users/jitame/logs/
#$ -o /data/clusterfs/lag/users/jitame/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -m beas

### USAGE ###

usage()
{
   echo -e "\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   echo "PRS-CS preparataion"
   echo " "
   echo "The script takes as input a (chromosome-specific) bgen binary fileset(s), a snp-list and subject list and outputs PLINK-format (.bed, .bim .fam) and applies filtering steps to select variants to use as input in REGENIE step 1."
   echo "Filtering includes , MAF < 0.01, HWE p-value < 1e-7 and genotype missingness > 0.05 and imputation quality < 0.7."
   echo " "
   echo "Usage: bash /home/jitame/bin/code/FLICA_language/05_pgs/01_convert_bgen_prs_cs.sh -c chromosome_number"
   echo -e "\t-c chromosome number"
   echo " "
   echo "-- Cluster use (single15.q) --"
   echo "When running the script on the cluster (through gridmaster), you might want to provide specific qsub arguments, such as the location where a standard"
   echo "log file is stored, or the email address to which a message should be sent when the script is finished."
   echo "In this case, provide the qsub arguments before the script name, and the arguments specific to the script after the script name:"
   echo "qsub -e /dir/where/err/is/saved -o /dir/where/log/is/saved convert_bgen_prs_cs.sh -c chromosome_number"
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


###  SPECIFY PATHS ###

Software_plink=/home/jitame/bin/software/plink2_221024
base_path=/data/clusterfs/lag/users/jitame/FLICA
outdir=${base_path}/geno/pgs/in

mkdir -p ${outdir}
cd ${outdir}

### Run plink2

${Software_plink}/plink2 \
--bgen ${base_path}/geno/regenie/st2_in_gwas/FLICA_32k_st2_chr${chr}.bgen 'ref-first' \
--sample ${base_path}/geno/regenie/st2_in_gwas/FLICA_32k_st2_chr${chr}.sample \
--extract ${base_path}/geno/regenie/st2_in_gwas/FLICA_32k_st2_chr${chr}.snpstats_mfi_hrc.compact.snps2keep \
--keep ${base_path}/pheno/subs_list_FID_IID_N32677.txt \
--make-bed \
--out ${outdir}/prscs_FLICA_in_c${chr}

