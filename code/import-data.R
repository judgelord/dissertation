source(here::here("code/setup.R"))
library(googledrive)
library(googlesheets4)

gs4_auth(email = "devin.jl@gmail.com")
drive_auth(email = "devin.jl@gmail.com")

# get all org comments 
s <- drive_find(pattern = "org_comment", type = "spreadsheet")

s$name 



# read all as char
read_sheet_c <- . %>% read_sheet(col_types = "c")

# init
d1 <- read_sheet_c(s[1,])

# map
d <- map_dfr(s$id, possibly(read_sheet_c, otherwise = head(d1)))

unique(d$docket_id)

sum(is.na(d$coalition_type))

d %>% filter(is.na(docket_id))

d %>% filter(!docket_id %in% str_remove(s$name,"_.*")) %>% distinct(docket_id)
str_remove(s$name,"_.*")

d %>% filter(str_dct(coalition_comment, "greyhound")) %>% pull(success)

# some dups with varitions in docket title 
d %<>% select(-docket_title) %>% distinct()

# class
d %<>%
  na_if("NA") %>% 
  na_if("na") %>% 
  # fix ids
  mutate(document_id = document_id %>% str_remove("-1.pdf")) %>% 
  mutate(success = success %>% str_squish() %>%  as.numeric()) %>% 
  mutate(docket_id2 = document_id %>% str_remove("-[0-9]+$")) %>% 
  mutate(docket_id = coalesce(docket_id, docket_id2),
         docket_url = str_c("https://www.regulations.gov/docket/", docket_id))# %>%  mutate(across(starts_with("success")), as.numeric )



# Inspect 
# some docket_url's are missing 
d %>% distinct(docket_id, docket_url)  %>% kablebox()

# comments where there is no docket id
d %>% filter(is.na(docket_id))

d$success %<>% as.numeric()
d$position %<>% as.numeric() 
d$number_of_comments_received %<>% as.numeric()
  


# fix comment type and  org type 
clean_org_type <- . %>% 
  str_replace_all(":", ";") %>% 
  str_to_lower() %>% 
  str_squish() 

# groups in more than one coalition 
d %<>% 
  mutate(coalition_comment = str_split(coalition_comment, ";") ) %>%
  unnest(coalition_comment) 

sum(is.na(d$coalition_type))

# Misssing position coding
d %>% filter(is.na(position), !is.na(coalition_comment))

# docket - level summary vars
d %<>%
  na_if("NA") %>% 
  na_if("na") %>% 
  drop_na(position) %>% 
  group_by(docket_id) %>%
  # drop extra info added after coalition, org type etc
  mutate(coalition_comment = coalition_comment %>% clean_org_type() %>% str_replace("false", "FALSE"),
         org_type = org_type %>% clean_org_type(),
         org_name = org_name %>% clean_org_type(),
         coalition_type = coalition_type %>% clean_org_type() %>% str_remove(";.*")) %>% 
  # docket level summary 
  mutate(coalitions = unique(coalition_comment) %>% length(),
         coalition_unopposed = abs(max(position, na.rm = T)-min(position,na.rm = T)) < 2,
         comments = number_of_comments_received %>% replace_na(1), #FIXME
         congress = str_dct(org_type, "congress|house|senate")) %>% 
  group_by(docket_id, coalition_comment) #TODO all coalition vars here 
  
sum(is.na(d$coalition_type))

#FIXME just to make sure we are not dropping obs due to this reasonable assumption
d$congress %<>% replace_na(FALSE)

# diognostics 
comment_errors <- d %>% filter(is.na(position), !is.na(org_type)) 

comments_coded <- d %>% drop_na(position)

d %>% ungroup() %>%
  filter(!is.na(coalition_type),coalition_comment != "FALSE") %>% 
  drop_na(docket_id) %>% 
  group_by(docket_id) %>% 
  distinct(coalition_comment, coalition_type) %>% 
  add_count(coalition_comment) %>% 
  arrange(coalition_comment) %>% 
  filter(n > 1) %>% kablebox()

# coalitions with no main orgs
d %>%
  mutate(success = mean(success, na.rm = T))  %>% 
  distinct(coalition_comment, success) %>% 
  select(docket_id, everything()) %>% 
  filter(is.na(success), coalition_comment != "FALSE", !is.na(coalition_comment)) %>% 
  kablebox()

