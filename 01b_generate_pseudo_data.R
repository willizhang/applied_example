### 1. Load Packages

library(ggplot2)
library(tidyverse)
library(naniar)
library(haven)
library(finalfit)
library(survey)
library(miapack)
library(mice)
library(mitools)
library(forestploter)
library(lemon)
library(readxl)
library(here)
library(DHARMa)

# Note: The packages loaded above are used in the analyses presented in this
# script as well as in other analysis scripts in this repository.


### 2. Generate Synthetic Pseudo-Dataset

# This synthetic dataset is generated solely to demonstrate the analysis code.
# The sample size, variable distributions, associations, and missing-data
# patterns are arbitrary and do not represent those in the original SPHC data.

set.seed(20260929)

n <- 15000

d_2014_selected_pseudo <- tibble(
  
  sexual_identity_2014 = factor(
    sample(
      c("Heterosexual", "Non-heterosexual"),
      size = n,
      replace = TRUE,
      prob = c(0.7, 0.3)
      ),
    levels = c("Heterosexual", "Non-heterosexual")
    ),
  
  sexual_identity_2021 = factor(
    sample(
      c("Heterosexual", "Non-heterosexual"),
      size = n,
      replace = TRUE,
      prob = c(0.7, 0.3)
    ),
    levels = c("Heterosexual", "Non-heterosexual")
  ),
  
  age = sample(
    25:60,
    size = n,
    replace = TRUE
    ),
  
  sex = factor(
    sample(
      c("Male", "Female"),
      size = n,
      replace = TRUE,
      prob = c(0.5, 0.5)
      ),
    levels = c("Male", "Female")
    ),
  
  country_of_birth = factor(
    sample(
      c("Sweden", "Europe", "Outside Europe"),
      size = n,
      replace = TRUE
      ),
    levels = c("Sweden", "Europe", "Outside Europe")
    ),
  
  occupation = factor(
    sample(
      c(
        "Manual and field trades",
        "Service and support",
        "Expertise and leadership"
      ),
      size = n,
      replace = TRUE
      ),
    levels = c(
      "Manual and field trades",
      "Service and support",
      "Expertise and leadership"
    )
  )
)

missing_identity <- sample(
  seq_len(n),
  size = 5000,
  replace = FALSE
)

missing_occupation <- sample(
  seq_len(n),
  size = 4000,
  replace = FALSE
)

d_2014_selected_pseudo$sexual_identity_2021[missing_identity] <- NA
d_2014_selected_pseudo$occupation[missing_occupation] <- NA

d_2014_selected_pseudo <- d_2014_selected_pseudo %>%
  mutate(
    identity_change = as.numeric(
      sexual_identity_2014 != sexual_identity_2021
    )
  )

d_2014_selected_pseudo <- d_2014_selected_pseudo %>%
  select(
    sexual_identity_2014,
    sexual_identity_2021,
    identity_change,
    age,
    sex,
    country_of_birth,
    occupation
  )

str(d_2014_selected_pseudo)

summary(d_2014_selected_pseudo)

miss_var_summary(d_2014_selected_pseudo)