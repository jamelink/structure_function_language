#!/bin/sh
#$ -cwd
#$ -q single15.q
#$ -S /bin/bash
#$ -e /home/jitame/bin/logs/
#$ -o /home/jitame/bin/logs/
#$ -M Jitse.Amelink@mpi.nl
#$ -m beas

### USAGE ###

usage()
{
   echo -e "\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   echo "This script is the resting state pipeline for deriving a subject-specific map of the resting state language network based on the ICA-100 decomposition from the UK Biobank."
   echo " "
   echo "1. Warp from subject space to MNI space with previously defined warp. (FSL's applywarp)"
   echo "2. Smooth data with a sigma of 2.5 (fslmaths)"
   echo "3. Run dual regression step 2 (fsl_glm)"
   echo "4. Split components (fsl_split)"
   echo "5. Keep language-related components (9 and 28)"
   echo " "
   echo "Usage: bash /home/jitame/bin/code/FLICA_language/01_IDP_maps/01_rsfMRI_to_MNI_dr2.sh -s <subid>"
   echo -e "\t-s Subject ID."
   echo -e "\t-h - Show help."
   echo " "
   echo "-- Cluster use (single15.q) --"
   echo "When running the script on the cluster (through gridmaster), you might want to provide specific qsub arguments, such as the location where a standard"
   echo "log file is stored, or the email address to which a message should be sent when the script is finished."
   echo "In this case, provide the qsub arguments before the script name, and the arguments specific to the script after the script name:"
   echo "qsub -N dr2_MNI_${s} 01_rsfMRI_to_MNI.sh -s ${s}"
   echo " "
   echo "Last update: Jitse Amelink. Nov 27 2023"
   echo -e "------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n"
   exit 1 # Exit script after printing usage
}


while getopts "s:" opt
do
   case "$opt" in
      s ) subid="$OPTARG" ;;
      ? ) usage ;; 
    esac
done

# Store current date and time in variable and start time of the script
now=$( date )
start=`date +%s`
echo "Start at ${start}" 

printf "Start dr pipeline for subject: ${subid} \n"

## load software
module load fsl/6.0.3

#specify paths
base_path="/data/clusterfs/lag/projects/lg-ukbiobank/primary_data/imaging_data"
rs_out_path="/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/FLICA_multimodal/fMRI/${subid}"
dr_out_path="/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/FLICA_multimodal/dr_stage2/${subid}"

#data
cleaned_rs_data=${base_path}/${subid}/fMRI/rfMRI.ica/filtered_func_data_clean.nii.gz
dr_betas=${base_path}/${subid}/fMRI/rfMRI_100.dr/dr_stage1.txt
mni_mask="/usr/shared/apps/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain_mask.nii.gz"
mni="/usr/shared/apps/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain.nii.gz"

if [ ! -f ${cleaned_rs_data} ]; then
    echo "Resting state data does not exist for ${subid}. Exiting."
    exit 1
fi

#warps
rs2mni_mat=${base_path}/${subid}/fMRI/rfMRI.ica/reg/example_func2standard.mat
rs2mni_warp=${base_path}/${subid}/fMRI/rfMRI.ica/reg/example_func2standard_warp.nii.gz
example_rs_ref=${base_path}/${subid}/fMRI/rfMRI.ica/reg/example_func2standard.nii.gz

#naming
symlink_rs_data=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/rfMRIreg/${subid}/fMRI/rfMRI.ica/reg/filtered_func_data_clean_standard.nii.gz
mni_rs_data=${rs_out_path}/filtered_func_data_clean_standard.nii.gz
mni_rs_data_out=${rs_out_path}/filtered_func_data_clean_standard_s2_5.nii.gz
dr_out_name=${dr_out_path}/dr_stage2
keep_comp_mtl=${dr_out_path}/ica_mtl.nii.gz
keep_comp_ifl=${dr_out_path}/ica_ifl.nii.gz

#preprocessing settings
sigma=2.5

#tr_value = 0.735
#hp_freq = 0.01
#hp_sigma = round(1/(2*hp_freq*tr_value), 0)
#smoothing_in_mm = 5
#round(smoothing_in_mm/2.3548, 4)

# --------------------------- #
### PIPELINE ###
# ---------------------------#

### PREP DATA ###
#make path
printf "0. Making path. \n"
mkdir -p $rs_out_path

#WARPING
if [ -f "${mni_rs_data}" ]; then
    printf "1. Warped data: ${mni_rs_data} already exists. \n"
elif [ -f "${symlink_rs_data}" ]; then
   printf "1. Warped data already exists elsewhere: ${symlink_rs_data} already exists. Symlinking to earlier data. \n"
    ln -s ${symlink_rs_data} ${mni_rs_data}
elif [ -f "${cleaned_rs_data}" ]; then
    printf "1. Applying warp. \n"
    applywarp --ref=${mni} --in=${cleaned_rs_data} --warp=${rs2mni_warp} --out=${mni_rs_data}
else
    printf "No data available. Exiting. "
    exit 1
fi

#SMOOTHING
if [ -f "${mni_rs_data_out}" ]; then
    printf "2. Smoothed data: ${mni_rs_data_out} already exists. \n"
else
    printf "2. Smoothing with sigma: ${sigma}. \n"
    fslmaths ${mni_rs_data} -kernel gauss ${sigma} -fmean ${mni_rs_data_out}
fi

#HIGHPASS FILTER NOT NECESARRY BECAUSE ALREADY DONE BY UKB.

now=$( date )
checkpoint=`date +%s`
runtime=$(((checkpoint-start)/60))
printf "\n Elapsed time after step 1 is ${runtime} minutes.\n\n"


### RUN DUALREG STEP 2 ###

#make path
printf  "3. Run dual regression step 2. \n"
mkdir -p $dr_out_path

#run dual regression step 2 (adapted from fsl's dual regression)
fsl_glm -i ${mni_rs_data_out} -d ${dr_betas} -o ${dr_out_name} --demean -m $mni_mask --des_norm #--out_z=${dr_out_name}_Z

#split components
printf  "4. Split components. \n"
fslsplit ${dr_out_name} ${dr_out_name}_ic

printf  "5. Keep components. \n"
mv ${dr_out_name}_ic0009.nii.gz ${keep_comp_mtl}
mv ${dr_out_name}_ic0028.nii.gz ${keep_comp_ifl}

## RUN CONGRADS
printf  "6. Running CONGRADS \n"
bash /home/jitame/bin/code/CONGRADS_language/00_data_prep/02_congrads_job_mni.sh -s $subid  -n 3 -f 3

#remove outputs for storage saving
rm ${dr_out_name}_ic*

rm ${mni_rs_data_out}
rm ${mni_rs_data}
#rm ${dr_out_name}

now=$( date )
checkpoint=`date +%s`
runtime=$(((checkpoint-start)/60))
printf "\n Total time is ${runtime} minutes.\n\n"

