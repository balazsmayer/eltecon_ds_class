library(gglot2)
library(data.table)

sales <- fread("data/sales.csv")

ggplot(sales, aes(x = sales_amount)) + geom_bar()