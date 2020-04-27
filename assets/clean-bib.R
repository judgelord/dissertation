rawbib <- "assets/mendeley.bib"
bib <- iconv(readLines(file), "UTF-8", "UTF-8",sub="")
write(bib, "assets/dissertation.bib")
