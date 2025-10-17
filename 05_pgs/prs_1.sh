#!/bin/sh
#$ -q single15.q
#$ -S /bin/bash
#$ -e /home/jitame/bin/logs/
#$ -o /home/jitame/bin/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -m beas
#written by Jitse S. Amelink
#last update 20250113

#get options
while getopts "htc:f:o:n:c"  opt
do
   case "$opt" in
      f ) sst="$OPTARG" ;;
      o)  outp="$OPTARG" ;;
      n) n="$OPTARG" ;;
      c) chrom="$OPTARG" ;;
   esac
done

# Store current date and time in variable and start time of the script
now=$( date )
start=`date +%s`
echo "Start at ${start}" 
echo "Estimate effect sizes using PRScs for pheno ${sst} and chromosome ${c}" 

#python_path="/home/jitame/bin/envs/std_work_env/bin/python"
base_dir=/data/clusterfs/lag/users/jitame/FLICA

N_THREADS=6

export MKL_NUM_THREADS=$N_THREADS
export NUMEXPR_NUM_THREADS=$N_THREADS
export OMP_NUM_THREADS=$N_THREADS

cd /home/jitame/bin/software/PRScs/
python PRScs.py \
--ref_dir=${base_dir}/geno/prs_ref/ldblk_1kg_eur --bim_prefix=$base_dir/geno/pgs/in/prscs_FLICA_in_c${chrom} \
--sst_file=${sst} --n_gwas=$n --out_dir=${outp} --chrom=$chrom --phi=1e-2 --seed=2025

#
# Store current date and time in variable and calculate the runtime
now=$( date )
checkpoint=`date +%s`
runtime=$(((checkpoint-start)/60))
printf "\n Elapsed time is "${runtime}" minutes.\n\n"