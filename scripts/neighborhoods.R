# libraries ----
library(opendatatoronto)
library(dplyr)
library(janitor)

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
  
