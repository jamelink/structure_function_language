#$ -S /bin/bash
#conda deactivate
module load anaconda
module load openblas
source activate /home/jitame/bin/anaconda3/envs/mrtrix

template_path=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/qc-sourena/template
template_fod=${template_path}/fod-template/fod-895-template.mif.gz
template_fod_mask=${template_path}/fod-template/fod-890-template-intersection-mask-95-percent.mif
voxel_mask=${template_path}/fod-template/analysis_voxel_mask.mif
fixel_mask=${template_path}/fod-template/peak_amp_mask_thresh_0.mif
template_fixel=${template_path}/fixels #This is a directory, try using /data/clusterfs/lag/projects/lg-ukbiobank/working_data/qc-sourena/template/fixels 
dir_index1=100
dir_index2=200
dirgen_file1=${template_path}/fod-template/dirgen-${dir_index1}.txt
dirgen_file2=${template_path}fod-template/dirgen-${dir_index2}.txt

sub_list=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/missing_diff_on_cluster_N4124.txt
i=/data/clusterfs/lag/projects/lg-ukbiobank/working_data/diff_extra

cd ${i}


#Loop over subject ids as $s
for s in $(cat ${sub_list}); do

if [ $(cat ${i}/${s}/mrtrix/log.txt |grep "finished" |wc -l) -eq 1 ]; then

echo "Output already exists for $i/$s , skipping.."

#elif [ -f ${i}/${s}/mrtrix/script.sh ]; then 
#echo "Job already submitted for $i/$s , skipping.."
#mkdir -p ${i}/${s}/mrtrix

#elif [ -d ${i}/${s}/mrtrix ];

else
echo "Submitting $i/$s"

#if [ -d ${i}/${s}/mrtrix ];
#then rm -rf ${i}/${s}/mrtrix/* 
#fi

mkdir -p ${i}/${s}/mrtrix
#fi

 echo " echo \"Analysis started at: \$(date) \" > ${i}/${s}/mrtrix/log.txt" > ${i}/${s}/mrtrix/script.sh

  echo " module load anaconda" >> ${i}/${s}/mrtrix/script.sh
  echo " module load openblas" >> ${i}/${s}/mrtrix/script.sh
  echo " source activate /home/jitame/bin/anaconda3/envs/mrtrix" >> ${i}/${s}/mrtrix/script.sh

 echo "dwi2fod -force -nthreads 0 -info -strides -2,3,4,1 -mask ${i}/${s}/fieldmap/fieldmap_mask_ud.nii.gz -fslgrad ${i}/${s}/dMRI/data.eddy_rotated_bvecs ${i}/${s}/dMRI/bvals msmt_csd ${i}/${s}/dMRI/data_ud.nii.gz ${template_path}/response_mean/mean_sfwm ${i}/${s}/mrtrix/wmfod.mif  ${template_path}/response_mean/mean_gm ${i}/${s}/mrtrix/gm.mif  ${template_path}/response_mean/mean_csf ${i}/${s}/mrtrix/csf.mif" >> ${i}/${s}/mrtrix/script.sh

 echo "mtnormalise -info -force -nthreads 0 ${i}/${s}/mrtrix/wmfod.mif ${i}/${s}/mrtrix/wmfod_norm.mif.gz ${i}/${s}/mrtrix/gm.mif ${i}/${s}/mrtrix/gm_norm.mif ${i}/${s}/mrtrix/csf.mif ${i}/${s}/mrtrix/csf_norm.mif -mask ${i}/${s}/fieldmap/fieldmap_mask_ud.nii.gz" >> ${i}/${s}/mrtrix/script.sh

 echo "rm ${i}/${s}/mrtrix/wmfod.mif" >> ${i}/${s}/mrtrix/script.sh
 
 echo "mrregister -nthreads 0 -force -info ${i}/${s}/mrtrix/wmfod_norm.mif.gz -mask1 ${i}/${s}/fieldmap/fieldmap_mask_ud.nii.gz $template_fod -mask2 $template_fod_mask -nl_warp ${i}/${s}/mrtrix/subj2template.mif ${i}/${s}/mrtrix/template2subj.mif" >> ${i}/${s}/mrtrix/script.sh

 echo "mrtransform -strides -2,3,4,1 -info -force -nthreads 0 ${i}/${s}/mrtrix/wmfod_norm.mif.gz -warp ${i}/${s}/mrtrix/subj2template.mif -reorient_fod 0 ${i}/${s}/mrtrix/wmfod_norm_warped2template.mif" >> ${i}/${s}/mrtrix/script.sh

 echo "mrconvert -nthreads 0 -force ${i}/${s}/mrtrix/wmfod_norm_warped2template.mif ${i}/${s}/mrtrix/wmfod_norm_warped2template.nii.gz" >> ${i}/${s}/mrtrix/script.sh

 echo "fslroi ${i}/${s}/mrtrix/wmfod_norm_warped2template.nii.gz ${i}/${s}/mrtrix/wmfod_norm_warped2template_frame.nii.gz 0 1" >> ${i}/${s}/mrtrix/script.sh

 echo "rm ${i}/${s}/mrtrix/wmfod_norm_warped2template.nii.gz" >> ${i}/${s}/mrtrix/script.sh

 echo "fod2fixel -nthreads 0 -info -force ${i}/${s}/mrtrix/wmfod_norm_warped2template.mif  ${i}/${s}/mrtrix/fixel -afd afd.mif -mask $voxel_mask" >> ${i}/${s}/mrtrix/script.sh

 echo "fixelreorient -nthreads 0 -force -info ${i}/${s}/mrtrix/fixel ${i}/${s}/mrtrix/subj2template.mif  ${i}/${s}/mrtrix/fixel_reoriented" >> ${i}/${s}/mrtrix/script.sh

 echo "fixelcorrespondence -force -nthreads 0 -info ${i}/${s}/mrtrix/fixel_reoriented/afd.mif $template_fixel ${i}/${s}/mrtrix/fixel_in_template afd.mif" >> ${i}/${s}/mrtrix/script.sh

