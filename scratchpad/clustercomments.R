
source(here("setup.R"))
#####################################
# select and name documentID and text columns
text_df <- select(mass, document = documentId, text = commentText, group = docketId) %>%
  # clean up and tokenize
  mutate(text = tolower(text)) %>% 
  # filter out whole TEXTS with certian phrases or terms
  filter(!grepl("see attached|attachment", text)) %>%
  # tokenize by word, new column is called word
  unnest_tokens(word, text) %>%
  # filter out unwanted WORDS 
  anti_join(get_stopwords()) %>%
  filter(!word %in% c("see", "attach.*", "comment.*", "federal", "agenc.*") ) %>% 
  filter(!is.na(word))


# loop over groups (e.g. dockets) modeling each 
for(i in "BLM-2013-0002"){ #text_df$group){
  text_df %<>% 
    filter(group == i) %>% 
    group_by(document, word) %>% 
    summarise(count = n()) %>% 
    ungroup() 
}

## make document term matrix
## Turns a tidy one-term-per-document-per-row data frame into a DocumentTermMatrix
cast_dtm(text_df, document = document, term = word, value = count)

lda <- LDA(cast_dtm(text_df, document = document, term = word, value = count), 
           k = 2, control = list(seed = 1234))

# # Beta matrix = dist of words over topics
# select top words in each topic 
topic_names <- tidy(lda, matrix = "beta") %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  summarise(name = paste(term, collapse = ", ")) %>% 
  ungroup() 
  
# Gamma matrix = dist of topics over documents 
topics <- tidy(lda, matrix = c("gamma")) %>% 
  left_join(topic_names)
# topics %<>% spread(topic, gamma)

topics$group <- group

topics %<>% rename(documentId = document)

topics %<>% left_join(mass)



# For two topics 
topics$topic <- topics$topic-1
topics %>% 
  mutate(gamma =ifelse(topic==1,gamma,NA)) %>% 
ggplot() + 
  geom_point(aes(x = postedDate,y = gamma, size = numberOfCommentsReceived), alpha = .2) + 
  geom_text(aes(x = postedDate, y = topic, label = name), check_overlap = T, size = 2, color ="blue")+
  geom_text(aes(x = postedDate, y = gamma, label = organization), size =1) +
  facet_grid(. ~ group)
##










# Beta matrix = dist of words over topics 
topics <- tidy(lda, matrix = "beta")

top_terms <- topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()





# k means 






