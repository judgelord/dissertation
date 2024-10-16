

```{r setup, echo = FALSE, include = FALSE}
source("setup.R")

knitr::opts_chunk$set(echo = T, # echo = TRUE means that your code will show
                      warning = FALSE,
                      message = FALSE,
                      # fig.align = "center", 
                      fig.path= 'Figs/', ## where to save figures
                      fig.height = 3,
                      # fig.retina = 6,
                      fig.width = 8)
                      #dev = "cairo_pdf")
```

## Pre-analysis

### Simulated Data

To illustrate my planned analysis, I simulate data for each variable described above. 

**Dependent variable:** *Coalition success* is drawn from a descrete distribution {-1, -.5, 0, .5, 1}. 

**Explanatory variables:** *Coalition size* (a count) is drawn from a Poisson distribution. *Business colation* is binomial. In reality, business coalitions are more common than non-business coalitions, but here I estimate a balanced sample. I set rule pages constant at 85 and draw *comment lengths* from a Poisson distribution. While in reality, less than one percent of coalitions lobbying in rulemaking opt for a mass-comment campaign, I aim to gather a balanced sample, so half of the simulated data are assumed to have no mass comment campaign (*comments* = 1, *log(comments)* = 0) and the other half have a number of *comments* drawn from a Zero-Truncated Poisson distribution, which is then transformed to a log scale. 

```{r,  fig.width=2, fig.height=2}
coalition_success <- sample(x = c(-1, -.5, 0, .5, 1), 1000, prob = c(0.1, 0.3, .1, 0.4, 0.1), replace = T)

d = tibble(rule_id = c(1:1000, rep(1001:1500, 2)),
           coalition_id = sample(1:2000),
           coalitions  = c(rep(1, 1000), rep(2, 1000)),
           coalition_unopposed = c(rep(0, 1000), rep(1, 1000)),
           coalition_success = c(coalition_success, sort(coalition_success)), 
           coalition_size = rtnorm(1000, mean = 5, sd= 10, lower = 1) %>% rep(2) %>% round(), 
           coalition_business = sample(x = c(0,1), 2000, replace = T, prob = c(0.3, .7)), 
           comment_length = round(rpois(2000, 10)/85 *100, 1), 
           comments= c(rtnorm(1000, mean = 10000, sd = 100000, lower = 100), rep(1, 1000)) %>% sample() %>% round() , 
           cong_support = c(rtnorm(1000, mean = 1, sd = 5, lower = 0), rep(0, 1000)) %>% sample() %>% round() )

d %>% sample_n(10) %>% dplyr::select(rule_id, coalition_id, everything()) %>% knitr::kable(caption = "Simulated data") %>% kable_styling(font_size = 5)
```

```{r, hist_coalitions, fig.show="hold", fig.width=2, fig.height=2, echo=FALSE}
ggplot(d, aes(x = coalition_success)) + geom_histogram()+ labs(x = "Coalition Success")
ggplot(d, aes(x = coalition_business)) + geom_histogram()+ labs(x = "Business Coalition")
ggplot(d, aes(x = coalition_size)) + geom_histogram()+ labs(x = "Coalition size")
```

```{r, hist_comments, fig.show="hold", fig.width=3, fig.height=2, echo=FALSE}
ggplot(d, aes( x= comment_length)) + geom_histogram()+ labs(x = "% (Comment length/proposed rule length)*100")
ggplot(d, aes( x= comments)) + geom_histogram() + labs(x = "Log(comments)")
```

### Simulated Results
Unsurprisingly this model yields no significant results. With lobbying success as the dependent variable, the coefficient on the main variable of interest would be interpreted as a one-unit increase in the logged number of comments corresponds to a $\beta_{logmasscomments}$ increase in the five-point influence scale.

```{r model_success}
m <- lm(coalition_success ~ log(comments) + 
          comment_length + 
          coalition_business +  
          coalition_size + 
          coalition_unopposed, 
        data = d) 
```

```{r model_success_plot, echo=FALSE}
m %>%
  tidy(conf.int = TRUE) %>% 
  filter(term != "(Intercept)") %>% 
  ggplot() + 
  geom_hline(yintercept = 0, color = "grey") + 
  aes(x = term, y = estimate, ymin = conf.low, ymax =conf.high) + 
  geom_pointrange( )  + 
  coord_flip() +
  labs(title = "OLS model of coalition lobbying sucess with simulated data",
       y = "Lobbying Success", 
       x = "") + 
  scale_color_discrete()
```

To assess congressional support as a mediator in the influence of public pressure campaigns on rulemaking, I estimate the average conditional marginal effect (ACME, conditional on the number of comments from Members of Congress) and average direct effect (ADE) of mass comments using mediation analysis. 

```{r mediation}
library(mediation)

# model predicting mediator
model.m <- lm(cong_support ~  log(comments) + comment_length + coalition_business+  coalition_size + coalition_unopposed, data = d) 

# model predicting DV
model.y <- lm(coalition_success ~ log(comments) + cong_support + comment_length + coalition_business+  coalition_size + coalition_unopposed, data = d) 

med.cont <- mediate(model.m, model.y, sims=1000, treat = "log(comments)",
mediator = "cong_support")

summary(med.cont)
```