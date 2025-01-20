print(paste(Sys.time(), ' :: 1st Line Chart : Average Artist and Song Popularity over time'))
# First Visual

# joining the year and removing the null song popularity and grouping by years
df_all_songpop = df_pop_songs %>%
  left_join(df_all %>% select(song_id, song_popularity) %>% distinct(), by = c('song_id')) %>%
  filter(is.na(song_popularity) == FALSE) %>%
  mutate(year_group = floor(year / 4) * 4) %>%
  group_by(year_group) %>%
  summarize(
    mean_song_popularity = mean(song_popularity, na.rm = TRUE)
  )

# joining the year and removing the null artist popularity and grouping by years
df_all_artistpop = df_pop_artists %>%
  left_join(df_all %>% select(artist_id, artist_popularity) %>% distinct(), by = c('artist_id')) %>%
  filter(is.na(artist_popularity) == FALSE) %>%
  mutate(year_group = floor(year / 4) * 4) %>%
  group_by(year_group) %>%
  summarize(
    mean_artist_popularity = mean(artist_popularity, na.rm = TRUE)
  )

# joining both the tables
df_all_year = df_all_songpop %>% left_join(df_all_artistpop, by = c('year_group'))

# Plotting the visual
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

# Saving the plot
plot(plot_1)
ggsave(paste0("../3_Outputs/Plots/plot_1.jpeg"), plot_1)

print(paste(Sys.time(), ' :: 2nd Stacked Bar chart : Average Popularity by number of followers and artist type'))
# Second Visual

# Aggregating data for the chart
stacked_data = df_all %>%
  group_by(artist_type, followers_category) %>%
  summarise(mean_popularity = mean(song_popularity, na.rm = TRUE)) %>%
  filter(is.na(followers_category) == FALSE) %>%
  filter(artist_type != 'not given')

# Assigning color for the bar
text_colors = c(
  "<10K" = "white",
  "10K-50K" = "white",
  "50K-100K" = "white",
  "100K-500K" = "white",
  ">500K" = "gray3"
)

# Stacked Bar Chart
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

# Saving the plot
plot(plot_2)
ggsave(paste0("../3_Outputs/Plots/plot_2.jpeg"), plot_2)

print(paste(Sys.time(), ' :: 3rd Treemap : Top Artist Genre and average popularity'))
# Third Visual

# cleaning the data and aggregating to extract the top genres
df_treemap = df_all %>%
  filter(!is.na(main_genre), main_genre != "not given") %>%
  group_by(main_genre) %>%
  summarise(
    count = n(),
    avg_popularity = mean(song_popularity, na.rm = TRUE)
  ) %>%
  arrange(desc(count)) %>%
  # Extracting only the top 50 genres to reduce the clutter
  mutate(main_genre = ifelse(row_number() >= 50, "Others", main_genre)) %>%
  # Changing to title case for the visual
  mutate(main_genre = str_to_title(main_genre)) %>%
  group_by(main_genre) %>%
  summarise(
    count = sum(count),
    avg_popularity = mean(avg_popularity, na.rm = TRUE)
  )

# Setting the size of the plotting window and saving option
options(repr.plot.width = 10, repr.plot.height = 7)

treemap(
  df_treemap,
  index = "main_genre",
  vSize = "count",
  vColor = "avg_popularity",
  type = "value",
  title = "Top 50 Artist Genres and their Impact on Song Popularity",
  palette = "RdYlGn",
  fontsize.labels = 12,
  fontsize.title = 18,
  fontfamily.labels = "mono",
  fontfamily.title = "mono",
  title.legend = "Average Popularity", # Legend title
  fontsize.legend = 10,
  border.col = "black", # Border color for tiles
  border.lwds = 1.5
)

# Settings for saving the plot
png("../3_Outputs/Plots/plot_3.jpeg", width = 1200, height = 800)

treemap(
  df_treemap,
  index = "main_genre",
  vSize = "count",
  vColor = "avg_popularity",
  type = "value",
  title = "Top 50 Artist Genres and their Impact on Song Popularity",
  palette = "RdYlGn",
  fontsize.labels = 12,
  fontsize.title = 18,
  fontfamily.labels = "mono",
  fontfamily.title = "mono",
  title.legend = "Average Popularity", # Legend title
  fontsize.legend = 10,
  border.col = "black", # Border color for tiles
  border.lwds = 1.5
)

# Close the device to save the file
dev.off()  

print(paste(Sys.time(), ' :: 4th Dumbell : Number of Explicit and Non-Explicit artist over time'))
# Fourth Visual

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

# Saving the plot
plot(plot_4)
ggsave(paste0("../3_Outputs/Plots/plot_4.jpeg"), plot_4)