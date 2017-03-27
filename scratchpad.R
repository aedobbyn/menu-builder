# scratchpad


# the unnesting for loop that worked
for (i in 1:length(lunch$nutrients)) {
  for (j in 1:4) {
    lunch$nutrients[[i]]$gm[j] <- as.character(lunch$nutrients[[i]]$gm[j])
  }
}

# functionize it
dinner <- lunch[1:12,]

characterize <- function(list_column, col)
  for (i in 1:length(list_column)) {
    for (j in 1:length(col)) {
      list_column[[i]][[col]][j] <- as.character(list_column[[i]][[col]][j])
      print(list_column[[i]][[col]][j])
    }
    list_column
  }

dinner$nutrients <- characterize(dinner$nutrients, "gm")


# cooked2 <- tbl_json(cooked)

# dairy_and_eggs$nutrients[[1]]$gm <- as.character(dairy_and_eggs$nutrients[[1]]$gm)

# cooked$nutrients <- as.character(cooked$nutrients)

cooked$nutrients[[1]]$gm <- as.character(cooked$nutrients[[1]]$gm)
cooked$nutrients[[2]]$gm <- as.character(cooked$nutrients[[2]]$gm)
cooked$nutrients[[3]]$gm <- as.character(cooked$nutrients[[3]]$gm)
breakfast <- cooked[1:3, ]
free_range <- breakfast %>% unnest()



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


