

comments_min %<>% mutate(metadata = nchar(organization) >3 & organization %in% orgs$org_name)

# 2% of rows have metadata
comments_min %>% count(metadata) %>% mutate(percent = n/nrow(comments_min))

# 9.5% of comments have metadata
comments_min %>% group_by(metadata) %>% tally(number_of_comments_received) %>% 
  mutate(percent = n/sum(comments_min$number_of_comments_received))

         