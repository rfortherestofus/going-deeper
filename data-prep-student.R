
# Load Packages -----------------------------------------------------------

# Load all packages you'll need here. This includes tidyverse, readxl, and janitor.

library(tidyverse)
library(readxl)
library(janitor)
library(skimr)


# Import Data -------------------------------------------------------------

download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/fallmembershipreport_20182019.xlsx",
              destfile = "data/enrollment.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2019/pagr_schools_math_tot_raceethnicity_1819.xlsx",
              destfile = "data/math-scores.xlsx")

enrollment <- read_excel("data-raw/enrollment.xlsx",
                         sheet = "District (18-19)") %>% 
    clean_names()

# Enrollment by Race ------------------------------------------------------

enrollment_by_race <- enrollment %>% 
    select(-contains("grade")) %>% 
    select(-contains("kindergarten")) %>% 
    select(-contains("percent")) %>% 
    select(-contains("2017")) %>% 
    pivot_longer(cols = -c(county:x2018_19_total_enrollment),
                 names_to = "race_ethnicity",
                 values_to = "number_of_students") %>%
    mutate(number_of_students = na_if(number_of_students, "-")) %>% 
    mutate(number_of_students = replace_na(number_of_students, 0)) %>% 
    mutate(number_of_students = as.numeric(number_of_students)) %>% 
    mutate(pct = number_of_students / x2018_19_total_enrollment) %>% 
    mutate(race_ethnicity = recode(race_ethnicity,
                                   "x2018_19_asian" = "Asian",
                                   "x2018_19_american_indian_alaska_native" = "American Indian/Alaskan Native",
                                   "x2018_19_black_african_american" = "Black/African American",
                                   "x2018_19_hispanic_latino" = "Hispanic/Latino",
                                   "x2018_19_multiracial" = "Multi-Racial",
                                   "x2018_19_native_hawaiian_pacific_islander" = "Pacific Islander",
                                   "x2018_19_white" = "White",
    )) 



# Reading Scores by Race --------------------------------------------------

reading_scores_by_race <- read_excel("data-raw/reading-scores.xlsx",
                             na = c("*", "--", "> 95.0%")) %>% 
    clean_names() %>% 
    filter(grade_level == "All Grades") %>% 
    filter(student_group %in% c("American Indian/Alaskan Native",
                                "Asian",
                                "Black/African American",
                                "Hispanic/Latino",
                                "Multi-Racial",
                                "Pacific Islander",
                                "White")) %>% 
    select(district_id, student_group, percent_proficient_level_3_or_4) %>% 
    mutate(percent_proficient_level_3_or_4 = as.numeric(percent_proficient_level_3_or_4)) %>%
    mutate(percent_proficient_level_3_or_4 = percent_proficient_level_3_or_4 / 100)



# Merge Data --------------------------------------------------------------

enrollment_and_reading_scores_by_race <- left_join(enrollment_by_race, reading_scores_by_race, 
                                            by = c("race_ethnicity" = "student_group",
                                                   "attending_district_institution_id" = "district_id")) %>% 
    rename("district_id" = "attending_district_institution_id",
            "total_enrollment" = "x2018_19_total_enrollment",
           "percent_of_total_enrollment" = "pct",
           "reading_proficient_percent" = "percent_proficient_level_3_or_4")



# Export Data -------------------------------------------------------------

enrollment_and_reading_scores_by_race %>% 
    write_rds("data/enrollment_and_reading_scores_by_race.rds")
