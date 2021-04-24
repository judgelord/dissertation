
requires <- c("tidyverse",
              "magrittr",
              "broom",
              "here",
              "msm",
              "kableExtra")
to_install <- c(requires %in% rownames(installed.packages()) == FALSE)
install.packages(c(requires[to_install], "NA"), repos = "https://cloud.r-project.org/" )
rm(requires, to_install)

library(tidyverse)
# library(ggplot2); theme_set(theme_bw())
library(magrittr)
library(broom)
library(here)
library(msm)
library(kableExtra)

library(ggplot2); theme_set(theme_minimal())
options(
  ggplot2.continuous.color = "viridis",
  ggplot2.continuous.fill = "viridis"
)
scale_color_discrete <- function(...)
  scale_color_viridis_d(...)
scale_fill_discrete <- function(...)
  scale_fill_viridis_d(...)

kablebox <- . %>% 
  head(100) %>%
  knitr::kable() %>% 
  kable_styling() %>% 
  scroll_box(height = "400px")


## Sets defaults for R chunks
knitr::opts_chunk$set(echo = FALSE, # echo = TRUE means that your code will show
                      warning = FALSE,
                      message = FALSE,
                      fig.show="hold",
                      fig.pos= "htbp",
                      #fig.path = "Figs/",
                      fig.align='center',
                      fig.cap = '   ',
                      fig.retina = 6,
                      fig.height = 3,
                      fig.width = 7,
                      out.width = "100%",
                      out.extra = "")

options(stringsAsFactors = FALSE)

options(knitr.graphics.auto_pdf = TRUE)


#functions for case sensitive string manipulation
str_rm_all <- function(string, pattern) {
  str_remove_all(string, regex(pattern, ignore_case = TRUE))
}

str_rpl <- function(string, pattern, replacement) {
  str_replace(string, regex(pattern, ignore_case = TRUE), replacement)
}

str_rm <- function(string, pattern) {
  str_remove(string, regex(pattern, ignore_case = TRUE))
}

str_dct <- function(string, pattern) {
  str_detect(string, regex(pattern, ignore_case = TRUE))
}

str_ext <- function(string, pattern) {
  str_extract(string, regex(pattern, ignore_case = TRUE))
}

str_spl <- function(string, pattern) {
  str_split(string, regex(pattern, ignore_case = TRUE))
}






