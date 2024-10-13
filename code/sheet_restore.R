load("~/dissertation/data/comments_coded2021.Rdata")
cc2021 <- comments_coded %>% mutate(date_pulled = 2021)

load("~/dissertation/data/comments_codedJuly30.Rdata")
ccjuly30 <- comments_coded %>% mutate(date_pulled = 2020)

load("~/dissertation/data/comments_coded2022.Rdata")
cc2022 <- comments_coded %>% mutate(date_pulled = 2022)

comments_code_old <- full_join(cc2021, cc2022)

comments_code_old %<>% distinct()
comments_code_old %<>% arrange(document_id)
comments_code_old %<>% mutate(comment_url = str_to_lower(comment_url)) %>% distinct()
comments_code_old %<>% mutate(docket_url = str_to_lower(docket_url)) %>% distinct()
comments_code_old %<>% mutate(org_type = str_to_lower(org_type)) %>% distinct()
comments_code_old %<>% mutate(comment_type = str_to_lower(comment_type)) %>% distinct()
comments_code_old %<>% mutate(source = str_to_lower(source)) %>% distinct()
comments_code_old %<>% mutate(transparent = str_to_lower(transparent)) %>% distinct()
comments_code_old %<>% mutate(coalition_comment = str_to_lower(coalition_comment)) %>% distinct()
comments_code_old %<>% mutate_all(str_squish)
comments_code_old %<>% mutate(coalition_comment = str_to_lower(coalition_comment)) %>% distinct()

d <- comments_code_old %>% select(-coalition_leader_success,-coalition_success, -org_type, -transparent) %>% 
  mutate_all(str_to_lower) %>% 
  select(-coalition_id) %>% 
  mutate_all(str_to_lower) %>% 
  distinct() %>% 
  add_count(document_id) %>% 
  filter(n > 1)