
###################################################################################################################
###################################################################################################################
# DEFINE PACKAGES
pack <- c("sp", "rgdal", "raster", "dplyr", "geosphere", "tmap", "tmaptools", "rgeos")

# INSTALL PACKAGES
#lapply(pack, install.packages) # Run this if packages are not already installed.

# LOAD PACKAGES 
lapply(pack, require, character.only=T); rm(pack)
rm(list=ls())

# SET WORKING DIRECTORY
setwd(".../08_opgaver")  # change this to the location of the folder "08_opgaver" on your own computer 

######INFORMATION ON DATA:
## >> tobacco_africa.tif: file containing info on the harvested area fraction of small gridcells (squares) across Africa
## >> region.shp: file containing info on the location of ADM1 (i.e. regional level) areas across Africa
## >> SA_survey.shp: subset of survey respondents in South Africa
## >> Voting_District.shp: file on voting districts locations in South Africa (subset)
## >> voting_stations.shp: file on voting station locations in South Africa (subset)
## >> ZAP_adm0.shp: file containing data describing South Africa, including a polygon of the country 


###################################################################################################################
###################################################################################################################
## EXERCISE 1: READ SPATIAL DATA                                                                                      | 1 |
## >> Read in data: 
## >> Get a sense of the data using plot(). If you want to plot two shp files together, simply plot them separately, 
## >> adding 'add=T' to the plot function called last: plot(shp1); plot(shp2, col="red", add=T)
## >> use ReadOGR() and raster(). Check projections using Proj4string()
###################################################################################################################
###################################################################################################################

# Read in data
tobacco <- raster("tobacco_africa.tif")
region <- readOGR("GADM_africa.shp")
survey <- readOGR("SA_survey.shp")
voting_districts <- readOGR("Voting_districts.shp")
voting_stations <- readOGR("voting_stations.shp")
South_africa <- readOGR("ZAF_adm0.shp")

# Check if projections are the same 
proj4string(region)
proj4string(region)==proj4string(tobacco)

proj4string(survey)==proj4string(voting_districts)
proj4string(voting_districts)==proj4string(voting_stations)


# Get a sense of the data playing around with plot()
plot(tobacco)
plot(South_africa)
plot(survey)
plot(region)
plot(voting_districts)
plot(voting_stations)

plot(South_africa)
plot(survey, col = "green", add = TRUE)
plot(voting_districts, col = "red", add = TRUE)
plot(voting_stations, col = "blue", add = TRUE)

plot(tobacco)
plot(region, add = TRUE)


## Shortly describe the data you have just loaded in 
# A raster layer of tobacco production across Africa as a relative measure per grid cell + vector shape files of 
# regions in Africa and of South Africa and voting stations, dictricts as well as survey respondents' locations in SA. 


###################################################################################################################
###################################################################################################################
## EXERCISE 2:  MAPOVERLAYING (shapefile & shapefile)                                                                 | 2 |
## >> For each respondent in the survey shapefile, assign the unique voting district id, within which the respondent 
## >> resides as a variable. The unique voting district id is the 'VDNumber' variable in voting_districts shapefile.
## >> use over()
## >> Interpret the output: how does the output help you? (see 'Value' in ?over)
###################################################################################################################
###################################################################################################################

# Matching attributes of the 'voting_districts' to the respondents in 'survey'
overlay <- over(survey, voting_districts)

nrow(overlay) # what does this number correspond to? => rows in 'survey@data'
ncol(overlay) # what does this number correspond to? => columns in 'voting_disticts@data'

# Adding VDNumber to the survey respondents 
survey$VDNumber <- overlay$VDNumber


## Why is the procedure above smart? Describe some perspectives of this approach beyond this particular case 
# Using the function over(), we overlay the survey respondents with the voting_districts, thus using the locations
# in the shape files to match each respondent to a voting district. This is smart since we match data spatially, 
# which potentially can be used to match any data with geographical information, suchs as tweets and drone strikes. 


