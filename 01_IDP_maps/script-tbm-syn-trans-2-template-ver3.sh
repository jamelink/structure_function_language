#!/bin/bash

t1_list=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/missing_tbms_N2616.txt
ants_path=/home/jitame/bin/software/ANTs/bin/
templ_dir=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/qc-sourena/template/
template=${templ_dir}/stage_11_syn_template.nii.gz
template_mask=${templ_dir}/stage_11_syn_template_brain_mask_dil.nii.gz
fsl_path=/usr/shared/apps/fsl/6.0.3/bin
s_path=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/tbm_extra
c3d_path=/home/jitame/bin/software/c3d-1.1.0-Linux-x86_64/bin
t_mask=${templ_dir}/brain-mask-freesurfer.nii.gz


for subj in $(cat $t1_list); do 


i=${subj}\-unbiased-brain.nii.gz
i_mask=${subj}_brain_mask.nii.gz


echo "submitting subject ID: $subj"

	echo "echo \"Analysis started: \$(date) \" >>  ${s_path}/${subj}/log.txt " > ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "module load openblas; module load fsl; export FSLOUTPUTTYPE=NIFTI2_GZ" >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "volratio=\$(echo \"\$(cat ${s_path}/${subj}/brain-vol-${i%.nii.gz}.txt)/1156131 \"|bc -l )" >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "${fsl_path}/fslmaths ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac.nii.gz -div \$volratio ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm.nii.gz " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "${fsl_path}/fslmaths ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac.nii.gz -log ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-log.nii.gz " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "${fsl_path}/fslroi ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-log ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-log-roi 20 140 20 175 13 133 " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "${fsl_path}/fslroi ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-roi 20 140 20 175 13 133 " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "${fsl_path}/fslroi ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-roi 20 140 20 175 13 133 " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "flirt -in ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-roi -ref ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-roi -applyisoxfm 2 -out ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-roi_iso_2.nii.gz  -v " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "flirt -in ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-roi -ref ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-roi -applyisoxfm 2 -out ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-roi_iso_2.nii.gz  -v " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "flirt -in ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-log-roi -ref ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-log-roi -applyisoxfm 2 -out ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-log-roi_iso_2.nii.gz  -v " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh

echo "flirt -in ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-log-roi -ref ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-log-roi -applyisoxfm 2 -out ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-log-roi_iso_2.nii.gz  -v " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh




	echo "echo \"Analysis finished: \$(date) \" >>  ${s_path}/${subj}/log.txt " >> ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh
#bash ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh 
qsub -wd ${s_path}/${subj} -S /bin/bash -N s-${i%.nii.gz} -q single15.q -p -777 ${s_path}/${subj}/script_${i%.nii.gz}_iso.sh | awk '{print $3}'


sleep 2

#while [ $(qstat|wc -l) -gt 1000 ]
#do
#	echo "submitted a batch of $(qstat|wc -l) jobs"
#	sleep 210
#done

done

 
