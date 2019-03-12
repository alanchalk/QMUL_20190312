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


#-------------------------------------------------------------------------------
# 1. first tree

# TO DO
# rpart is the function which will fit our first 
#   Recurstive PARTitioning tree.
# a. Below, enter a formula allowing 'target' to depend on the first
#    five features and submit the code.

rpart_1 <-  rpart(enter the formula here, 
                  data = dt_train,
                  method = "anova",
                  cp = 1e-3)


# TO DO
# b. Use rpart.plot to plot the tree

rpart.plot(rpart_1)


# TO DO
# c. Set cp much lower to 1e-5 produce a more complex tree and plot it
#    to a file (not to your screen)


rpart_2 <-  rpart(enter the formula here, 
                  data = dt_train,
                  method = "anova",
                  cp = enter cp here)

pdf(file.path(dirROutput, '04f_tree_2.pdf'))
rpart.plot(rpart_2)
dev.off()

# TODO
# 1. Inspect the pdf produced above.  Is it useful?
# 2. Are decision trees interpretable or a black box?


#-------------------------------------------------------------------------------
# 2. Optimal complexity of decision trees

# What is the AUC on validation data of rpart_2
pred_test = predict(rpart_2, dt_test)
dt_val <- dt_all[fold_random %in% folds_test, list(ID_code, target)]
dt_val[, pred := pred_test]
val_auc <- pROC::auc(dt_val$target, dt_val$pred)
print(paste0('validation auc: ',  round(as.numeric(val_auc), 3)))

# TODO:
# 1. Is the AUC for rpart_2 good?  Why not?


# Run the code below to see how performance of the decision tree
# varies with its complexity.

dt_rpart_2_cptable <- rpart_2$cptable %>%
  as_tibble %>%
  rename('rel_error' = 'rel error') %>%
  mutate(complexity = log(nsplit + 1)) %>%
  dplyr::select(complexity, rel_error, xerror) %>%
  gather(key="train_test", 
         value="loss",
         -complexity) %>%
  as.data.table()

dt_rpart_2_cptable %>%
  ggplot(aes(x = complexity, y = loss, col = train_test)) +
  geom_line()

# TODO
# 1. Explain the concepts of bias and variance.


# Run the code below to prune the tree to optimal complexity

idx_cp_optimal <- which.min(rpart_2$cptable[,4])
cp_optimal <- rpart_2$cptable[idx_cp_optimal, 1]
rpart_3 <- prune(rpart_2, cp = cp_optimal)

pred_test = predict(rpart_3, dt_test)
dt_val <- dt_all[fold_random %in% folds_test, list(ID_code, target)]
dt_val[, pred := pred_test]
val_auc <- pROC::auc(dt_val$target, dt_val$pred)
print(paste0('validation auc: ',  round(as.numeric(val_auc), 3)))

# TODO
# 1. Is the AUC of the pruned tree on test data better than 
#    the none pruned tree?
# 2. Is it a good AUC compared to our baseline?  If not, why not?


#-------------------------------------------------------------------------------
# 3. fit train and predict rpart on all features 

# TODO
# 1. Fit a rpart tree with the full formula given below 
#    Use a cp of 1e-3
# 2. Prune it
# 3. Calculate predictions and find the AUC on test data
# 4. Is the resulting AUC good?

fmla_1 <- paste0("target ~ ", 
                 paste0(vars_toUseOriginal, collapse = " + "))

rpart_4 <- rpart(#formula here, 
                  data = dt_train,
                  method = "anova",
                  cp = #enter cp here,
                  maxsurrogate = 0)

idx_cp_optimal <- 
cp_optimal <- 
rpart_5 <- 

pred_test = predict(rpart_5, dt_test)

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
            file=file.path(dirROutput, "sub_rpart.csv"),
            row.names=F)
}




