import os
import subprocess
import numpy as np
import pandas as pd
import glob
import sys
from multiprocessing import Pool
import multiprocessing

###########################
# This script will run SPrediXcan on 
# dyslexia and rhythm impairment CPM
# sumstats.
# 10.04.2023 (provided by Yasmina Mekki)
# Last update 2025-03-05, Amelink, J.S.

# POTENTIAL PROBLEM: INFLATION
#  inflation problem in TWAS: https://www.biorxiv.org/content/10.1101/2023.10.17.562831v2.full.pdf
#  Brain tissue does not contain phi-values
#  Alternative inflation correction method is correct for brain traits: https://bioconductor.org/packages/release/bioc/manuals/bacon/man/bacon.pdf
# Use BACON!

# FOLLOW-UP:
# - QQ plots
# - BACON

###########################
######### Example #########
###########################
# conda activate imlabtools
# conda activate /home/jitame/.conda/envs/imlabtools
#
# python TWAS_SprediXcan.py 
#
###########################

def perform_twas(parameters):
    
    model_db_path, covariance_path, gwas_file, snp_column, effect_allele_column, non_effect_allele_column, beta_column, pvalue_column, output_file = parameters

    cmd = " ".join(['/home/jitame/.conda/envs/imlabtools/bin/python /home/jitame/bin/software/MetaXcan/software/SPrediXcan.py',
                    '--model_db_path %s' % model_db_path,
                    '--covariance %s' % covariance_path,
                    '--gwas_file %s' % gwas_file,
                    '--snp_column %s' % snp_column,
                    '--effect_allele_column %s' % effect_allele_column,
                    '--non_effect_allele_column %s' % non_effect_allele_column,
                    '--beta_column %s' % beta_column,
                    '--pvalue_column %s' % pvalue_column,
                    '--output_file %s' % output_file,
                    #'--verbosity 9',
                    #'--throw'
                   ])

    print("command Predict : {}".format(cmd))
    p = subprocess.check_call(cmd, shell=True)
    
if __name__ == "__main__":
    
    weights_path = '/data/workspaces/lag/shared_spaces/Resource_DB/JTI'
    model_db_paths = glob.glob(os.path.join(weights_path, '*.db'))
    gwas_file = '/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/twas/FLICA_32k_10c_c4_liftover_hg38.txt.gz'
    snp_column = 'variant_id'
    effect_allele_column = 'effect_allele'
    non_effect_allele_column = 'non_effect_allele'
    beta_column = 'effect_size'
    pvalue_column = 'pvalue'
    
    list_cmd = []
    for model_db_path in model_db_paths:
        
        covariance_path = os.path.join(weights_path, os.path.basename(model_db_path).replace(".db", ".txt.gz"))
        output_file = os.path.join('/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/twas/10c', os.path.basename(model_db_path).replace(".db", "_assoc.txt"))
        
        list_cmd.append([model_db_path, covariance_path, gwas_file, snp_column, effect_allele_column,
                        non_effect_allele_column, beta_column, pvalue_column, output_file]) 

    pool = Pool(processes = 31)
    pool.map(perform_twas, list_cmd)
    pool.close()
    pool.join()

