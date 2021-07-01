
requires <- c("bookdown",
              "tidyverse",
              "scales",
              "magrittr",
              "broom",
              "here",
              "msm",
              "kableExtra",
              "modelsummary",
              "dotwhisker",
              "mediation",
              "lme4",
              "lmerTest",
              "fixest",
              "flextable",
              "magick",
              "equatiomatic", 
              "latex2exp",
              "tidytext",
              "latex2exp")
to_install <- c(requires %in% rownames(installed.packages()) == FALSE)
install.packages(c(requires[to_install], "NA"), repos = "https://cloud.r-project.org/" )
rm(requires, to_install)

library(scales)
library(magrittr)
library(broom)
library(dotwhisker)
library(here)
library(knitr)
library(kableExtra)
library(mediation)
#library(lme4)
library(lmerTest)
library(fixest)
library(modelsummary)
library(tidyverse)

library(ggplot2); theme_set(theme_bw());
options(
  ggplot2.continuous.color = "viridis",
  ggplot2.continuous.fill = "viridis"
)
scale_color_discrete <- function(...){
  scale_color_viridis_d(..., direction = -1, 
                        begin = 0, end = .6, option = "plasma")}
scale_fill_discrete <- function(...){
  scale_fill_viridis_d(..., direction = -1, 
                       begin = 0, end = .6, option = "plasma")}

scale_color_continuous <- function(...){
  scale_color_viridis_c(..., direction = -1, 
                        option = "plasma")}
scale_fill_continuous <- function(...){
  scale_fill_viridis_c(..., direction = -1, 
                       option = "plasma")}



options(
  ggplot2.continuous.color = "viridis",
  ggplot2.continuous.fill = "viridis"
)



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
      x %>% kable_styling(latex_options = c("scale_down"))
  } else{
    kableExtra::as_image(x, width = 6.5, file = paste0("figs/", file, ".png"))
    }
}


library(flextable)

# A function to trim and format tables for different outputs 
kable3 <- function(x, caption = ""){
  if(knitr:::is_html_output()) {
    x %>% 
      ungroup() %>% 
      slice_head(n = 100) %>%
      knitr::kable(caption = caption) %>% 
      kable_styling() %>% 
      scroll_box(height = "400px")
  } else{
    if(knitr::is_latex_output() ){
      x %>% 
        ungroup() %>% 
        slice_head(n = 20) %>%
        knitr::kable(caption = caption) %>% 
        kable_styling(font_size = 10)
    } else{x %>% 
        ungroup() %>% 
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

fig.path <- here("figs")

## Sets defaults for R chunks
knitr::opts_chunk$set(echo = FALSE, # echo = TRUE means that code will show
                      #cache = FALSE,
                      cache = TRUE,
                      warning = FALSE,
                      message = FALSE,
                      fig.show="hold",
                      fig.pos= "htbp",
                      fig.path = "figs/",
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






