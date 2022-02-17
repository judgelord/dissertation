load(here::here("data", "ejPRnew.Rdata"))
ejPR <- ejPRnew #FIXME 

load(here::here("data", "ejFRnew.Rdata"))
ejFR <- ejFRnew

load(here::here("data", "ejcommentsnew.Rdata"))
ejcomments <- ejcommentsnew

load(here::here("data", "ej_race.Rdata"))

load(here::here("data", "rules_metadata.Rdata"))

# alternatively 
#rules <- dbGetQuery(con, "SELECT * FROM rules")

# unique
ejPR %<>% 
  dplyr::select(-page, #FIXME,
                -open_for_comment,
                -type, -document_type, -withdrawn, -links) %>% 
  distinct()

ejFR %<>% 
  dplyr::select(-page, #FIXME
                -open_for_comment,
                -type, -document_type, -withdrawn, -links) %>% 
  distinct()

ejcomments %<>% 
  dplyr::select(-lastpage, -type, -document_type, -withdrawn, -links) %>% 
  distinct() 


# a function to clean raw selected text
clean_summary <- . %>% 
  mutate(summary = str_remove_all(highlighted_content,
                                  "./em../mark.|.mark..em.") %>% 
           str_replace_all("\\&hellip;\\&nbsp;"," ") %>% 
           str_replace_all("[^[A-z][0-9] \\.\\,\\?\\!\\;&\\;<>]", " ") %>% 
           str_remove_all("\\(|\\)|\\[|\\]") %>%
           str_squish() )

# ## Testing regex
# str_remove_all(ejPRnew$highlighted_content[1],
#                "./em../mark.|.mark..em.") %>% 
#            str_replace_all("\\&hellip;\\&nbsp;"," ") %>% 
#            str_replace_all("[^[A-z][0-9] \\.\\,\\?\\!\\;&\\;<>]", " ") %>% 
#            str_remove_all("\\(|\\)|\\[|\\]") %>%
#   str_squish() 

# summary vars
ejcomments %<>%
  mutate(docket_id = str_remove(id, "-[0-9]*$") ) %>% 
  clean_summary()

ejPR %<>% clean_summary()

ejFR %<>% clean_summary()

rules %<>% filter(document_type %in% c("Proposed Rule", "Rule"),
                  # drop rules before clinton
                  !is.na(posted_date),
                  posted_date > as.Date("1993-01-20"),
                  # rulemaking dockets only
                  docket_type == "Rulemaking" ) %>%
  # one document per docket (drop additional PRs )
  group_by(document_type, docket_id) %>%
  slice_max(number_of_comments_received)


# make summary vars for main data
rules %<>% 
  # # add ej comments and ej unique comment counts #FIXME merge in counts from old data, find if new API has this
  # left_join(ejcomments %>% 
  #             group_by(docket_id) %>% 
  #             summarise(ej_comments = sum(number_of_comments_received) ) ) %>%
  left_join(ejcomments %>% 
              count(docket_id, name = "ej_comments_unique") ) %>% 
  mutate(#ej_comments = replace_na(ej_comments, 0),
    ej_comments_unique = replace_na(ej_comments_unique, 0) ) %>% 
  # recode 1 as 0 to reduce colinearity with ej_comment, logical
  #FIXME make this a new var 
  mutate(ej_comments_unique = ifelse(ej_comments_unique == 1, 0, ej_comments_unique))

# indicators for ej in various docket-level variables
rules %<>% 
  group_by(docket_id) %>% 
  mutate(comments = sum(number_of_comments_received)) %>% 
  ungroup() %>% 
  mutate(ej_pr = docket_id %in% ejPR$docket_id,
         ej_comment = docket_id %in% ejcomments$docket_id,
         ej_fr = docket_id %in% ejFR$docket_id,
         # indicator for president
         president = ifelse(posted_date < as.Date("2017-01-17"), "Obama", "Trump"),
         president = ifelse(posted_date < as.Date("2009-01-20"), "G. W. Bush", president),
         president = ifelse(posted_date < as.Date("2001-01-20"), "Clinton", president),
         year = str_sub(posted_date, 1,4),
         Year = str_sub(posted_date, 3,4),
         Year = str_c("`", Year),
         agency = agency_id
  ) 

rules %<>% dplyr::select(docket_id, 
                         docket_title, 
                         # ej_comments = ej_comments_unique, 
                         ej_comments_unique, 
                         ej_pr, 
                         ej_comment, 
                         ej_fr, 
                         president, year, 
                         comments, 
                         agency, 
                         document_type,
                         year,
                         Year) %>%
  distinct()





############



# filter to agencies that published at least one ej rule 
rules %<>% 
  group_by(agency) %>% 
  mutate(agency_ej_rules = sum(ej_fr),
         agency_ej_comments = sum(ej_comments_unique),
         agency_ej_nprms = sum(ej_pr)) %>% 
  filter(agency_ej_rules > 0)# | agency_ej_nprms > 0) #TODO sensitivity analysis using EJ share floor


share <- rules %>% 
  distinct(agency, ej_fr, docket_id) %>% 
  group_by(agency) %>% 
  # share 
  mutate(agency_dockets = unique(docket_id) %>% length(),
         agency_ej_dockets = sum(ej_fr),
         agency_ej_share = agency_ej_dockets/agency_dockets) %>% 
  ungroup() %>% 
  group_by(agency) %>% 
  arrange(-agency_ej_share) %>%
  distinct(agency, agency_ej_share)
  #filter(agency == "EPA")

share 

rules %<>% left_join(share)



ejcomments$number_of_comments_received %<>% replace_na(0) 



save(ejcomments, ejPR, ejFR, rules, file = "data/ej_data_clean.Rdata")
