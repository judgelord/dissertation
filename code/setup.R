
requires <- c("tidyverse",
              "scales",
              "magrittr",
              "broom",
              "here",
              "msm",
              "kableExtra")
to_install <- c(requires %in% rownames(installed.packages()) == FALSE)
install.packages(c(requires[to_install], "NA"), repos = "https://cloud.r-project.org/" )
rm(requires, to_install)

library(scales)
library(magrittr)
library(broom)
library(here)
library(msm)
library(knitr)
library(kableExtra)

library(tidyverse)
library(ggplot2); theme_set(theme_minimal())


options(
  ggplot2.continuous.color = "viridis",
  ggplot2.continuous.fill = "viridis"
)
scale_color_discrete <- function(...)
  scale_color_viridis_d(...)
scale_fill_discrete <- function(...)
  scale_fill_viridis_d(...)


# Table formatting
library(kableExtra)
kablebox <- . %>% 
  slice_head(n = 100) %>%
  knitr::kable() %>% 
  kable_styling() %>% 
  scroll_box(height = "400px")

# a function to format kables for different formats 
kable2 <- function(x, file){
  if(knitr:::is_html_output() | knitr::is_latex_output() ){
      kable_styling(x, latex_options = c("scale_down"))
  } else{
    kableExtra::as_image(x, width = 6.5, file = paste0("figs/", file, ".png"))
    }
}


library(flextable)

# A function to trim and format tables for different outputs 
kable3 <- function(x, caption){
  if(knitr:::is_html_output()) {
    x %>% 
      slice_head(n = 100) %>%
      knitr::kable(caption = caption) %>% 
      kable_styling() %>% 
      scroll_box(height = "400px")
  } else{
    if(knitr::is_latex_output() ){
      x %>% 
        slice_head(n = 20) %>%
        knitr::kable(caption = caption) %>% 
        kable_styling(latex_options = c("scale_down"))
    } else{x %>% 
        slice_head(n = 20) %>%
        flextable() %>% 
        set_caption(caption) %>% 
        autofit() %>% 
        fit_to_width(max_width = 6)
      #knitr::kable(caption = caption) %>% 
      #kableExtra::as_image(file = paste0("figs", caption, ".png"))
    }
  }
}

# inline formatting 
knit_hooks$set(inline = function(x) {
  prettyNum(x, big.mark=",")
})

## Sets defaults for R chunks
knitr::opts_chunk$set(echo = FALSE, # echo = TRUE means that your code will show
                      cache = FALSE,
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






