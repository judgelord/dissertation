```{r data}
load("Data/AllRegsGov.Rdata")

# top mobilizers
top20orgs <- all$group_by(organization) %>% sumarize(numberOfComments) %>% top_n(20)

# overall counts
commentcount <- sum(all$numberOfComments)
RINcount <- length(unique(all$rin))

# Mass RINs are rules with over 100 identical comments
allmass <- filter(all, numberOfComments > 100)
masscommentcount <- sum(allmass$numberOfComments)
allmass %>% select(organization, numberOfComments) %>% arrange(numberOfComments) %>% top_n(200)

massRINs <- unique(allmass$rin)
length(massRINs)
massorgs <- unique(allmass$organization)
length(massorgs)

allmassRINs <- filter(all, rin %in% massRINs)
massRINcommentcount <- sum(allmassRINs$numberOfCommentsReceived)


```

### Regulations.gov records

I leverage a dataset of all `r commentcount` comments posted on regulations.gov. 
Of the `r RINcount` rulemaking processes on regulations.gov, `r openRINcount` accepted public comments and, of these, `r RINcount` recieved at least one comment. 

I use text reuse and topic models to identify comments that belong to same coalition, focusing on the `r length(massRINs)` rulemakings that saw a mass commenting campaign, which I define narrowly has 100 or more idendical comments. `r length(massorgs)` different organizations mobilized more than 100 identical comments, averaging over `r round(mean(allmass$numberOfComments))` per campaign. 

### Rules with mass commenting

### Organizations
r top20orgs

# Analysis



```{r save, eval=FALSE}
rm(all, allmassRINs)
save.image(file = "whyMail.RData")
````