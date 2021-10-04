#chapter <- "05-ej/ej.tex"
#chapter <- "02-pressure/whyMail.tex"

make_article <- function(input, ...) {
  
  #rmarkdown::render(input)
  
  chapter <- paste0(xfun::sans_ext(input), '.tex')
  
text <- readLines(chapter) %>%
  # up one header level
  str_replace_all("subsection", "section") %>% 
  #inspect for chapter cites .[doc %>% str_detect("Chapter .ref")] %>% 
  str_replace_all("this chapter", "this paper") %>% 
  str_replace_all("This chapter", "This paper") %>% 
  str_replace_all("(In the |The) previous chapter(s|)", "Elsewhere") %>% 
  str_replace_all("(in )the previous chapter(s|)", "elsewhere") %>% 
  str_replace_all("Chapter .ref", "\\\\citet")

# rename
article <- chapter %>% str_replace(".tex$", "-article.tex") 

# save article .tex file 
writeLines(text, article)  

# comple latex
tinytex::xelatex(article)
}
