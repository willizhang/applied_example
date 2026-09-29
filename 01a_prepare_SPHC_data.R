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


### 2. SPHC 2014, followed up to 2021

load('/Volumes/projects/LGBT Project data/d_2014.RData')

# sexual identity in 2014
table( d_2014$F14U90G82, useNA = "always" )
d_2014$sexual_identity_2014 <- factor( ifelse( d_2014$F14U90G82 == 1, "Heterosexual", "Non-heterosexual" ),
                                       levels = c( "Heterosexual", "Non-heterosexual" ) )
table( d_2014$sexual_identity_2014, useNA = "always" )

# sexual identity in 2021
table( d_2014$F21F91, useNA = "always" )
d_2014$sexual_identity_2021 <- factor( ifelse( d_2014$F21F91 == 1, "Heterosexual", "Non-heterosexual" ),
                                       levels = c( "Heterosexual", "Non-heterosexual" ) )
table( d_2014$sexual_identity_2021, useNA = "always" )

# change in sexual identity
d_2014$identity_change <- ifelse( d_2014$sexual_identity_2014 == d_2014$sexual_identity_2021, 0, 1 )
table( d_2014$identity_change, useNA = "always" )

# sex
table( d_2014$kon, useNA = "always" )
d_2014$sex <- factor( ifelse( d_2014$kon == 1, "Male", "Female" ),
                      levels = c( "Male", "Female" ) )
table( d_2014$sex, useNA = "always" )

# age
summary( d_2014$F14alder )
d_2014$age <- d_2014$F14alder
d_2014$age_group <- cut( d_2014$age,
                         breaks = c( min( d_2014$age ), 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, max( d_2014$age ) ),
                         right = FALSE,
                         include.lowest = TRUE )
table( d_2014$age_group )

# country of birth
table( d_2014$fodelseland, useNA = "always" )
d_2014$country_of_birth <- factor( ifelse( d_2014$fodelseland == "Sverige", "Sweden",
                                           ifelse( d_2014$fodelseland == "Europa", "Europe", "Outside Europe" ) ),
                                   levels = c( "Sweden", "Europe", "Outside Europe" ) )
table( d_2014$country_of_birth, useNA = "always" )

# occupation
table( d_2014$SSYK_kl, useNA = "always" )
d_2014$occupation <- factor(
  ifelse(
    d_2014$SSYK_kl == "Yrken inom byggverksamhet och tillverkning" |
      d_2014$SSYK_kl == "Yrken inom lantbruk, trädgård, skogsbruk och fiske" |
      d_2014$SSYK_kl == "Yrken inom maskinell tillverkning och transport m.m.",
    "Manual and field trades",
    ifelse(
      d_2014$SSYK_kl == "Service-, omsorgs- och försäljningsyrken" |
        d_2014$SSYK_kl == "Yrken inom administration och kundtjänst" |
        d_2014$SSYK_kl == "Yrken med krav på kortare utbildning eller introduktion",
      "Service and support",
      ifelse(
        d_2014$SSYK_kl == "Yrken med krav på fördjupad högskolekompetens" |
          d_2014$SSYK_kl == "Yrken med krav på högskolekompetens eller motsvarande" |
          d_2014$SSYK_kl == "Chefsyrken" |
          d_2014$SSYK_kl == "Militära yrken",
        "Expertise and leadership",
        NA
      )
    )
  ),
  levels = c(
    "Manual and field trades",
    "Service and support",
    "Expertise and leadership"
  )
)
table( d_2014$occupation, useNA = "always" )

