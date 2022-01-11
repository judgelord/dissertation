
load(here::here("data", "comments_congress.Rdata"))

# a string to search for member names
d <- comments_congress %>% 
  mutate(string = paste(submitter_name, title, organization))


# transform year into congress for better matching 
year_congress<- function(year){
  return(floor((year - 1787)/2))
}

d %<>% mutate(congress = Year %>% as.numeric() %>%  year_congress())

# loads data and functions from augmentCongress
load(here::here("data", "members.Rdata") %>% 
       str_replace("dissertation", "augmentCongress") )

source(here::here("R", "nameMethods.R") %>% 
       str_replace("dissertation", "augmentCongress") )

source(here::here("R", "MemberNameTypos.R") %>% 
         str_replace("dissertation", "augmentCongress") )

# test
extractMemberName(data = head(d),
                  col_name = "string")

# get member names / icpsr 
d %<>% extractMemberName(col_name = "string")

d %<>% mutate(FROM = submitter_name,
             comment_url = str_c("https://www.regulations.gov/comment/", id)) %>% 
  select(FROM, bioname, chamber, state, icpsr, title, organization, comment_url, any_of(names(comments_congress)) )



# add blanks for hand coding
d %<>% mutate(position = "",
              position_certainty = "",
              comment_type = "",
              coalition_comment = "",
              coalition_type = "",
              # org_name = organization, # run scratchpad/orgnames.R until this is a function
              org_name_short = "",
              org_type = "",
              ask = "",
              ask1 = "",
              ask2 = "",
              ask3 = "",
              success = "",
              success_certainty = "",
              sucess1 = "",
              success2 = "",
              success3 = "",
              response = "",
              pressure_phrases = "",
              accept_phrases = "",
              compromise_phrases = "",
              reject_phrases = "",
              notes = "")

# replace NA with blank
replace_na_str <- . %>% replace_na("")

d %<>% mutate(across(everything(), replace_na_str))

# save 
write_csv(d, file = "data/comments_congress_clean.csv")


