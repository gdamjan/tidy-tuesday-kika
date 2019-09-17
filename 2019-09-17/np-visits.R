library(tidyverse)
# install.packages("ggthemes")
library(ggthemes)

park_visits <-
  readr::read_csv(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-09-17/national_parks.csv"
  )

# state_pop <-
#   readr::read_csv(
#     "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-09-17/state_pop.csv"
#   )
# gas_price <-
#   readr::read_csv(
#     "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-09-17/gas_price.csv"
#   )


pv <- 
  park_visits %>%
  filter(unit_type == "National Park") %>% 
  filter(!year == Total)
  group_by(year) %>% 
  summarise_at(.vars = vars("visitors"), .funs = list("visitors_per_year"=sum)) %>% 
  mutate(year = as.numeric(year)) %>% 
  drop_na(year)

  ggplot(pv) +
    aes(x = year) +
    aes(y = visitors_per_year / 10^6) +
    geom_line(color = "forestgreen") +
    geom_area(alpha = .3, fill = "forestgreen") +
    scale_y_continuous(labels = scales::comma) +
    scale_y_continuous(labels = scales::unit_format(unit = "M")) +
    scale_x_continuous(breaks = seq(1910, 2016, 10),
                       labels = c(1910, paste("'", seq(20, 90, 10), sep = ""), 2000, "'10")) +
    labs(x="") +
    labs(y="") +
    labs(title="U.S. national parks have never been so popular") +
    labs(subtitle="Annial recreational visits to national parks since 1904") +
    labs(caption="Source: National Parks Service") +
    ggthemes::theme_fivethirtyeight()
    

# lines and ridges

library(ggridges)

top20 <- park_visits %>% 
  filter(unit_type == "National Park") %>% 
  filter(year == "Total") %>% 
  arrange(desc(visitors)) %>% 
  top_n(n = 20, wt=visitors) 

pv2 <- 
  park_visits %>% 
  filter(unit_type == "National Park") %>% 
  filter(!year == "Total") %>% 
  select(year, unit_name, visitors) %>%
  group_by(year) %>% 
  mutate(year_rank = rank(-visitors)) %>% 
  ungroup %>% 
  mutate(year = as.numeric(year)) %>% 
  arrange(year, year_rank)

pv2_top20 <- filter(.data = pv2, unit_name %in% top20$unit_name) 

# like fivethirtyeight (without the embelishments)
ggplot(pv2_top20) +
  aes(x = year) +
  aes(y = -year_rank) +
  aes(group = unit_name) +
  geom_line()

# alternative
ord <- top20$unit_name[order(top20$visitors, decreasing = FALSE)]
lbl <- str_remove(ord, "National Park")
  
(
  ridges <-
    ggplot(pv2_top20) +
    aes(x = year) +
    aes(y = unit_name) +
    aes(fill = unit_name) +
    aes(group = unit_name) +
    aes(height = visitors) +
    aes(scale = .0000003) +
    ggridges::geom_ridgeline(alpha = .5) +
    theme_ridges() +
    labs(y = "") +
    labs(x = "") +
    labs(title = "National park visitors per year") +
    labs(subtitle = "The twenty most-visited parks overall") +
    # theme(axis.text.y = element_text(size = 14)) +
    scale_y_discrete(limits = ord, labels = lbl) +
    scale_fill_cyclical(limits = ord, values = c("dodgerblue", "forestgreen")) +
    scale_x_continuous(
      limits = c(1950, 2016),
      breaks = seq(1950, 2016, 10),
      labels = c("1950", "'60", "'70", "'80", "'90", "2000", "'10")
    ) +
    ggthemes::theme_fivethirtyeight()
)

# animate it? this is lame
if (FALSE) {
  library(gganimate)
  
  anim <- animate(ridges + transition_manual(frames = year, cumulative  = TRUE),
                  duration = 15)
  anim
}

# try something different
# https://stackoverflow.com/questions/53162821/animated-sorted-bar-chart-with-bars-overtaking-each-other/53163549#53163549

library(gganimate)
 
for_anim <-
  pv2_top20 %>%
  group_by(year) %>%
  mutate(year_rank = rank(-visitors)) %>%
  mutate(value_rel = visitors / visitors[year_rank == 1]) %>%
  mutate(value_lbl = paste0(" ", visitors)) %>%
  group_by(unit_name) %>%
  filter(year_rank <= 10)

ggplot(for_anim, aes(-year_rank, value_rel, fill = unit_name)) +
  geom_col(width = 0.8, position = "identity") +
  coord_flip() +
  geom_text(aes(
    -year_rank,
    y = 0,
    label = unit_name,
    hjust = 0
  )) +
  geom_text(aes(
    -year_rank,
    y = value_rel,
    label = value_lbl,
    hjust = 0
  )) + # value label
  theme_minimal() +
  theme(legend.position = "none", axis.title = element_blank()) +
  # animate along Year
  transition_states(year, 4, 1) +
  theme(axis.text = element_blank()) +
  scale_fill_viridis_d(begin = .2)

animate(pp, 200, fps = 2, duration = 40)
