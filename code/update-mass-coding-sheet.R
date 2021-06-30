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

mass <- mass_raw %>%  mutate(comments = comments %>% str_squish() %>% as.numeric(),
                             success = success %>% str_squish()%>% as.numeric(),
                             position = position %>% str_squish() %>%as.numeric())

# split back out to one obs per comment
mass %<>% mutate(comment_url = str_split(comment_url, "\n") ) %>% unnest(comment_url)

mass %<>% unnest(comment_url)

# should be less than 100 or the split did not work
max(nchar(mass$comment_url), na.rm = T)

# get id from url 
mass %<>% mutate(id = str_remove_all(comment_url, ".*=|.*/") %>% str_squish()) %>% 
  dplyr::select(-comment_url)

head(mass$id)
# should be ~ 26
max(nchar(mass$id), na.rm = T)

mass %>% arrange(-nchar(id)) %>% pull(id)

# select mass comments and lead orgs from hand-coded data 
mass_coded <- comments_coded  %>% 
  filter(str_detect(str_to_lower(comment_type), "mass")|org_lead|coalition_comment %in% c(org_name, org_name_short)|comments>10) %>%
  mutate(id = str_remove_all(comment_url, ".*=|.*/") %>% str_squish(),
         success = success %>% str_squish() %>% as.numeric(),
         position = position %>% str_squish() %>% as.numeric(),
         number_of_comments_received = number_of_comments_received %>% str_squish() %>% as.numeric()) %>%
  dplyr::select(-comments, -comment_url)


head(mass_coded$id)
nchar("BSEE-2018-0002-44131")
max(nchar(mass_coded$id))

mass %<>% dplyr::select(-number_of_comments_received)


# join hand-coded  mass and org_comments
mass %<>% left_join(mass_coded) 

# drop vars we are going to fill in from master 
mass %<>% dplyr::select(-organization, -submitter_name)

mass %<>% dplyr::select(-president, -date)

mass %<>% dplyr::select(-number_of_comments_received)

# add dates
mass %<>% left_join(comments_min )
sum(is.na(mass$date))

look <- mass %>% filter(is.na(date))
mass %>% filter(is.na(id))


mass %<>% mutate(comment_url = str_c("https://www.regulations.gov/comment/", id))

mass %<>% mutate(president = ifelse(date > as.Date("2009-01-20"), "Obama", "Bush"),
                 president = ifelse(date > as.Date("2017-01-20"), "Trump", president))

mass %>% count(president)

mass %<>% ungroup() 

mass %<>% mutate(rownumber = row_number() %>% str_c(" rando"),
                 org_name = coalesce(org_name, organization, comment_title, rownumber))

sum(is.na(mass$org_name))

mass$number_of_comments_received %<>% as.numeric()
sum(is.na(mass$number_of_comments_received))

# to make collapsing go faster
mass2 <- mass %>% dplyr::select(president, date, docket_id, id, number_of_comments_received, organization, comment_title, comment_url, comment_type, org_name, org_name_short, org_type, transparent, coalition_comment,coalition_type, position, position_certainty, ask, success, notes)#, everything())

# a collapsing function 
str_collapse <- . %>% unique() %>% str_squish() %>% str_c(collapse = "\n ")

mass2 %<>% 
  group_by(docket_id, org_name, president) %>% 
  mutate(success = mean(success,na.rm = T), #FIXME no sure why this did not work
         comments = sum(number_of_comments_received, na.rm = T)) %>% # this works
  summarise_all(str_collapse) %>% 
  ungroup() %>% 
  distinct()

# this should not cause NAs
sum(is.na(mass2$comments))
mass2$comments %<>% as.numeric()
sum(is.na(mass2$comments))
sum(is.na(mass2$number_of_comments_received))

mass2 %>% dplyr::select(comments, number_of_comments_received)

# add tally by docket (only use for sorting, it may overcount to the extent that hand coding does not match )
mass2 %<>% 
  ungroup() %>% 
  group_by(docket_id) %>% 
  mutate(mass_comments_on_docket = sum(as.numeric(comments)))



# add in rulemaking / nonrulemaking "docket_type"
mass2 %<>% dplyr::select(-docket_type)

mass2 %<>% left_join(rules %>% distinct(docket_id, docket_type))

# arrange by number of comments + rulemaking at top
mass2 %<>% arrange(desc(docket_type), -mass_comments_on_docket, president, -comments)

head(mass2)

mass2 %>% dplyr::select(mass_comments_on_docket, docket_id)

mass2 %>% distinct(mass_comments_on_docket, docket_id) %>% arrange(-mass_comments_on_docket)
head(mass2)

mass2 %>% distinct(org_name, comments)

mass2 %>% filter(comment_url == "https://www.regulations.gov/comment/EPA-HQ-OAR-2013-0602-18908")

mass3 <- mass2 %>% dplyr::select(president, date, docket_id, docket_type, mass_comments_on_docket,
                                  comments, number_of_comments_received, comment_type, comment_url, organization, #comment_title,
                                  org_name, org_name_short, org_type, transparent,
                                  coalition_comment, coalition_type, 
                                  position, position_certainty, ask, success)#, everything())

mass3 %<>% distinct() 
head(mass3)

sheet_write(mass3, ss, sheet = Sys.Date() %>% as.character())



