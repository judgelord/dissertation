options(strings.as.factors = FALSE)
library(tidyverse)
library(magrittr)
library(scales)
library(aod)

d <- read.csv("data/PS%2BPR%2BFR %22environmental%2Bjustice%22 .csv")

ejregs <- d
eregs <- filter(regs, agencyAcronym %in% ejregs$agencyAcronym) %>%
  filter(documentType == "Proposed Rule")
unique(eregs$agencyAcronym)


ejcomments <- filter(ejregs, documentType == "Public Submission")
ejPRs <-  filter(ejregs, documentType == "Proposed Rule")
ejFRs <- filter(ejregs, documentType == "Rule")

eregs %<>% mutate(ejcomment = as.factor(ifelse(docketId %in% ejcomments$docketId, 1, 0)))
eregs %<>% mutate(ejproposed = as.factor(ifelse(docketId %in% ejPRs$docketId, 1, 0)))
eregs %<>% mutate(ejfinal = as.factor(ifelse(docketId %in% ejFRs$docketId, 1, 0)))

eregs %<>% filter(agencyAcronym %in% ejFRs$agencyAcronym)
unique(ejFRs$agencyAcronym)
unique(eregs$agencyAcronym)
i <- ejFRs %>% group_by(agencyAcronym) %>% count() %>% arrange(desc(n))

mydata <- eregs

mylogit <- glm(ejfinal ~ ejcomment + ejproposed + agencyAcronym, 
               data = mydata, family = "binomial")

# at each value of ejcomments
newdata1 <- with(mydata, data.frame(numberOfCommentsReceived = mean(numberOfCommentsReceived), 
                                    ejproposed = factor(0),
                                    ejcomment = factor(1,0)
                                    ))
newdata1$rankP <- predict(mylogit, newdata = newdata1, type = "response")

# at each vlue of number of comments
newdata2 <- with(mydata, data.frame(numberOfCommentsReceived = rep(seq(from = 0, to = 100000, length.out = 100), 2), 
                                    ejproposed = factor(0),
                                    ejcomment = factor(rep(0:1, each = 100))))

newdata3 <- cbind(newdata2, predict(mylogit, newdata = newdata2, type = "link",
                                    se = TRUE))
newdata3 <- within(newdata3, {
  PredictedProb <- plogis(fit)
  LL <- plogis(fit - (1.96 * se.fit))
  UL <- plogis(fit + (1.96 * se.fit))
})

levels(newdata3$ejcomment) <- c(paste0("No (N = ", sum(eregs$ejcomment == 0),")"),
                                paste0("Yes (N = ", sum(eregs$ejcomment == 1),")"))

ggplot(newdata3, aes(x = numberOfCommentsReceived, y = PredictedProb)) + 
  geom_ribbon(aes(ymin = LL,
                  ymax = UL, fill = ejcomment), alpha = 0.2) +
  geom_line(aes(colour = ejcomment), size = 1) + 
  labs(y = "Predicted Probability of EJ in Final", 
       x =  "Total Number of Comments on Proposed Rule",
       color = "Evironmental Justice 
Raised by Comments",
       fill = "Evironmental Justice 
Raised by Comments") 




###########################################
# by agency 

mylogit <- glm(ejfinal ~ ejcomment + ejproposed + numberOfCommentsReceived + agencyAcronym, 
               data = mydata, family = "binomial")


# at each vlue of number of comments
newdata2 <- with(mydata, data.frame(numberOfCommentsReceived = mean(numberOfCommentsReceived), 
                                    ejproposed = factor(0),
                                    agencyAcronym = agencyAcronym,
                                    ejcomment = factor(rep(0:1, each = length(mydata$agencyAcronym)))))

newdata3 <- cbind(newdata2, predict(mylogit, newdata = newdata2, type = "link",
                                    se = TRUE))
newdata3 <- within(newdata3, {
  PredictedProb <- plogis(fit)
  LL <- plogis(fit - (1.96 * se.fit))
  UL <- plogis(fit + (1.96 * se.fit))
})

levels(newdata3$ejcomment) <- c(paste0("No (N = ", sum(eregs$ejcomment == 0)," Rules)"),
                                paste0("Yes (N = ", sum(eregs$ejcomment == 1)," Rules)"))

newdata3 %<>%  filter(UL < .9) %>% arrange(UL)
sig <- newdata3 %>% filter(agencyAcronym %in% c("FS", "EPA", "FMCSA", "NRC", "NOAA", "FWS"))
  #group_by(agencyAcronym) %>% filter(max(LL)<min(UL)) %>% ungroup()

ggplot(newdata3, aes(x = agencyAcronym, y = PredictedProb)) + 
  geom_linerange(aes(ymin = LL,
                  ymax = UL, color = ejcomment), alpha = 0.01) +
  #geom_point(aes(color = ejcomment), alpha = 0.002) + 
  geom_linerange(data = sig, aes(ymin = LL,
                     ymax = UL, color = ejcomment)) +
  geom_point(data = sig, aes(color = ejcomment)) + 
  labs(title = "Proposed Rules Not Addressing Environmental Justice",
       y = "Predicted Probability that Environmental Justice Issues are Addressed in Final Rule", 
       x =  "",
       color = "Evironmental Justice 
Raised by Comments",
       fill = "Evironmental Justice 
Raised by Comments") + 
  coord_flip() 

ejcomments %<>% mutate(year = substr(postedDate, 1,4))

ggplot(data = ejcomments %>% filter(year>2005)) + 
  geom_bar(aes(x = year, fill = Racism))




sum(ejcomments$Economic)

geom_histogram()


