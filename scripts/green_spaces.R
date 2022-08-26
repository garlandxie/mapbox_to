# libraries ----
library(dplyr)
library(sf)
library(here)

# import ----

# green space sizes
to_green_space <- st_read(
  here("data", "green_space_shp", "Green Spaces.shp")
)

# metadata
field_codes <- read.csv(
  here("data", "green_space_shp", "Green Spaces_fields.csv")
)

# merge polygons ----

to_merge <- to_green_space %>%
  
  # renaming columns based on Green Spaces_field.csv file
  rename(
    id = FIELD_1,
    area_id = FIELD_2, 
    area_attr_id = FIELD_3, 
    parent_area_id = FIELD_4, 
    area_class_id = FIELD_5, 
    area_class = FIELD_6, 
    area_short_code = FIELD_7, 
    area_long_code = FIELD_8, 
    area_name = FIELD_9, 
    area_desc = FIELD_10, 
    objectid = FIELD_11
  ) %>%
  
  # merge nested and duplicated green spaces
  # to form a contiguous polygon
  group_by(area_name) %>%
  summarize(geometry = sf::st_union(geometry)) %>%
  ungroup()

# export as ESRI shape file ----
st_write(
  obj = to_merge, 
  dsn = here("data", "merged_green_spaces.shp"),
  delete_dsn = TRUE
)
