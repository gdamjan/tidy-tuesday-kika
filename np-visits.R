library(tidyverse)

park_visits <-
  readr::read_csv(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-09-17/national_parks.csv"
  )
state_pop <-
  readr::read_csv(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-09-17/state_pop.csv"
  )
gas_price <-
  readr::read_csv(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-09-17/gas_price.csv"
  )


pv <- 
  park_visits %>%
  group_by(year) %>% 
  summarise_at(.vars = vars("visitors"), .funs = list("visitors_per_year"=sum)) %>% 
  mutate(year = as.numeric(year)) %>% 
  drop_na(year)

ggplot(pv) + 
  aes(x=year) + 
  aes(y=visitors_per_year) +
  scale_x_continuous()+
  geom_line() +
  geom_area(alpha=.3)


library(ggridges)

top20 <- park_visits %>% 
  filter(year == "Total") %>% 
  arrange(desc(visitors)) %>% 
  top_n(n = 20, wt=visitors) 

pv2 <- 
  park_visits %>% 
  filter(!year == "Total") %>% 
  select(year, unit_name, visitors) %>%
  group_by(year) %>% 
  mutate(max_in_year = max(visitors)) %>% 
  mutate(diff_from_max = max_in_year - visitors) %>%
  mutate(year_rank=rank(diff_from_max))  %>% 
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
ord <- top20$unit_name[order(top20$visitors, decreasing = TRUE)]

ggplot(pv2_top20) +
  aes(x = year) +
  aes(y = unit_name) +
  aes(fill = unit_name) +
  aes(group = unit_name) +
  aes(height = visitors) +
  aes(scale = .0000001) +
  ggridges::geom_ridgeline(alpha=.5) +
  theme_ridges() +
  labs(y="National park") +
  labs(x="Year") +
  labs(title="Park visitors per year") +
  theme(axis.text.y = element_text(size=10)) +
  scale_y_discrete(limits = ord, labels = ord) +
  scale_fill_cyclical(limits = ord, values = c("blue", "green"))
