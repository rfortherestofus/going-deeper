
# Load Packages -----------------------------------------------------------

# Load all packages you'll need here. This includes tidyverse, readxl, and janitor.

library(tidyverse)
library(readxl)
library(janitor)
library(skimr)

# Importing Data -------------------------------------------------------

# You'll be working with the following data:
# Enrollment data: https://www.oregon.gov/ode/reports-and-data/students/Documents/fallmembershipreport_20182019.xlsx
# 3rd grade reading data: https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2019/pagr_Districts_ELA_1819.xlsx

# First, download the two files above manually and put them in the data folder

# Second, download the two files above using the download.file() function. 
# Use the destfile argument to put them in the data folder. 
# In the process, you should overwrite the files you downloaded before. 

# download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/fallmembershipreport_20182019.xlsx",
#               destfile = "data/enrollment.xlsx")
# 
# download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2019/pagr_schools_math_tot_raceethnicity_1819.xlsx",
#               destfile = "data/math-scores.xlsx")

# Using the read_excel() function from the readxl package, import the enrollment data into a data frame called enrollment
# You will need to use the sheet argument to import the data from the District (18-19) sheet
# Then, use the clean_names() function to give you nice variable names to work with

enrollment <- read_excel("data-raw/enrollment.xlsx",
                         sheet = "District (18-19)") %>% 
    clean_names()


# Tidy data ---------------------------------------------------------------

# No exercises here, but read this article on tidy data: https://tidyr.tidyverse.org/articles/tidy-data.html


# Reshaping data ----------------------------------------------------------

# Create a new data frame called enrollment_by_race by doing the following:

# 1. select() the variables from county to district as well as all variables about grade (hint: use the contains() helper function within select())
# 2. Use pivot_longer() to convert all of the grade variables into one variable
# 3. Within pivot_longer(), use the names_to argument to call that variable grade
# 4. Within pivot_longer(), use the values_to argument to call that variable number_of_students


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
    # mutate(race_ethnicity = if_else(race_ethnicity == "x2018_19_asian", "Asian", race_ethnicity)) %>% 
    mutate(race_ethnicity = recode(race_ethnicity,
                                   "x2018_19_asian" = "Asian",
                                   "x2018_19_american_indian_alaska_native" = "American Indian/Alaskan Native",
                                   "x2018_19_black_african_american" = "Black/African American",
                                   "x2018_19_hispanic_latino" = "Hispanic/Latino",
                                   "x2018_19_multiracial" = "Multi-Racial",
                                   "x2018_19_native_hawaiian_pacific_islander" = "Pacific Islander",
                                   "x2018_19_white" = "White",
    )) 


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

Done

# Convert all instances of the race_ethnicity variable that say x2018_19_asian to Asian using if_else()

Done

# Use case_when to convert all instances of the race_ethnicity variable in the following ways:


# Merging data ------------------------------------------------------------

# Merge attendance data with reading scores data

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



enrollment_and_reading_scores_by_race <- left_join(enrollment_by_race, reading_scores_by_race, 
                                            by = c("race_ethnicity" = "student_group",
                                                   "attending_district_institution_id" = "district_id")) 


# Renaming variables ------------------------------------------------------


# Rename pct variable


# Exporting data ----------------------------------------------------------


write_csv()
write_rds()
rio::export()

