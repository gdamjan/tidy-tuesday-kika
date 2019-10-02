library(tidyverse)

pizza_barstool <-
  readr::read_csv(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-10-01/pizza_barstool.csv"
  )

# compare how pizzerias are rated by community vs. Dave

# first grab just columns we need
pzbs <-
  pizza_barstool %>%
  dplyr::select(name, 
                address = address1, 
                city, 
                tidyselect::contains("average_score"))

# calculate the other two dataset
# that we created in the exploratory session

# color the pizzerias based on the degree of rating disagreement
# first lets calculate the difference in rating

rate_diff <-
  pzbs %>% 
  filter(review_stats_community_average_score > 0) %>% 
  mutate(
    difference = 
      review_stats_community_average_score - review_stats_dave_average_score
  )

# highlight points (outliers, influential values,..)
# we need another dataset, this time for the five pizzerias
# with largest negative and positive difference

rate_diff_top5 <- rate_diff %>%
  mutate(pos_neg = ifelse(difference > 0, "preferred by community", "preferred by dave")) %>%
  group_by(pos_neg) %>%
  top_n(n = 5, wt = abs(difference))

# should have everything to build the plot

ggplot(data = pzbs) +
  aes(x = review_stats_community_average_score) +
  aes(y = review_stats_dave_average_score) +
  geom_point(data=rate_diff, inherit.aes = TRUE, aes(size=abs(difference), fill=difference), pch=21) +
  theme_minimal() +
  theme(legend.position = 'top') +
  coord_cartesian() +
  scale_fill_gradient2(name="Difference in rating",
                       low = "purple", 
                       mid = "darkgrey", 
                       high = "forestgreen", 
                       guide = guide_colourbar(
                         title.vjust = 1,
                         # frame.colour = 'black',
                         frame.linewidth = 0.5,
                         ticks.colour = 'white',
                         ticks.linewidth = 2,
                         barheight = unit(.35, "cm"),
                         barwidth = unit(8, "cm"),
                         draw.ulim = TRUE,
                         draw.llim = TRUE
                       )
  )

