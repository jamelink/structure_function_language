# Add inflaction correction to TWAS results using bacon
# Written by: Amelink, J.S., last updated 2025-03-11


### 0. SETUP ###
#install.packages("bacon")
library(bacon)
library(readr)

# set paths
# Define paths for both systems
workspace_base_linux_path = "/data/workspaces/lag/workspaces/lg-ukbiobank"
workspace_base_windows_path = "P:/workspaces/lg-ukbiobank"

# Check system and set appropriate paths
if (.Platform$OS.type == "unix") {workspace_path <- workspace_base_linux_path} else {workspace_path <- workspace_base_windows_path}

wd_path <- file.path(workspace_path, "projects", "FLICA_multimodal")
# set working directory
setwd(wd_path)

# get file names from path
results_5c_path <- file.path(workspace_path, "projects", "FLICA_multimodal", "evo_annots", "twas", "5c")
results_10c_path <- file.path(workspace_path, "projects", "FLICA_multimodal", "evo_annots", "twas", "10c")

# get all files in the directory

fns <- list.files(results_5c_path, full.names = TRUE)
fns_10c <- list.files(results_10c_path, full.names = TRUE)
#combine files



### 1. FUNCTIUON TO ADD BACON INFLATION CORRECTION TO TWAS RESULTS ###

add_bacon <- function(fn) {
  print("Adding bacon correction to: ")
  print(fn)
  # load data
  data <- read.table(fn, header = TRUE, sep = ",")
  
  head(data)
  # run bacon
  bc <- bacon(data$zscore)
  
  # add bacon results to data
  data$BACON_LAMBDA <- as.numeric(inflation(bc))
  data$BACON_bias <- as.numeric(bias(bc))
  data$BACON_P <- as.numeric(pval(bc))
  data$BACON_Z <- as.numeric(tstat(bc))
  # save data
  out_fn <- gsub(".tsv", "_bacon.csv", fn)
  write_csv(as.data.frame(data), out_fn)
  rm(data)
  rm(bc)
}

### 2. APPLY BACON INFLATION CORRECTION TO ALL TWAS RESULTS FILES ###
for (fn in fns) {
    add_bacon(fn)
}


for (fn in fns_10c) {
    add_bacon(fn)
}
