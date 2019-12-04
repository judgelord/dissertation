## Sets defaults for R chunks
knitr::opts_chunk$set(echo = FALSE, # echo = TRUE means that your code will show
                      warning = FALSE,
                      message = FALSE,
                      # fig.align = "center", 
                      fig.path= 'Figs/', ## where to save figures
                      fig.height = 3,
                      # fig.retina = 6,
                      fig.width = 8)
                      #dev = "cairo_pdf")
options(stringsAsFactors = FALSE)

requires <- c("dplyr", 
              "ggplot2", 
              "magrittr",
              "stringr", 
              "here",
              "tidyverse",
              "topicmodels",
              "tidytext",
              "quanteda",
              "topicmodels",
              "tm",
              "msm",
              "kableExtra")
to_install <- c(requires %in% rownames(installed.packages()) == FALSE)
install.packages(c(requires[to_install], "NA"), repos = "https://cloud.r-project.org/" )
rm(requires, to_install)

library(tidyverse)
library(ggplot2); theme_set(theme_bw())
library(magrittr)
library(broom)
library(here)
library(topicmodels)
library(tidytext)
library(quanteda)
library(tm)
library(msm)
library(kableExtra)



