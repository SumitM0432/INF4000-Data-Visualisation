folder_creation_check = function() {
  # Description : This function check if the required folders for the process are present or not
  #               If the folder is not present, it create them so the scripts run uninterrupted
  
  # Creating the Results Folder to save the plots for results
  if (!dir.exists("../3_Outputs/Plots")){
    dir.create("../3_Outputs/Plots", recursive = TRUE)
    
    print("Results Directory Created!")
  }else{
    print("Results Directory Exist!")
  }
  
  # Creating the RData Folder to save the plots for results
  if (!dir.exists("../3_Outputs/RData")){
    dir.create("../3_Outputs/RData", recursive = TRUE)
    
    print("RData Directory Created!")
  }else{
    print("RData Directory Exist!")
  }
}

extract_artist = function(val) {
  # Description : This function clean and extract the list of artists present in the df_meta_songs as one song can have multiple artists
  
  # Matches a literal expression saying extract anything between ' - ': where .* means match any sequence and ? means make it non greedy
  id = str_extract_all(val, "'(.*?)':")[[1]]
  # Replace ' and :
  id = str_replace_all(id, "[':]", "")
  # Replace anything that is there before ,
  id = str_replace_all(id, "(.*?), ", "")
  # Making a vector
  id_vector = as.vector(id)
  
  return (id_vector)
}