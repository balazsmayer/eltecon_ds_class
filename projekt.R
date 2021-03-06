#Feleves projekt 2019/20/1
#Mayer Balazs
install.packages("data.table")
install.packages("ggplot2")
install.packages("magrittr")
install.packages("tidyverse")
install.packages("gridExtra")
install.packages("dplyr")
install.packages("reshape2")
install.packages("class")
install.packages("ISLR")
install.packages("caret")

library(tidyverse)
library(gridExtra)
library(dplyr)
library(data.table)
library(ggplot2)
library(magrittr)
library(reshape2)
library(class)
library(ISLR)
library(caret)

data <- fread("data/heart.csv")
data

#stat
summary(data)

g1_age <- data %>% ggplot(aes(x=age)) + geom_histogram(bins=50) 
g1_age

g2_trestbps <- data %>% ggplot(aes(x=trestbps)) + geom_histogram(bins=50) 
g2_trestbps

g3_chol <- data %>% ggplot(aes(x=chol)) + geom_histogram(bins=50) 
g3_chol

data %>% ggplot(aes(x=age, fill=factor(target))) +
  geom_density(alpha=0.5) +
  geom_vline(xintercept=c(54, 70), color='red', linetype=2)

data %>% mutate(
  sex = ifelse(sex==1, "Male", "Female")
)%>%ggplot(aes(x=sex, fill=factor(target))) +
  geom_bar(position='dodge')


data %>% ggplot(aes(x=cp, fill=factor(target))) +
  geom_bar(position='dodge') 

data %>% ggplot(aes(x=trestbps, fill=factor(target))) +
  geom_density(alpha=0.5) 

data %>% ggplot(aes(x=chol, fill=factor(target))) +
  geom_density(alpha=0.5) 

#Multikollinearitas
install.packages("corrplot")
library(corrplot)
head(data)
C <- cor(data)
head(round(C,2))
corrplot(C, method="number")

#modell1: logit
logit <- glm(target ~ sex+age+cp+trestbps+chol, data = data, family = 'binomial')
summary(logit)
plot(logit) 

logit %>% coefficients %>% exp %>% round(3)


# Load libraries, get data & set seed for reproducibility ---------------------
set.seed(123)    # seef for reproducibility
library(glmnet)  # for ridge regression
library(dplyr)   # for data cleaning
library(psych)   # for function tr() to compute trace of a matrix

data("data")
# Center y, X will be standardized in the modelling function
y <- data %>% select(target) %>% scale(center = TRUE, scale = FALSE) %>% as.matrix()
X <- data %>% select(-target) %>% as.matrix()


# Perform 10-fold cross-validation to select lambda ---------------------------
lambdas_to_try <- 10^seq(-3, 5, length.out = 100)
# Setting alpha = 0 implements ridge regression
ridge_cv <- cv.glmnet(X, y, alpha = 0, lambda = lambdas_to_try,
                      standardize = TRUE, nfolds = 10)
# Plot cross-validation results
plot(ridge_cv)

# Best cross-validated lambda
lambda_cv <- ridge_cv$lambda.min
# Fit final model, get its sum of squared residuals and multiple R-squared
model_cv <- glmnet(X, y, alpha = 0, lambda = lambda_cv, standardize = TRUE)
y_hat_cv <- predict(model_cv, X)
ssr_cv <- t(y - y_hat_cv) %*% (y - y_hat_cv)
rsq_ridge_cv <- cor(y, y_hat_cv)^2


# Use information criteria to select lambda -----------------------------------
X_scaled <- scale(X)
aic <- c()
bic <- c()
for (lambda in seq(lambdas_to_try)) {
  # Run model
  model <- glmnet(X, y, alpha = 0, lambda = lambdas_to_try[lambda], standardize = TRUE)
  # Extract coefficients and residuals (remove first row for the intercept)
  betas <- as.vector((as.matrix(coef(model))[-1, ]))
  resid <- y - (X_scaled %*% betas)
  # Compute hat-matrix and degrees of freedom
  ld <- lambdas_to_try[lambda] * diag(ncol(X_scaled))
  H <- X_scaled %*% solve(t(X_scaled) %*% X_scaled + ld) %*% t(X_scaled)
  df <- tr(H)
  # Compute information criteria
  aic[lambda] <- nrow(X_scaled) * log(t(resid) %*% resid) + 2 * df
  bic[lambda] <- nrow(X_scaled) * log(t(resid) %*% resid) + 2 * df * log(nrow(X_scaled))
}

# Plot information criteria against tried values of lambdas
plot(log(lambdas_to_try), aic, col = "orange", type = "l",
     ylim = c(190, 260), ylab = "Information Criterion")
lines(log(lambdas_to_try), bic, col = "skyblue3")
legend("bottomright", lwd = 1, col = c("orange", "skyblue3"), legend = c("AIC", "BIC"))

# Optimal lambdas according to both criteria
lambda_aic <- lambdas_to_try[which.min(aic)]
lambda_bic <- lambdas_to_try[which.min(bic)]

# Fit final models, get their sum of squared residuals and multiple R-squared
model_aic <- glmnet(X, y, alpha = 0, lambda = lambda_aic, standardize = TRUE)
y_hat_aic <- predict(model_aic, X)
ssr_aic <- t(y - y_hat_aic) %*% (y - y_hat_aic)
rsq_ridge_aic <- cor(y, y_hat_aic)^2

model_bic <- glmnet(X, y, alpha = 0, lambda = lambda_bic, standardize = TRUE)
y_hat_bic <- predict(model_bic, X)
ssr_bic <- t(y - y_hat_bic) %*% (y - y_hat_bic)
rsq_ridge_bic <- cor(y, y_hat_bic)^2


# See how increasing lambda shrinks the coefficients --------------------------
# Each line shows coefficients for one variables, for different lambdas.
# The higher the lambda, the more the coefficients are shrinked towards zero.
res <- glmnet(X, y, alpha = 0, lambda = lambdas_to_try, standardize = FALSE)
plot(res, xvar = "lambda")
legend("bottomright", lwd = 1, col = 1:6, legend = colnames(X), cex = .7)
