# 04a_NaiveSolution.R

# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: Naive solution

# Contents:
# Start_: Load data and run parameters
# 1: Naive solution

# Sources:
# 


#-------------------------------------------------------------------------------
# Start_: Load data and run parameters

# valTest - if val we are training models and estimating performance,
# if test we are training final models on all data and creating 
# a submission

set.seed(2019)
valTest <- 'val' # 'val' or 'test'
#valTest <- 'test' # 'val' or 'test'

load(file = file.path(dirRData, '02a_dt_all.RData'))
load(file = file.path(dirRData, '02a_vars.RData'))


if (valTest == 'val'){
  folds_train = 7:8
  folds_test = 9
} else if (valTest == 'test'){
  folds_train = 7:9
  folds_test = 99
} else {
  folds_train = NULL
  folds_test = NULL
  
}


#-------------------------------------------------------------------------------
# 1: Naive solution

# Create a naive solution, e.g. prediction is a random number generated 
# from a normal distribution with mean equal to train data

n_train <- length(dt_all[fold_random %in% folds_train, target])
n_test <- length(dt_all[fold_random %in% folds_test, target])
target_mean <- mean(dt_all[fold_random %in% folds_train, target])

## TODO
# Create pred_test as the target mean plus a random normal variate
# with mean of 0 and standard deviation of 0.1 
# Use the function rnorm()

pred_test <- target_mean + rnorm(PUT PARAMETERS HERE)

if (valTest == 'val'){
  # find AUC on validation data
  dt_val <- dt_all[fold_random %in% folds_test, list(ID_code, target)]
  dt_val[, pred := pred_test]
  val_auc <- pROC::auc(dt_val$target, dt_val$pred)
  print(paste0('validation auc: ',  round(as.numeric(val_auc), 3)))
} else if (valTest == 'test') {
  submission <- read.csv("../input/sample_submission.csv")
  submission$target <- pred_test
  write.csv(submission, 
            file=file.path(dirROutput, "sub_naive.csv"),
            row.names=F)
}

# train: 0.505
# LB: 0.501
