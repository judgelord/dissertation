source("setup.R")

# comment data
load("Data/allcomments.Rdata")
# all %<>% rename(numberOfComments = numberOfCommentsReceived)
alltemp <- all
all <- alltemp
all %<>% rename(commentId = documentId)
all %<>% rename(commentDate = postedDate)
all %<>% select(-documentType, -openForComment, -documentStatus, -allowLateComment)

all %<>% group_by(rin) %>% mutate(numberOfCommentsPosted = sum(numberOfComments) ) %>% ungroup()
all %<>% distinct()
dim(all)

###################################################################
# merge in rule data
load("Data/AllRegsGovRules.Rdata")
# d %<>% filter(documentType == "Proposed Rule")
names(d)
# remove conflicting vars
d %<>% rename(ruletitle = title)
d %<>% rename(numberOfCommentsReported = numberOfCommentsReceived)
d %<>% select(-X, -documentStatus, -openForComment, -attachmentCount, -docketTitle, -commentDueDate, -commentStartDate, -docketType, -agencyAcronym, -rin)
d %<>% distinct()
dim(d)
sum(is.na(d$ruletitle))

# because if factor, it will overload RAM 
d$docketId %<>% as.character()

# select one obs per docket, with most comments
d %<>% group_by(docketId) %>% arrange(-numberOfCommentsReported) %>% mutate(rank = row_number()) %>% ungroup()
head(d$rank[which(d$rank>1)])   
head(d$numberOfCommentsReported[which(d$rank>1)]) 

d %<>% filter(rank == 1)
length(unique(d$docketId))
dim(d)

# merge 
names(d)[which(names(d) %in% names(all) )]
sum(is.na(d$docketId))
sum(is.na(all$docketId))
head(all$docketId)
head(d$docketId)

# wtf 
both <- full_join(all, d)
dim(both)
sum(is.na(both$ruletitle))
sum(is.na(both$numberOfComments))

head(both$numberOfComments)
both %<>% arrange(-numberOfComments)
head(both$numberOfComments)
head(both$numberOfCommentsPosted)
head(both$numberOfCommentsReported)
head(both$agencyAcronym)
head(both)



d <- both 

# clean orgs
d %<>% mutate(organization = ifelse(is.na(organization), title, organization) )
d$organization <- gsub(".*ponsored by |.*ponsoring organization |.*ampaign from |.*ubmitted by |.*omment from |.* on behalf of ", "", d$organization)
d$organization <- gsub(" \\(.*| \\[.*", "", d$organization)
d$organization <- gsub(".*MoveOn.*", "MoveOn", d$organization)
d$organization <- gsub(".*CREDO.*", "CREDO Action", d$organization)
d$organization <- gsub(".*NRDC.*", "Natural Resources Defense Council", d$organization)
d$organization <- gsub(".*Care2.*", "Care2", d$organization)
d$organization <- gsub(".*Environmental Working Group|EWG.*", "Environmental Working Group", d$organization)
d$organization <- gsub(".*Earthjustice.*", "Earthjustice", d$organization)
d$organization <- gsub(".*Sierra Club.*", "Sierra Club", d$organization)
d$organization <- gsub(".*unknown.*", "unknown", d$organization)



save(d, file = "Data/AllRegsGov.Rdata")