##added recently
  echo "mrconvert -info $i/$s/mrtrix/fixel_in_template/afd.mif $i/$s/mrtrix/fixel_in_template/afd.nii.gz" >> ${i}/${s}/mrtrix/script.sh
##

 echo "mrtransform -force -strides -2,3,4,1 -info -nthreads 0 ${i}/${s}/mrtrix/wmfod_norm.mif.gz -warp ${i}/${s}/mrtrix/subj2template.mif -reorient_fod 1 ${i}/${s}/mrtrix/wmfod_norm_warped2template_reoriented.mif.gz" >> ${i}/${s}/mrtrix/script.sh

 echo "mrcalc -force ${i}/${s}/mrtrix/wmfod_norm_warped2template_reoriented.mif.gz $template_fod_mask -mul ${i}/${s}/mrtrix/wmfod_norm_warped2template_reoriented_masked.mif.gz" >> ${i}/${s}/mrtrix/script.sh


 echo "rm ${i}/${s}/mrtrix/wmfod_norm_warped2template.mif ${i}/${s}/mrtrix/wmfod_norm_warped2template_reoriented.mif.gz" >> ${i}/${s}/mrtrix/script.sh

 #I decided to skip this experimental analysis across all directions, due to the computational burden
# echo "sh2amp -info -force -nthreads 0 ${i}/${s}/mrtrix/wmfod_norm_warped2template_reoriented_masked.mif.gz $dirgen_file1 ${i}/${s}/mrtrix/wmfod_norm_warped2template_amp_dirgen_${dir_index1}.nii.gz" >> ${i}/${s}/mrtrix/script.sh

# echo "sh2amp -info -force -nthreads 0 ${i}/${s}/mrtrix/wmfod_norm_warped2template_reoriented_masked.mif.gz $dirgen_file2 ${i}/${s}/mrtrix/wmfod_norm_warped2template_amp_dirgen_${dir_index2}.nii.gz" >> ${i}/${s}/mrtrix/script.sh
 
 echo "echo \"Analysis finished at: \$(date) \" >> ${i}/${s}/mrtrix/log.txt" >> ${i}/${s}/mrtrix/script.sh


#bash ${i}/${s}/mrtrix/script.sh
qsub -q multi15.q -wd $(pwd) -o ${i}/${s}/mrtrix -e ${i}/${s}/mrtrix -S /bin/bash ${i}/${s}/mrtrix/script.sh
sleep 1
m_flag=true

while [ $(qstat|wc -l) -gt 399 ]
do
	if [ $m_flag = true ];then echo "submitted a batch of $(qstat|wc -l) jobs at $(date)"; m_flag=false; fi
	sleep 30
done

fi



done
##done