# coalitions with positive and negative success
d %>%
  mutate(success_mean = mean(success, na.rm = T) )  %>% 
  distinct(coalition_comment, success, success_mean) %>% 
  select(docket_id, everything()) %>% 
  filter(!is.na(success), !success_mean >= 1, !success_mean <= -1 , coalition_comment != "FALSE", !is.na(coalition_comment)) %>%
  arrange(coalition_comment) %>% 
  kablebox()

# coalition leaders with positive and negative success
d %>%
  filter(org_name == coalition_comment) %>% 
  mutate(success_mean = mean(success, na.rm = T) )  %>% 
  distinct(org_name, coalition_comment, success, success_mean) %>% 
  select(docket_id, everything()) %>% 
  filter(!is.na(success), !success_mean >= 1, !success_mean <= -1 , coalition_comment != "FALSE", !is.na(coalition_comment)) %>%
  arrange(coalition_comment) %>% 
  kablebox()

# Coalitions without leader 
d %>%
  mutate(leader = org_name == coalition_comment) %>% 
  distinct(leader) %>%
  add_count() %>% 
  filter(n<2, coalition_comment != FALSE) %>% 
  kablebox()


d %>% filter(str_dct(coalition_comment, "greyhound")) %>% distinct(success)

d %>% filter(str_dct(coalition_comment, "greyhound")) %>% select(success) %>% mutate(success = mean(success, na.rm = T))

# missing or extra coalition type 
d %>% 
  filter(coalition_comment != "FALSE", is.na(coalition_type)) %>%
  select(document_id, coalition_comment, coalition_type) %>%
  kablebox()

# where coalition = FALSE, but coalition_type is not blank
d %>% 
  filter(coalition_comment == "FALSE", !is.na(coalition_type)) %>%
  select(document_id, org_name, coalition_comment, coalition_type) %>% 
  kablebox()


# miscoded elected as gov
d %>% 
  filter(comment_type == "elected", org_type == "gov") %>%  
  count(docket_id, comment_type, org_type) %>%
  kablebox()

d$comments %>% range(na.rm = T)
d$position %>% unique()
d$positions %>% unique()
d$coalition_unopposed %>% unique()
d$congress %>% unique()



# this could just be d till the end
comments_coded <- d %>% mutate(comment_type = comment_type %>% clean_org_type() %>% 
                             str_replace("gov", "org") %>% 
                               str_replace("astroturf", "mass") %>% 
                               str_replace("^indi.*al$", "individual") %>%
                             str_remove(";.*|-.*| o.*"),
                           org_type = org_type %>% clean_org_type() %>% 
                             str_replace("business", "corp") %>% 
                             str_replace("nonprofit", "ngo") %>% 
                             str_replace("ngo;ngo", "ngo") %>% 
                             str_replace("corps", "corp") %>%
                             str_replace("corp:corp", "corp") %>%
                             str_replace("^union", "ngo") %>%
                             str_replace("^tribe", "gov")) %>% 
  ungroup()


comments_coded %>% count(comment_type, sort =T) %>% 
  kablebox()

comments_coded %>% filter(is.na(comment_type)) %>% 
  count(docket_id)

comments_coded %>% count(docket_id, comment_type, sort =T) %>% 
  drop_na(comment_type) %>% 
  filter(!comment_type %in% c("ngo", "astroturf", "corp", "corp group", "gov", "elected", "mass", "individual", "house", "senate", "org", "congress")) %>%  
  kablebox()

# org type 

comments_coded %>% count(org_type, sort =T) %>% 
  kablebox()

comments_coded %>% count(docket_id, org_type, comment_type, sort =T) %>% 
  drop_na(org_type) %>% 
  filter(comment_type != "elected",
         !str_detect(org_type, str_c("ngo", "astroturf", "corp", "corp group", "gov", 
                                     "elected", "mass", "individual", 
                                     "house", "senate", "state", "city", "assembly", "org", "congress", sep = "|"))) %>%  
  kablebox()

# missing success
# I know some of these are in progress, but FYI these sheets are missing “success” for some org comments
comments_coded %>% 
  filter(comment_type == "org") %>% 
  group_by(docket_id, coalition_comment) %>% 
  summarise(percent_success_coded = sum(!is.na(success))/n()) %>% 
  ungroup() %>%
  arrange(percent_success_coded) %>% kablebox()

# FIXME NEED TO MERGE IN OTHER DATA
comments_coded %>% 
  filter(is.na(number_of_comments_received)) %>% 
  count(docket_id) %>% kablebox()

sum(is.na(comments_coded$coalition_type))

