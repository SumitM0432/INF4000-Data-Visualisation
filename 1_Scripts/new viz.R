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

df_meta_artists = df_meta_artists %>%
  rename('artist_popularity' = 'popularity') %>%
  mutate(artist_type = ifelse(artist_type == 'duo', "Duo", artist_type),
         artist_type = ifelse(artist_type == 'band', "Band", artist_type),
         artist_type = ifelse(artist_type == 'rapper', "Rapper", artist_type),
         artist_type = ifelse(artist_type == 'singer', "Singer", artist_type)) %>%
  select(-c(image_url, genres))

# Categorize artist followers
df_meta_artists = df_meta_artists %>%
  mutate(followers_category = cut(followers, 
                                  breaks = c(0, 10000, 50000, 100000, 500000, Inf), 
                                  labels = c("<10K", "10K-50K", "50K-100K", "100K-500K", ">500K")))

# Dropping the null values (only one where the song_id is just and empty string)
df_meta_songs = df_meta_songs %>%
  filter(!song_id %in% c("")) %>%
  filter(song_type == 'Solo') %>%
  mutate(artist_id = as.character(artist_id_vectors)) %>%
  rename("song_popularity" = "popularity") %>%
  select(-c(billboard, artists, artist_id_vectors))

df_all = df_meta_songs %>% left_join(df_meta_artists, by = c('artist_id'))

####----- 1st -----####
df_all_songpop = df_pop_songs %>%
  left_join(df_all %>% select(song_id, song_popularity) %>% distinct(), by = c('song_id')) %>%
  filter(is.na(song_popularity) == FALSE) %>%
  mutate(year_group = floor(year / 4) * 4) %>%
  group_by(year_group) %>%
  summarize(
    mean_song_popularity = mean(song_popularity, na.rm = TRUE)
  )

df_all_artistpop = df_pop_artists %>%
  left_join(df_all %>% select(artist_id, artist_popularity) %>% distinct(), by = c('artist_id')) %>%
  filter(is.na(artist_popularity) == FALSE) %>%
  mutate(year_group = floor(year / 4) * 4) %>%
  group_by(year_group) %>%
  summarize(
    mean_artist_popularity = mean(artist_popularity, na.rm = TRUE)
  )

df_all_year = df_all_songpop %>% left_join(df_all_artistpop, by = c('year_group'))

plot_1 = ggplot(df_all_year, aes(x = as.factor(year_group))) +
  geom_area(aes(y = mean_artist_popularity, group = 1, fill = "Artist Popularity"), alpha = 0.6, color = "darkorange") +
  geom_area(aes(y = mean_song_popularity, group = 1, fill = "Song Popularity"), alpha = 0.6, color = "darkcyan") +
  geom_line(aes(y = mean_artist_popularity, group = 1, color = "Artist Popularity"), size = 1.2) +
  geom_line(aes(y = mean_song_popularity, group = 1, color = "Song Popularity"), size = 1.2) +
  geom_point(aes(y = mean_artist_popularity, color = "Artist Popularity"), size = 2.5) +
  geom_point(aes(y = mean_song_popularity, color = "Song Popularity"), size = 2.5) +
  scale_color_manual(values = c("Artist Popularity" = "darkorange", "Song Popularity" = "darkcyan")) +
  scale_fill_manual(values = c("Artist Popularity" = "darkorange", "Song Popularity" = "darkcyan")) +
  scale_y_continuous(
    name = "Average Popularity",  # Label for y-axis
    breaks = seq(0, 100, by = 10)  # Adjust the range and step size of ticks
  ) +
  labs(
    title = "Average Artist and Song Popularity Over Time",
    x = "Year",
    y = "Average Popularity",
    color = "Legend",
    fill = "Legend",
    caption = "Source: MuscicOSet Dataset"
  ) +
  theme_minimal() +
  theme(text = element_text(family = 'mono'),
        plot.title = element_text(hjust = 0.5, size = 13, face = 'bold'),
        axis.title.x = element_text(size = 13, face = 'bold'),
        axis.title.y = element_text(size = 13, face = 'bold'),
        axis.text.x = element_text(size = 12, face = 'bold', angle = 45, hjust = 1),
        axis.text.y = element_text(size = 12, face = 'bold'),
        legend.title = element_text(size = 12, face = 'bold'),
        legend.text = element_text(size = 10, face = 'bold'),
        legend.position = "bottom"
  )

plot(plot_1)
ggsave(paste0("plot_1.jpeg"), plot_1)

####----- 2nd -----####
# Aggregating data for the chart
stacked_data = df_all %>%
  group_by(artist_type, followers_category) %>%
  summarise(mean_popularity = mean(song_popularity, na.rm = TRUE)) %>%
  filter(is.na(followers_category) == FALSE) %>%
  filter(artist_type != 'not given')

text_colors = c(
  "<10K" = "white",
  "10K-50K" = "white",
  "50K-100K" = "white",
  "100K-500K" = "white",
  ">500K" = "gray3"
)

