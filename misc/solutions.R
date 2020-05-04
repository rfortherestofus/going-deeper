# DATA PREP DK ------------------------------------------------------------

# Load Packages -----------------------------------------------------------

# Load all packages you'll need here. This includes tidyverse, readxl, and janitor.

library(tidyverse)
library(readxl)
library(janitor)


# Import Data -------------------------------------------------------------

math_scores_17_18 <- read_excel("data-raw/math-scores-17-18.xlsx")

math_scores_18_19 <- read_excel("data-raw/math-scores-18-19.xlsx")



# Third Grade Math Proficiency --------------------------------------------


third_grade_math_proficiency_18_19 <- math_scores_18_19 %>% 
    filter(student_group == "Total Population (All Students)") %>% 
    filter(grade_level == "Grade 3") %>% 
    select(school_id, contains("number")) %>% 
    pivot_longer(cols = -school_id,
                 names_to = "proficiency_level",
                 values_to = "number_proficient") %>% 
    mutate(number_proficient = na_if(number_proficient, "--")) %>% 
    mutate(number_proficient = na_if(number_proficient, "*")) %>% 
    mutate(number_proficient = as.numeric(number_proficient)) %>% 
    mutate(proficiency_level = parse_number(proficiency_level)) %>% 
    mutate(proficiency_level = case_when(
        proficiency_level >= 3 ~ "Proficient",
        TRUE ~ "Not Proficient"
    )) %>%
    group_by(school_id, proficiency_level) %>% 
    summarize(number_proficient = sum(number_proficient)) %>% 
    ungroup() %>% 
    drop_na(number_proficient) %>%
    group_by(school_id) %>% 
    mutate(percent_proficient = number_proficient / sum(number_proficient)) %>% 
    ungroup() %>% 
    filter(proficiency_level == "Proficient") %>% 
    select(-proficiency_level) %>% 
    mutate(year = "2018-2019")


third_grade_math_proficiency_17_18 <- math_scores_17_18 %>% 
    filter(student_group == "Total Population (All Students)") %>% 
    filter(grade_level == "Grade 3") %>% 
    select(school_id, contains("number")) %>% 
    pivot_longer(cols = -school_id,
                 names_to = "proficiency_level",
                 values_to = "number_proficient") %>% 
    mutate(number_proficient = na_if(number_proficient, "--")) %>% 
    mutate(number_proficient = na_if(number_proficient, "*")) %>% 
    mutate(number_proficient = as.numeric(number_proficient)) %>% 
    mutate(proficiency_level = parse_number(proficiency_level)) %>% 
    mutate(proficiency_level = case_when(
        proficiency_level >= 3 ~ "Proficient",
        TRUE ~ "Not Proficient"
    )) %>%
    group_by(school_id, proficiency_level) %>% 
    summarize(number_proficient = sum(number_proficient)) %>% 
    ungroup() %>% 
    view()
    drop_na(number_proficient) %>%
    group_by(school_id) %>% 
    mutate(percent_proficient = number_proficient / sum(number_proficient)) %>% 
    ungroup() %>% 
    filter(proficiency_level == "Proficient") %>% 
    select(-proficiency_level) %>% 
    mutate(year = "2017-2018")



third_grade_math_proficiency <- bind_rows(third_grade_math_proficiency_17_18,
                                          third_grade_math_proficiency_18_19)

# Merge Data --------------------------------------------------------------

oregon_districts_and_schools <- read_excel("data-raw/oregon-districts-and-schools.xlsx") %>% 
    clean_names()

third_grade_math_proficiency <- left_join(third_grade_math_proficiency,
                                          oregon_districts_and_schools,
                                          by = c("school_id" = "attending_school_institutional_id")) %>% 
    rename("district_id" = "attending_district_institutional_id") %>% 
    drop_na(school) %>% 
    select(school, school_id, district, district_id, percent_proficient, year) 

# Export Data -------------------------------------------------------------

write_csv(third_grade_math_proficiency,
          "data/third_grade_math_proficiency.csv")

write_rds(third_grade_math_proficiency,
          "data/third_grade_math_proficiency.rds")



# DATA PREP STUDENT -------------------------------------------------------

# Load Packages -----------------------------------------------------------

# Load all packages you'll need here. This includes tidyverse, readxl, and janitor.

library(tidyverse)
library(readxl)
library(janitor)
library(skimr)


# Import Data -------------------------------------------------------------

enrollment_17_18 <- read_excel("data-raw/enrollment-17-18.xlsx")

enrollment_18_19 <- read_excel("data-raw/enrollment-18-19.xlsx")



# Enrollment by Race ------------------------------------------------------


enrollment_by_race_ethnicity_18_19 <- enrollment_18_19 %>% 
    select(-contains("grade")) %>% 
    select(-contains("kindergarten")) %>% 
    select(-contains("percent")) %>% 
    select(-contains("male")) %>% 
    pivot_longer(cols = -district_id,
                 names_to = "race_ethnicity",
                 values_to = "number_of_students") %>% 
    mutate(number_of_students = na_if(number_of_students, "-")) %>% 
    mutate(number_of_students = replace_na(number_of_students, 0)) %>% 
    mutate(number_of_students = as.numeric(number_of_students)) %>% 
    mutate(race_ethnicity = str_remove(race_ethnicity, "x2018_19_")) %>% 
    mutate(race_ethnicity = recode(race_ethnicity,
                                   "asian" = "Asian",
                                   "american_indian_alaska_native" = "American Indian/Alaskan Native",
                                   "black_african_american" = "Black/African American",
                                   "hispanic_latino" = "Hispanic/Latino",
                                   "multiracial" = "Multi-Racial",
                                   "native_hawaiian_pacific_islander" = "Pacific Islander",
                                   "white" = "White",
    )) %>%
    group_by(district_id) %>% 
    mutate(pct = number_of_students / sum(number_of_students)) %>%
    ungroup() %>% 
    mutate(year = "2018-2019")