# assume private if it is lobbying alone as a business 
comments_coded %<>% mutate(business = org_type %in% c("corp", "corp group"),
                           coalition_type = ifelse(is.na(coalition_type) & coalition_comment == "FALSE" & business, "private", coalition_type) )

sum(is.na(comments_coded$coalition_type))


# replace missing/non coalitions with org name 
comments_coded %<>% mutate(coalition_comment = ifelse(coalition_comment=="FALSE", org_name, coalition_comment))


#FIXME MOVE UP ABOVE DIOGNOSTICS 
comments_coded %<>% 
  ungroup() %>% 
  group_by(docket_id, coalition_comment) %>% 
  mutate(coalition_congress = sum(congress),
            coalition_size = n(),
            coalition_position = mean(position, na.rm =T),
            #FIXME coalition_private and coalition_buisness are two ways of running this
            coalition_business = sum(business),
            #coalition_type =  median(coalition_type, na.rm = T) %>% as.character(),
            coalition_success = mean(success %>% as.numeric(), na.rm = T), # average success of coalition
            org_lead = org_name == coalition_comment,
            coalition_leader_success = ifelse(org_lead, success, NA) %>% mean(na.rm = T) %>% coalesce(coalition_success),
            coalition_comments = sum(comments, na.rm = T)) %>%
  ungroup() %>% 
  mutate(coalition_id = as.factor(coalition_comment) %>% as.numeric()) %>%
  distinct()


sum(is.na(comments_coded$coalition_type))



coalitions_coded <- comments_coded %>% 
  drop_na(coalition_comment) %>% 
  select(starts_with("docket"), starts_with("coalition")) %>%
  distinct()

# # post-hoc corrections 
# coalitions_coded %<>% 
#   add_count(docket_id, coalition_comment) %>% 
#   filter(!(is.na(coalition_business) & n >1)) %>% 
#   select(-n) %>% 
#   add_count(docket_id, coalition_comment) 



coalitions_coded %>% kablebox()


# Drop coalition = FALSE 
# coalitions_coded %<>% filter(coalition_comment != "FALSE")

#FIXME MOVE UP
coalitions_coded %<>% mutate(Coalition_size = case_when(
  coalition_size==1 ~ "1",
  coalition_size > 1 & coalition_size < 11 ~ "2-10",
  coalition_size > 10 & coalition_size < 101~ "11-100",
  coalition_size > 100 ~ "More than 100"
))

coalitions_coded %<>% mutate(Comments = case_when(
  coalition_comments==1 ~ "1",
  coalition_comments > 1 & coalition_comments < 11 ~ "2-10",
  coalition_comments > 10 & coalition_comments < 101~ "11-100",
  coalition_comments > 100 ~ "More than 100"
))

d %>% filter(success > 2) %>% select(document_id, success)

ggplot(coalitions_coded, aes(x = coalition_success)) + geom_histogram()+ labs(x = "Coalition Success")

ggplot(coalitions_coded, aes(x = coalition_business %>% as.numeric())) + geom_histogram()+ labs(x = "Business Coalition")

ggplot(coalitions_coded %>% filter(!is.na(coalition_type)), aes(x = coalition_type)) + 
  geom_histogram(stat = "count")+ 
  labs(x = "Coalition Type") +
  facet_wrap("Coalition_size")

ggplot(coalitions_coded %>% filter(!is.na(coalition_type)), aes(x = coalition_type)) + 
  geom_histogram(stat = "count")+ 
  labs(x = "Coalition Type") +
  facet_wrap("Comments")

ggplot(coalitions_coded, aes(x = coalition_size)) + geom_histogram()+ labs(x = "Coalition size")

#ggplot(coalitions_coded, aes( x= comment_length)) + geom_histogram()+ labs(x = "% (Comment length/proposed rule length)*100")

ggplot(coalitions_coded, aes( x= log(coalition_comments))) + geom_histogram() + labs(x = "Log(comments)")

# these should be close to the same, with d a bit bigger perhaps 
d$number_of_comments_received %>% sum(na.rm = T) 
coalitions_coded$coalition_comments %>% sum() 


comments_coded %<>% distinct()
coalitions_coded %<>% distinct()

look <- coalitions_coded %>% add_count(docket_id, coalition_comment, sort = T) %>% 
  filter(n>1) %>% arrange(coalition_comment) %>% distinct()


save(comments_coded, file = here::here("data", "comments_coded.Rdata"))
save(coalitions_coded, file = here::here("data", "coalitions_coded.Rdata"))







