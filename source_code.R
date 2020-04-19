#Libaries needed.

library(knitr)
library(readxl)
library(ggplot2)
library(pROC)
library(randomForest)
library(aTSA)

set.seed(11233)

rec_dates <- function(dataset, n){
  # A function for getting the business cycle peak dates from the data.
  dataset = dataset[1:n,]
  idx = dataset[2:n, 8] - dataset[1:(n-1), 8]
  idx = idx < 0
  idx = append(FALSE, idx)
  dataset[idx, 1] 
}

recession <- function(country, path){
  # A function for creating a list with all the models parameters and other relevant information for a given country.
  
  #read data from excel
  MRP_dataset <- read_excel(path, sheet = country)
  n <- nrow(MRP_dataset)-2
  
  #The 15th row is the first none empty row since I need to calcuate the 3 year growth rate.
 
  data <- MRP_dataset[15:n, 4:ncol(MRP_dataset)]
  dates <- MRP_dataset[15:n, 1]
  recDates <- rec_dates(MRP_dataset, n)
  colnames(data) <- c("x1", "x2", "x3", "x4", "rec")
  data$rec <- as.factor(data$rec)
  
  # Out of sample results uses data from Q1 1988 to Q4 2005 to estimate the model parameters. 
  # Next the model parameters are kept constant and used to estimate the probability of recession from Q1 2006 to Q1 2019
  # Note row 70 has the Q4 2005 data.
  
  rfOut <- randomForest(rec ~ ., data=data, subset = 1:70)
  predrfOut <- predict(rfOut, newdata = data[71:(n-14),], type = "vote") 
  
  glmOut <-  glm(rec ~ x1 + x2 + x3 + x4, family = binomial(link = "probit"), 
                   data = data[1:70,], maxit = 1000)
  
  predProbOut <- predict(glmOut, newdata = data[71:(n-14),], type = "response")
  
  rfIn <- randomForest(rec ~ ., data=data)
 
  glmIn <-  glm(rec ~ x1 + x2 + x3 + x4, family = binomial(link = "probit"), data = data, maxit = 1000)
  
  res <- list(dates, recDates, data$rec, rfOut, predrfOut, glmOut, predProbOut, rfIn, glmIn, country, n)
  
  names(res) <- c("dates", "peakDates", "recession", "rfOut", "predrfOut", 
                  "glmOut", "predProbOut", "rfIn", "glmIn", "nation", "n")
  
  res
}

plotRec.out <- function(country){
  # A function for plotting the out of sample probability of recession for a given country using both a probit and random forest.
  par(pty = "m")
  
  plot(country$dates[71:(country$n - 14),1], country$predProbOut, type = "l",
       main = paste("Probability of Recession within next 12 month for", country$nation, "(out of sample)"), 
       ylab = "Probability", xlab = "Dates", col = "blue", lwd=3, ylim=range(c(0,1)))
  
  abline(v = c(country$peakDates$`Observation date`), col = "red", lwd=3)
  
  par(new = TRUE)
  
  plot(country$dates[71:(country$n - 14),1], country$predrfOut[,2], type = "l",
       col = "green", xlab = "", ylab = "", axes = F, lwd=3)

  legend("topright", legend=c("Probit Regression", "business cycle peak", "Random Forest"), 
         col=c("blue", "red", "green"), lwd=3)
  
  par(new = FALSE)     
}

plotRec.in <- function(country){
  # A function for plotting the in sample probability of recession for a given country using both a probit and random forest.
  
  par(pty = "m")
  
  plot(country$dates, country$glmIn$fitted.values, type = "l",
       main = paste("Probability of Recession within next 12 month for", country$nation, "(in sample)"), 
       ylab = "Probability", xlab = "Dates", col = "blue", lwd=3, ylim=range(c(0,1)))
  
  abline(v = c(country$peakDates$`Observation date`), col = "red", lwd=3)
  
  par(new = TRUE)
  
  plot(country$dates, country$rfIn$votes[,2], type = "l",
       col = "green", xlab = "", ylab = "", axes = F, lwd=3)
  
  legend("topright", legend=c("Probit Regression", "business cycle peak", "Random Forest"), 
         col=c("blue", "red", "green"), lwd=3)
  
  par(new = FALSE)
}

plotAUC.in <- function(country){
  #A function for plotting the in sample AUC curve for the probit and random forest model.
  
  par(pty = "s")
  
  roc(country$recession, country$glmIn$fitted.values, plot=TRUE, 
      legacy.axes=TRUE, percent=TRUE, xlab="False Positive Percentage", 
      ylab="True Postive Percentage", main = paste("ROC curve for" , country$nation, "(in sample)"),
      col="blue", lwd=4, print.auc=TRUE, direction = "<") 
  
  plot.roc(country$recession, country$rfIn$votes[,2], percent=TRUE, col="green", 
           lwd=4, print.auc=TRUE, add=TRUE, print.auc.y=40, direction = "<")
  
  legend("bottomright", legend=c("Probit Regression", "Random Forest"), col=c("blue", "green"), lwd=4)
}

plotAUC.out <- function(country){
  #A function for plotting the out of sample AUC curve for the probit and random forest model.
  
  par(pty = "s")
  
  roc(country$recession[71:(country$n - 14)], as.numeric(country$predProbOut), plot=TRUE, 
      legacy.axes=TRUE, percent=TRUE, xlab="False Positive Percentage", 
      ylab="True Postive Percentage", col="blue", lwd=4, direction = "<",
      main = paste("ROC curve for" , country$nation, "(out of sample)"), print.auc=TRUE)
  
  plot.roc(country$recession[71:(country$n - 14)], country$predrfOut[,2], percent=TRUE, col="green", 
           lwd=4, print.auc=TRUE, add=TRUE, print.auc.y=40, direction = "<")
  
  legend("bottomright", legend=c("Probit Regression", "Random Forest"), col=c("blue", "green"), lwd=4)
}

plotAll <- function(country, path){
  #A function for creating all the plots for a given country.
  
  rec <- recession(country, path)
  
  plotRec.in(rec)
  plotRec.out(rec)
  plotAUC.in(rec)
  plotAUC.out(rec) 
}

plotAllNations <- function(countries, path){
  #A function for plotting all the countries in the countries variable.
  
  for (country in countries){
    plotAll(country, path)
  }
}
