# Simple script to run GCTB
# Last edit: Amelink, J.S., 2025-02-25. Based on Gokberk Alagoz's script 
# https://github.com/galagoz/pleiotropyevo/tree/main/GCTB


module load gctb/2.02
base_dir=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/gctb/
in_file="FLICA_32k_10c_c4.regenie"
mldm_fn=/data/workspaces/lag/shared_spaces/Resource_DB/ukbEURu_hm3_shrunk_sparse/ukbEURu_hm3_sparse_mldm_list_new_paths.txt
in_base=FLICA_32k_5c_c2
#in_base=FLICA_32k_10c_c4 
gwas_ma=${base_dir}/${in_base}.ma

#prep sumstats for gctb
#python /home/jitame/bin/code/FLICA_language/06_evo/gtcb_prep_stats.py

#run gctb - TODO: UPDATE PATHS
gctb --sbayes S \
     --mldm $mldm_fn \
     --gwas-summary $gwas_ma \
     --burn-in 2000 \
     --out ${base_dir}${in_base} > ${base_dir}${in_base}.log 2>&1 