###################################################################################################################
###################################################################################################################
## EXERCISE 3:  CALCULATING DISTANCES                                                                                 | 3 |                                                                                                   | 3 |
## >> For each respondent in the survey, calculate the distance to the closest 1) voting station, 2) voting 
## >> district border. What is the average distance to the closest voting station? To the voting district border?
## >> use dist2Line
## >> !! Consider: does the code account for the fact that the closest voting stations might not necessarily be 
## >>    the assigned voting station? If not, what could you do, in order to calculate the correct distance?
###################################################################################################################
###################################################################################################################

# Calculating distances from respontens in 'survey' to voting stations and voting district borders 
survey$voting_st_dist <- dist2Line(survey, voting_stations)[,1]
survey$district_dist <- dist2Line(survey, voting_districts)[,1]

## What is the average distance to the closest voting station? Why the '[,1]' in the code above?

mean(survey$voting_st_dist)  # 718,3 m
mean(survey$district_dist)  # 315,7 m

# The [,1] selects the columns with the distance (as opposed to the columns with the coordinates of matched location).


###################################################################################################################
###################################################################################################################
## EXERCISE 4: MAPOVERLAYING (for one raster object & one shapefile object)                                           | 4 |
## >> What region (of what country) harvests most tobacco (measured as harvested area fraction)? 
## >> Use extract()
## !! See 'df' and 'fun' in ?extract. 
###################################################################################################################
###################################################################################################################

# Extracting values from the raster object 'tobacco' for the regions in the shp file 'region'.
# OBS: takes 5-10 min to run, depending on computational power
overlay_2 <- extract(tobacco, region, fun = mean, df=TRUE)

# Binding columns together
result <- cbind(region@data[, c("NAME_0", "NAME_1")], overlay_2)


# What region in which country harvests the most tobacco? Use your dplyr skills on the 'result' dataframe
library(dplyr)
result %>% arrange(desc(tobacco_africa)) %>% head(n = 5)  # Mchinji, Malawi 


### Describe with your own words: What happens in the code above? 
# Here we overlay a raster object with a vector object and extracts the mean values of the raster object within
# the regions, ie the mean tobacco production in each region. The result is returned as a dataframe. 


###################################################################################################################
###################################################################################################################
## EXERCISE 5: CALCULATE AREAS                                                                                        | 5 |
## >> What region covers the largest area in Africa? What country covers the largest area?
## >> Use area()     (and group_by?)
###################################################################################################################
###################################################################################################################

# Calculating areas
region$area_size <- area(region)
region$area_size <- region$area_size*10^(-6)

# Order 'region@data' according to area size with the largest ones first 
region@data <- region@data %>% arrange(desc(area_size))

# Which five regions are the biggest? (the variable 'NAME_1' contains region names)
region@data %>% 
  select(NAME_0, NAME_1, area_size) %>% 
  head(region, n = 5)  # Agadez, Niger; Tamanghasset, Algeria; Timbuktu, Mali; Orientale, DR Congo; Katanga, DR Congo 

# Which five countries are the biggest? (the variable 'NAME_0' contains region names)
region@data %>% 
  group_by(NAME_0) %>% 
  summarize(total_area = sum(round(area_size, digits=0), na.rm=T)) %>% 
  arrange(desc(total_area))  # DR Congo, Algeria, Sudan, Libya, Chad


### Describe with your own words: What happens in the code above? 
# First, we calculate the area of the region using the function area(). Then we transform the units from m^2 to km^2 and 
# arrange the data according to area size in descending order. 


### Does your resulting top 5 largest countries correspond to what Wikipedia has to say? If no, why might this be? # Hint: see ?area
# No, it doesn't. Measuring areas across a large area such a Africa will result in significant impreciseness as
# we project the coordinates on a sphere to a flat plane. 


###################################################################################################################
###################################################################################################################
## EXERCISE 6: PLOTTING SHAPEFILES                                                                                    | 6 |
## >> Plot respondents, voting districts and voting stations across south africa
## >> tm_shape
###################################################################################################################
###################################################################################################################

# Plot
map <- tm_shape(South_africa) + tm_polygons("green", alpha=0.1) + 
          tm_shape(voting_districts) + tm_polygons(alpha=0.4) +
              tm_shape(survey) + tm_dots(size=0.05, "red") +
                  tm_shape(voting_stations) + tm_dots(size=0.05, "blue", alpha=0.6)

# Take a look at the map
map





















