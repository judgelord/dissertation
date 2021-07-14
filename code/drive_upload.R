library(googledrive)

drive_auth()

file.rename("judgelord.Rmd", "judgelord.text")

drive_upload("judgelord.text", 
             name = str_c("diss", Sys.Date() ), 
             overwrite = T)


