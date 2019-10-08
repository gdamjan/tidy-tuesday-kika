library(tidyverse)
library(broom)

lifting <-
  ipf_lifts <-
  readr::read_csv(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-10-08/ipf_lifts.csv"
  )

glimpse(lifting)

# fitting models to grouped data

# convert to long format 
# such that we have one column
# weight lifted

ll <- lifting_long <- 
  lifting %>% gather(type, weight, starts_with("best"))

ll <- group_by(ll, sex, type)

# now we can fit a linear model of 
# weight ~ boyweight 
# while keeping track of relevant
# groupings

# check these step by step
# to see what nest does
# what the map within mutate does
# and unnest

LMs_by_sex_and_type <- 
  ll %>%
  tidyr::nest() %>%
  mutate(fit = purrr::map(data, ~ lm(weight ~ bodyweight_kg, data = .))) %>%
  mutate(results = purrr::map(fit, broom::tidy)) %>% 
  tidyr::unnest(results)

# if you get this error: 
# Error: 'vec_dim' is not an exported object from 'namespace:vctrs'
# reinstall pillar with install.packages('pillar')
# https://github.com/r-lib/vctrs/issues/487

# now we can ask what are the coefficients
# of the linear regressions for each group

LMs_by_sex_and_type %>% 
  select(-data, -fit) %>% 
  filter(term == "(Intercept)") %>% 
  knitr::kable(caption = "Inercepts for lifted weight by bodyweight by sex and type of lifting")
  # caption will render in Rmd 

LMs_by_sex_and_type %>% 
  select(-data, -fit) %>% 
  filter(term == "bodyweight_kg") %>% 
  knitr::kable(caption = "Inercepts for lifted weight by bodyweight by sex and type of lifting")

# neat, everything is significant

# to visualize, we can use this table,
# or plot the raw data and use geom_smooth
# while faceting by sex and type (similar to last week)

LMs_by_sex_and_type_wide <- 
  LMs_by_sex_and_type %>% 
  select(sex, type, term, estimate) %>% 
  spread(term, estimate) %>% 
  rename("Intercept" = `(Intercept)`) %>% 
  rename("Slope" = bodyweight_kg)

ggplot(data = LMs_by_sex_and_type_wide) +
  # aes(group=interaction(sex, type)) +
  geom_abline(size = 1,
              aes(
                slope = Slope,
                intercept = Intercept,
                color = type,
                linetype = sex
              )) +
  # since we don't have mapping for x and y
  # the slope lines are not visible
  # add manual axis limits to see them
  scale_x_continuous(limits = c(0, 100)) +
  scale_y_continuous(limits = c(0, 200)) +
  labs(x="bodyweight (kg)") +
  labs(y="weight lifter (kg)") +
  theme_bw() +
  theme(legend.position="top")

# then you can ask are slopes for women higher than men?
# are slopes significantly different from each other
# (maybe use likelihood ratio test or anova to compare models)
# ...

