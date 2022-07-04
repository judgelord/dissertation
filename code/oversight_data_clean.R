library(tidyverse)
library(magrittr)
library(googledrive)
library(googlesheets4)

source("../correspondence/setup.R")
source("code/setup.R")

load(url("https://github.com/judgelord/augmentCongress/raw/main/data/members.rda"))

source(url("https://raw.githubusercontent.com/judgelord/augmentCongress/main/R/nameMethods.R"))
source(url("https://raw.githubusercontent.com/judgelord/augmentCongress/main/R/MemberNameTypos.R"))


# read all as char
read_sheet_c <- . %>% read_sheet(col_types = "c")


gs4_auth(email = "devin.jl@gmail.com")
drive_auth(email = "devin.jl@gmail.com")



#1 ###########################
# comments_congress sheet 
s <- drive_get(id ="1HBjG32qWVdf9YxfGPEJhNmSw65Z9XzPhHdDbLnc3mYc")

s$name 

comments_congress <- read_sheet_c(s)

comments_congress %<>% mutate(across(everything(), str_to_lower))

comments_congress %>% count(coalition_type)

comments_congress$icpsr %<>% as.numeric()
comments_congress$congress %<>% as.integer()
comments_congress$TYPE %<>% as.integer()

comments_congress %<>% 
  filter(!is.na(bioname) | str_dct(org_type,"house|senat|congress|rep")) %>% 
  select(comment_url, id, docket_id, chamber, congress, posted_date, org_name, org_type, position, 
         coalition, coalition_type, success)

select <- . %>% dplyr::select(...)

comments_congress %<>% dplyr::select(-chamber, -state) %>% 
  mutate(ERROR = "", DATE = posted_date) %>%
  extractMemberName(col_name = "org_name", members = members)

# filter to matched observations
comments_congress %<>% 
  drop_na(icpsr) 

# derivative vars
comments_congress %<>% 
  mutate(
    agency = str_remove(docket_id, "-.*"), 
    POLICY_EVENT = "rule",
    TYPE = case_when(
           str_dct(coalition_type, "private") ~ 4,
           str_dct(coalition_type, "public") ~ 5
         ))


save(comments_congress, file = here::here("data", "comments_congress_coded.Rdata"))
  


#2 ######################################
# get letters_congress sheet
s <- drive_get(id ="1Za78Pcmjw-E71_n-utMiKxVTn8oXVR1To94gFWlw60c")

s$name 

letters_congress <- read_sheet_c(s)


year_congress<- function(year){
  return(floor((year - 1787)/2))
}

letters_congress %<>% 
  mutate(year = str_sub(DATE, 1,4) %>% as.numeric(),
         congress = year_congress(year))


letters_congress$icpsr %<>% as.numeric()
letters_congress$congress %<>% as.integer()
letters_congress$TYPE %<>% as.integer()

letters_congress %<>% left_join(members %>% select(chamber, icpsr, congress))


letters_congress  %<>% 
  select(FROM, DATE, agency, icpsr, congress, chamber, chair_of, 
         oversight_committee, oversight_committee_chair, TYPE, POLICY_EVENT,
         EVENT_COMMITTEE, EVENT_NAME, EVENT_DATE, event_url, success)

letters_congress %<>% 
  mutate(agency = str_remove(agency, "_HQ") %>% 
           str_remove(agency, ".*_") )
  

save(letters_congress, file = here::here("data", "letters_congress_coded.Rdata"))


#3 ##########################
# Join the two
oversight <-  full_join(comments_congress, letters_congress)

save(oversight, file = here::here("data", "oversight.Rdata"))

