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
    
    in_file = os.path.join(in_path, pheno+".txt")
    print("Reading in file: ", in_file)
    data=pd.read_csv(in_file, sep=' |\t', engine='python')
    
    if N_case_control:
        data["N"] = np.add(data[N[0]], data[N[1]])
    
    if freq_cas_con:
        data["freq"] = np.divide(data[freq[0]]*data[N[0]] + data[freq[1]]*data[N[1]], data["N"] )
    
    data.rename(columns={SNP:"SNP",
                      A1:"A1",
                     A2:"A2",
                    p:"P",
                        se:"se"}, inplace=True)
    if capitalize:
        data['A1'] = data['A1'].str.upper()
        data['A2'] = data['A2'].str.upper()
    
    if not odds_ratio:
        data.rename(columns={b:"BETA"}, inplace=True)
    
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
        data["SNP A1 A2 BETA P".split()].to_csv(os.path.join(out_path, pheno+".ma"), sep="\t", index=False)

    
# INFORMATION TO READ IN ALL THE FILES RIGHT

pheno_labels=[{"pheno":"ad",
 "SNP":"variant_id",
 "A1":"effect_allele",
 "A2":"other_allele",
 "freq":"effect_allele_frequency",
 "b":"odds_ratio",
 "se":"standard_error",
 "p":"p_value",
 "N":["n_cases", "n_controls"],
 "N_case_control":True,
 "odds_ratio":True,
  "freq_cas_con":False
},
 {"pheno": "adhd",
 "SNP": "SNP",
 "A1": "A1",
 "A2":"A2",
 "freq":["FRQ_A_38691","FRQ_U_186843"],
 "b":"OR",
 "se":"SE",
 "p":"P",
 "N":["Nca", "Nco"],
 "N_case_control":True,
 "odds_ratio":True,
  "freq_cas_con":True
 },
 {"pheno":"als",
 "SNP":"rsid",
 "A1":"effect_allele",
 "A2":"other_allele",
 "freq":"effect_allele_frequency",
 "b":"beta",
 "se":"standard_error",
 "p":"p_value",
 "N":"N_effective",
 "N_case_control":False,
 "odds_ratio":False,
  "freq_cas_con":False
},
{"pheno":"anx",
 "SNP":"SNPID",
 "A1":"Allele1",
 "A2":"Allele2",
 "freq":"Freq1",
 "b":"Effect",
 "se":"StdErr",
 "p":"P.value",
 "N":"TotalN",
 "N_case_control":False,
 "odds_ratio":False,
 "freq_cas_con":False},

#ASD NO FREQ + TOTALN(!!!)
{"pheno":"asd",
 "SNP":"SNP",
 "A1":"A1",
 "A2":"A2",
 "freq":"Freq1",
 "b":"OR",
 "se":"StdErr",
 "p":"P",
 "N":"TotalN",
 "N_case_control":False,
 "odds_ratio":True,
 "freq_cas_con":False},
               
{"pheno":"bip",
 "SNP":"ID",
 "A1":"A1",
 "A2":"A2",
 "freq":["FCAS", "FCON"],
 "b":"BETA",
 "se":"SE",
 "p":"PVAL",
 "N":["NCAS", "NCON"],
 "N_case_control":True,
 "odds_ratio":False,
 "freq_cas_con":True},

#NOTE: NO N, ALLELE A AND B REVERSED?? CHECK WITH SOURENA??
{"pheno":"dyslexia",
 "SNP":"rsid",
 "A1":"alleleB",
 "A2":"alleleA",
 "freq":"freq.b",
 "b":"effect",
 "se":"stderr",
 "p":"pvalue",
 "N":["im.num.0", "im.num.1"],
 "N_case_control":True,
 "odds_ratio":False,
 "freq_cas_con":False},

#CHR     BP      MarkerName      Allele1 Allele2 Freq1   FreqSE  Weight  Zscore  P-value Direction       HetISq  HetChiSq        HetDf   HetPVal               
#CHECK: Z-SCORE, FreqSE usable?
               #N missing??
{"pheno":"epilepsy",
 "SNP":"MarkerName",
 "A1":"Allele1",
 "A2":"Allele2",
 "freq":"Freq1",
 "b":"Zscore",
 "se":"FreqSE",
 "p":"P-value",
 "N":"",
 "N_case_control":False,
 "odds_ratio":False,
 "freq_cas_con":False},

#SNP A1 A2 BETA P
#MISSING: N, SE, FREQ
{"pheno":"hand",
 "SNP":"SNP",
 "A1":"A1",
 "A2":"A2",
 "freq":"",
 "b":"BETA",
 "se":"",
 "p":"P",
 "N":"",
 "N_case_control":False,
 "odds_ratio":False,
 "freq_cas_con":False},

{"pheno":"read",
 "SNP":"MarkerName",
 "A1":"Allele1",
 "A2":"Allele2",
 "freq":"Freq1",
 "b":"Effect",
 "se":"StdErr",
 "p":"P-value",
 "N":"TotalSampleSize",
 "N_case_control":False,
 "odds_ratio":False,
 "freq_cas_con":False,
"capitalize":True},

{"pheno":"ea",
 "SNP":"rsID",
 "A1":"Effect_allele",
 "A2":"Other_allele",
 "freq":"EAF_HRC",
 "b":"Beta",
 "se":"SE",
 "p":"P",
 "N":"",
 "N_case_control":False,
 "odds_ratio":False,
 "freq_cas_con":False},

{"pheno":"scz",
 "SNP":"ID",
 "A1":"A1",
 "A2":"A2",
 "freq":["FCAS", "FCON"],
 "b":"BETA",
 "se":"SE",
 "p":"PVAL",
 "N":["NCAS", "NCON"],
 "N_case_control":True,
 "odds_ratio":False,
 "freq_cas_con":True}]

#CREATE OVERVIEW
phenos_overview = pd.DataFrame(pheno_labels)
phenos_overview.set_index("pheno", inplace=True)

#parameters
good_phenos = [  "hand", "ea", # read, "dyslexia", reading-related
                "scz", "adhd", "asd" ]  # ndds 


#paths
in_path = "/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/gwas_summary/all_sums"
out_path = "/data/workspaces/lag/workspaces/lg-ukbiobank/projects/CONGRADS_rest/gwas_summary/all_sums_pgs"

#RUN THE MAGIC
for i, pheno in enumerate(good_phenos):
    print("Running pheno {0}/{1}".format(i+1, len(good_phenos)))
    print("Current pheno: ", pheno)
    data_munger_gctb(in_path,
                       out_path,
                        pheno,
                       *list(phenos_overview.loc[pheno, :]))