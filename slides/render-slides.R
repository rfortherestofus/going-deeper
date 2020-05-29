
# Packages ----------------------------------------------------------------

library(pagedown)
library(tidyverse)
library(magick)


# HTML > PDF --------------------------------------------------------------

chrome_print("slides/slides-data-wrangling-and-analysis.html",
             timeout = 180)

chrome_print("slides/slides-data-visualization.html",
             timeout = 360)

chrome_print("slides/slides-rmarkdown.html",
             timeout = 180)


# PDF > GIF ---------------------------------------------------------------

# data_wrangling_slides <- image_read_pdf("slides/slides-data-wrangling-and-analysis.pdf",
#                                         density = 50)
# 
# data_wrangling_slides %>% 
#   image_animate(fps = 0.5) %>% 
#   image_write("test.gif")

