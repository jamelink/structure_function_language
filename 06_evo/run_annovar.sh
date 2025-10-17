#!/bin/bash

#annovar_path=/home/jitame/bin/software/annovar/
annovar_path=/data/workspaces/lag/shared_spaces/Resource_DB/annovar/
main_path=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/magma/


${annovar_path}/table_annovar.pl ${main_path}/lead_snps_10c.vcf \
  ${annovar_path}/humandb/ \
  -buildver hg19 \
  -out ${main_path}/lead_snps_10c_annotated.csv \
  -protocol refGeneWithVer,cytoBand,gnomad211_exome,dbnsfp47a \
  -operation gx,r,f,f \
  -remove -nastring . -csvout -polish