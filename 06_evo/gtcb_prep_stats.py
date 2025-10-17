import pandas as pd
import os
import numpy as np

"""
Takes various summary statistics files and processes them into a nice format for PRS-CS (https://github.com/getian107/PRScs)
Saves data to output folder.

Written by J.S. Amelink
On: 2023-03-21


"""

#Read column names
def data_munger_gctb(in_path, out_path, pheno, SNP, A1, A2, freq, b, se, p, N, N_case_control, odds_ratio, freq_cas_con, capitalize=False):
    
    data=pd.read_csv(os.path.join(in_path,pheno+".regenie"), sep=' |\t', engine='python')
    
    if N_case_control:
        data["N"] = np.add(data[N[0]], data[N[1]])
    
    if freq_cas_con:
        data["freq"] = np.divide(data[freq[0]]*data[N[0]] + data[freq[1]]*data[N[1]], data["N"] )
    
    data.rename(columns={SNP:"SNP",
                      A1:"A1",
                     A2:"A2",
                    p:"p",
                        se:"se"}, inplace=True)
    if capitalize:
        data['A1'] = data['A1'].str.upper()
        data['A2'] = data['A2'].str.upper()
    
    if not odds_ratio:
        data.rename(columns={b:"b"}, inplace=True)
    
    if not N_case_control:
        data.rename(columns={N:"N"}, inplace=True)
    
    if not freq_cas_con:
        data.rename(columns={freq:"freq"}, inplace=True)
    
    if pheno == "read":
        data = data[data["N"] > 10000]
    
    if odds_ratio:
        data.rename(columns={b:"OR"}, inplace=True)
        data = data[data["P"] < 0.05]
        data["SNP A1 A2 OR P".split()].to_csv(os.path.join(out_path, pheno+".ma"), sep="\t", index=False)
    else:
        data["SNP A1 A2 freq b se p N".split()].to_csv(os.path.join(out_path, pheno+".ma"), sep="\t", index=False)

    
# INFORMATION TO READ IN ALL THE FILES RIGHT

pheno_labels=[

{"pheno":"FLICA_32k_10c_c4",
 "SNP":"ID",
 "A1":"ALLELE1",
 "A2":"ALLELE0",
 "freq":"A1FREQ",
 "b":"BETA",
 "se":"SE",
 "p":"P",
 "N":"N",
 "N_case_control":False,
 "odds_ratio":False,
 "freq_cas_con":False,
"capitalize":False},

{"pheno":"FLICA_32k_5c_c2",
 "SNP":"ID",
 "A1":"ALLELE1",
 "A2":"ALLELE0",
 "freq":"A1FREQ",
 "b":"BETA",
 "se":"SE",
 "p":"P",
 "N":"N",
 "N_case_control":False,
 "odds_ratio":False,
 "freq_cas_con":False,
"capitalize":False},

]

#CREATE OVERVIEW
phenos_overview = pd.DataFrame(pheno_labels)
phenos_overview.set_index("pheno", inplace=True)

#parameters
good_phenos = ["FLICA_32k_10c_c4", "FLICA_32k_5c_c2"] #  "hand"]

#paths
in_path = "/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/magma"
out_path = "/data/workspaces/lag/workspaces/lg-ukbiobank/projects/FLICA_multimodal/evo_annots/gctb"

#RUN THE MAGIC
for i, pheno in enumerate(good_phenos):
    print("Running pheno {0}/{1}".format(i+1, len(good_phenos)))
    print("Current pheno: ", pheno)
    data_munger_gctb(in_path,
                       out_path,
                        pheno,
                       *list(phenos_overview.loc[pheno, :]))