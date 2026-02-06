# Integrating brain structure and function to understand the genetics and neurobiology of language

Repository with code for the structure-function manuscript: www.biorxiv.org/content/10.64898/2025.12.17.694832v1

All custom code was run on the High Performance Computing cluster at the MPI for Psycholinguistics in Nijmegen on Linux distribution OpenSUSE 15.2.

Data is available from UK Biobank through request. 

All custom code written by Jitse S. Amelink, Alberto Llera Arenas (FLICA algorithm), Sourena Soheili-Nezhad (diffusion and TBM), Dick Schijven (GWAS) and Gökberk Alagöz (evolution).

Software packages include:
- REGENIE v.3.6.0 (https://rgcgithub.github.io/regenie/)
- GCTA v.1.94.1 (https://cnsgenomics.com/software/gcta/#GREML)
- FUMA v1.5.2 (https://fuma.ctglab.nl/)
- MAGMA v.1.10 (https://ctg.cncr.nl/software/magma),
- PRS-CS v.2021.04.06 (https://github.com/getian107/PRScs)
- LDSC v. 1.0.1 (https://github.com/bulik/ldsc),
- FLICA (https://fsl.fmrib.ox.ac.uk/fsl/docs/utilities/flica.html),
- ANTs v. 2.3.5 (https://github.com/ANTsX/ANTs),
- mrtrix v. 3.0.3 (https://mrtrix.readthedocs.io/en/latest/index.html),
- FSL v.6.0.3 (https://fsl.fmrib.ox.ac.uk/fsl/docs/index.html,
- S-PrediXcan (https://github.com/hakyimlab/MetaXcan),
- NiMARE v.0.8.1 (https://nimare.readthedocs.io/en/stable/),
- neuromaps v. 0.0.5 (https://neuromaps-main.readthedocs.io/en/latest/),
- PLINK v.1.9 (https://www.cog-genomics.org/plink2/)
- GCTB v.2.0.2 (http://www.cnsgenomics.com/software/gctb/)

For the FLICA implementation used here, the following set-up is required:

conda env create -f flica/flica_env_linux.yaml

Alternatively, you can create the environment yourself with these packages:
- python 3.7.1 (any 3.7.X)
- numpy 1.21.5
- pandas 1.3.4
- matplotlib 1.3.3
- nibabel 4.0.2

Installation time should take a few minutes if conda is installed. 
