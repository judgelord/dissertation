# all comment data from ______
load(here("data", "comments_min.Rdata"))
names(comments_min)
comments_min %<>% 
  distinct()
head(comments_min$id)
comments_min$date %>% min(na.rm = T)


##############################################
# comments coded from import-data.R
load(here::here("data", "comments_coded.Rdata"))


# MASS DOCKETS GOOGLE SHEET TO UPDATE 
ss <- "1uM69A3MjX4-kHJSP6b5EZ33VKoNjefue3BqXDgLu0cY"

mass_raw <- read_sheet_c(ss)

mass <- mass_raw %>%  mutate(comments = comments %>% as.numeric(),
                             success = success %>% as.numeric(),
                             position = as.numeric(position))

# split back out to one obs per comment
mass %<>% mutate(comment_url = str_split(comment_url, "\n") ) %>% unnest(comment_url)

mass %<>% unnest(comment_url)

# should be less than 100 or the split did not work
max(nchar(mass$comment_url), na.rm = T)

# get id from url 
mass %<>% mutate(id = str_remove(comment_url, ".*/") %>% str_squish()) %>% 
  dplyr::select(-comment_url)

head(mass$id)




# select mass comments and lead orgs from hand-coded data 
mass_coded <- comments_coded  %>% 
  filter(str_detect(str_to_lower(comment_type), "mass")|org_name == coalition_comment|comments>10) %>%
  mutate(id = str_remove(comment_url, ".*/|.*=") %>% str_squish(),
         success = success %>% str_squish() %>% as.numeric(),
         position = position %>% str_squish() %>% as.numeric(),
         number_of_comments_received = number_of_comments_received %>% str_squish() %>% as.numeric()) %>%
  dplyr::select(-comments, -comment_url)


head(mass_coded$id)

# join hand-coded  mass and org_comments
mass %<>% left_join(mass_coded) 

# drop vars we are going to fill in from master 
mass %<>% dplyr::select(-organization, -submitter_name)

mass %<>% dplyr::select(-number_of_comments_received)

# add dates
mass %<>% left_join(comments_min)
sum(is.na(mass$date))

look <- mass %>% filter(is.na(date))
look <- mass %>% filter(is.na(id))


mass %<>% mutate(comment_url = str_c("https://www.regulations.gov/comment/", id))

mass %<>% mutate(president = ifelse(date > as.Date("2009-01-20"), "Obama", "Bush"),
                 president = ifelse(date > as.Date("2017-01-20"), "Trump", president))

mass %>% count(president)


str_collapse <- . %>% unique() %>% str_squish() %>% str_c(collapse = "\n ")

mass %<>% 
  group_by(docket_id, org_name, president) %>% 
  mutate(success = pmean(success,na.rm = T)) %>% 
  summarise_all(str_collapse) %>% 
  ungroup() %>% 
  distinct()



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
