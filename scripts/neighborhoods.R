# libraries ----
library(opendatatoronto)
library(dplyr)

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

# load the 2016 datastore resource 
data_2016 <- filter(datastore_resources, row_number()==2) %>% get_resource()