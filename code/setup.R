
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
library(ggplot2); theme_set(theme_bw())
library(magrittr)
library(broom)
library(here)
library(msm)
library(kableExtra)


## Sets defaults for R chunks
knitr::opts_chunk$set(echo = FALSE, # echo = TRUE means that your code will show
                      warning = FALSE,
                      message = FALSE,
                      fig.show="hold",
                      fig.pos= "htbp",
                      out.extra = "",
                      fig.path = "figs/",
                      out.width = "100%",
                      fig.align='center',
                      fig.cap = '...',
                      fig.retina = 6,
                      fig.height = 3,
                      fig.width = 7)

options(stringsAsFactors = FALSE)

options(knitr.graphics.auto_pdf = TRUE)



