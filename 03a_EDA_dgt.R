# 03a_EDA.R

# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: EDA on Kaggle: Santander Customer Prediction 2019

# Contents:
# 1: Load data
# 2: EDA

# Sources:
# https://www.kaggle.com/psystat/simple-eda-logistic-regression-speedglm-with-r
# https://www.kaggle.com/gpreda/santander-eda-and-prediction


#-------------------------------------------------------------------------------
# 1: Load data

load(file = file.path(dirRData, '02a_dt_all.RData'))
load(file = file.path(dirRData, '02a_vars.RData'))

#-------------------------------------------------------------------------------
# numbers of examples and features

dim(dt_all[fold_order != 99])
dim(dt_all[fold_order == 99])


#-------------------------------------------------------------------------------
# view a sample of the data

head(dt_all)
tail(dt_all)

# train data contains 
# - ID_code (string)
# - target 0 /1
# - 200 numeric variables: var_- to var_199

# test data contains the same but no target


#-------------------------------------------------------------------------------
# check for missing values

dt_all %>%
  summarise_all(list(~sum(is.na(.))))

# TODO
# 1. In the result above, why is target missing 200,000 times?
# 2. Are there any other missing values?  Does this mean there
#    is no missing data?


#-------------------------------------------------------------------------------
# What proportion of examples have target = 1?

dt_all %>%
  filter(fold_random != 99) %>%
  ggplot(aes(x = factor(target), fill = factor(target))) +  
  geom_bar(aes(y = (..count..)/sum(..count..))) +
  xlab("target") + ylab("% of examples")


#-------------------------------------------------------------------------------
# Density plots of features

feature_groups <- 1:10
col_names <- c('target', vars_toUseOriginal[feature_groups])

dt_temp <- gather(dt_all[fold_random %in% 7:8, col_names, with=F], 
                  key="features", 
                  value="value",
                  -target) %>%
  as.data.table()

dt_temp[, target := factor(target)]
dt_temp[, features := factor(features, 
                             levels=col_names[-1], 
                             labels=col_names[-1])]

pdf(file.path(dirROutput, '03a_density_target.pdf'))

ggplot(data = dt_temp, aes(x = value)) +
  geom_density(aes(fill = target, color = target), alpha = 0.3) +
  scale_color_manual(values = c("1" = "dodgerblue", 
                                "0" = "firebrick1")) +
  facet_wrap(~ features, ncol = 4, scales = "free")

dev.off()


#-------------------------------------------------------------------------------
# compare density train and test 

# TODO:
# 1. What do we hope to see when we compare density plots of 
#    for features, between train and test


feature_groups <- 1:5
col_names <- c("fold_random", vars_toUseOriginal[feature_groups])

dt_temp <- gather(dt_all[fold_random %in% c(7, 99), col_names, with=F], 
                  key="features", 
                  value="value",
                  -fold_random) %>%
  as.data.table()
dt_temp[, key := factor(ifelse(fold_random == 99, "train", "test"))]

dt_temp[, features := factor(features, 
                             levels=col_names[-1], 
                             labels=col_names[-1])]

pdf(file.path(dirROutput, '03a_density_train_test.pdf'))

ggplot(data = dt_temp, aes(x = value)) +
  geom_density(aes(fill = key, color = key), alpha = 0.3) +
  scale_color_manual(values = c("train" = "dodgerblue",
                                "test" = "firebrick1")) +
  facet_wrap(~ features, ncol = 2, scales = "free")

dev.off()


#-------------------------------------------------------------------------------
# have some missing values been imputed
# look at most frequent values 

var_this <- 'var_108'; train_value <- 14.1999;

dt_temp <- copy(dt_all[fold_random != 99,
                       c("target", var_this),
                       with = FALSE])
setnames(dt_temp, var_this, "var_this")
var_breaks <- quantile(dt_temp$var_this,
                          probs = seq(0, 1, by = 0.1))
var_breaks <- unique(sort(c(train_value, unname(var_breaks))))
dt_temp[, var_qq := cut(var_this, 
                           breaks=var_breaks,
                           labels = 1:(length(var_breaks) - 1),
                           include.lowest=TRUE)]

dt_temp %>% 
  group_by(var_qq) %>% 
  summarise(average = mean(target),
            var_this = mean(var_this)) %>%
  ggplot(aes(x = var_this, y = average)) + 
  geom_line() +
  xlab(var_this) + ylab("target %") + 
  geom_vline(xintercept = train_value, linetype = "dashed")





