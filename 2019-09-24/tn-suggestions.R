library(tidyverse)

school_diversity <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-09-24/school_diversity.csv") 

NE.abrv <- c("CT","ME","MA","NH","RI","VT","NJ","NY","PA")

MW.abrv <- c("IN","IL","MI","OH","WI","IA","KS","MN","MO","NE",
             "ND","SD")

S.abrv <- c("DE","DC","FL","GA","MD","NC","SC","VA","WV","AL",
            "KY","MS","TN","AR","LA","OK","TX")

W.abrv <- c("AZ","CO","ID","NM","MT","UT","NV","WY","AK","CA",
            "HI","OR","WA")

region.list <- list(
  Northeast=NE.abrv,
  Midwest=MW.abrv,
  South=S.abrv,
  West=W.abrv
  )

# better than either of the two ways in the presentation is to use dplyr::left_join
# first we make them into tibbles, 
# I am using the preexisting vectors, but we can easily start here with the raw data:
# NE_tbl <- tibble(state=c("CT","ME","MA","NH","RI","VT","NJ","NY","PA"), region="Northeast)

NE_tbl <- tibble(state=NE.abrv, region="Northeast") # or is it new england?
MW_tbl <- tibble(state=MW.abrv, region="Midwest")
S_tbl  <- tibble(state=S.abrv,  region="South")
W_tbl  <- tibble(state=W.abrv,  region="West")

# then we concatenate into a single tibble
region_df <- dplyr::bind_rows(NE_tbl, MW_tbl, S_tbl, W_tbl)

# then we join. Note that if we named the column above "ST" instead of "state", 
# the `by` would have been only `by="ST"`. 
# but since the columns don't  have the same names, we have to specify
# column name for left hand side (LHS) and column name for right hand side (RHS)

school_diversity_w_regions <- dplyr::left_join(x = school_diversity, y = region_df, by=c("ST"="state"))
# now we have a region column for the schools

##### Constructive digression?

  # Good moment to talk about dplyr / SQL connection? 
  # i.e. that dplyr (and better yet dbplyr) can connect to 
  # external mySQL, PostgressSQL, SQLite databases when files are too big?
  # its an advanced topic, but maybe worth mentioning that its the same syntax,
  # except on a 'connection' to an external database. 
  # dplyr translates its code to SQL syntax and queries sent to the outside DB
  # then collected with `collect`
  # more: https://db.rstudio.com/dplyr/


##### Make a cartogram

# adapted from https://serialmentor.com/dataviz/geospatial-data.html#cartograms

# install.packages("geofacet")
library(geofacet)

reorganized <-
  school_diversity %>%
  group_by(ST, SCHOOL_YEAR, diverse) %>%
  tally() %>%
  select(state = ST, school_year = SCHOOL_YEAR, diverse, n) %>%
  mutate(diverse = factor(
    diverse,
    levels = c("Extremely undiverse", "Undiverse", "Diverse")
  )) %>%
  group_by(state, school_year) %>%
  mutate(percent = n / sum(n)) %>%
  filter(school_year == "1994-1995")

ggplot(data = reorganized) + 
  labs(title="School diversity in the US in 1994-1995") +
  aes(x=diverse) +
  labs(x="") +
  aes(y=percent) +
  labs(y="") +
  aes(fill=diverse) +
  labs(fill="") +
  geom_col() +
  scale_fill_manual(values=c("grey10", "grey40", "forestgreen")) +
  scale_y_continuous(breaks=c(0, .5, 1), labels = scales::percent) +
  coord_flip() +
  facet_geo(~state, grid = "us_state_grid1") +
  theme_minimal()+
  theme(
    strip.text = element_text(
      margin = margin(3, 3, 3, 3)
    )) +
  theme(legend.position = "bottom") +
  theme(axis.text.x = element_text(angle=30, hjust=1, vjust=1)) +
  theme(axis.line.x = element_blank()) +
  theme(panel.grid.major = element_line(color = "gray80")) +
  theme(panel.background = element_rect(fill = "gray90")) 

