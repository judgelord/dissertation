options(stringsAsFactors = FALSE)

requires <- c("dplyr", 
              "ggplot2", 
              "gdata", 
              "magrittr",
              "stringi",
              "stringr", 
              "stargazer",
              "here",
              "tidyverse")
to_install <- c(requires %in% rownames(installed.packages()) == FALSE)
install.packages(c(requires[to_install], "NA"), repos = "https://cloud.r-project.org/" )
rm(requires, to_install)

library(tidyverse)
library(dplyr) # in case tydyverse fails (problem on linux)
library(ggplot2)
library(magrittr)
library(stringr)
library(stringi)
library(here)
