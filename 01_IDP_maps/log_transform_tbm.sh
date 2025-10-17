#!/bin/bash
#$ -cwd
#$ -q single15.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs/
#$ -o /home/jitame/bin/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -m beas
#$ -p -5
### USAGE ###

# This script is used to log transform the TBM maps
# Last edited by: Jitse Amelink, 2024-12-04

# Load modules
module load fsl/6.0.3

# Get subid
s=$1

echo "Log transforming TBM maps for ${s}"

# Set paths
in_dir=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/FLICA_multimodal/flica_in_raw
mask=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/qc-sourena/template/masks/brain-mask-freesurfer-roi-iso-2.nii.gz

# Log transform TBM maps
fslmaths ${in_dir}/${s}/${s}_tbm.nii.gz -log ${in_dir}/${s}/${s}_tbm_log.nii.gz
fslmaths ${in_dir}/${s}/${s}_tbm_log.nii.gz -mas ${mask} ${in_dir}/${s}/${s}_tbm_log_masked.nii.gz

rm ${in_dir}/${s}/${s}_tbm_log.nii.gz

echo "Done log transforming TBM maps for ${s}"



