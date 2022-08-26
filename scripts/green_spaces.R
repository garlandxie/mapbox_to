# libraries ----
library(opendatatoronto)
library(dplyr)

# get package ----
package <- show_package("9a284a84-b9ff-484b-9e30-82f22c1780b9")

# get all resources for this package
resources <- list_package_resources("9a284a84-b9ff-484b-9e30-82f22c1780b9")

# identify data-store resources
# by default, Toronto Open Data sets data-store resource format to CSV 
# for non-geospatial and GeoJSON for geospatial resources

datastore_resources <- filter(
  resources, 
  tolower(format) %in% c('csv', 'geojson')
  )

# download CSV of green spaces with the projected coordinate system
# MTM 10, EPSG 2952
to_green_spaces <- filter(
  datastore_resources, 
  name == "Green Spaces - 2952.csv") %>% 
  get_resource()


