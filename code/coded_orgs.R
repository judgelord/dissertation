str_collapse <- . %>% unique() %>% str_squish() %>% str_c(collapse = "; ")


orgs <- d %>% ungroup %>% 
  mutate(
    #corrections 
    org_type = ifelse(str_dct(org_name, 'credit union'), "ngo;credit union", org_type),
    org_type = ifelse(str_dct(org_name, 'Axcess Finanicial'), "corp", org_type),
    # clean ids
         comment_id = str_remove(comment_url, ".*=|.*/"),
         agency = str_remove(docket_id, "-.*"),
         org_type = org_type %>% str_to_lower() %>% str_remove("(;|:).*") %>% str_squish() ) %>% 
  # FIXME LIMITS TO FINREG 
  filter(str_detect(docket_id, "CFPB|TREAS|IRS"),
         str_dct(org_type, "corp|ngo"),
         !str_dct(org_name, "Axcess Financiall"),
         org_name != "Payday Lending") %>%
  distinct(agency, org_name, org_name_short, org_type, comment_id) %>% 
  group_by(org_name) %>% 
  summarise_all(str_collapse)%>%
  ungroup() %>%
  arrange(org_name) 

orgs %>% kablebox()

ss <- drive_find(pattern = "finreg orgs", type = "spreadsheet")

sheet_write(orgs, ss, sheet = "hand-coded")

