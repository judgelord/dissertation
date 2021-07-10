load(here("data", "comments_min.Rdata"))

#FIXME move
comments_mass <- comments_min %>% 
  mutate(year = date %>% str_sub(1,4)) %>%
  filter(number_of_comments_received  > 99) 

save(comments_mass, file = here("data", "comments_mass.Rdata"))






data <- unique(all)
# data %<>% select(-postedDate)
data %<>% unique()
data %<>% filter(!is.na(documentType), documentType != "NA")
names(data)
head(data$title)
unique(data$documentId)
data$commentDueDate %<>% as.Date()
data$postedDate %<>% as.Date()
data$commentStartDate %<>% as.Date()


data %<>% arrange(docketId)
head(data)
# data$openForComment %<>% as.logical()

data %>% group_by(agencyAcronym) %>% count() %>% arrange(-n)
data %>% group_by(organization) %>% count() %>% arrange(-n)

data %>% filter(docketType == "Rulemaking") %>%  group_by(docketId) %>% count() %>% arrange(-n)

data %<>% mutate(year = substr(postedDate, 1, 4))
data$year %<>% as.numeric()

data$commentStartDate[which(data$year == 2099)]

data$year %<>% {gsub("2099", "2009", .)}

data$organization %<>% as.factor() %<>% droplevels()
levels(data$organization)

data$documentType %<>% {gsub("Submission", "Comments", .)}


ggplot(data %>% filter(year > 1993, numberOfCommentsReceived < 1000, numberOfCommentsReceived > 0)) + 
  geom_histogram(aes(numberOfCommentsReceived), binwidth = 100)


ggplot() +
  geom_bar(data = data %>% 
             filter(year > 1993, documentType %in% c("Rule", "Proposed Rule")), 
           aes(
             x=year, 
             fill = documentType
           ), position = "dodge") +  
  labs(x = "", y = "", title = "") + 
  theme(axis.text.x  = element_text(angle=45, vjust=0.5), legend.title = element_blank()) #+
ggplot()+
  geom_point(data = data %>% 
               filter(year > 1993, documentType %in% c("Public Comments")) %>%
               group_by(docketId) %>% 
               top_n(1) %>%
               ungroup() %>%
               group_by(year, documentType) %>%
               count() %>% 
               ungroup(),
             aes(x = year, y = n, color = documentType))


data %<>% ungroup()


# number of comments 
ggplot(data %>% filter(numberOfCommentsReceived > 0, 
                       numberOfCommentsReceived < 1000000, 
                       # documentType %in% c("Public Comments"),
                       year != "NA", year > 1993)) + 
  geom_point(aes(
    x = postedDate, 
    y = numberOfCommentsReceived, 
    color = documentType
  ), alpha = .5) +
  geom_text(data = data %>% filter(numberOfCommentsReceived > 250000, 
                                   numberOfCommentsReceived < 1000000, 
                                   # documentType %in% c("Public Comments"),
                                   year != "NA", year > 1993),
            aes(postedDate, numberOfCommentsReceived, 
                label = agencyAcronym), vjust = 0, hjust = 1, size = 3) +
  labs(x = "", y = "", title = "") + 
  theme(axis.text.x  = element_text(angle=45, vjust=0.5), legend.title = element_blank()) +
  scale_x_date(labels = date_format("%Y"), date_breaks = "1 year")



data %>% filter(numberOfCommentsReceived > 10000)




ggplot(data %>% filter(
  !is.na(postedDate), 
  #documentType %in% c("Rule", "Proposed Rule"),
  year > 1993
)) +
  geom_point(aes(
    x = postedDate, 
    y = numberOfCommentsReceived, 
    color = documentType
  )) + facet_grid(~agencyAcronym)




data %<>% 
  group_by(year, documentType) %>% 
  mutate(AvgComments = mean(numberOfCommentsReceived)) %>%
  ungroup()



ggplot(data %>% filter(documentType == "Proposed Rule", 
                       year != "NA", 
                       year > 1993, 
                       numberOfCommentsReceived >0), 
       aes(x = factor(year), y = numberOfCommentsReceived)) + 
  geom_boxplot() + labs(x = "", y = "", title = "") + 
  theme(axis.text.x  = element_text(angle=45, vjust=0.5), legend.title = element_blank()) +
  scale_y_continuous(limit = c(0, 100)) 


ggplot(data %>% filter(documentType == "Proposed Rule", 
                       year != "NA", 
                       year > 2005, 
                       numberOfCommentsReceived >0), 
       aes(x = postedDate, y = numberOfCommentsReceived)) + 
  geom_point(alpha = .1) + 
  scale_y_continuous(limit = c(0, 1000)) 



ggplot(data %>% group_by(year) %>% filter(year != "NA", year > 1993, numberOfCommentsReceived <100000)) + 
  geom_point(aes(x = year, y = AvgComments, color = documentType))  + labs(x = "", y = "", title = "") + 
  theme(axis.text.x  = element_text(angle=45, vjust=0.5), legend.title = element_blank()) 


ggplot(data %>% group_by(year) %>% filter(year != "NA", year > 1993, numberOfCommentsReceived > 0)) + 
  geom_violin(scale = "area", aes(x = year, y = numberOfCommentsReceived, 
                                  alpha = 1)) + labs(x = "", y = "", title = "") + 
  theme(axis.text.x  = element_text(angle=45, vjust=0.5), legend.title = element_blank()) +
  scale_y_continuous(limit = c(0, 100))

unique(data$AvgComments)

plot(n)
