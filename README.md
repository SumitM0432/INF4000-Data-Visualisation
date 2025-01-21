# INF4000-Data-Visualisation

### Description
This repository contains the codebase for the INF4000 Data Visualization Module report. It includes data preprocessing and visualization scripts, and it generates the visualizations used in the report.

### File Structure
```
├── 0_Config
│    ├── 0_functions.R
│    ├── 0_libraries.R
│    └── 0_musicoset_data_loading.R
├── 1_Dataset
│    ├── musicoset_metadata
│    └── musicoset_popularity
├── 2_Scripts
│    ├── 0_main_.R
│    ├── 1_data_preprocessing.R
│    └── 2_visualization.R
├── 3_Outputs
│    ├── Plots
└──  └── RData
```
##### Configuration Scripts (0_Config/):
```
0_functions.R - Script consisting of all the functions used in the main scripts

0_libraries.R - Script to install the Required libraries

0_musicoset_data_loading.R - Loading the data from the SQL server or CSV
```

##### Main Scripts (1_Scripts/):
```
0_main_.R - Main Script to run all the required scripts in order

1_data_preprocessing.R - Script to do the data preprocessing

2_visualization.R - Script that generates and saves the plots.
```

##### Output Folders (2_Outputs/):
```
Plots Folder: Saved Plots

RData Folder: Saves the RData generated from running the scripts.
```
## Instructions for Running the Code
#### Using SQL
### 1. Ingesting the dataset
1. On the terminal install MySQL.
2. Download the SQL Script from the [MusicOSet Dataset](https://marianaossilva.github.io/DSW2019/index.html#relational>) Website.
3. Make the Database 'musicoset' and use the same database.
4. Run the SQL Script.
   
![Screenshot 2025-01-04 at 8 44 08 PM](https://github.com/user-attachments/assets/72af55fc-2b9b-4315-a4f9-c8feada97bc1)

### 2. Setting up the Configuration
##### Note: The configuration variable needs to be set in 1_Scripts/0_main_.R file
1. Change the data_load_type variable to "SQL"
2. Change the username and password for the MySQL server to ingest the data.

#### Using CSV
1. Change the data_load_type variable to "CSV".

### Running the Code (Scripts)
1. Run the ```0_main_.R``` Script.
*NOTE: This script runs all the required scripts and produces the results.*
