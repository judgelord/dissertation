source(here::here("code/setup.R"))
library(googledrive)
library(googlesheets4)

gs4_auth(email = "devin.jl@gmail.com")
1
drive_auth(email = "devin.jl@gmail.com")
1

# read all as char
read_sheet_c <- . %>% read_sheet(col_types = "c")

#textrank
d <- read_sheet_c("1bshINHSVs46MmcPOCPbIWwa7GD8QADxpkv4vbW5eqgI")

#  sheet without textrank
d1 <- read_sheet_c("1rUAXUiXXEgPWM_QpOdnBlHUZ_NVX0mvHOhRhAbZq1zQ")


d %<>% left_join(d1)

sheet_write(d, ss = "1bshINHSVs46MmcPOCPbIWwa7GD8QADxpkv4vbW5eqgI")
