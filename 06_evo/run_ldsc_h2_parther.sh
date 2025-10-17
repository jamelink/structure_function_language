#!/bin/bash/

# This script runs the LDSC h2 partitioning analysis for the FLICA language data
# Last update: Amelink, J.S., 2025-02-21
# based on: https://github.com/galagoz/pleiotropyevo/blob/main/ldsc

# Inputs
#input_file=$1
#input_file=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/results/5c_c2/FLICA_32k_5c_c2.regenie.gz
input_file=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/results/10c_c4/FLICA_32k_10c_c4.regenie.gz


input=$(basename "${input_file%.*.*}")

echo "Running LDSC h2 partitioning analysis for ${input_file}"
echo "${input}" 

munge_dir=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/munge 
h2_dir=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/h2
part_her_dir=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/part_her

mkdir -p ${munge_dir}
mkdir -p ${h2_dir}
mkdir -p ${parther_dir}

# Input files
#annotations
annot_path=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/part_her

#LDSC main files
snp_list=/data/clusterfs/lag/users/jitame/SENT_CORE/geno/ldsc/w_hm3.snplist
ref_dir=/data/clusterfs/lag/users/jitame/SENT_CORE/geno/ldsc/eur_ref_ld_chr
w_ld_dir=/data/clusterfs/lag/users/jitame/SENT_CORE/geno/ldsc/eur_w_ld_chr
baseline_ld_path=/data/workspaces/lag/shared_spaces/Resource_DB/LDscores/Phase3/baselineLD_v2.2
#baseline_ld_path=/data/workspaces/lag/shared_spaces/Resource_DB/baselineLD
frq_path=/data/workspaces/lag/shared_spaces/Resource_DB/LDscores/Phase3/1000G_Phase3_frq
ldscores_path=/data/workspaces/lag/shared_spaces/Resource_DB/LDscores/Phase3/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC.

# Software paths
ldsc_dir=/home/jitame/bin/software/ldsc

module purge
conda deactivate
module load python/2.7.15


# STEP 1: MUNGE SUMSTATS
python ${ldsc_dir}/munge_sumstats.py \
    --sumstats ${input_file} \
    --out ${munge_dir}/${input} \
    --snp ID \
    --a1 ALLELE1 \
    --a2 ALLELE0 \
    --merge-alleles ${snp_list}

#STEP 2: RUN HERITABILITY

python  ${ldsc_dir}/ldsc.py \
 --h2 ${munge_dir}/${input}.sumstats.gz \
 --ref-ld-chr ${w_ld_dir}/ \
 --out  ${h2_dir}/${input}_h2 \
 --w-ld-chr ${w_ld_dir}/


#STEP 3: RUN PARTITIONED HERITABILITY
for annot in $(ls -d ${annot_path}/*/ ); do

base_annot=$(basename ${annot})

#base_annot=fetal_hge_hg19.merged.sorted
#base_annot=oligo_enhancers.sorted
base_annot=oligo_promoters.sorted
annot=${annot_path}/${base_annot}/

if [ ${base_annot} == "E081_active_marks" ]; then
    echo "${base_annot} is not an interesting annotation, skipping"
    continue
elif [ ${base_annot} == "fetal_hge_hg19.merged.sorted" ]; then

    python ${ldsc_dir}/ldsc.py \
    --h2 ${munge_dir}/${input}.sumstats.gz  \
    --out ${part_her_dir}/${input}_${base_annot} \
    --frqfile-chr ${frq_path}/1000G.EUR.QC. \
    --overlap-annot \
    --ref-ld-chr ${annot}${base_annot}.,${annot_path}/E081_active_marks/E081_active_marks.,${baseline_ld_path}/baselineLD.  \
    --w-ld-chr ${ldscores_path} \
    --print-coefficients

else

    python ${ldsc_dir}/ldsc.py \
    --h2 ${munge_dir}/${input}.sumstats.gz  \
    --out ${part_her_dir}/${input}_${base_annot} \
    --frqfile-chr ${frq_path}/1000G.EUR.QC. \
    --overlap-annot \
    --ref-ld-chr ${annot}${base_annot}.,${baseline_ld_path}/baselineLD. \
    --w-ld-chr ${ldscores_path} \
    --print-coefficients

fi
done

echo "Done"