# Stacked Bar Chart with Manually Adjusted Text Colors
plot_2 = ggplot(stacked_data, aes(x = artist_type, y = mean_popularity, fill = followers_category)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(
    title = "Impact of Artist Type and Follower Base on Song Popularity",
    x = "Types of Artists",
    y = "Average Song Popularity",
    fill = "Followers",
    caption = "Source: MuscicOSet Dataset"
  )+
  geom_text(
    aes(
      label = round(mean_popularity, 1),
      group = followers_category,
      color = followers_category  # Assign text colors by category
    ),
    position = position_stack(vjust = 0.5),
    size = 3, fontface = "bold"
  ) +
  scale_color_manual(values = text_colors, guide = 'none') +
  scale_fill_viridis_d(option = "viridis") +
  theme_minimal() +
  theme(text = element_text(family = 'mono'),
        plot.title = element_text(hjust = 0.5, size = 13, face = 'bold'),
        axis.title.x = element_text(size = 13, face = 'bold'),
        axis.title.y = element_text(size = 13, face = 'bold'),
        axis.text.x = element_text(size = 13, face = 'bold'),
        axis.text.y = element_text(size = 13, face = 'bold'),
        legend.title = element_text(size = 12, face = 'bold'),
        legend.text = element_text(size = 10, face = 'bold'),
        legend.position = "right"
  )

plot(plot_2)
ggsave(paste0("plot_2.jpeg"), plot_2)

####----- 3rd -----####
# Prepare the data
df_treemap = df_all %>%
  filter(!is.na(main_genre), main_genre != "not given") %>%
  group_by(main_genre) %>%
  summarise(
    count = n(),
    avg_popularity = mean(song_popularity, na.rm = TRUE)
  ) %>%
  arrange(desc(count)) %>%
  mutate(
    main_genre = ifelse(row_number() >= 50, "Others", main_genre)
  ) %>%
  group_by(main_genre) %>%
  summarise(
    count = sum(count),
    avg_popularity = mean(avg_popularity, na.rm = TRUE)
  )

# Plot the treemap
treemap(
  df_treemap,
  index = "main_genre",          # Labels for tiles
  vSize = "count",              # Size of the tiles
  vColor = "avg_popularity",    # Color by average popularity
  type = "value",               # Color scale type
  title = "Top 50 Genres and their Impact on Song Popularity",
  palette = "RdYlGn",            # Color palette
  fontsize.labels = 12,       # Font size for labels
  fontsize.title = 18,        # Font size for the title
  fontfamily.labels = "Arial",# Font family for labels
  fontfamily.title = "Arial", # Font family for the title
  title.legend = "Average Popularity",  # Legend title
  fontsize.legend = 10,       # Font size for legend
  border.col = "black",       # Border color for tiles
  border.lwds = 1.5   
)

####----- 4th -----####
# Data preparation (grouped by year_gap for explicit and non-explicit counts)
df_dumbbell = df_all %>%
  left_join(df_pop_songs %>% select(song_id, year) %>% distinct(), by = c('song_id')) %>%
  filter(!is.na(year)) %>%
  mutate(year_gap = floor(year / 4) * 4) %>%
  group_by(year_gap, explicit) %>%
  summarize(num_artists = n_distinct(artist_id), .groups = "drop") %>%
  pivot_wider(names_from = explicit, values_from = num_artists, values_fill = 0) %>%
  rename(Explicit = `True`, Non_Explicit = `False`)

# Dumbbell Chart
plot_4 = ggplot(df_dumbbell, aes(x = Explicit, xend = Non_Explicit, y = as.factor(year_gap))) +
  geom_dumbbell(
    size = 3,  
    size_x = 3,
    size_xend = 3,
    colour = "lightgray",
    colour_x = "firebrick3",
    colour_xend = "deepskyblue3"
  ) +
  scale_x_continuous(breaks = seq(0, max(df_dumbbell$Explicit, df_dumbbell$Non_Explicit), by = 100)) +
  geom_point(aes(x = Explicit, color = "Explicit"), size = 3) +
  geom_point(aes(x = Non_Explicit, color = "Non-Explicit"), size = 3) +
  # Define color scale for the legend
  scale_color_manual(
    name = "Artist Type:",  # Legend title
    values = c("Explicit" = "firebrick3", "Non-Explicit" = "deepskyblue3")
  ) +
  labs(
    title = "Comparison of Explicit and Non-Explicit Artists Over Time",
    subtitle = "Explicit vs. Non-Explicit",
    x = "Number of Artists",
    y = "Year",
    caption = "Source: MuscicOSet Dataset"
  ) +
  theme_minimal() +
  theme(text = element_text(family = 'mono'),
        plot.subtitle = element_text(size = 12, hjust = 0.5, color = "darkgray"),  # Subtitle style
        plot.title = element_text(hjust = 0.5, size = 13, face = 'bold'),
        axis.title.x = element_text(size = 13, face = 'bold', vjust = -1.2),
        axis.title.y = element_text(size = 13, face = 'bold', vjust = 1.2),
        axis.text.x = element_text(size = 12, face = 'bold'),
        axis.text.y = element_text(size = 12, face = 'bold'),
        legend.title = element_text(size = 12, face = 'bold'),
        legend.text = element_text(size = 10, face = 'bold'),
        legend.position = "bottom"
  ) +
  guides(
    color = guide_legend(override.aes = list(
      size = 5, shape = 16  # Custom size and shape for legend points
    ))
  ) +
  geom_text(
    aes(label = Explicit, x = Explicit - 5),  # Add Explicit labels slightly to the left
    size = 3.4, color = "firebrick3", vjust = 0.5, hjust = 1.5
  ) +
  geom_text(
    aes(label = Non_Explicit, x = Non_Explicit + 5),  # Add Non-Explicit labels slightly to the right
    size = 3.4, color = "deepskyblue3", vjust = 0.5, hjust = -0.5,
  )

plot(plot_4)
ggsave(paste0("plot_4.jpeg"), plot_4)
