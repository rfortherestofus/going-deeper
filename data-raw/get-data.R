
# Load Packages -----------------------------------------------------------

library(tidyverse)
library(readxl)
library(janitor)
library(rio)

# Math --------------------------------------------------------------------

# download.file("https://www.oregon.gov/ode/educator-resources/assessment/TestResults2018/pagr_schools_math_tot_ecd_ext_gnd_lep_1718.xlsx",
#               destfile = "data-raw/original-math-scores-17-18.xlsx")
# 
# download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2019/pagr_schools_math_tot_ecd_hom_mlc_1819.xlsx",
#               destfile = "data-raw/original-math-scores-18-19.xlsx")

math_scores_17_18 <- read_excel("data-raw/original-math-scores-17-18.xlsx") %>%
  clean_names() %>%
  select(school_id, student_group:last_col()) %>%
  select(-c(number_proficient, percent_proficient_level_3_or_4, participation_rate, number_of_participants)) 

math_scores_17_18 %>%
  export("data-raw/math-scores-17-18.xlsx")

math_scores_18_19 <- read_excel("data-raw/original-math-scores-18-19.xlsx") %>%
  clean_names() %>%
  select(school_id, student_group:last_col()) %>%
  select(-c(number_proficient, percent_proficient_level_3_or_4, participation_rate, number_of_participants))

math_scores_18_19 %>%
  export("data-raw/math-scores-18-19.xlsx")



# Enrollment --------------------------------------------------------------

# download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/fallmembershipreport_20172018.xlsx",
#               destfile = "data-raw/original-enrollment-17-18.xlsx")
#
# download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/fallmembershipreport_20182019.xlsx",
#               destfile = "data-raw/original-enrollment-18-19.xlsx")


enrollment_17_18 <- read_excel("data-raw/original-enrollment-17-18.xlsx",
                               sheet = "District (17-18)") %>% 
  clean_names() %>% 
  select(-contains("total")) %>% 
  select(-district) %>%
  select(-county) %>% 
  rename(district_id = attending_district_institution_id)

enrollment_17_18 %>% 
  export("data-raw/enrollment-17-18.xlsx")

enrollment_18_19 <- read_excel("data-raw/original-enrollment-18-19.xlsx",
                               sheet = "District (18-19)") %>% 
  clean_names() %>% 
  select(-contains("total")) %>% 
  select(-district) %>%
  select(-county) %>% 
  rename(district_id = attending_district_institution_id)

enrollment_18_19 %>% 
  export("data-raw/enrollment-18-19.xlsx")

