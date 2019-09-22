library(data.table)
library(ggplot2)
library(magrittr)
options(datatable.print.class = TRUE)
install.packages('bit64')

sales <- fread("data/sales.csv")
summary(sales)

#adat módosul
clearUnliableSales <- function(sales) {
  sales[sales_amount < 1 | sales_amount > 200, sales_amount:=NA]
}

clearUnliableQuantity <- function(sales) {
  sales[quantity < 1000 | quantity > 6000, quantity:=NA]
}

clearUnliableSales(sales)
clearUnliableQuantity(sales)



ggplot(sales, aes(sales_amount, quantity)) + geom_point() 

melt(sales, measure.vars = c("sales_amount", "quantity")) %>%
    ggplot(., aes(value)) + geom_histogram(bins = 10) + facet_wrap(~variable, scales = "free_x")





