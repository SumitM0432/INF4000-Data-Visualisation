if (data_load_type == 'SQL'){
  print ("INGESTING DATA THROUGH SQL")
  
  # Setting up the connection with the MySQL Server (user and password will change according to the user)
  con = dbConnect(RMySQL::MySQL(),
                  host = 'localhost',
                  port = 3306,
                  user = username_sql,
                  password = password_sql)
  
  # Using the database where the sql script is run and tables are saved
  dbSendQuery(con, "USE musicoset;")
  
  # Using SQL
  # Running the queries to ingest the required tables and converting them to data table for further preprocessing
  # Music Metadata
  artists_results = dbSendQuery(con, "SELECT DISTINCT * FROM musicoset.artists;")
  df_meta_artists = data.table(fetch(artists_results, n = -1)) # -1 flag used to ingest all the rows
  
  songs_results = dbSendQuery(con, "SELECT DISTINCT * FROM musicoset.songs;")
  df_meta_songs = data.table(fetch(songs_results, n = -1)) # -1 flag used to ingest all the rows
  
  # Music Popularity Pop
  artists_pop_results = dbSendQuery(con, "SELECT DISTINCT * FROM musicoset.artist_pop;")
  df_pop_artists = data.table(fetch(artists_pop_results, n = -1)) # -1 flag used to ingest all the rows
  
  song_pop_results = dbSendQuery(con, "SELECT DISTINCT * FROM musicoset.song_pop;")
  df_pop_songs = data.table(fetch(song_pop_results, n = -1)) # -1 flag used to ingest all the rows
} else {
  print ("INGESTING DATA THROUGH CSVs")
  # Using CSVs
  # Music Metadata
  df_meta_artists = fread("../1_Dataset/musicoset_metadata/artists.csv")
  df_meta_songs = fread("../1_Dataset/musicoset_metadata/songs.csv") %>%
    mutate(explicit = ifelse(explicit == TRUE, "True", "False"))
  
  # Music Popularity Pop
  df_pop_artists = fread("../1_Dataset/musicoset_popularity/artist_pop.csv") %>%
    select(-c(is_pop))
  df_pop_songs = fread("../1_Dataset/musicoset_popularity/song_pop.csv") %>%
    select(-c(is_pop))
}

# Garbage collection
gc()

# Saving RData for decrease the data loading time
tables_to_save <- grep("df", ls(), value = TRUE)
save(list = tables_to_save, file = paste0('../3_Outputs/RData/Loaded_Music_Data.RData'))