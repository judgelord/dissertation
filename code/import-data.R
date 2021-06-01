source(here::here("code/setup.R"))
library("googledrive")
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

# class
d %<>%
  na_if("NA") %>% 
  # fix ids
  mutate(document_id = document_id %>% str_remove("-1.pdf")) %>% 
  mutate(docket_id = document_id %>% str_remove("-[0-9]+$"))# %>%  mutate(across(starts_with("success")), as.numeric )



# Inspect 
d %>% distinct(docket_id, docket_url)  %>% kablebox()
d %>% filter(is.na(docket_id)) %>% distinct(document_id)


d$position %<>% as.numeric()
  
# docket - level summary vars
d %<>%
  na_if("NA") %>% 
  drop_na(position) %>% 
  group_by(docket_id) %>%
  # drop extra info added after coalition
  mutate(coalition_comment = coalition_comment %>% str_remove(";.*")) %>% 
  mutate(org_type = org_type %>% str_remove(";.*")) %>% 
  mutate(coalition_type = coalition_type %>% str_remove(";.*")) %>% 
  mutate(coalitions = unique(coalition_comment) %>% length(),
         positions = unique(position) %>% length(),
         coalition_unopposed = abs(max(position, na.rm = T)-min(position,na.rm = T)) < 2,
         coalition_type = tolower(coalition_type),
         comments = as.numeric(number_of_comments_received) %>% replace_na(1),
         congress = str_dct(org_type, "congress|house|senate"))

d$comments %>% range(na.rm = T)
d$position %>% unique()
d$positions %>% unique()
d$coalition_unopposed %>% unique()
d$congress %>% unique()

#FIXME just to make sure we are not dropping obs due to this reasonable assumption
d$congress %<>% replace_na(FALSE)

comments_coded <- d %>% drop_na(position)

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

d_all <- d


d_coalitions <- comments_coded %>% 
  ungroup() %>% 
  drop_na(coalition_comment) %>% 
  group_by(docket_id, coalition_comment, coalition_unopposed, coalitions) %>% 
  summarise(cong_support = sum(congress),
            coalition_size = n(),
            #FIXME coalition_private and coalition_buisness are two ways of running this
            coalition_business = str_dct(coalition_type, "private") %>% unique(),
            coalition_success = mean(success %>% as.numeric(), na.rm = T), # average success of coalition
            comments = sum(comments)) %>%
  ungroup() %>% 
  mutate(coalition_id = as.factor(coalition_comment) %>% as.numeric())


# post-hoc corrections 
d_coalitions %<>% 
  add_count(docket_id, coalition_comment) %>% 
  filter(!(is.na(coalition_business) & n >1)) %>% 
  select(-n) %>% 
  add_count(docket_id, coalition_comment) 

look <- filter(d_coalitions, n >1) 

look %>%kablebox()

d_coalitions %>% kablebox()

# diognostics 
d_all %>% ungroup() %>%
  drop_na(docket_id) %>% 
  group_by(docket_id) %>% 
  distinct(coalition_comment, coalition_type) %>% 
  add_count(coalition_comment) %>% 
  arrange(coalition_comment) %>% 
  filter(n > 1) %>% kablebox()

# coalitions with no main orgs
d_all %>%
  mutate(success = mean(success,na.rm = T))  %>% 
  distinct(coalition_comment, success) %>% 
  select(docket_id, everything()) %>% 
  filter(is.na(success), coalition_comment != "FALSE", !is.na(coalition_comment)) %>% 
  kablebox()

coalitions_coded <- d_coalitions 


ggplot(coalitions_coded, aes(x = coalition_success)) + geom_histogram()+ labs(x = "Coalition Success")

d %>% filter(success > 2) %>% select(document_id, success)


ggplot(coalitions_coded, aes(x = coalition_business %>% as.numeric())) + geom_histogram()+ labs(x = "Business Coalition")

ggplot(coalitions_coded, aes(x = coalition_size)) + geom_histogram()+ labs(x = "Coalition size")

#ggplot(coalitions_coded, aes( x= comment_length)) + geom_histogram()+ labs(x = "% (Comment length/proposed rule length)*100")

ggplot(coalitions_coded, aes( x= log(comments))) + geom_histogram() + labs(x = "Log(comments)")

coalitions_coded$comments %>% sum() 
coalitions_coded$docket_id %>% unique()


save(comments_coded, file = here::here("data", "comments_coded.Rdata"))
save(coalitions_coded, file = here::here("data", "coalitions_coded.Rdata"))





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

sheet_write(mass, ss, sheet = Sys.Date() %>% as.character())




