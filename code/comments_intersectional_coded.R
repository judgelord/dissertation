source("code/setup.R")

load("data/comments_coded.Rdata")


library(googlesheets4)
library(googledrive)


gs4_auth(email = "devin.jl@gmail.com")
drive_auth(email = "devin.jl@gmail.com")


kewords <- drive_get(id = "13NvUjpD3VeN5qdNGbGbIV83L4aWuBvJt4sSqzfp79U4") %>% read_sheet(col_types = "c")


k <- str_c(kewords$word, collapse = "|")



d <- comments_coded %>% 
  filter(str_dct(org_name, k)) 

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
  arrange(org_name)

unique(d$org_name)

ss <- drive_get(id = "1hF3X8ENtGrhQVQWEP42ypVMmhtYufWNxLFu7xScpsJc")

sheet_write(d1, ss = ss, sheet = "coded")
