# ------------------- Processing artist data -------------------

# Converting artist string to a list and counting the number of unique artists there are
df_meta_songs = df_meta_songs %>%
  # Getting the Artists IDs
  mutate(artist_id_vectors := mapply(extract_artist, artists)) %>%
  # Counting the number of artist that has worked on that song
  mutate(num_artist = str_count(as.character(artist_id_vectors), ",") + 1)

# Changing the inconsistent band names and also giving a new category to the artist type as not given" if there's '-'
# Doing the same with '-' in main_genre as 'not given'
df_meta_artists = df_meta_artists %>%
  # Changing 'band' to band
  mutate(artist_type = ifelse(artist_type == "'band'", 'band', artist_type)) %>%
  # Changing the NA given as '-'
  mutate(artist_type = ifelse(artist_type == '-', 'not given', artist_type)) %>%
  # Changing the NA given as '-'
  mutate(main_genre = ifelse(main_genre == '-', 'not given', main_genre))

# Adjusting follower column since it's character with some strings as 'None'
df_meta_artists = df_meta_artists %>%
  mutate(followers = ifelse(followers == 'None', '0', followers)) %>%
  # Changing from character to integer
  # Changing from character to integer
  mutate(followers = as.integer(followers))

# Renaming the artist type to make it more consistent
df_meta_artists = df_meta_artists %>%
  rename('artist_popularity' = 'popularity') %>%
  mutate(artist_type = ifelse(artist_type == 'duo', "Duo", artist_type),
         artist_type = ifelse(artist_type == 'band', "Band", artist_type),
         artist_type = ifelse(artist_type == 'rapper', "Rapper", artist_type),
         artist_type = ifelse(artist_type == 'singer', "Singer", artist_type)) %>%
  select(-c(image_url, genres))

# Categorize artist followers in bins for the charts
df_meta_artists = df_meta_artists %>%
  mutate(followers_category = cut(followers, 
                                  breaks = c(0, 10000, 50000, 100000, 500000, Inf), 
                                  labels = c("<10K", "10K-50K", "50K-100K", "100K-500K", ">500K")))

# ------------------- Processing songs data -------------------

# Dropping the null values (only one where the song_id is just and empty string)
df_meta_songs = df_meta_songs %>%
  filter(!song_id %in% c("")) %>%
  # Filter the solo songs only (aligning with the research question)
  filter(song_type == 'Solo') %>%
  mutate(artist_id = as.character(artist_id_vectors)) %>%
  rename("song_popularity" = "popularity") %>%
  select(-c(billboard, artists, artist_id_vectors))

df_all = df_meta_songs %>% left_join(df_meta_artists, by = c('artist_id'))