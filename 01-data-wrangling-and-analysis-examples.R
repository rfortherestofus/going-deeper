
# Load Packages -----------------------------------------------------------

# Load all packages you'll need here. This includes tidyverse, readxl, and janitor.

library(tidyverse)
library(readxl)
library(janitor)
library(skimr)

# Importing Data -------------------------------------------------------

# We'll be working with the following data:
# Attendance data: https://www.oregon.gov/ode/reports-and-data/students/Documents/fallmembershipreport_20182019.xlsx
# 3rd grade math data: https://www.oregon.gov/ode/reports-and-data/students/Documents/regularattenders_report_1819.xlsx

# First, download the two files above manually and put them in the data folder

# YOUR CODE HERE

# Second, download the two files above using the download.file() function. 
# Use the destfile argument to put them in the data folder. 
# In the process, you should overwrite the files you downloaded before. 

download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/regularattenders_report_1819.xlsx",
              destfile = "data/regular-attenders.xlsx")

download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2019/pagr_schools_math_tot_raceethnicity_1819.xlsx",
              destfile = "data/math-scores.xlsx")


# Using the read_excel() function from the readxl package, import the math scores data into a data frame called math_scores
# You will need to use the sheet argument to import the data from the District (18-19) sheet
# Then, use the clean_names() function to give you nice variable names to work with

math_scores <- read_excel("data/math-scores.xlsx") %>% 
    clean_names()

attendance <- read_excel("data/regular-attenders.xlsx", 
                         sheet = "1819 Regular Attenders Data") %>% 
    clean_names()


# Reshaping data ----------------------------------------------------------

# Create a new data frame called third_grade_math_proficiency by doing the following:

# 1. filter to only keep rows where the student_group variable is "Total Population (All Students)"
# 2. 

math_scores_percent_proficient <- math_scores %>% 
    filter(student_group == "Total Population (All Students)") %>% 
    filter(grade_level == "Grade 3") %>% 
    select(school_id, school, contains("percent")) %>% 
    select(-percent_proficient_level_3_or_4) %>% 
    pivot_longer(cols = -c(school_id, school),
                 names_to = "proficiency_level",
                values_to = "percent_proficient") %>% 
    mutate(percent_proficient = na_if(percent_proficient, "--")) %>% 
    mutate(percent_proficient = na_if(percent_proficient, "*")) %>% 
    mutate(percent_proficient = as.numeric(percent_proficient))

# Dealing with missing data -----------------------------------------------

# Convert all of the missing values (they should show up as "-") in the number_of_students variable to NA using na_if()

Done

# Convert all of the values in the number_of_students variable, which should actually show up as NA, to 0 using replace_na()

Done

# Changing variable types -------------------------------------------------

# Convert the number_of_students variable to numeric by using as.numeric()

Done


# Advanced variable creation ----------------------------------------------

# Convert all instances of the race_ethnicity variable that say x2018_19_asian to Asian using recode()

# Convert all instances of the race_ethnicity variable that say x2018_19_asian to Asian using if_else()

# Use case_when to convert all instances of the race_ethnicity variable in the following ways:


# Merging data ------------------------------------------------------------

# Merge attendance data with reading scores data

reading_scores <- read_excel("data/reading-scores.xlsx",
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
    select(academic_year:grade_level, percent_proficient_level_3_or_4) %>% 
    mutate(percent_proficient_level_3_or_4 = as.numeric(percent_proficient_level_3_or_4)) %>% 
    mutate(percent_proficient_level_3_or_4 = percent_proficient_level_3_or_4 / 100) %>% 
    select(-c(academic_year, district, subject, grade_level)) %>% 
    mutate(unique_id = str_glue("{district_id} {student_group}"))



enrollment_and_reading_by_race <- left_join(enrollment_by_race, reading_scores, by = "unique_id") %>% 
    select(district_id, district, county, race_ethnicity, number_of_students, pct, percent_proficient_level_3_or_4) %>% 
    rename("pct_of_school_enrollment" = "pct")


# Renaming variables ------------------------------------------------------


# Rename pct variable



# Exporting data ----------------------------------------------------------


write_csv()
write_rds()
rio::export()

