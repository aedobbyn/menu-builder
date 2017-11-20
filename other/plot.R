

source("./connect.R")


ggplot(data = na.omit(all_foods), aes(x = ndbno, y = value, colour = nutrient)) +
  geom_point() +
  theme_light()


# take a sample of just 100 of the most common 1000 foods
some_foods <- sample_n(all_foods, 100)

# trim the names to 20 characters
some_foods$name <- strtrim(some_foods$name, 20)

# ---- fivethirtyeight rip off graph -----
# plot energy per 100g for a sample of
ggplot(data = na.omit(some_foods[some_foods[["nutrient"]] == "Energy", ]), aes(x = ndbno, y = value)) +
  geom_point() +
  geom_text_repel(aes(label = name), 
                  box.padding = unit(1, "lines"),
                  family = "Helvetica",
                  size = 3.5,
                  label.size = 0.5) +
  theme_bw() +
  theme(panel.background=element_rect(fill="#F0F0F0")) +
  theme(plot.background=element_rect(fill="#F0F0F0")) +
  theme(panel.border=element_rect(colour="#F0F0F0")) +
  theme(panel.grid.major=element_line(colour="#D0D0D0",size=.75)) +
  theme(axis.ticks=element_blank()) +
  ggtitle("Energy of Common Foods") +
  theme(plot.title=element_text(face="bold",colour="#3C3C3C",size=20)) +
  ylab("Kcal/100g") +
  xlab("NDB number") +
  theme(axis.text.x=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.text.y=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.title.y=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.title.x=element_text(size=11,colour="#535353",face="bold"))

# same thing except bar graph
ggplot(data = na.omit(some_foods[some_foods[["nutrient"]] == "Energy", ]), aes(x = name, y = value)) +
  geom_bar(stat = "identity") +
  theme_bw() +
  theme(panel.background=element_rect(fill="#F0F0F0")) +
  theme(plot.background=element_rect(fill="#F0F0F0")) +
  theme(panel.border=element_rect(colour="#F0F0F0")) +
  theme(panel.grid.major=element_line(colour="#D0D0D0",size=.75)) +
  theme(axis.ticks=element_blank()) +
  ggtitle("Energy of Common Foods") +
  theme(plot.title=element_text(face="bold",colour="#3C3C3C",size=20)) +
  ylab("Kcal/100g") +
  xlab("NDB number") +
  theme(axis.text.x=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.text.y=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.title.y=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.title.x=element_text(size=11,colour="#535353",face="bold")) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1, family = "Helvetica"))



# plot energy vs. sugar
ggplot(data = some_foods[some_foods[["nutrient"]] == "Energy", ], aes(x = some_foods[some_foods[["nutrient"]] == "Energy", ]$value, 
                                                                      y = some_foods[some_foods[["nutrient"]] == "Sugars, total", ]$value,
                                                                      colour = factor(ndbno))) +
  geom_point() +
  geom_text_repel(aes(label = name), 
                  box.padding = unit(0.45, "lines"),
                  family = "Courier",
                  label.size = 0.5) +
  theme_bw()


