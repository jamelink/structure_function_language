#!/bin/sh

base_dir=/data/clusterfs/lag/users/jitame/FLICA
wrapper=/home/jitame/bin/code/FLICA_language/03_GCTA/01_run_heritability.sh

mkdir -p $base_dir/geno/gcta/
for i in {1..2}; do
  out_hsq="$base_dir/geno/gcta/flica_32k_new2_${i}.hsq"
  if [ -f ${out_hsq} ]; then
  echo "${out_hsq} exists"
  else
  echo "${out_hsq} does not exist"
qsub -q multi15.q -p -50 -N gcta_32k_${i} $wrapper -f $base_dir/pheno/rs_ics_32k_gcta_resid_norm_N32661.tsv -n $i -c $base_dir/geno/gcta/flica_32k_new2_${i}
  fi
done

