
# Load Packages -----------------------------------------------------------

# Load all packages you'll need here. This includes tidyverse, readxl, and janitor.

library(tidyverse)
library(readxl)
library(janitor)


# Import Data -------------------------------------------------------------

# download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/regularattenders_report_1819.xlsx",
#               destfile = "data/regular-attenders.xlsx")
# 
# download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2019/pagr_schools_math_tot_raceethnicity_1819.xlsx",
#               destfile = "data/math-scores.xlsx")

math_scores <- read_excel("data-raw/math-scores.xlsx") %>% 
    clean_names()

attendance <- read_excel("data-raw/regular-attenders.xlsx", 
                         sheet = "1819 Regular Attenders Data") %>% 
    clean_names()


# Percent not Proficient in Math ------------------------------------------

math_percent_not_proficient <- math_scores %>% 
    filter(student_group == "Total Population (All Students)") %>% 
    filter(grade_level == "Grade 3") %>% 
    select(school_id, school, district, district_id, contains("percent")) %>% 
    select(-percent_proficient_level_3_or_4) %>% 
    pivot_longer(cols = -c(school_id, school, district, district_id),
                 names_to = "proficiency_level",
                 values_to = "percent_proficient") %>% 
    mutate(percent_proficient = na_if(percent_proficient, "--")) %>% 
    mutate(percent_proficient = na_if(percent_proficient, "*")) %>% 
    mutate(percent_proficient = as.numeric(percent_proficient)) %>% 
    mutate(proficiency_level = case_when(
        proficiency_level == "percent_level_1" ~ "Level 1",
        proficiency_level == "percent_level_2" ~ "Level 2",
        proficiency_level == "percent_level_3" ~ "Level 3",
        proficiency_level == "percent_level_4" ~ "Level 4"
    )) %>% 
    drop_na(percent_proficient) %>% 
    filter(proficiency_level %in% c("Level 1", "Level 2")) %>% 
    group_by(school, school_id, district, district_id) %>% 
    summarize(percent_not_proficient = sum(percent_proficient)) %>% 
    mutate(percent_not_proficient = percent_not_proficient / 100) %>% 
    ungroup() %>% 
    view()


# Chronic Absenteeism -----------------------------------------------------

chronic_absenteeism <- attendance %>% 
    filter(student_group == "Grade 3") %>% 
    select(institution_id, institution, percent_chronically_absent) %>% 
    mutate(percent_chronically_absent = na_if(percent_chronically_absent, "-")) %>%
    mutate(percent_chronically_absent = na_if(percent_chronically_absent, "*")) %>%
    mutate(percent_chronically_absent = na_if(percent_chronically_absent, ">95")) %>%
    mutate(percent_chronically_absent = as.numeric(percent_chronically_absent)) %>% 
    mutate(percent_chronically_absent = percent_chronically_absent / 100)


# Merge Data --------------------------------------------------------------

math_scores_chronic_absenteeism <- left_join(math_percent_not_proficient, 
                                             chronic_absenteeism, 
                                             by = c("school_id" = "institution_id")) %>% 
    select(-institution) %>% 
    rename("percent_not_proficient_math" = "percent_not_proficient")


# Export Data -------------------------------------------------------------

write_csv(math_scores_chronic_absenteeism,
          "data/math_scores_chronic_absenteeism.csv")

write_rds(math_scores_chronic_absenteeism,
          "data/math_scores_chronic_absenteeism.rds")