# association of age and occupation
ggplot( d_2014 %>%
          filter( !is.na( occupation ) ),
        aes( x = age_group, fill = occupation ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs(
    x = "Age Group",
    y = "Percentage",
    fill = "Occupation" ) +
  theme_classic()

ggplot( d_2014,
        aes( x = age_group, fill = is.na( occupation ) ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs(
    x = "Age Group",
    y = "Percentage",
    fill = "Missingness of Occupation" ) +
  theme_classic()

# association of age and identity change
ggplot( d_2014 %>%
          filter( !is.na( identity_change ) ) %>%
          mutate( identity_change = as.factor( ifelse( identity_change == 1, "Yes", "No" ) ) ),
        aes( x = age_group, fill = identity_change ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs(
    x = "Age Group",
    y = "Percentage",
    fill = "Identity Change" ) +
  theme_classic()

ggplot( d_2014,
        aes( x = age_group, fill = is.na( identity_change ) ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs(
    x = "Age Group",
    y = "Percentage",
    fill = "Missingness of Identity Change" ) +
  theme_classic()


# define study sample
prop_miss( d_2014$sexual_identity_2014 )

d_2014_selected <- d_2014 %>% 
  select( "sexual_identity_2014", "sexual_identity_2021", "identity_change", "age", "sex", "country_of_birth", "occupation" ) %>%
  filter( age >= 25,
          age <= 60,
          !is.na( sexual_identity_2014 ) # remove missingness in sexual_identity_2014 
  )
summary( d_2014_selected )
nrow( d_2014_selected ) # 11,274
miss_var_summary( d_2014_selected )

# characteristics table
explanatory =  c( "age", "sex", "country_of_birth", "occupation", "sexual_identity_2014", "sexual_identity_2021" )
dependent = "identity_change"

d_2014_table <- d_2014_selected %>%
  mutate( identity_change = as.factor( ifelse( identity_change == 1, "Yes", "No" ) ) ) %>%
  summary_factorlist( dependent,
                      explanatory, 
                      na_include = TRUE,
                      na_include_dependent = TRUE, 
                      total_col = TRUE,
                      add_col_totals = TRUE,
                      column = TRUE )

d_2014_table

# correlation of sexual identity in 2014 and occupation
ggplot( d_2014_selected %>%
          filter( !is.na( occupation ) ),
        aes( x = sexual_identity_2014, fill = occupation ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs( x = "Sexual Identity in 2014", y = "Percentage", fill = "Occupation" ) +
  theme_classic()

ggplot( d_2014_selected,
        aes( x = sexual_identity_2014, fill = is.na( occupation ) ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs( x = "Sexual Identity in 2014", y = "Percentage", fill = "Missingness of Occupation" ) +
  theme_classic()

# correlation of sexual identity in 2014 and identity change
ggplot( d_2014_selected %>% 
          filter( !is.na( identity_change ) ) %>%
          mutate( identity_change = as.factor( ifelse( identity_change == 1, "Yes", "No" ) ) ),
        aes( x = sexual_identity_2014, fill = identity_change ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs( x = "Sexual Identity in 2014", y = "Percentage", fill = "Identity Change" ) +
  theme_classic()

ggplot( d_2014_selected,
        aes( x = sexual_identity_2014, fill = is.na( identity_change ) ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs( x = "Sexual Identity in 2014", y = "Percentage", fill = "Missingness of Identity Change" ) +
  theme_classic()

# correlation of occupation and identity change
ggplot( d_2014_selected %>%
          filter( !is.na( identity_change ) ) %>%
          mutate( occupation = fct_na_value_to_level( occupation, level = "Missing" ),
                  identity_change = as.factor( ifelse( identity_change == 1, "Yes", "No" ) ) ),
        aes( x = occupation, fill = identity_change ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs( x = "Occupation", y = "Percentage", fill = "Identity Change" ) +
  theme_classic()

ggplot( d_2014_selected %>%
          mutate( occupation = fct_na_value_to_level( occupation, level = "Missing" ) ),
        aes( x = occupation, fill = is.na( identity_change ) ) ) +
  geom_bar( position = "fill" ) +
  scale_y_continuous( labels = scales::percent ) +
  labs( x = "Occupation", y = "Percentage", fill = "Missingness of Identity Change" ) +
  theme_classic()


### association (risk ratio) of occupation and identity change ###

# occupation and missingness of identity change
tab1 <- table( d_2014_selected$occupation, is.na( d_2014_selected$identity_change ) ) # among participants with complete occupation data
tab1

( tab1[ "Service and support", "TRUE" ] / sum( tab1[ "Service and support", ] ) ) / 
  ( tab1[ "Manual and field trades", "TRUE" ] / sum( tab1[ "Manual and field trades", ] ) ) # service and support vs manual and field trades

( tab1[ "Expertise and leadership", "TRUE" ] / sum( tab1[ "Expertise and leadership", ] ) ) / 
  ( tab1[ "Manual and field trades", "TRUE" ] / sum( tab1[ "Manual and field trades", ] ) ) # expertise and leadership vs manual and field trades

# occupation and identity change
tab2 <- table( d_2014_selected$occupation, d_2014_selected$identity_change )
tab2

( tab2[ "Service and support", "1" ] / sum( tab2[ "Service and support", ] ) ) / 
  ( tab2[ "Manual and field trades", "1" ] / sum( tab2[ "Manual and field trades", ] ) ) # service and support vs manual and field trades

( tab2[ "Expertise and leadership", "1" ] / sum( tab2[ "Expertise and leadership", ] ) ) / 
  ( tab2[ "Manual and field trades", "1" ] / sum( tab2[ "Manual and field trades", ] ) ) # expertise and leadership vs manual and field trades

# check missing data pattern
md.pattern( 
  d_2014 %>% # among all participants
    filter( !is.na( sexual_identity_2014 ) ) %>%
    select( "occupation", "sexual_identity_2021" ) %>%
    rename( SI_2021 = sexual_identity_2021 ),
  rotate.names = FALSE )

d_2014 %>%
  filter( !is.na( sexual_identity_2014 ) ) %>%
  summarise(
    prop_id2021_missing_given_occ_missing = mean( is.na( sexual_identity_2021[ is.na( occupation ) ] ) ),
    prop_occ_missing_given_id2021_missing = mean( is.na( occupation[ is.na( sexual_identity_2021 ) ] ) )
  )

pdf( "missing_pattern.pdf", width = 4, height = 6 )
md.pattern( d_2014_selected %>% # among 25-60 years
              select( "occupation", "sexual_identity_2021" ) %>%
              rename( SI_2021 = sexual_identity_2021 ),
            rotate.names = FALSE )
dev.off()

d_2014_selected %>%
  summarise(
    prop_id2021_missing_given_occ_missing = mean( is.na( sexual_identity_2021[ is.na( occupation ) ] ) ),
    prop_occ_missing_given_id2021_missing = mean( is.na( occupation[ is.na( sexual_identity_2021 ) ] ) )
  )
