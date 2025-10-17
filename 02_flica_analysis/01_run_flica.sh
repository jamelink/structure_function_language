#!/bin/bash
#$ -cwd
#$ -q big.q
#$ -S /bin/bash 
#$ -e /home/jitame/bin/logs/
#$ -o /home/jitame/bin/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -m beas
#$ -p -55
### USAGE ###

usage()
{
   echo -e "\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   echo "This script is a wrapper for running linked ICA."
   echo " "
   echo "Usage: bash /home/jitame/bin/code/FLICA_language/02_flica_analysis/01_run_flica.sh"
   echo " "
   echo "-- Cluster use (single15.q) --"
   echo "When running the script on the cluster (through gridmaster), you might want to provide specific qsub arguments, such as the location where a standard"
   echo "log file is stored, or the email address to which a message should be sent when the script is finished."
   echo "In this case, provide the qsub arguments before the script name, and the arguments specific to the script after the script name:"
   echo "qsub -N flica_32k_5c /home/jitame/bin/code/FLICA_language/02_flica_analysis/01_run_flica.sh"
   echo " "
   echo "Last update: Jitse Amelink. Feb 2 2024"
   echo -e "------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n"
   exit 1 # Exit script after printing usage
}

now=$( date )
start=`date +%s`
echo "Start at ${start}" 

c=$1

#module load fsl/6.0.3
#module load freesurfer/6.0.0
module purge
module load miniconda/3.2021.10
#conda activate nibabel

which python
pip list

python /home/jitame/bin/code/FLICA_language/02_flica_analysis/01_flica_run_${c}c.py

now=$( date )
checkpoint=`date +%s`
runtime=$(((checkpoint-start)/60))
printf "\n Total time is ${runtime} minutes.\n\n"

