
#--------------------------------------#
### MEDIATION ANALYSIS ###
# This script performs mediation analysis using the mediation package in R.
# Steps include:
# 0. Setup
# 1. Load data
# 2. Run mediation analysis
#
# written by Amelink, J.S., last updated 2025-03-10
#--------------------------------------#

#--------------------------------------#
# Potential behavioral variables:
#  26302 - Specific cognitive ability (AS)
#  26306 - Response delay interval
#  6364 - Vocabulary level
#  6365 - Uncertainty in vocabulary level

#Any publications, journal articles or presentations using data from this category should acknowledge that
#this test was a modified version of the NIH Toolbox Picture Vocabulary Tests amended with permission from NIH Toolbox for use in UK Biobank. 


#The vocabulary levels as originally calculated during the test were obtained from difficulty
# levels calibrated to a US audience (see below), and following initial collection of the data,
# recalibration was carried out by Adam Hampshire’s team at Imperial College, London [2],
# resulting in the following derived data:
# - an estimate of cognitive ability (specific ability) when performing the picture vocabulary task
# -  estimate of the basic visuomotor processing times of the participant
# It is strongly recommended that the recalibrated estimate is used in preference to the original MLE calculation directly from the test.

# USE 26302 (!!!) (maybe validate with 6364?)


# Usage:
# module purge
# module load R/R-4.4.0
# Rscript mediation.R

#--------------------------------------#
### 0. SETUP ###
#--------------------------------------#


#install.packages("mediation")
library(mediation)
library(readr)


# set paths
# Define paths for both systems
workspace_base_linux_path = "/data/workspaces/lag/workspaces/lg-ukbiobank/"
workspace_base_windows_path = "P:\\workspaces\\lg-ukbiobank\\"

# Check system and set appropriate paths
if (.Platform$OS.type == "unix") {workspace_path <- workspace_base_linux_path} else {workspace_path <- workspace_base_windows_path}

wd_path <- file.path(workspace_path, "projects", "FLICA_multimodal")
# set working directory
setwd(wd_path)

# set file names
pgs_fn <- file.path(workspace_path, "projects", "FLICA_multimodal", "pgs_all_scores_uncor.tsv")
idps_fn <- file.path(workspace_path, "projects", "FLICA_multimodal", "rs_ics_32k_gcta_N32677.tsv")
cov_fn <- file.path(workspace_path, "projects", "FLICA_multimodal", "regenie_final_covs_32k.tsv")
beh_fn <- file.path(workspace_path, "derived_data", "phenotype_data", "cognitive", "ElsePheno_participant.tsv")

#--------------------------------------#
### 1. LOAD DATA ###
#--------------------------------------#

## load data + covariates
pgs <- read.table(pgs_fn, header = TRUE, sep = "\t", row.names = 1)
pgs_centered <- scale(pgs, center = TRUE, scale = TRUE)
pgs_centered <- pgs_centered[order(rownames(pgs_centered)),]
#remove "score_" from column names and capitalize
colnames(pgs_centered) <- gsub("score_", "", colnames(pgs_centered))
colnames(pgs_centered) <- toupper(colnames(pgs_centered))

## load IDPs
idps <- read.table(idps_fn, header = TRUE, sep = "\t")
idps$FID <- as.integer(idps$FID)
rownames(idps) <- idps$FID
idps$FID <- NULL
idps$IID <- NULL
colnames(idps) <- c("Extended", "Narrow")
idps <- scale(idps, center = TRUE, scale = TRUE)

## load behavioural data
beh_df <- read.table(beh_fn, header = TRUE, sep = "\t", row.names = 1)
beh_df <- beh_df[, c("X26302.2.0", "X6364.2.0")]
# remove rows with all NA values
beh_df <- beh_df[rowSums(is.na(beh_df)) < ncol(beh_df), ]
# center and scale
beh_df <- scale(beh_df, center = TRUE, scale = TRUE)
colnames(beh_df) <- c("COG_ABILITY", "PIC_VOCAB")

## load covariates
covariates <- read.table(cov_fn, header = TRUE, sep = "\t")
covariates$FID <- as.integer(covariates$FID)
rownames(covariates) <- covariates$FID
covariates$FID <- NULL
covariates$IID <- NULL
covariates <- scale(covariates, center = TRUE, scale = TRUE)

## set names
pgs_nms <- colnames(pgs_centered)
idp_nms <- colnames(idps)
beh_nms <- colnames(beh_df)
cov_nms <- colnames(covariates)

## combine data 

# get overlapping row IDs
row_ids <- Reduce(intersect, list(rownames(pgs_centered), rownames(idps), rownames(beh_df), rownames(covariates)))

