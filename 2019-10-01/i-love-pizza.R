# I love pizza

library(tidyverse)

#pizza_jared <-
#  readr::read_csv(
#    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-10-01/pizza_jared.csv"
#  )
pizza_barstool <-
  readr::read_csv(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-10-01/pizza_barstool.csv"
  )
#pizza_datafiniti <-
#  readr::read_csv(
#    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-10-01/pizza_datafiniti.csv"
#  )


# compare how pizzerias are rated by community vs. critics

# first grab just columns we need
pzbs <-
  pizza_barstool %>% 
  dplyr::select(name, address = address1, city, tidyselect::contains("average_score"))

# first a basic scatter plot
(
  community_vs_dave <- 
    ggplot(data = pzbs) +
    aes(x = review_stats_community_average_score) +
    aes(y = review_stats_dave_average_score) +
    geom_point(pch=21, size=3) +
    theme_classic()
)


# now lets add a 1:1 line (intercept = 0, slope 1)
# tells us how much agreement there is between the community and dave 

community_vs_dave + geom_abline(slope = 1, intercept = 0)

# alternatively, we can fit a linear model through these data

community_vs_dave + geom_smooth(method = "lm")

# clearly the pizzerias not rated by the community (0 score on x)
# are pushing the intercept away from 0

# update the plot with filtered data

# `%+%` is a special ggplot operator for changing the data in place
# for other components (layers, titles, scales) `+` works 
# see ?`%+%`

no_zeros <- community_vs_dave %+% filter(pzbs, review_stats_community_average_score > 0)

# now the 1:1 line and the linear regression are much closer!
no_zeros + geom_abline(slope = 1, intercept = 0) + geom_smooth(method="lm", stat = ) 

# annotatations are better than legends
(
  annot <- 
  no_zeros + 
    geom_abline(slope = 1, intercept = 0) + 
    geom_smooth(method = "lm") + 
    geom_segment(mapping = aes(x=1, y=1, xend=2, yend=.2), size=.05) +
    geom_label(mapping = aes(x=2.1, y=0.2, label="1:1 line")) +
    geom_segment(mapping = aes(x=1, y=2, xend=0.2, yend=3.5), size=.05) +
    geom_label(mapping = aes(x=0.5, y=3.5, label="linear\nregression"), nudge_x = .2)
)

# color the pizzerias based on the degree of rating disagreement
# first lets calculate the difference in rating

rate_diff <-
  pzbs %>% 
  filter(review_stats_community_average_score > 0) %>% 
  mutate(
    difference = 
      review_stats_community_average_score - review_stats_dave_average_score
    )


(
  annot <-
    annot + geom_point(
      pch = 21,
      data = rate_diff,
      aes(
        fill = difference,
        size = abs(difference),
        x = review_stats_community_average_score,
        y = review_stats_dave_average_score
      ),
      inherit.aes = FALSE
    ) +
    scale_fill_gradient2(low = "purple", mid = "darkgrey", high = "forestgreen") +
    scale_size(guide = "none")
)


# highlight points (outliers, influential values,..)
# we need another dataset, this time for the five pizzerias
# with largest negative and positive difference

rate_diff_top5 <- rate_diff %>%
  mutate(pos_neg = ifelse(difference > 0, "preferred by community", "preferred by dave")) %>%
  group_by(pos_neg) %>% 
  top_n(n=5, wt = abs(difference))

library(ggrepel) 

annot <- 
  annot + geom_label_repel(
  data = rate_diff_top5,
  aes(
    x = review_stats_community_average_score, 
    y = review_stats_dave_average_score, 
    label = name), inherit.aes = FALSE
) 

# prettyfy the legend

annot <-
  annot + 
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
library(ggpubr)
annot + stat_cor(method = "pearson")