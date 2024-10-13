if(F){
#old
  install.packages("ReadMe")
  
  # new
devtools::install_github("iqss-research/readme-software/readme")
download_wordvecs() 

reticulate::install_miniconda()

devtools::install_github("rstudio/tensorflow")
library(tensorflow)
install_tensorflow()

}

library(tensorflow)
library(readme)


#EXAMPLE https://github.com/iqss-research/readme-software
data(clinton, package="readme")


## Generate a word vector summary for each document
wordVec_summaries = undergrad(documentText = cleanme(clinton$TEXT), wordVecs = NULL)

# Estimate category proportions
set.seed(2138) # Set a seed if you choose
readme.estimates <- readme(dfm = wordVec_summaries , 
                           labeledIndicator = clinton$TRAININGSET, 
                           categoryVec = clinton$TRUTH)

# We can compare the output with the true category codings
# Output proportions estimate
readme.estimates$point_readme
# Compare to the truth
table(clinton$TRUTH[clinton$TRAININGSET == 0])/sum(table((clinton$TRUTH[clinton$TRAININGSET == 0])))


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
  arrange(org_name)



## Generate a word vector summary for each document
wordVec_summaries = undergrad(documentText = cleanme(d$organization), wordVecs = NULL)

# Estimate category proportions
set.seed(2138) # Set a seed if you choose
readme.estimates <- readme(dfm = wordVec_summaries , 
                           labeledIndicator = d$TRAININGSET, 
                           categoryVec = d$org_name)

# We can compare the output with the true category codings
# Output proportions estimate
readme.estimates$point_readme 

# Compare to the truth
table(d$org_name[d$TRAININGSET == 0])/sum(table((d$org_name[d$TRAININGSET == 0])))


d1 <- d %>%  mutate(TRUTH = n/nrow(d)) %>% 
  distinct(org_name, TRUTH) %>% 
  mutate(diff = TRUTH - readme.estimates$point_readme,
    README = readme.estimates$point_readme %>% percent(),
         TRUTH = TRUTH %>% percent()) 

d1$diff %>% sum()

kable(d1) %>% kable_paper()
