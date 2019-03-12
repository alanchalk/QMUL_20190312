# 01a_ReadRawData.R
# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: Read raw data only. Data manipulation done later.

# Contents:
# 1: Load data
# End_: Save and gc()

# Sources:
# 


#-------------------------------------------------------------------------------
# 1: Load data

dt_train <- fread(file.path(dirRawData, "train.csv"))
dt_test  <- fread(file.path(dirRawData, "test.csv"))

# TODO:
# 1. What is the class of dt_train?
# 2. How many examples and features are in each dataset?


#-------------------------------------------------------------------------------
# End_: Save and gc()

save(dt_train, dt_test,
     file = file.path(dirRData, '01a_dt_train_dt_test.RData'))

#rm(dt_train, dt_test)
gc()
