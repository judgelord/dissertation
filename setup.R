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
              "tm")
to_install <- c(requires %in% rownames(installed.packages()) == FALSE)
install.packages(c(requires[to_install], "NA"), repos = "https://cloud.r-project.org/" )
rm(requires, to_install)

library(tidyverse)
library(dplyr) # in case tydyverse fails (problem on linux)
library(ggplot2); theme_set(theme_bw())
library(magrittr)
library(stringr)
library(here)

library(topicmodels)
library(tidyverse)
library(tidytext)
library(quanteda)
library(tm)
