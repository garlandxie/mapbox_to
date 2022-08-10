# libraries ----
library(opendatatoronto)
library(dplyr)
library(janitor)
library(ggplot2)
library(tibble)
library(stringr)

# download dataset ----

# get package 
package <- show_package("6e19a90f-971c-46b3-852c-0c48c436d1fc")

# get all resources for this package
resources <- list_package_resources("6e19a90f-971c-46b3-852c-0c48c436d1fc")

# identify data store resources; 
# by default, Toronto Open Data sets datastore resource format to CSV 
# for non-geospatial and GeoJSON for geospatial resources
datastore_resources <- dplyr::filter(
  resources, tolower(format) %in% c('csv', 'geojson')
  )

# load the 2016 data store resource 
data_2016 <- filter(datastore_resources, row_number()==2) %>% get_resource()

# clean data ----

# convert into a tidy format 
data_2016_tidy <- data_2016 %>%
  janitor::clean_names() %>%
  
  select(
    
    # get all neighbourhood characteristics 
    characteristic, 
    
    # get all 140 neighborhood profiles in Toronto 
    agincourt_north:yorkdale_glen_park
    
    ) %>%
  
  # transpose where: 
  # all neighbourhood profiles are rows within a single column 
  # each neighbourhood characteristic becomes a column 
  t() %>%
  
  as.data.frame() %>%
  
  # get the first row as the header and clean column names
  janitor::row_to_names(1) %>%
  janitor::clean_names()

# assign neighbourhood names as a column
data_2016_tidy$neighbourhood_name <- rownames(data_2016_tidy)

# extract candidate variables -----

# colnames(data_2016_tidy)[str_detect(colnames(data_2016_tidy), "income")]

data_2016_cand <- data_2016_tidy %>%
  select(
    neighbourhood_name, 
    
    # population and dwellings
    pop_density_per_sqkm = population_density_per_square_kilometre,
    pop_65 = population_age_65_by_family_characteristics,
    
    # immigration 
    no_of_immigrants = immigrants, 
    no_of_can_citizens = canadian_citizens, 
    
    # income 
    prev_lico_at = prevalence_of_low_income_based_on_the_low_income_cut_offs_after_tax_lico_at_percent,
    prev_lim_at = prevalence_of_low_income_based_on_the_low_income_measure_after_tax_lim_at_percent, 
    avg_total_income = total_income_average_amount, 
    avg_after_tax_income = after_tax_income_average_amount,
    
    # housing 
    spend_30_perc_shelter_costs = spending_30_percent_or_more_of_income_on_shelter_costs, 
    
    # education (between ages 25 to 64)
    no_degree_ages_25_64 = no_certificate_diploma_or_degree_2
  
  ) %>%
  
  # make sure the variables are all numeric
  mutate(
    across(
      c(pop_density_per_sqkm:no_degree_ages_25_64),
    ~ as.numeric(
      str_replace(.x, pattern = ",", replacement = "")
      )
    )
  )