enrollment_by_race_ethnicity_17_18 <- enrollment_17_18 %>% 
    select(-contains("grade")) %>% 
    select(-contains("kindergarten")) %>% 
    select(-contains("percent")) %>% 
    select(-contains("male")) %>% 
    pivot_longer(cols = -district_id,
                 names_to = "race_ethnicity",
                 values_to = "number_of_students") %>% 
    mutate(number_of_students = na_if(number_of_students, "-")) %>% 
    mutate(number_of_students = replace_na(number_of_students, 0)) %>% 
    mutate(number_of_students = as.numeric(number_of_students)) %>% 
    mutate(race_ethnicity = str_remove(race_ethnicity, "x2017_18_")) %>% 
    mutate(race_ethnicity = recode(race_ethnicity,
                                   "asian" = "Asian",
                                   "american_indian_alaska_native" = "American Indian/Alaskan Native",
                                   "black_african_american" = "Black/African American",
                                   "hispanic_latino" = "Hispanic/Latino",
                                   "multiracial" = "Multi-Racial",
                                   "native_hawaiian_pacific_islander" = "Pacific Islander",
                                   "white" = "White",
    )) %>%
    group_by(district_id) %>% 
    mutate(pct = number_of_students / sum(number_of_students)) %>%
    ungroup() %>% 
    mutate(year = "2017-2018")

enrollment_by_race_ethnicity <- bind_rows(enrollment_by_race_ethnicity_17_18,
                                          enrollment_by_race_ethnicity_18_19)

# Merge Data --------------------------------------------------------------

oregon_districts <- read_excel("data-raw/oregon-districts.xlsx") %>% 
    clean_names()

enrollment_by_race_ethnicity <- left_join(enrollment_by_race_ethnicity, 
                                          oregon_districts, 
                                          by = c("district_id" = "attending_district_institutional_id")) %>% 
    rename(percent_of_total_enrollment = pct) %>% 
    select(district_id, district, everything()) 

# Export Data -------------------------------------------------------------

enrollment_by_race_ethnicity %>% 
    write_rds("data/enrollment_by_race_ethnicity.rds")



# DATA VIZ ----------------------------------------------------------------


# Load Packages -----------------------------------------------------------

library(tidyverse)
library(scales)
library(gghighlight)
library(ggrepel)
library(shadowtext)
library(ggtext)

# DK SLOPEGRAPH -----------------------------------------------------------



# https://twitter.com/dgkeyes/status/1237812892189093888


# Slopegraph --------------------------------------------------------------

third_grade_math_proficiency <- read_rds("data/third_grade_math_proficiency.rds")

schools_to_highlight <- third_grade_math_proficiency %>% 
    filter(school %in% c("Vestal Elementary School")) %>% 
    mutate(percent_proficient_display = percent(percent_proficient, 1))


third_grade_math_proficiency %>% 
    filter(district %in% c("Portland SD 1J")) %>%
    ggplot(aes(year, percent_proficient,
               group = school)) +
    theme_minimal(base_family = "Inter Medium") +
    geom_line(color = "lightgray") +
    geom_line(data = schools_to_highlight,
              inherit.aes = TRUE,
              color = "blue") +
    geom_shadowtext(data = schools_to_highlight,
                    inherit.aes = TRUE,
                    aes(label = percent_proficient_display),
                    color = "blue",
                    nudge_x = c(-0.1, 0, 0.1),
                    nudge_y = c(0, -0.01, 0),
                    bg.color = "white") +
    labs(x = NULL,
         y = NULL,
         title = "<span style = 'color: blue;'>Vestal Elementary School</span> showed large growth between 2017-2018 and 2018-2019") +
    scale_y_continuous(label = percent_format(1)) +
    scale_x_discrete(expand = c(0, 0.2, 0, 0.2)) +
    theme(panel.grid.minor = element_blank(),
          plot.title = element_markdown(lineheight = 1.2))


# STUDENT SLOPEGRAPH ------------------------------------------------------

enrollment_by_race_ethnicity <- read_rds("data/enrollment_by_race_ethnicity.rds")

enrollment_by_race_ethnicity %>% 
    filter(race_ethnicity == "White") %>% 
    
    ggplot(aes(percent_of_total_enrollment)) +
    geom_histogram() 

enrollment_by_race_ethnicity %>% 
    filter(race_ethnicity == "White") %>% 
    ggplot(aes(percent_of_total_enrollment,
               1)) +
    geom_point(alpha = 0.5) +
    theme_void() +
    scale_x_continuous(limits = c(0, 1.1),
                       labels = percent_format())

pct_white <- enrollment_by_race_ethnicity %>% 
    filter(race_ethnicity == "White")

enrollment_by_race_ethnicity %>% 
    # filter(race_ethnicity == "White") %>%
    # mutate(district = factor(district)) %>%
    mutate(district = fct_rev(district)) %>%
    ggplot(aes(percent_of_total_enrollment,
               district,
               fill = race_ethnicity)) +
    geom_col() 
