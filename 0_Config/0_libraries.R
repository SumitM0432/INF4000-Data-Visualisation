# Libraries for Data Ingestion
if (!requireNamespace("RMySQL")) install.packages("RMySQL")
library("RMySQL")

if (!requireNamespace("DBI")) install.packages("DBI")
library("DBI")

# Libraries for Preprocessing and Plotting
if (!requireNamespace("data.table")) install.packages("data.table")
library("data.table")

if (!requireNamespace("tidyverse")) install.packages("tidyverse")
library("tidyverse")

if (!requireNamespace("treemap")) install.packages("treemap")
library("treemap")

if (!requireNamespace("ggalt")) install.packages("ggalt")
library("ggalt")
