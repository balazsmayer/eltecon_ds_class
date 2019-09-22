library(data.table)
library(ggplot2)
library(magrittr)

heart <- fread("C:/Users/Balázs/Desktop/heart.csv")

#van-e outlier?
summary(heart)
#nincs outlier

#integerbol numericba
heart[, age := as.numeric(age)]
heart[, trestbps := as.numeric(trestbps)]
heart[, chol := as.numeric(chol)]
heart[, thalach := as.numeric(chol)]

#ures sorok torlese
clearNa <- function(heart) {
  heart[age := NA]
}

#pontdiagram: ev es vernyomas
ggplot(heart, aes(age, trestbps)) + geom_point()
