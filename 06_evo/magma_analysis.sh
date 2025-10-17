#!/bin/bash

# This script will 1) run snp2gene (annotation),
#		   2) run gene analysis,
#		   3) run gene-set analysis on evo. gene lists.

# Original: Gokberk Alagoz, 11.10.22. Last update: Amelink, J.S., 2025-02-25
##########################

# Set Paths

base_path=/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots
genotype_f="/data/workspaces/lag/shared_spaces/Resource_DB/magma_v1.10/g1000_eur/"
programs=/data/workspaces/lag/shared_spaces/Resource_DB/magma_v1.10/
inDir=${base_path}/magma/
outDir=${inDir}/out/
in_base=FLICA_32k_10c_c4
#in_base=FLICA_32k_5c_c2
in_file=${in_base}.regenie
annots_evo=${base_path}/magma/gene_sets/evo_annots.gmt
annots_bird=${base_path}/magma/gene_sets/birdsonggenes_9Sets_7dec2023.gmt

## 0) Preparations
awk 'OFS="\t" {print $1, $2, $3}' ${inDir}${in_file} | tail -n +2 > ${outDir}${in_base}_snp_loc.tab
#awk 'OFS="\t" {print $1, $2, $3}' ${inDir}${in_file} > ${outDir}${in_base}_pval.tab

# GET GENE SYMBOLS AS FIRST COLUMN
awk 'OFS="\t" {print $6, $2, $3, $4}' ${inDir}NCBI37.3.gene.loc > ${outDir}geneLoc_file.tab


# 1) Annotation

${programs}magma --annotate --snp-loc ${outDir}${in_base}_snp_loc.tab --gene-loc ${outDir}geneLoc_file.tab --out ${outDir}${in_base}_annot

# 2) Gene analysis (using SNP p-values)

${programs}magma --bfile ${genotype_f}g1000_eur --pval  ${inDir}${in_file} use=ID,P  ncol=N  --gene-annot ${outDir}${in_base}_annot.genes.annot --out ${outDir}${in_base}

# 3) Gene-set analysis

${programs}magma --gene-results ${outDir}${in_base}.genes.raw --set-annot ${annots_evo} --out ${outDir}${in_base}_evo_annots

# DOES NOT RUN, ENSEMBL LABELS, NOT GENE SYMBOLS
#${programs}magma --gene-results ${outDir}${in_base}.genes.raw --set-annot ${annots_bird} --out ${outDir}${in_base}_bird

