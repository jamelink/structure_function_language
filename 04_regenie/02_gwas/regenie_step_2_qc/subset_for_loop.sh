#!/bin/sh
#$ -S /bin/bash
#$ -cwd
#$ -m eas
#$ -N subset_snpstats
#$ -q single15.q


for c in {1..18}; do
qsub -N "subset_40k_c${c}" /home/jitame/bin/code/FLICA_language/04_regenie/02_gwas/regenie_step_2_qc/imaging40k_subset_and_snpstats.sh -c ${c}
done

#/home/jitame/bin/code/AICHA/genetics/regenie/gwas/imaging40k_subset_and_snpstats.sh \
#-s /home/jitame/bin/code/AICHA/genetics/regenie/gwas/imaging40k_subset_and_snpstats_config.txt 

for c in {1..22}; do
qsub -N "variant_qc_40k_c${c}"  /home/jitame/bin/code/FLICA_language/04_regenie/02_gwas/regenie_step_2_qc/variant_qc_wrapper.sh -c ${c}
done

for c in {1..22}; do
qsub -N "FLICA_26k_GWAS_c${c}" /home/jitame/bin/code/FLICA_language/04_regenie/02_gwas/regenie_step_2_gwas.sh -c ${c}
done