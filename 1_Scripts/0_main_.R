# Setting the path to the current directory
if (interactive()) {
  # If in RStudio, use rstudioapi
  if ("rstudioapi" %in% rownames(installed.packages())) {
    setwd(dirname(rstudioapi::getSourceEditorContext()$path))
  }
}

# Username and Password for SQL Server
username_sql = 'root'
password_sql = 'qwe123@A@A' # Change the empty string to the password for your MySQL server

# Setting seed for reproducibility
set.seed(123)

# TRUE - RUN with Lyrical Features and FALSE - RUN without Lyrical Features
# Generate two sets of results based on the research questions in the report.
lyrical_switch = TRUE

print(paste(Sys.time(), ' :: INGESTING LIBRARIES AND FUNCTIONS'))
# Getting the libraries and the required functions
source("../0_Config/0_libraries.R", local = TRUE)
source("../0_Config/0_functions.R", local = TRUE)

# Checking for folder presence
folder_creation_check()

print(paste(Sys.time(), ' :: DOWNLOADING THE DATA FROM THE DATABASE'))
# Loading the Data from the Script
source("../0_config/0_musicoset_data_loading.R", local = TRUE)