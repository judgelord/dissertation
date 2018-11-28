install.packages(c("topicmodels", "tidytext", "tidyverse"))

install.packages("quanteda")
library(topicmodels)
library(tidyverse)
library(tidytext)
library(quanteda)
library(tm)


data("AssociatedPress")
AssociatedPress


text_df <- data_frame(document = 1:4338, text = all$commentText)

text_df %<>% 
  filter(!grepl("See attached", text)) %>% 
  unnest_tokens(word, text)

tidy(text_df)

cast_dtm(text_df, document = document, term = word, value = word)

ap_lda <- LDA(cast_dtm(text_df, word, document, value = word), 
              k = 2, control = list(seed = 1234))
ap_lda



ap_topics <- tidy(ap_lda, matrix = "beta")
ap_topics



ap_top_terms <- ap_topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

ap_top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

