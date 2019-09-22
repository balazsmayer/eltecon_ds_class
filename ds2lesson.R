library(data.table)
library(ggplot2)
library(magrittr)
options(datatable.print.class = TRUE)
install.packages('bit64')

student <- fread("data/student-data.csv")

summary(student)

#adat módosul
convertWeightToCm <- function(student) {
  student [height > 1.3 & height < 2.1, height := height * 100 ]
}


clearUnliableHeight <- function(student) {
  student[height < 100 | height > 230, height:=NA]
}

clearUnliableFood <- function(student) {
  student[food > 10^6 | food < 45, food:=NA]
}

clearUnliableBeer <- function(student) {
  student[beer < 0 | beer > 230, beer:=NA]
}



convertWeightToCm(student)
clearUnliableHeight(student)
clearUnliableFood(student)
clearUnliableBeer(student)



student[, television := as.numeric(television)]

ggplot(student, aes(height,weight)) + geom_point() + facet_wrap(~as.factor(male))

melt(student, measure.vars = c("food", "beer", "television")) %>%
  .[male == 1] %>%
  ggplot(., aes(value)) + geom_histogram(bins = 10) + facet_wrap(~variable, scales = "free_x")



####
mean(c(1, 2, 3))
c (1, 2, 3) %>% mean () %>% sqrt ()


       