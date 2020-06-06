rawbib <- "assets/mendeley.bib"
bib <- iconv(readLines(rawbib), "UTF-8", "UTF-8",sub=" ")
write(bib, "assets/dissertation.bib")
