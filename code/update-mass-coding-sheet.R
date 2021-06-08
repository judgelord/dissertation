load(here("data", "comments_min.Rdata"))
names(comments_min)
comments_min %<>% distinct() %>% mutate(comment_url = str_c("https://www.regulations.gov/comment/", id))




# MASS DOCKETS 
ss <- "1uM69A3MjX4-kHJSP6b5EZ33VKoNjefue3BqXDgLu0cY"

mass <- read_sheet_c(ss)

mass %<>% mutate(comments = comments %>% as.numeric(),
                 success = success %>% as.numeric(),
                 position = as.numeric(position))

# split 
mass %<>% mutate(comment_url = str_split(comment_url, "\n") ) %>% unnest(comment_url)

mass %>% unnest(comment_url)

mass %<>% mutate(comment_url = str_squish(comment_url))

max(nchar(mass$comment_url), na.rm = T)

mass_coded <- d_all %>% 
  filter(str_detect(str_to_lower(comment_type), "mass")) %>%
  mutate(comments = comments %>% str_squish() %>% as.numeric(),
         success = success %>% str_squish() %>% as.numeric(),
         position = position %>% str_squish() %>% as.numeric(),
         number_of_comments_received = number_of_comments_received %>% str_squish() %>% as.numeric()) 

mass %<>% full_join(mass_coded) %>% select(-organization, -submitter_name)

# add dates
mass %<>% left_join(comments_min)
sum(is.na(mass$date))
sum(is.na(mass$comment_url))

mass %<>% mutate(president = ifelse(date > as.Date("2009-01-20"), "Obama", "Bush"),
                 president = ifelse(date > as.Date("2017-01-20"), "Trump", president))

str_collapse <- . %>% unique() %>% str_squish() %>% str_c(collapse = "\n ")

masss %<>% 
  group_by(docket_id, org_name, president) %>% 
  mutate(success = pmean(success,na.rm = T)) %>% 
  summarise_all(str_collapse) %>% 
  ungroup() %>% 
  distinct()

mass %<>% full_join(coded)

# add tally by docket (only use for sorting, it may overcount to the extent that hand coding does not match )
mass %<>% 
  group_by(docket_id) %>% 
  mutate(mass_comments_on_docket = sum(as.numeric(comments)))



# add in rulemaking / nonrulemaking 

mass %<>% left_join(rules %>% distinct(docket_id, docket_type))
mass %<>% arrange(docket_type, -mass_comments_on_docket, -comments)

mass %<>% select(docket_id, comments, comment_type, comment_url, org_name, org_name_short, org_type, coalition_comment,coalition_type, position, position_certainty, everything())

# sheet_write(mass, ss, sheet = Sys.Date() %>% as.character())


save(mass_coded, file = here::here("data", "mass_coded.Rdata"))
