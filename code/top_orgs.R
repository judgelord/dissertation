source(here::here("code", "setup.r"))

# a function to clean org names
clean_orgs <- . %>%
str_rm_all("\\(.*| Action Fund|^The |of the United States| - .*|:.*|Mass Comment Campaign of the |/.*| USA$|\\.com") %>%
  str_squish() %>%
  str_to_title() %>%
  str_replace(".*Sierra.*", "Sierra Club")%>% 
  str_replace(".*Nrdc.*|Natural Resources Defense Council.*", "NRDC")%>% 
  str_replace(".*Center For Biological Diversity.*|Cneter For Biological Diversity", "Center For Biological Diversity")%>% 
  str_replace(".*World Wildlife Fund.*|.WWF", "World Wildlife Fund")%>%
  str_replace(".*Greenpeace.*", "Greenpeace")%>%
  str_replace(".*Pew .*","Pew") %>% 
  str_replace(".*Audubon.*", "Audubon") %>% 
  str_replace(".*Credo.*", "Credo")%>%
  str_replace(".*Defenders Of Wildlife.*", "Defenders Of Wildlife")%>%
  str_replace(".*Friends Of The Earth.*", "Friends Of The Earth")%>%
  str_replace(".*Earthjustice.*|.*Earth Justice.*", "Earthjustice")%>%
  str_replace(".*Defenders Of Wildlife.*", "Defenders Of Wildlife")%>%
  str_replace(".*American Heart Association.*", "American Heart Association")%>%
  str_replace(".*Audubon.*", "Audubon")%>%
  str_replace(".*Wildlife Conservation Society.*", "Wildlife Conservation Society")%>%
  str_replace(".*Oceana.*", "OCEANA")%>%
  str_replace(".*Planned Parenthood.*", "Planned Parenthood")%>%
  
  str_replace(".*Moveon.*|.*Move On.*", "credo")%>%
  str_replace("Nat'l", "National")%>% 
  str_replace(".*Ifaw.*", "INTERNATIONAL FUND FOR ANIMAL WELFARE")%>% 
  str_replace(".*Humane Society.*|HSUS.*|.*\\bHSI\\b.*", "Humane Society")%>%
  str_replace("Moms Rising|Momsrising|Mom's Rising|Momsrisiing", "Moms Rising")%>%
  str_replace("Care 2|Care2", "Care2")%>%
  str_replace("Preventobesity.*", "American Heart Association")%>%
  str_replace("Axess.*|.*Axcess\\b.*", "AXCESS FINANCIAL")%>%
  str_replace(".*American Petroleum Institute.*|.*\\bApi\\b.*|Joe Jansen", "American Petroleum Institute") %>%
  str_replace(".*Consumer Energy Alliance.*", "Consumer Energy Alliance") %>%
  str_replace("Saveourenvironment.org|Save Our Environment$", "Partnership Project") %>% 
  str_replace("^None$|^Na$|^Self$|^Private Citizen$|^Citizen$|^Individual$|^Private Individual$|^Personal$|^Retired$|^Myself$|^US Citizen|^U.S. Citizen$|^Not Applicable|^Me$|^Student$|^Mr.$|^Ms.$|^Mrs.$|^No Organization", "Individual") %>% 
  str_squish() %>%
  str_to_title()


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
