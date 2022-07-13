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

# |- visualize income data ----

##  |-- plot: difference between mean total income and after-tax income ----
data_2016_tidy %>%
  
  select(
    neighbourhood_name, 
    avg_total_income = total_income_average_amount, 
    avg_after_tax_income = after_tax_income_average_amount
  ) %>%
  
  mutate(
    
    avg_total_income = str_replace(
      avg_total_income, 
      pattern = ",", 
      replace = ""), 
    
    avg_after_tax_income = str_replace(
      avg_after_tax_income, 
      pattern = ",", 
      replace = ""), 
    avg_after_tax_income = as.numeric(avg_after_tax_income)
  
    ) %>%
  
  mutate(
    avg_total_income = as.numeric(avg_total_income), 
    avg_after_tax_income = as.numeric(avg_after_tax_income)
  ) %>%
  
  ggplot(aes(y = neighbourhood_name)) + 
  geom_point(aes(x = avg_total_income), col = "black") + 
  geom_point(aes(x = avg_after_tax_income), col = "red") + 
  labs(
    x = "Difference between Mean Total Income and After-Tax Income", 
    y = "Neighbourhood Name") + 
  theme(axis.text.y = element_blank())

# |-- plot: histogram of total income ----

data_2016_tidy %>%
  
  select(
    neighbourhood_name, 
    avg_total_income = total_income_average_amount
  ) %>%
  
  mutate(
    
    avg_total_income  = str_replace(
      avg_total_income , 
      pattern = ",", 
      replace = ""), 
    avg_total_income = as.numeric(avg_total_income)
    
  ) %>%
  
  ggplot(aes(x = avg_total_income)) + 
  geom_histogram() + 
  labs(x = "Mean Total Income") + 
  theme_bw() 

# |-- plot: histogram of after-tax income ----

data_2016_tidy %>%
  
  select(
    neighbourhood_name, 
    avg_after_tax_income = after_tax_income_average_amount
  ) %>%
  
  mutate(
  
    avg_after_tax_income = str_replace(
      avg_after_tax_income, 
      pattern = ",", 
      replace = ""), 
    avg_after_tax_income = as.numeric(avg_after_tax_income)
    
  ) %>%
  
  ggplot(aes(x = avg_after_tax_income)) + 
  geom_histogram() + 
  labs(x = "Mean After-Tax Income") + 
  theme_bw() 
  
# |-- visualize population data ----

## |-- histogram: changes in population between 2011 and 2016 ----

data_2016_tidy %>%
  select(neighbourhood_name, population_change_2011_2016) %>%
  rename(pop_change_11_16 = population_change_2011_2016) %>%
  mutate(
    
    pop_change_11_16 = str_replace(
      pop_change_11_16, 
      pattern = "%", 
      replace = ""), 
    
    pop_change_11_16 = as.numeric(pop_change_11_16)
    
    ) %>%
  
  ggplot(aes(x = pop_change_11_16)) +
  geom_histogram() + 
  geom_vline(xintercept = 0, linetype = "dashed") + 
  labs(x = "Population Change (%) between 2011 and 2016 Census") + 
  theme_bw()




