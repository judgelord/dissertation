source(here::here("code", "setup.r"))

source(here::here("code", "clean_orgs.R"))
# mass sheet (over 10)
load(here("data", "mass_raw.Rdata"))
mass <- mass_raw %>% 
  filter(docket_type == "Rulemaking") %>%
  mutate(org_name = ifelse(str_dct(org_name, "anonymous|rando|unknown|knowwho") & !is.na(coalition_comment),
                                               coalition_comment,
                                               org_name)) %>% 
                               select(org_name, comments, docket_id)


mass %<>% mutate(org_name = org_name %>% clean_orgs())

mass %<>% mutate(comments = str_squish(comments) %>% str_remove_all(",") %>% as.numeric())

mass %>% filter(is.na(comments))

mass %<>% group_by(docket_id, org_name) %>% tally(comments, name = "comments", sort = T) 

# total from top 100 mass
mass %<>% 
  filter(!str_dct(org_name, "unknown|404error|broken link|anonymous|knowwho")) 

# FIXME THIS IS CLOSE TO WORKING 
# # A function to search for known hand-coded orgs in raw data
# dct_org <- function(x, string){
#   if(str_dct(x, string)){
#     x <- str_c(x, string,  sep = ";")
#   }
#   return(x)
# }
# 
# x = mass$org_name
# y = mass$org_name[999]
# 
# dct_org(x, y)
# 
# dct_orgs <- function(patterns, x){
# map2_chr(.x = x, .y = strings, dct_org)
# }
# 
# dct_orgs(mass$org_name, mass$org_name[999])
# 
# map2_chr(mass$org_name, mass$org_name, dct_orgs)


# org_comments 
load(here("data", "org_comments.Rdata"))

# (under 10)
nonmass <- filter(org_comments, number_of_comments_received < 10) %>% 
  mutate(org_name = org_name %>% str_to_lower() %>% str_squish() )


# clean
nonmass %<>% mutate(org_name = org_name %>% clean_orgs() )


# this takes a minute on 300k
nonmass %<>% group_by(org_name, docket_id) %>% 
  tally(number_of_comments_received, name = "comments", sort = T) 


                    
# COMBINE 
org_counts <- full_join(mass %>% mutate(campaign = T), 
                        nonmass %>% mutate(campaign = F)
)

# sum up by org
org_counts %<>% ungroup() %>%
  group_by(org_name) %>% 
  summarise(rules = docket_id %>% unique() %>% length(),
            comments = sum(comments),
            campaigns = sum(campaign) )

org_counts %>% arrange(-comments) %>% 
  add_tally(comments, name = "total") %>% 
  head(100) %>% 
  add_tally(comments, name = "top100") %>% 
  mutate(share = top100/total, rank = row_number()) %>% 
  # scree
  #ggplot()  + aes(x = rank, y = comments) + geom_point()
  kablebox()

org_counts %>% arrange(-comments) %>% 
  add_tally(comments, name = "total") %>% 
  head(10) %>% 
  add_tally(comments, name = "Top10") %>% 
  mutate(share = Top10/total, rank = row_number()) %>% 
  kablebox()

save(org_counts, file =  here::here("data", "org_counts.Rdata"))



# FORMAT FOR PRESENTATION 
org_counts %<>% mutate(org_name = ifelse(nchar(org_name)<10, str_to_upper(org_name), org_name) )

org_counts_summary <- org_counts %>% 
  ungroup() %>%
  mutate(percent = percent(campaigns/rules, accuracy = .1),
         average = round(comments/campaigns)) %>% 
  filter(!str_dct(org_name, "^NA$|unknown|individuals|n/a|^N$")) %>%
  arrange(-comments)  %>% 
  filter(comments > 100)

# need to do better
nrow(org_counts_summary)
org_counts_summary$comments %>% sum()

# org_comments_summary$org_name

#org_comments_summary$org_name[1:20]

org_counts_summary %>% 
  kablebox() 
#kable3(caption = "Organizations Mobilizing the Most Public Comments 2005-2020")



save(org_counts_summary, file =  here::here("data", "org_counts_summary.Rdata"))

