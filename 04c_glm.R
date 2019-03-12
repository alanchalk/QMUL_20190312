# 04c_glm.R

# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: Baseline solution (simplest linear model on basic features)

# Contents:
# Start_: Load data and run parameters
# 1. glm: fit the model
# 2. glm: predictions

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

n_train <- length(dt_all[fold_random %in% folds_train, target])
n_test <- length(dt_all[fold_random %in% folds_test, target])


#-------------------------------------------------------------------------------
# 1. glm: fit the model

fmla_1 <- paste0("target ~ ", 
                 paste0(vars_toUseOriginal, collapse = " + "))

glm_1 <- glm(fmla_1, 
             family = binomial(link = "logit"),
             data = dt_all[fold_random %in% folds_train])
summary(glm_1)


#-------------------------------------------------------------------------------
# 1. glm: predictions

pred_test <- predict(glm_1, 
                     dt_all[fold_random %in% folds_test],
                     type = "response")

# TODO
# 1. Create a histogram of the predictions
# 2. Do the predictions lie between 0 and 1?  


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
            file=file.path(dirROutput, "sub_glm_logit.csv"),
            row.names=F)
}

# train: 0.866
# LB: 0.86 (same as lm)



