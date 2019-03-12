# 02a_ManipulateData.R
# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: EDA on Kaggle: Santander Customer Prediction 2019

# Contents:
# Start_: Load data
# 1: Add folds and concatenate train and test

# Sources:
# 


#-------------------------------------------------------------------------------
# Start_: Load data

# load: dt_train, dt_test
load(file = file.path(dirRData, '01a_dt_train_dt_test.RData'))


#-------------------------------------------------------------------------------
# 1: Add folds and concatenate train and test

# Store column names
colnames(dt_train)
var_id <- "ID_code"
var_target <- "target"
vars_toUseOriginal <- paste0("var_", 0:199)
  
n_train <- dim(dt_train)[1]
n_test <- dim(dt_test)[1]

# Add fold variables

# TODO
# Why do we need folds?
# Why is it important to set the seed?
# What are the required arguments for the sample function to work?
# After creating the fold variables, use the table() function
#   to see the number of examples for each fold.  Is the result
#   in line with what you expected?

set.seed(2019)
dt_train[, fold_random := sample(#put argument here, 
                                 # put argument here, 
                                 replace = TRUE)]

dt_train[, fold_order := rep(1:10, each = n_train/10)]
dt_test[, fold_random := 99]
dt_test[, fold_order := 99]

vars_fold <- c('fold_random', 'fold_order')

# Check for features on one dataset but not the other 

# TODO
# 1. Are there variables in train not in test, or vice verca?
# 2. If so, what are they and does it matter?

setdiff(colnames(dt_train) , colnames(dt_test)) 
setdiff(colnames(dt_test) , colnames(dt_train)) 

# Join train and test
dt_all <- rbind(dt_train, dt_test, fill = TRUE)

# TODO
# 1. How many examples and features are there in dt_all?
# 2. Is this what you expected?


#-------------------------------------------------------------------------------
# End_: Save and gc()

save(dt_all,
     file = file.path(dirRData, '02a_dt_all.RData'))

save(var_id, var_target, vars_toUseOriginal, vars_fold,
     file = file.path(dirRData, '02a_vars.RData'))

rm(dt_train, dt_test, dt_all,
   var_id, var_target, vars_toUseOriginal, vars_fold,
   n_train, n_test)
gc()
