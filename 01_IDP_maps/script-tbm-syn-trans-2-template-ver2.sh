#!/bin/bash

sub_list=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/missing_tbms_N2616.txt

ants_path=/home/jitame/bin/software/ANTs/bin/
templ_dir=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/qc-sourena/template/
template=${templ_dir}/stage_11_syn_template.nii.gz
template_mask=${templ_dir}/stage_11_syn_template_brain_mask_dil.nii.gz
fsl_path=/usr/shared/apps/fsl/6.0.3/bin
s_path=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/tbm_extra
c3d_path=/home/jitame/bin/software/c3d-1.1.0-Linux-x86_64/bin
t_mask=${templ_dir}/brain-mask-freesurfer.nii.gz

for subj in $(cat $sub_list); do 

i=${subj}\-unbiased-brain.nii.gz
i_mask=${subj}_brain_mask.nii.gz

if [ $( ls ${s_path}/${subj}/|wc -l ) -eq 2 ] ;then


echo "submitting subject ID: $subj"

	echo "echo \"Analysis started: \$(date) \" >>  ${s_path}/${subj}/log.txt " > ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh

	echo "echo \"flirt directory \" >>  ${s_path}/${subj}/log.txt " >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh
    
    echo "module load openblas; module load fsl; export FSLOUTPUTTYPE=NIFTI2_GZ" >>  ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh
    
echo "${fsl_path}/flirt -in ${s_path}/${subj}/$i -ref $template -cost corratio -dof 12 -v -omat ${s_path}/${subj}/${i%.nii.gz}-2-template.mat" >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh


##echo "${fsl_path}/fslmaths $i_mask -kernel sphere 5 -dilF ./${i%.nii.gz}_mask_dil.nii.gz" >> script_${i%.nii.gz}.sh
##i_mask=${i%.nii.gz}_mask_dil.nii.gz

echo "${c3d_path}/c3d_affine_tool -ref $template -src ${s_path}/${subj}/$i ${s_path}/${subj}/${i%.nii.gz}-2-template.mat -fsl2ras -oitk ${s_path}/${subj}/${i%.nii.gz}-2-template-itk.mat" >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh

##rm ${i%.nii.gz}-2-template.mat 

echo "  ${ants_path}/antsRegistration -d 3 --float 1 --verbose 1 -u 1 -w [ 0.01,0.99 ] -z 1 \
        --initial-moving-transform ${s_path}/${subj}/${i%.nii.gz}-2-template-itk.mat \
        -t SyN[ 0.1,3,0 ]  -m CC[${template},${s_path}/${subj}/${i},1,4 ] -c [ 100x100x70x20,1e-9,10 ] -f 6x4x2x1 -s 4x2x1x0vox \
        -o ${s_path}/${subj}/${i%.nii.gz}_syn -x [${template_mask},${s_path}/${subj}/${i_mask}] " >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh #  


echo " ${ants_path}/antsApplyTransforms -d 3 -t ${s_path}/${subj}/${i%.nii.gz}_syn1Warp.nii.gz -t ${s_path}/${subj}/${i%.nii.gz}_syn0GenericAffine.mat -r $template -o [${s_path}/${subj}/${i%.nii.gz}-composite-warp.nii.gz,1] -v  " >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh

echo "	${ants_path}/antsApplyTransforms -d 3 --float 1 --verbose 1 -i ${s_path}/${subj}/$i -o ${s_path}/${subj}/${i%.nii.gz}-composite-warped2template.nii.gz -r $template -t ${s_path}/${subj}/${i%.nii.gz}-composite-warp.nii.gz " >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh

echo "	${ants_path}/CreateJacobianDeterminantImage 3 ${s_path}/${subj}/${i%.nii.gz}-composite-warp.nii.gz ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac.nii.gz 0 0 " >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh

echo "	${ants_path}/antsApplyTransforms -d 3 --float 1 -n NearestNeighbor --verbose 1 -i $t_mask -o ${s_path}/${subj}/${i%.nii.gz}-fs-mask.nii.gz -r ${s_path}/${subj}/$i -t [ ${s_path}/${subj}/${i%.nii.gz}_syn0GenericAffine.mat,1] -t ${s_path}/${subj}/${i%.nii.gz}_syn1InverseWarp.nii.gz" >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh


echo "${fsl_path}/fslstats ${s_path}/${subj}/${i%.nii.gz}-fs-mask.nii.gz -V |awk '{print \$2}' > ${s_path}/${subj}/brain-vol-${i%.nii.gz}.txt " >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh

echo "volratio=\$(echo \"\$(cat ${s_path}/${subj}/brain-vol-${i%.nii.gz}.txt)/1156131 \"|bc -l )" >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh

echo "${fsl_path}/fslmaths ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac.nii.gz -div \$volratio -log ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-log.nii.gz " >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh

echo "${fsl_path}/fslroi ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-log.nii.gz ${s_path}/${subj}/${i%.nii.gz}-composite-warp-jac-norm-log-roi.nii.gz 20 140 20 175 13 133 " >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh

	echo "echo \"Analysis finished: \$(date) \" >>  ${s_path}/${subj}/log.txt " >> ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh
#bash ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh 
qsub -wd ${s_path}/${subj} -S /bin/bash -N s-${subj} -p -55 -q single15.q ${s_path}/${subj}/script_${i%.nii.gz}_comp.sh | awk '{print $3}'

sleep 2

#while [ $(qstat|wc -l) -gt 60 ]
#do
#	echo "submitted a batch of $(qstat|wc -l) jobs"
#	sleep 100
#done

else
	echo "Subject directory should exactly have two files, but it doesnt: ${s_path}/${subj} : $(ls ${s_path}/${subj}/|wc -l) files"
fi

done
 
