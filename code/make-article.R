# Test
# chapter <- "05-ej/ej.tex"

make_article <- function(chapter){

text <- readLines(here::here(chapter)) %>%
  # up one header level
  str_replace_all("subsection", "section") %>% 
  # inspect for chapter refs 
  #.[doc %>% str_detect("(C|c)hapter")] %>% 
  # change chapter refs 
  str_replace_all("this chapter", "this paper") %>% 
  str_replace_all("This chapter", "This paper") %>% 
  str_replace_all("(In the |The) previous chapter(s|)", "Elsewhere") %>% 
  str_replace_all("(in )the previous chapter(s|)", "elsewhere") %>% 
  #TODO MAKE DOUBLE REF 
  str_replace_all("Chapter .ref", "\\\\citet") %>% 
  str_replace_all("Chapter .ref", "\\\\citet")

# make article file path
article <- here::here(chapter) %>% str_replace("05-ej", "docs")# str_replace(".tex$", "-article.tex") 

# save article version of tex file 
writeLines(text, article)  

# compile tex
tinytex::xelatex(article)
}
