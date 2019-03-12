# 04h_xgboost.R

# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: xgboost

# Contents:
# Start_: Load data and run parameters
# 1. xgboost: fit the model
# 2. xgboost: predictions


# Sources:
# 


# 04f_DecisionTree.R

# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: decision tree

# Contents:
# Start_: Load data and run parameters
# 1. First tree
# 2. Optimal complexity of decision trees
# 3. fit train and predict rpart on all features 


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

dt_train <- dt_all[fold_random %in% folds_train, 
                   c(vars_toUseOriginal, "target"),
                   with = FALSE]
dt_test <- dt_all[fold_random %in% folds_test, 
                  c(vars_toUseOriginal, "target"),
                  with = FALSE]
n_train <- dim(dt_train)[1]
n_test <- dim(dt_test)[1]

trainX <- dt_train[, vars_toUseOriginal, with = F]
testX <- dt_test[, vars_toUseOriginal, with = F]

# preparing XGB matrix
dtrain <- xgb.DMatrix(data = as.matrix(trainX), 
                      label = dt_train$target)

# parameters
params <- list(booster = "gbtree",
               objective = "binary:logistic",
               eta=0.02,
               #gamma=80,
               max_depth=2,
               min_child_weight=1, 
               subsample=0.5,
               colsample_bytree=0.1,
               scale_pos_weight = round(sum(!trainY) / sum(trainY), 2))

# CV
set.seed(123)
xgbcv <- xgb.cv(params = params, 
                data = dtrain, 
                nrounds = 30000, 
                nfold = 5,
                showsd = F, 
                stratified = T, 
                print_every_n = 100, 
                early_stopping_rounds = 500, 
                maximize = T,
                metrics = "auc")

cat(paste("Best iteration:", xgbcv$best_iteration))

# train final model
set.seed(123)
xgb_model <- xgb.train(
  params = params, 
  data = dtrain, 
  nrounds = xgbcv$best_iteration, 
  print_every_n = 100, 
  maximize = T,
  eval_metric = "auc")

#view variable importance plot
imp_mat <- xgb.importance(feature_names = colnames(trainX), model = xgb_model)
xgb.plot.importance(importance_matrix = imp_mat[1:30])

pred_test <- predict(xgb_model, newdata=as.matrix(testX), type="response")

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
            file=file.path(dirROutput, "sub_xgboost.csv"),
            row.names=F)
}





