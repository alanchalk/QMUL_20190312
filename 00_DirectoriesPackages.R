# 00_DirectoriesPackages.R

# Author: Alan Chalk
# Date: 10 March 2019

# Purpose: Define directories.  Install / load packages

# Contents:
# 1: Define directories
# 2: Install / load packages

# Sources:
# 


#-------------------------------------------------------------------------------
# 1: Define directories

dirRawData = '../input'
dirRData = '../RData'
dirROutput = '../ROutput'


#-------------------------------------------------------------------------------
# 2: Install / load packages

fn_pkgInstallLoad <- function(x)
{ 
  
  # Install package if needed
  if (!(x %in% rownames(installed.packages())))
  {
    install.packages(x, dep = TRUE)
  }
  
  # Silently load package
  suppressPackageStartupMessages(
    require(x, character.only = TRUE, quietly = TRUE,
            warn.conflicts = FALSE)
  )
} 

packagesToLoad <- c('tidyverse', 'data.table',
                    'glmnet', 'rpart', 'ranger', 'xgboost',
                    'pROC'
                    )

sapply(packagesToLoad, fn_pkgInstallLoad)

# library(tidyverse) 
# library(data.table)
# library(pROC)
# library(glmnet)
# library(ranger)
# library(xgboost)

install.packages('xgboost')

