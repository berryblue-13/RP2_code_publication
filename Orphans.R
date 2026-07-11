

#Clearing global environment and loading necessary packages
rm(list = ls())
setwd("") #The full path to the folder with this script and the data should be specified between quotation brackets
library(tidyverse)
library(data.table)
library(lubridate)
library(DescTools)
library(crayon)

#Loading relevant files
RepurposingDB <- read.delim("DATA/repurposing and type II for rstud with index.txt")
EMRD <- read.delim("DATA/EMRD_for_rstud.txt")


#Filtering repurposed drugs from the repurposingDB (Muizelaar et al., 2025)
repurposed <- RepurposingDB %>%
  filter(
    repurposing == 1|type2_var == 1
  )


#Filtering orphans from EMRD (Bloem et al., 2025)
EMRD_orphans <- EMRD %>%
  filter(
    OD_at_MA == "True"
  )


#Harmonisation of name formatting
repurposed$name <- tolower(repurposed$name)

EMRD_orphans$brand_name_current <- tolower(EMRD_orphans$brand_name_current)

EMRD_orphans$brand_name_original <- tolower(EMRD_orphans$brand_name_original)


#Filtering orphans from repurposed drugs based on brand name
repurposed_orphans <- repurposed %>%
  filter(
    name %in% c(EMRD_orphans$brand_name_current, EMRD_orphans$brand_name_original)
    )

#Filtering orphans from repurposed drugs based on name of active substance. 
#This list may contain false positives and should therefore be manually verified
repurposed_orphans_substancebased <- repurposed %>%
  filter(
    active_substance %in% c(EMRD_orphans$act_substance_current, EMRD_orphans$act_substance_original),
    !name %in% c(repurposed_orphans$name)
    )


#Preparing the list of orphan repurposing cases for export
repurposed_orphans_export <- as.data.frame(repurposed_orphans)

repurposed_orphans_export <- repurposed_orphans_export %>%
  select(
    name, 
    active_substance, 
    ma_date, 
    type2_var, 
    repurposing
    ) %>%
  mutate(
    ma_date = dmy(ma_date)
  )

#Preparing the list of of substance-based matches for export
substance_based_matches_export <- as.data.frame(repurposed_orphans_substancebased)

substance_based_matches_export <- substance_based_matches_export %>%
  select(
    name, 
    active_substance, 
    ma_date, 
    type2_var, 
    repurposing
  ) %>%
  mutate(
    ma_date = dmy(ma_date)
  )

#Export lists to folder
write.csv(repurposed_orphans_export, file = "OUTPUT/repurposed orphans.csv", row.names = FALSE)
write.csv(substance_based_matches_export, file = "OUTPUT/substance based matches.csv", row.names = FALSE)

#Necessary warning messages
writeLines("THE LIST CONTAINED IN SUBSTANCE BASED MATCHES MAY CONTAIN FALSE POSITIVE CASES AND SHOULD BE MANUALLY CHECKED FOR ORPHAN STATUS AND REPURPOSING CLASSIFICATION", "IMPORTANT READ ME.txt")
cat(bold(green("\n Script completed.")))
cat(bold(yellow("\n IMPORTANT NOTE: THE LIST CONTAINED IN SUBSTANCE BASED MATCHES MAY CONTAIN FALSE POSITIVE CASES AND SHOULD BE MANUALLY CHECKED FOR ORPHAN STATUS AND REPURPOSING CLASSIFICATION")))