# subset data
covariates <- covariates[row_ids, ]
pgs_centered <- pgs_centered[row_ids, ]
idps <- idps[row_ids, ]
beh_df <- beh_df[row_ids, ]
# combine data
all_data <- as.data.frame(cbind(pgs_centered, idps, beh_df, covariates))
print(paste("Dimensions dataframe after combination: ", dim(all_data)))

rm(pgs, pgs_centered, idps, beh_df, covariates)

# check for missing values
print(paste("Number of NaNs :", sum(is.na(all_data))))
# keep complete cases
all_data <- all_data[complete.cases(all_data), ]
print(paste("Dimensions dataframe after removing missing values:", dim(all_data)))

#--------------------------------------#
### 2. MEDIATION ANALYSIS ###
#--------------------------------------#

# Set significance level
no_effects = 5
alpha = 0.05 / (length(pgs_nms) * length(idp_nms) * length(beh_nms) * no_effects)

# Create dataframe to store results
results_df <- data.frame(
    PGS = character(),
    IDP = character(), 
    Behavior = character(),
    a_effect = numeric(),
    a_ci_lower = numeric(),
    a_ci_upper = numeric(),
    a_pvalue = numeric(),
    b_effect = numeric(), 
    b_ci_lower = numeric(),
    b_ci_upper = numeric(),
    b_pvalue = numeric(),
    direct_effect = numeric(),
    direct_ci_lower = numeric(),
    direct_ci_upper = numeric(),
    direct_pvalue = numeric(),
    indirect_effect = numeric(),
    indirect_ci_lower = numeric(),
    indirect_ci_upper = numeric(), 
    indirect_pvalue = numeric(),
    total_effect = numeric(),
    total_ci_lower = numeric(),
    total_ci_upper = numeric(),
    total_pvalue = numeric(),
    prop_mediated = numeric(),
    prop_mediated_ci_lower = numeric(),
    prop_mediated_ci_upper = numeric(),
    prop_mediated_pvalue = numeric(),
    stringsAsFactors = FALSE
)

for (pgx in pgs_nms) {
for (idp in idp_nms) {
for (beh in beh_nms) {

    # set up mediation models
    formula_a <- as.formula(paste(idp, "~", pgx, "+", paste(cov_nms, collapse = " + ")))
    formula_b <- as.formula(paste(beh, "~", idp, "+", paste(cov_nms, collapse = " + ")))
    formula_c <- as.formula(paste(beh, "~", pgx, "+", paste(cov_nms, collapse = " + ")))
    formula_c_prime <- as.formula(paste(beh, "~", pgx, "+", idp, "+", paste(cov_nms, collapse = " + ")))
    
    a <- glm(formula_a, data=all_data)
    b <- glm(formula_b, data=all_data)
    c <- glm(formula_c, data=all_data)
    c_prime <- glm(formula_c_prime, data=all_data)

    # get confidence intervals and p-values
    ci_a <- confint(a)
    ci_b <- confint(b)
    sig_a <- anova(a)
    sig_b <- anova(b)

    # run mediation analysis  
    med.out <- mediate(a, c_prime, treat=pgx, mediator=idp, covariates=cov_nms, sims=10000, boot=TRUE)
    
    # Store results in dataframe
    results_df <- rbind(results_df, data.frame(
        PGS = pgx,
        IDP = idp,
        Behavior = beh,
        a_effect = a$coef[2],
        a_ci_lower = ci_a[2,1],
        a_ci_upper = ci_a[2,2], 
        a_pvalue = sig_a$Pr[2],
        b_effect = b$coef[2],
        b_ci_lower = ci_b[2,1],
        b_ci_upper = ci_b[2,2],
        b_pvalue = sig_b$Pr[2],
        direct_effect = med.out$z0,
        direct_ci_lower = med.out$z0.ci[1],
        direct_ci_upper = med.out$z0.ci[2],
        direct_pvalue = med.out$z0.p,
        indirect_effect = med.out$d0,
        indirect_ci_lower = med.out$d0.ci[1],
        indirect_ci_upper = med.out$d0.ci[2],
        indirect_pvalue = med.out$d0.p,
        total_effect = med.out$tau.coef,
        total_ci_lower = med.out$tau.ci[1],
        total_ci_upper = med.out$tau.ci[2],
        total_pvalue = med.out$tau.p,
        prop_mediated = med.out$n0,
        prop_mediated_ci_lower = med.out$n0.ci[1],
        prop_mediated_ci_upper = med.out$n0.ci[2],
        prop_mediated_pvalue = med.out$n0.p
    ))

    rm(a, b, c, c_prime, ci_a, ci_b, sig_a, sig_b, med.out)
}
}
}


head(results_df)

# Write results to CSV
write_csv(results_df, file.path(workspace_path, "projects", "FLICA_multimodal", "mediation_results.csv"))
