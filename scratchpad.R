# scratchpad


l <- lunch %>% map_if(is.numeric, as.character) %>% as_data_frame



lunch <- cooked
lunch[] <- lapply(cooked[["nutrients"]], `[[`, as.character)




post_free_range <- lunch %>% unnest()




for (i in 1:length(lunch$nutrients)) {
  lunch$nutrients[[i]]["gm"] <- as.character(lunch$nutrients[[i]]["gm"])
}

home_on_range <- lunch %>% unnest()



cduR=NULL
for (i in 1:length(lunch$nutrients)){
  grams=lunch$nutrients[[i]]
  cduR=c(cduR,as.character(grams["4"]))
}




class(lunch$nutrients[[11]]$gm)


lapply(lunch$nutrients, `[[`, as.character("4"))


