library(tidyverse)
library(ggrepel)
library(ggpubr)

pizza_barstool <-
  readr::read_csv(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-10-01/pizza_barstool.csv"
  )

vv <- viridis::viridis(n = 9, alpha = .8, begin = .2 ,option = "C")[c(1,5,9)]

# compare how pizzerias are rated by community vs. Dave

# first grab just columns we need
pzbs <-
  pizza_barstool %>%
  dplyr::select(name,
                address = address1,
                city,
                tidyselect::contains("average_score")) %>%
  filter(review_stats_community_average_score > 0)%>%
  filter(review_stats_dave_average_score > 0.2)

# calculate the other two dataset
# that we created in the exploratory session

# color the pizzerias based on the degree of rating disagreement
# first lets calculate the difference in rating

rate_diff <-
  pzbs %>%
  mutate(difference =
           review_stats_community_average_score - review_stats_dave_average_score)  %>% 
  mutate(agreement=1/difference)

# highlight points (outliers, influential values,..)
# we need another dataset, this time for the five pizzerias
# with largest negative and positive difference

rate_diff_top5 <- rate_diff %>%
  mutate(pos_neg = ifelse(difference > 0, "preferred by community", "preferred by dave")) %>%
  group_by(pos_neg) %>%
  top_n(n = 5, wt = abs(difference)) %>% 
  ungroup

# more modifications to this data frame
# to make coordinates for segments 
# for manual labels

rdt5 <- 
  rate_diff_top5 %>% 
  mutate(name_city= paste(name, "\n(", city, ")", sep="")) %>% 
  select(name, name_city, contains("dave"), contains("community"), pos_neg, difference) %>% 
  arrange(pos_neg, desc(difference)) %>% 
  mutate(xend=c(rep(10.1,5), rep(2.4, 5))) %>% 
  mutate(yend=c(5,2,3,4,6, 7,6,10,9,8)) %>% 
  rename(x=review_stats_community_average_score,
         y=review_stats_dave_average_score)


# should have everything to build the plot

## geoms
PP <-
  ggplot(data = pzbs) +
  geom_abline(slope = 1,
              intercept = 0,
              linetype = 2) +
  aes(x = review_stats_community_average_score) +
  aes(y = review_stats_dave_average_score) +
  geom_point(
    data = rate_diff,
    inherit.aes = TRUE,
    color = "white",
    aes(size = abs(difference), fill = difference),
    pch = 21
  ) +
  geom_segment(
    data = rdt5,
    size = .5,
    linetype = 3,
    aes(
      x = x,
      y = y,
      xend = xend,
      yend = yend
    )
  ) +
  geom_label(
    data = rdt5,
    aes(
      x = xend,
      y = yend,
      fill = difference,
      label = str_wrap(name, 22)
    ),
    size = 3.5,
    hjust = c(rep(0, 5), rep(1, 5))
  )

## scales
PP <- PP +
  scale_fill_gradient2(
    name = "",
    low = vv[1],
    mid = vv[2],
    high = vv[3],
    limits = c(-5, 7.5),
    breaks = c(-5,-2.5, 0, 2.5, 5, 7.5),
    labels = c(
      "Dave's favorites\nrated low by the community",
      "",
      "",
      "",
      "",
      "Community favorites\nrated low by Dave"
    ),
    guide = guide_colourbar(
      title.vjust = 1,
      frame.colour = 'white',
      label.position = "top",
      frame.linewidth = 1,
      ticks.colour = 'white',
      ticks.linewidth = 2,
      barheight = unit(.30, "cm"),
      barwidth = unit(8, "cm"),
      draw.ulim = TRUE,
      draw.llim = TRUE
    )
  ) +
  scale_y_continuous(breaks = seq(0, 10, 2), limits = c(0, 12)) +
  scale_x_continuous(breaks = seq(0, 10, 2), limits = c(0, 12)) +
  scale_size_continuous(range = c(0.5, 8), guide = "none")

## labs
PP <- PP +
  labs(x = "Community rating (average)") +
  labs(y = "Dave's rating") +
  labs(title = "Trust Dave?") +
  labs(subtitle = "Or follow the crowd?") +
  labs(caption = "TidyTuesdayAtKIKA using pizza_barstool data")

## theme
PP <- PP +
  theme_minimal() +
  theme(legend.position = 'bottom') +
  theme(panel.background = element_rect(fill = "grey80", color = "white")) +
  theme(plot.background = element_rect(fill = "grey80", color = "grey60")) +
  theme(axis.title = element_text(hjust = 1, size = 12)) +
  theme(axis.text = element_text(hjust = 1, size = 10))
  
PP

# other ways to label stuff

# +
#   geom_label_repel(
#     data = rate_diff_top5, force=10,
#     aes(x = review_stats_community_average_score,
#         y = review_stats_dave_average_score,
#         label = name, 
#         fill=difference),
#     alpha=.8,
#     inherit.aes = FALSE
#   ) 

# function to make fancy labels
# library(ggforce)
# gmark <- function(row) {
#   geom_mark_circle(
#   data = row,
#   label.fontsize = 8,
#   label.fill = NA,
#   aes(x = review_stats_community_average_score,
#       y = review_stats_dave_average_score,
#       label = name),
#   inherit.aes = FALSE
# )
# }
# 
# 
# PP + map(1:10, function(x) slice(rate_diff_top5, x) %>% gmark)
