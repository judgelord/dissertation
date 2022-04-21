source("code/setup.R")

load("data/comments_min.Rdata")

library(googlesheets4)
library(googledrive)


gs4_auth(email = "devin.jl@gmail.com")
drive_auth(email = "devin.jl@gmail.com")


kewords <- drive_get(id = "13NvUjpD3VeN5qdNGbGbIV83L4aWuBvJt4sSqzfp79U4") %>% read_sheet(col_types = "c")


k <- str_c(kewords$word, collapse = "|")



d <- filter(comments_min) %>% 
  #FIXME
  filter(!is.na(organization), organization != "")


d$org_name <- d$organization



#FIXME run org_name.R
source("code/org_name.R")

d %<>% filter(str_dct(org_name, k)) 

d %>% 
  distinct(org_name) %>% pull(org_name)


d %<>% select(starts_with("comment"),
              starts_with("org_"),
              starts_with("coalition"),
              everything() ) %>% 
  select(-contains("_txt"), -org_lead, -comment_text)

nrow(d)

d1 <- d %>% 
  ungroup() %>% 
  group_by(org_name) %>% 
  slice_sample(n = 1) %>% 
  arrange(org_name) %>% 
  mutate(comment_url = str_c("https://www.regulations.gov/comment/", id)) %>% 
  select(comment_url, number_of_comments_received, org_name, everything())

# unique(d$org_name)


ss <- drive_get(id = "1hF3X8ENtGrhQVQWEP42ypVMmhtYufWNxLFu7xScpsJc")

sheet_write(d1, ss = ss, sheet = "all")
