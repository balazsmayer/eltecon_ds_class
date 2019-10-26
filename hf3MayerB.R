#Mayer Balázs hf3

library(knitr)
library(data.table)
library(ggplot2)
library(magrittr)
library(purrr)

#adatbehívás
dt <- fread("data/heart.csv")

#Feladat
       
       aggr_dt <- dt[, 
                     .(target_rate = sum(target)/ sum(fbs),
                       num_fbs = sum(fbs),
                       num_target = sum(target)),
                     by = group]
       
       mc_samples <- aggr_dt[,
                             .(target_rate_mc = rbinom(10000, num_fbs, target_rate)/num_target,
                               N=1:10000),
                             by = .(group)
                             ]%>%
         dcast(N ~ group, value.var = "open_rate_mc")
       mc_samples[, uplift := treatment / control - 1 ]
       
       CI_higher <- quantile(mc_samples$uplift, 0.975)
       CI_lower <- quantile(mc_samples$uplift, 0.025)
       
       ggplot(mc_samples, aes(x=uplift)) +
         geom_histogram()+
         geom_vline(xintercept = CI_lower, color = "red")+
         geom_vline(xintercept = CI_higher, color = "blue")