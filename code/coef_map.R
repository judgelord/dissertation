# coef map to rename vars 
cm = c("campaign_TRUE" = "Pressure Campaign",
       "campaign_TRUE:presidentObama" ="Pressure Campaign × Obama",
       "campaign_TRUE:presidentTrump" = "Pressure Campaign × Trump",
       "campaign_TRUE:presidentBush" = "Pressure Campaign × Bush",
       "campaign_TRUE:coalition_typePublic:presidentObama" = "Pressure Campaign × presidentObama",
       "campaign_TRUE:coalition_business_TRUE" = "Pressure Campaign × Business",
       "campaign_TRUE:coalition_typePublic" = "Pressure Campaign × Public",
       "campaign_TRUE:coalition_typePublic:presidentTrump" = "Pressure Campaign × Public × Trump",
       "log(comments + 1):coalition_typePublic" = "Log(Mass Comments) × Public",
       "log(comments + 1):coalition_business_TRUE" = "Log(Mass Comments) × Business",
       "coalition_TRUE" = "Coalition",
       "log(coalition_size)" = "Log(Coalition Size)",
       "coalition_size" = "Coalition Size",
       "coalition_typePublic" = "Public",
       "coalition_business_TRUE" = "Business Coalition",
       "Coalition_PositionSupports Rule" = "Supports Rule",
       "coalition_unopposedTRUE" = "Unopposed",
       "PositionSupports Rule" = "Supports Rule",
       "comments100k" = "Mass Comments",
       "comments100k:coalition_typePublic" = "Mass Comments*Public",
       "comments100k:coalition_business_TRUE" = "Mass Comments*Business",
       "log(comments + 1)"= "Log(Mass Comments)",
       "log(comments + 1):presidentTrump"= "Log(Mass Comments) × Trump",
       "log(comments + 1):presidentBush"= "Log(Mass Comments) × Bush",
       "I(comments100k^2)" = "(Mass Comments)^2",
       "agency" = "Agency",
       "president" = "President",
       "presidentTrump" = "Trump",
       "presidentObama" = "Obama",
       "presidentBush" = "Bush",
       "coalition_typePublic:presidentObama" = "Public × Obama",
       "coalition_typePublic:presidentTrump" = "Public × Trump",
       "coalition_business_TRUE:presidentTrump" = "Business × Trump",
       "coalition_business_TRUE:presidentBush" = "Business × Bush",
       "coalition_typePublic:presidentBush" = "Public × Bush",
       "partyRepublican" = "Republican President",
       "coalition_typePublic:partyRepublican" = "Republican President × Public",
       "log(comments + 1):coalition_business_TRUE:presidentTrump"= "Log(Mass Comments) × Business × Trump",
       "log(comments + 1):coalition_business_TRUE:presidentBush"= "Log(Mass Comments) × Business × Bush",
       "log(comments + 1):coalition_typePublic:presidentTrump"= "Log(Mass Comments) × Public × Trump",
       "log(comments + 1):coalition_typePublic:presidentBush"= "Log(Mass Comments) × Public × Bush",
       "acme_0" = "Average Conditional Marginal Effect",
       "ade_0" = "Average Direct Effect",
       "coalition_congress" = "Members of Congress",
       "presidentTrump:coalition_typePublic" = "Trump × Public",
       "presidentBush:coalition_typePublic"= "Bush × Public",
       "campaign_TRUE:presidentBush:coalition_typePublic" = "Campaign × Public × Bush",
       "campaign_TRUE:presidentTrump:coalition_typePublic" = "Campaign × Public × Trump")

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

attr(siccess_rows6, 'position') <- c(0)

# new name 
success_rows3 <- tibble(
  term = c("Dependent Variable"),
  `1` = c("Lobbying Success"), 
  `2` =c("Lobbying Success"), 
  `3`  = c("Lobbying Success")
)

attr(success_rows3, 'position') <- c(0)

