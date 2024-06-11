

library(keras)
library(dplyr)
library(ggplot2)
library(purrr)




#####################################################
# REAL ORGS
load("data/comments_coded.Rdata")
d <- comments_coded %>% 
  mutate(organization = str_to_lower(organization), 
         org_name = str_to_lower(org_name)) %>% 
  filter(org_name != organization) %>% 
  # distinct(org_name, organization) %>% 
  group_by(org_name) %>% 
  add_count() %>% 
  filter(n > 1) %>% 
  mutate(TRAININGSET = rbinom(n, 1, .2)) %>% 
  mutate(TRAININGSET = ifelse(n == 3, c(0,1, 1), TRAININGSET)) %>% 
  # filter out cases with zero in training set 
  filter(sum(TRAININGSET==1)>2, sum(TRAININGSET==0) > -1) %>% 
  ungroup() %>% 
  arrange(org_name) %>% 
  mutate(text = organization)


training <- d[d$TRAININGSET == 1,]
testing <- d[d$TRAININGSET == 0,]

num_words <- 10000
max_length <- 50
text_vectorization <- layer_text_vectorization(
  max_tokens = num_words, 
  output_sequence_length = max_length, 
)

# TODO see https://github.com/tensorflow/tensorflow/pull/34529
get_vocabulary(text_vectorization)

text_vectorization(matrix(d$text[1], ncol = 1))


input <- layer_input(shape = c(1), dtype = "string")

output <- input %>% 
  text_vectorization() %>% 
  layer_embedding(input_dim = num_words + 1, output_dim = 16) %>%
  layer_global_average_pooling_1d() %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dropout(0.5) %>% 
  layer_dense(units = 1, activation = "sigmoid")

model <- keras_model(input, output)



model %>% compile(
  optimizer = 'adam',
  loss = 'binary_crossentropy',
  metrics = list('accuracy')
)


history <- model %>% fit(
  training$text,
  as.numeric(training$org_name),
  epochs = 10,
  batch_size = 512,
  validation_split = 0.2,
  verbose=2
)

