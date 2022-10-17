library(plotly)
library(tidyverse)

candidates_df <- read_csv("data/candidates_data_numeric.csv")

candidates_df <- candidates_df %>% 
  replace(is.na(.), 0)

candidates_pca <- candidates_df %>%
  select_if(is.numeric) %>%
  prcomp(center = TRUE,scale. = TRUE)

summary(candidates_pca)

centroids <-  candidates_df %>%
  select(!starts_with("Q")) %>%
  bind_cols(candidates_pca$x) %>%
  group_by(parti) %>%
  summarise(PC1_m = mean(PC1),
            PC2_m = mean(PC2))

p <- candidates_df %>%
  select(!starts_with("Q")) %>%
  bind_cols(candidates_pca$x) %>%
  mutate(txt= glue::glue("{navn}\n{parti}\n{kreds}")) %>%
  ggplot(aes(PC1, PC2, colour=parti)) +
  geom_point(aes(text = txt)) +
  scale_color_viridis_d(option="C") +
  theme_minimal() +
  geom_point(data=centroids,aes(x=PC1_m, y=PC2_m, size=5,text=parti),shape=1) +
  geom_text(data=centroids,aes(x=PC1_m, y=PC2_m,label=parti, size=15)) +
  #geom_label(data=centroids,aes(x=PC1_m, y=PC2_m,label=parti)) +
  stat_ellipse()

ggplotly(p, tooltip = "text")
