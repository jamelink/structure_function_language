import os 
import sys
import glob

#modify next line to provide the  path to your fsl_flica directory
toolbox_path="/home/jitame/bin/software/fsl_flica"


#TODO: ADD CONGRADS vs FLICA

no_subs="32k"
num_components=50   #number of ICAS to extract (recommend but not necesarily < Number of Subjects/4 (ask me if you want more explanation) )

#Modify next line to identify where you want to save output:
input_dir="/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/FLICA_multimodal/flica_in_{}".format(no_subs)

num_mods = len(glob.glob(input_dir+"/*/"))

output_dir="/data/clusterfs/lag/projects/lg-ukbiobank/working_data/imaging_data/FLICA_multimodal/flica_out_{0}mods_{1}_{2}c_R".format(num_mods, no_subs, num_components)


#If you want to use your own data then modify next line to direct to your data folder

sys.path.append(os.path.join(os.path.abspath(toolbox_path),"flica")) 
from flica import flica 

os.makedirs(output_dir, exist_ok=True)

  #number of ICAS to extract (recommend but not necesarily < Number of Subjects/4 (ask me if you want more explanation) )
maxits=3000 # set to 3000 or somethng high, you can check convergence looking at Convergence rate.txt file saved in results.
lambda_dims='R' # 'R' or 'o'  # 'o' encodes modality-wise noise, 'R' encodes modality and subject wise (standard 'o')
#fsl_path=os.environ['FSLDIR']
fs_path='/Applications/freesurfer'
tol=0.0001 #0.000001 #tolerance for convergence. 
fsl_path=""
print("Number of components: {}".format(num_components))
print("Max iterations: {}".format(maxits))
print("Tolerance: {}".format(tol))

#run flica
#dum=flica(brain_data_main_folder, output_dir , num_components, maxits, tol, lambda_dims , fs_path, fsl_path,"PCAnew")
dum=flica(input_dir, output_dir , num_components, maxits, tol, lambda_dims , fs_path, fsl_path,"PCA")
