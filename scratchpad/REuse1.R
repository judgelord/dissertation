library(tidyverse)
library(magrittr)
library(Matrix)
library(quanteda)
library(reshape2)
# Theta.temp <- read.csv()

start = 1996
theta.temp <- ThetaEPAs
all <-  rbind(EPA, HouseEPAs, SenateEPAs)
# all <- EPA
all$year %<>% as.character()
all$year %<>% as.numeric()
all<-filter(all, agency %in% c("EPA"), year >= start)
all$agency %<>% droplevels() # %>%
{gsub("EPA", "EPA from House Committee Report", .)}
all$text %<>% as.character() 

all %<>% arrange(year)

# missing 
# all$text[which(!grepl(all$agency[1], all$subagency))] <- ""
missing <- all %>% filter(text=='')
missing
all %<>% filter(text != "")
Meta <- all %>% select(-text)
Corpus <- corpus(as.character(all$text), docvars = Meta)

# custom and standard stopwords
mystopwords <- tolower(c(
  "USDA", " DOI", "Interrior ", "Environmental Protection Agency", "EPA", 
  "FDA", "Food and Drug Administration", "DHHS", " Department of Health and Human Services ", 
  "Forest Service", "USFS", "federal",
  "will", "american", "us", "united states", "department","administration",
  "fund", "funding", "authorization ", "program","section", 
  "act", "section", "subsection", "budget",
  "appropriated", "appropriations","appropriation", 
  "title", "House", "Senate", "representatives", 
  "congress ", "legislative", "committee", "subcommittee", 
  "program ", "activities ", "projects", "agency", "executive", 
  "request ", " justification", "report ", "subtotal","total ","available" ,
  "expenses", "dollars", "thousands", "current", "actual ", "estimate", "inc", 
  "dec", "change", "estimate ", "discretionary", "balances", "available","staff", 
  "years", " fiscal", "year", "million", "billion", "project", "object" , "purpose", 
  "cost", "key", "FY","fy", "proposed", "sum", "reflect", "copy", "level", "unless", 
  "project", "funds", "cost", "sums", "committee" , "estimate", "chairman", "drafting", "program",
  "departmental", "service", "programs", "total",
  "Interior","BLM","BOEM","BOR ","BSEE","CUPCA","FWS","IA","MMS","NIGC","NPS","NRDA","OIA","OSM"," SOL","USGS","WFM",
  "address", "promote", "mission", "will", "strategic", "character", "particular", "frm", "secretari", "con","senate",
  "www.epa.gov", "workyear", "potential", "also", "manpower", "januari", "oo", "co", "leverage", "workforce", "salari",
  "xref", "federal", "image", 
  stopwords("english")))

# identify words with numbers and short words
toks <- quanteda::tokenize(quanteda::tokenize(Corpus, what='sentence', simplify = TRUE)) 
types <- unique(unlist(toks))
numbers <- types[stringi::stri_detect_regex(types, '[0-9]')]

dfm <- quanteda::dfm(Corpus
                     , remove = c(numbers, mystopwords)
                     , remove_numbers = T
                     , remove_symbols = T
                     , remove_url = T
                     , remove_punct = T
                     , stem = T
)

dtrim <- quanteda::dfm_trim(dfm, min_docfreq = .5) # 10% threshold
d <- dtrim[which(rowSums(dtrim) > 0),] # remove empty rows



# detect 10 gram match 
percent10 <- function(text){
  percent <- numeric()
  percent[1] <- NA
  for(i in 2:length(text)){
    new <- quanteda::tokenize(text[i], what="word", remove_numbers = T, remove_punct = T, remove_symbols =T, simplify = T) 
    old <- quanteda::tokenize(text[i-1], what="word", remove_numbers = T, remove_punct = T, remove_symbols =T, simplify = T) 
    new10 <- tokens_ngrams(new, n = 10)
    old10 <- tokens_ngrams(old, n = 10)
    match <- match10 <- new10 %in% old10
    for(m in 1:(length(match-9))){
      if(match10[m]== T){
        match[m:(m+9)] <- T
      }
    }
    percent[i] <- sum(match)/length(match) # similarity 
  }
  return(percent)
}
all$Tengrams <- percent10(all$text)







# sentences 
percentnews <- function(text){
  percent <- numeric()
  percent[1] <- NA
  for(i in 2:length(text)){
    news <- quanteda::tokenize(text[i], what="sentence", remove_numbers = T, remove_punct = T, remove_symbols =T, simplify = T) 
    olds <- quanteda::tokenize(text[i-1], what="sentence", remove_numbers = T, remove_punct = T, remove_symbols =T, simplify = T) 
    copied <- news %in% olds # similarity
    #added <- !(news %in% olds)
    #cut <- !(olds %in% news)
    percent[i] <- sum(copied)/length(news) # similarity 
  }
  return(percent)
}
all$Sentences <- percentnews(all$text)


# Cosine diff
Cos.sim <- function(dfm){
  cos.sim <- as.matrix(textstat_simil(dfm, margin = "documents", method = "cosine"))
  cos <- numeric()
  cos[1] <- NA
  for(i in 2:dim(cos.sim)[1]){
    cos[i] <- cos.sim[i,i-1]
  }
  return(cos)
}
all$Cosine <- Cos.sim(dfm)



# Wordfish 
wordfish_dif <- function(dtrim){
  text <- textmodel(dtrim, model = "wordfish", dir = c(length( dtrim@docvars$year)-1, length( dtrim@docvars$year)))
  score <- numeric()
  score <- NA
  for(i in 2:length(text@theta)){
    score[i] <- abs(text@theta[i]-text@theta[i-1])
  }
  return(score)
}
# EPA_House$Wordfish # NEVER WOKRED!!!

all$Wordfish <-  wordfish_dif(dtrim) %>% percent_rank()
all %<>% mutate(Wordfish = 1-Wordfish)  # similarity 

plot(seq(1967, 2018, 1) , text@theta)

# normalized average LDA theta 
theta.temp$year %<>% as.character()
theta.temp$year %<>% as.numeric()

theta.temp %<>% filter(year >= start, agency %in% c("EPA")) 
theta.temp %<>% group_by(year, agency) 
short <- summarize(theta.temp, avg_theta_diff = mean(theta_diff))
short$avg_theta_diff[1] <- NA
short$agency # %<>% 
{gsub("EPA", "EPA from House Committee Report", .)}
all$theta_diff <- short$avg_theta_diff %>% percent_rank()
all %<>% mutate(theta_diff = 1-theta_diff) # similartiy 

# full_join(all, short, by= c(agency, year))





EPA_67 <- all 



