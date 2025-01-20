# Setting the path to the current directory
if (interactive()) {
  # If in RStudio, use rstudioapi
  if ("rstudioapi" %in% rownames(installed.packages())) {
    setwd(dirname(rstudioapi::getSourceEditorContext()$path))
  }
}

# Setting seed for reproducibility
set.seed(123)

data_load_type = 'CSV' # Choosing how to ingest the data 'SQL' or 'CSV'

if (data_load_type == 'SQL') {
  # Username and Password for SQL Server
  username_sql = 'root'
  password_sql = 'qwe123@A@A' # Change the empty string to the password for your MySQL server
}

print(paste(Sys.time(), ' :: INGESTING LIBRARIES AND FUNCTIONS'))
# Getting the libraries and the required functions
source("../0_Config/0_libraries.R", local = TRUE)
source("../0_Config/0_functions.R", local = TRUE)

# Checking for folder presence
folder_creation_check()

print(paste(Sys.time(), ' :: INGESTING THE DATA FROM'))
# Loading the Data from the Script
source("../0_config/0_musicoset_data_loading.R", local = TRUE)

print(paste(Sys.time(), ' :: PREPROCESSING THE DATA'))
# Preprocessing the data to get it ready for visualization
source("../2_Scripts/1_data_preprocessing.R", local = TRUE)

print(paste(Sys.time(), ' :: RUNNING THE VISUALIZATION SCRIPT'))
# Generating the 4 visuals used in the study
source("../2_Scripts/2_visualization.R", local = TRUE)