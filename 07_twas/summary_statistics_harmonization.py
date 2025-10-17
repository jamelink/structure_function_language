import os
import subprocess
import numpy as np
import pandas as pd
import glob
import sys
from multiprocessing import Pool
import multiprocessing

###########################
# This script will lift over your sumstats from hg19 to hg38
# 10.04.2023 (provided by Yasmina Mekki)
# https://github.com/hakyimlab/summary-gwas-imputation
# https://github.com/hakyimlab/summary-gwas-imputation/wiki/GWAS-Harmonization-And-Imputation

###########################
######### Example #########
###########################
# First create a conda virtual env:
# conda env create -f /home/jitame/bin/software/summary-gwas-imputation/src/conda_env.yaml
#
# conda activate /home/jitame/.conda/envs/imlabtools
# Then run this script:
# python summary_statistics_harmonization.py
###########################
    
def summary_statistics_harmonization():
    
    cmd = " ".join(['/home/jitame/.conda/envs/imlabtools/bin/python /home/jitame/bin/software/summary-gwas-imputation/src/gwas_parsing.py',
                    '-gwas_file /data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/magma/FLICA_32k_5c_c2.regenie',
                    '-output_column_map ID variant_id',
                    '-output_column_map ALLELE0 non_effect_allele',
                    '-output_column_map ALLELE1 effect_allele',
                    '-output_column_map BETA effect_size',
                    '-output_column_map P pvalue',
                    '-output_column_map SE standard_error',
                    '-output_column_map GENPOS position',
                    '-output_column_map CHROM chromosome',
                    '-output_column_map N sample_size',
                    '--chromosome_format',
                    '-output_order variant_id panel_variant_id chromosome position effect_allele non_effect_allele pvalue effect_size standard_error sample_size',
                    '-liftover /data/workspaces/lag/shared_spaces/Resource_DB/liftover/hg19ToHg38.over.chain.gz',
                    '-output /data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/twas/FLICA_32k_5c_c2_liftover_hg38.txt.gz'
                   ])

    print("command summary statistics harmonization : {}".format(cmd))
    p = subprocess.check_call(cmd, shell=True)

if __name__ == "__main__":
    
    summary_statistics_harmonization()
