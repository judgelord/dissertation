install.packages("wru")
library(wru)

# race of commentor from census 
ejcomments %<>% mutate(surname = sub(".*\\s", "", submitterName))
unique(ejcomments$surname)

ejcommentors <- ejcomments %>% filter(nchar(surname)>4)

ejcommentors$surname %<>% toupper()

unique(ejcommentors$surname)


surnames <- read.csv("surnames.csv") # load 2010 census https://www.census.gov/topics/population/genealogy/data/2010_surnames.html

race <- left_join(ejcommentors, surnames, by = "surname")

write.csv(race, "eandjrace.csv")

race %<>% filter(!is.na(White))

mean(race$White)
mean(race$Latino)
mean(race$Native)
mean(race$Black)

race <- predict_race(race, census.surname = TRUE, surname.only = T)

Race <- data.frame("Race" = c(
  "Other",
  "White",
  "Black",
  "Latinx",
  "Asian"),
"Probability" = c(
mean(race$pred.oth),
mean(race$pred.whi),
mean(race$pred.bla),
mean(race$pred.his),
mean(race$pred.asi)),
"Predicted" = c(0,309,6, 27, 0)
)

ggplot(data = Race, aes(x = Race, y = Predicted)) +
  geom_col()

eregs %<>% mutate(year = substr(postedDate, 1,4))
ggplot(data = filter(eregs, ejcomment==1 & ejproposed == 0 & !is.na(year) & as.numeric(year) > 2005), 
       aes(x = year, fill = ejfinal)) +
  geom_bar() + 
  labs(y ="", x = "", fill = "EJ In Final")


max(race$pred.asi, race$pred.bla)

race %<>% mutate(comment = paste(commentText, environmentaljustice))


races <- select(race, pred.whi, pred.oth, pred.bla, pred.his, pred.asi)
race$race <- colnames(races)[max.col(races, ties.method="first")]

race$race %<>% as.factor()
levels(race$race) <- c("Black", "Latinx", "White")


ejcomments %<>% mutate(Racism = ifelse(grepl("racism|race|black|white|latino|native|asian|hispanic|racial",
          tolower(environmentaljustice)), 1, ifelse(
            grepl("racism|race|black|white|latino|native|asian|hispanic|racial",
                  tolower(commentText)), 1,0)))


ejcomments %<>% mutate(Economic = ifelse(
  grepl("income|wealthy|poor|inequality",
                                             tolower(environmentaljustice)), 1, ifelse(
                                               grepl("income|wealthy|poor|inequality",
                                                     tolower(commentText)), 1,0)))
