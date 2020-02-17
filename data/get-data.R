
# Load Packages -----------------------------------------------------------

library(tidyverse)
library(readxl)
library(janitor)
library(rio)


# 3rd Grade Math ----------------------------------------------------------

download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2019/pagr_schools_math_tot_raceethnicity_1819.xlsx",
              destfile = "data/math-scores.xlsx")


# Regular Attenders -------------------------------------------------------

download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/regularattenders_report_1819.xlsx",
              destfile = "data/regular-attenders.xlsx")


# Enrollment --------------------------------------------------------------

download.file("https://www.oregon.gov/ode/reports-and-data/students/Documents/fallmembershipreport_20182019.xlsx",
              destfile = "data/enrollment.xlsx")


# 3rd Grade Reading -------------------------------------------------------

download.file("https://www.oregon.gov/ode/educator-resources/assessment/Documents/TestResults2019/pagr_Districts_ELA_1819.xlsx",
              destfile = "data/reading-scores.xlsx")

