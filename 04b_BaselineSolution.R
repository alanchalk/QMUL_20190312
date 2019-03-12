# 04b_BaselineSolution.R

# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: Baseline solution (simplest linear model on basic features)

# Contents:
# Start_: Load data and run parameters
# 1. Linear model: fit the model
# 2. Linear model: predictions

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
# 1. Linear model: fit the model

# Create a simple linear model on basic features

n_train <- length(dt_all[fold_random %in% folds_train, target])
n_test <- length(dt_all[fold_random %in% folds_test, target])

fmla_1 <- paste0("target ~ ", 
                 paste0(vars_toUseOriginal, collapse = " + "))

lm_1 <- lm(fmla_1, data = dt_all[fold_random %in% folds_train])
summary(lm_1)

# TODO
# For the questions below you can inspect the model with
# summary(lm_1) and the coefficients with coef(lm_1)
# 1. Are there any features which are not "important" in the model.
# 2. What is the average coefficient?
# 3. Plot the coefficients (but not the intercept).
# 4. What is the feature with the biggest (absolute) coefficient? 
#    You can use which.max()
#    Is this the most important feature in the model? 


#-------------------------------------------------------------------------------
# 2. Linear model: predictions

pred_test <- predict(lm_1, dt_all[fold_random %in% folds_test])

# TODO
# 1. Create a histogram of the predictions
# 2. Do the predictions lie between 0 and 1?  
#    Should they?
#    Does it matter if they do not?
# 3. What is the mean prediction?  Is it "correct"?  If not, why not?

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
            file=file.path(dirROutput, "sub_lm.csv"),
            row.names=F)
}

# train
# val: 0.867
# LB: 
