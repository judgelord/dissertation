# coef map to rename vars 
cm = c("campaign_TRUE" = "Pressure Campaign",
       "campaign_TRUE:presidentObama" ="Pressure Campaign x Obama",
       "campaign_TRUE:presidentTrump" = "Pressure Campaign x Trump",
       "campaign_TRUE:presidentBush" = "Pressure Campaign x Bush",
       "campaign_TRUE:coalition_typePublic:presidentObama" = "Pressure Campaign x presidentObama",
       "campaign_TRUE:coalition_business_TRUE" = "Pressure Campaign x Business",
       "campaign_TRUE:coalition_typePublic" = "Pressure Campaign x Public",
       "campaign_TRUE:coalition_typePublic:presidentTrump" = "Pressure Campaign x Public x Trump",
       "log(comments + 1):coalition_typePublic" = "Log(Mass Comments) x Public",
       "log(comments + 1):coalition_business_TRUE" = "Log(Mass Comments) x Business",
       "coalition_TRUE" = "Coalition",
       "log(coalition_size)" = "Log(Coalition Size)",
       "coalition_size" = "Coalition Size",
       "coalition_typePublic" = "Public",
       "coalition_business_TRUE" = "Business Coalition",
       "Coalition_PositionSupports Rule" = "Supports Rule",
       "coalition_unopposedTRUE" = "Unopposed",
       "PositionSupports Rule" = "Supports Rule",
       "comments100k" = "Mass Comments",
       "comments100k:presidentTrump" = "Mass Comments x Trump",
       "comments100k:coalition_typePublic" = "Mass Comments x Public",
       "comments100k:coalition_typePublic:presidentTrump" = "Mass Comments x Public x Trump",
       "comments100k:coalition_business_TRUE" = "Mass Comments x Business",
       "log(comments + 1)"= "Log(Mass Comments)",
       "log(comments + 1):presidentTrump"= "Log(Mass Comments) x Trump",
       "log(comments + 1):presidentBush"= "Log(Mass Comments) x Bush",
       "I(comments100k^2)" = "(Mass Comments)^2",
       "coalition_business:I(comments100k^2)" = "Business x (Mass Comments)^2",
       "agency" = "Agency",
       "org_name"=  "Organization",
       "docket_id" = "Rule Docket",
       "president" = "President",
       "presidentTrump" = "Trump",
       "presidentObama" = "Obama",
       "presidentBush" = "Bush",
       "coalition_typePublic:presidentObama" = "Public x Obama",
       "coalition_typePublic:presidentTrump" = "Public x Trump",
       "coalition_business_TRUE:presidentTrump" = "Business x Trump",
       "coalition_business_TRUE:presidentBush" = "Business x Bush",
       "coalition_typePublic:presidentBush" = "Public x Bush",
       "partyRepublican" = "Republican President",
       "coalition_typePublic:partyRepublican" = "Republican President x Public",
       "log(comments + 1):coalition_business_TRUE:presidentTrump"= "Log(Mass Comments) x Business x Trump",
       "log(comments + 1):coalition_business_TRUE:presidentBush"= "Log(Mass Comments) x Business x Bush",
       "log(comments + 1):coalition_typePublic:presidentTrump"= "Log(Mass Comments) x Public x Trump",
       "log(comments + 1):coalition_typePublic:presidentBush"= "Log(Mass Comments) x Public x Bush",
       "acme_0" = "Average Conditional Marginal Effect",
       "ade_0" = "Average Direct Effect",
       "coalition_congress" = "Members of Congress",
       "presidentTrump:coalition_typePublic" = "Trump x Public",
       "presidentBush:coalition_typePublic"= "Bush x Public",
       "campaign_TRUE:presidentBush:coalition_typePublic" = "Campaign x Public x Bush",
       "campaign_TRUE:coalition_business_TRUE:presidentBush" = "Campaign x Business x Bush",
       "campaign_TRUE:presidentTrump:coalition_typePublic" = "Campaign x Public x Trump")

# coef map as tibble
cm2<- tibble(term = names(cm),
             Term = cm)
#FIXME rename
rowsFE <- tibble(
  term = c("Dependent Variable"),
  `1` = c("Lobbying Success"), 
  `2` =c("Lobbying Success"), 
  `3`  = c("Lobbying Success"), 
  `4` = c("Lobbying Success"),
  `5`  = c("Lobbying Success"), 
  `6`  = c("Lobbying Success")
)

attr(rowsFE, 'position') <- c(0)

# new name 
success_rows6 <- tibble(
  term = c("Dependent Variable"),
  `1` = c("Lobbying Success"), 
  `2` =c("Lobbying Success"), 
  `3`  = c("Lobbying Success"), 
  `4` = c("Lobbying Success"),
  `5`  = c("Lobbying Success"), 
  `6`  = c("Lobbying Success")
)

attr(success_rows6, 'position') <- c(0)

# new name 
success_rows3 <- tibble(
  term = c("Dependent Variable"),
  `1` = c("Lobbying Success"), 
  `2` =c("Lobbying Success"), 
  `3`  = c("Lobbying Success")
)

attr(success_rows3, 'position') <- c(0)

