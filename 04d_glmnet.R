# 04d_glmnet.R

# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: Baseline solution (simplest linear model on basic features)

# Contents:
# Start_: Packages and directories
# 1: Load data
# 2: linear model

# Sources:
# 


#-------------------------------------------------------------------------------
# Start_: Packages and directories

library(tidyverse) 
library(data.table)
library(pROC)
library(glmnet)

dirRawData = '../input'
dirRData = '../RData'
dirROutput = '../ROutput'

# valTest - if val we are training models, if test we are training
# final models on all data and creating a submission

valTest <- 'val' # 'val' or 'test'
#valTest <- 'test' # 'val' or 'test'


#-------------------------------------------------------------------------------
# 1: Load data

load(file = file.path(dirRData, '02a_tbl_all.RData'))
load(file = file.path(dirRData, '02a_vars.RData'))

dt_all <- as.data.table(tbl_all)

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
# Create a glm on basic features

n_train <- length(dt_all[fold_random %in% folds_train, target])
n_test <- length(dt_all[fold_random %in% folds_test, target])

fmla_1 <- paste0("target ~ ", 
                 paste0(vars_toUseOriginal, collapse = " + "))

X_train <- as.matrix(dt_all[fold_random %in% folds_train,
                vars_toUseOriginal, with = FALSE])
X_test <- as.matrix(dt_all[fold_random %in% folds_test,
                            vars_toUseOriginal, with = FALSE])
class(X_train)
dim(X_train)

y_train <- dt_all[fold_random %in% folds_train, target]
y_test <- dt_all[fold_random %in% folds_test, target]

glmnet_1 <- cv.glmnet(X_train,
                      y_train,
                      family = "binomial",
                      nfolds = 5,
                      alpha = 0.975)

print(glmnet_1)
plot(glmnet_1)
coef(glmnet_1)
pred_test <- predict(glmnet_1, 
                     X_test,
                     type = "response")

hist(pred_test)
mean(pred_test)
mean(dt_all[fold_random %in% folds_test, target])

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
            file=file.path(dirROutput, "sub_glmnet_logit.csv"),
            row.names=F)
}

# val:
# LB: 



