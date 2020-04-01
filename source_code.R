#Libaries needed.

library(knitr)
library(readxl)
library(ggplot2)
library(pROC)
library(randomForest)
library(aTSA)

set.seed(11233)


# A function for getting the business cycle peak dates from the data.

  rec_dates <- function(dataset){
    dataset = dataset[1:137,]
    idx = dataset[2:137, 8] - dataset[1:136,8]
    idx = idx < 0
    idx = append(FALSE, idx)
    dataset[idx, 1]
    
  }

# A function for creating a list with all the models parameters and other relevant information for a given country. 

recession <- function(country, path){
  
  #read data from excel
  MRP_dataset <- read_excel(path, sheet = country)
  
  #orgaizing the data
  data <- MRP_dataset[15:137, 4:ncol(MRP_dataset)]
  dates <- MRP_dataset[15:137, 1]
  recDates <- rec_dates(MRP_dataset)
  colnames(data) <- c("x1", "x2", "x3", "x4", "rec")
  data$rec <- as.factor(data$rec)
  
  #out of sample results
  
    #Random forest
  rfOut <- randomForest(rec ~ ., data=data, subset = 1:70)
  
  predrfOut <- predict(rfOut, newdata = data[71:123,], type = "vote") 
  
    #Probit
  glmOut <-  glm(rec ~ x1 + x2 + x3 + x4, family = binomial(link = "probit"), 
                   data = data[1:70,], maxit = 1000)
  
  
  predProbOut <- predict(glmOut, newdata = data[71:123,], type = "response")
  
  #in sample results
  
    #Random forest
  rfIn <- randomForest(rec ~ ., data=data)
  
    #Probit
  glmIn <-  glm(rec ~ x1 + x2 + x3 + x4, family = binomial(link = "probit"), data = data, maxit = 1000)
  
  res <- list(dates, recDates, data$rec, rfOut, predrfOut, glmOut, predProbOut, rfIn, glmIn, country)
  
  names(res) <- c("dates", "peakDates", "recession", "rfOut", "predrfOut", 
                  "glmOut", "predProbOut", "rfIn", "glmIn", "nation")
  
  res
  
}


# A function for plotting the out of sample probability of recession for a given country using both a probit and random forest.

plotRec.out <- function(country){
  # out of sample predictions
  
    #probability graphs
      
      #probit graph
  
  par(pty = "m")
  
  plot(country$dates[71:123,1], country$predProbOut, type = "l",
       main = paste("Probability of Recession within next 12 month for", country$nation, "(out of sample)"), 
       ylab = "Probability", xlab = "Dates", col = "blue", lwd=3, ylim=range(c(0,1)))
  
  abline(v = c(country$peakDates$`Observation date`), col = "red", lwd=3)
  
  par(new = TRUE)
  
      # random forest graph
  
  plot(country$dates[71:123,1], country$predrfOut[,2], type = "l",
       col = "green", xlab = "", ylab = "", axes = F, lwd=3)

  legend("topright", legend=c("Probit Regression", "business cycle peak", "Random Forest"), 
         col=c("blue", "red", "green"), lwd=3)
  
  par(new = FALSE)
  
      
}

# A function for plotting the in sample probability of recession for a given country using both a probit and random forest.

plotRec.in <- function(country){
  # in sample predictions
  
    #probability graphs
      
      #probit graph
  par(pty = "m")
  
  plot(country$dates, country$glmIn$fitted.values, type = "l",
       main = paste("Probability of Recession within next 12 month for", country$nation, "(in sample)"), 
       ylab = "Probability", xlab = "Dates", col = "blue", lwd=3, ylim=range(c(0,1)))
  
  abline(v = c(country$peakDates$`Observation date`), col = "red", lwd=3)
  
  par(new = TRUE)
  
      # random forest graph
  
  plot(country$dates, country$rfIn$votes[,2], type = "l",
       col = "green", xlab = "", ylab = "", axes = F, lwd=3)
  
  legend("topright", legend=c("Probit Regression", "business cycle peak", "Random Forest"), 
         col=c("blue", "red", "green"), lwd=3)
  
  par(new = FALSE)
  
      
}

#A function for plotting the in sample AUC curve for the probit and random forest model.

plotAUC.in <- function(country){
  
  par(pty = "s")
  
  roc(country$recession, country$glmIn$fitted.values, plot=TRUE, 
      legacy.axes=TRUE, percent=TRUE, xlab="False Positive Percentage", 
      ylab="True Postive Percentage", main = paste("ROC curve for" , country$nation, "(in sample)"),
      col="blue", lwd=4, print.auc=TRUE, direction = "<") 
  
  plot.roc(country$recession, country$rfIn$votes[,2], percent=TRUE, col="green", 
           lwd=4, print.auc=TRUE, add=TRUE, print.auc.y=40, direction = "<")
  
  legend("bottomright", legend=c("Probit Regression", "Random Forest"), col=c("blue", "green"), lwd=4)
}


#A function for plotting the out of sample AUC curve for the probit and random forest model.

plotAUC.out <- function(country){
  
  par(pty = "s")
  
  roc(country$recession[71:123], as.numeric(country$predProbOut), plot=TRUE, 
      legacy.axes=TRUE, percent=TRUE, xlab="False Positive Percentage", 
      ylab="True Postive Percentage", col="blue", lwd=4, direction = "<",
      main = paste("ROC curve for" , country$nation, "(out of sample)"), print.auc=TRUE)
  
  plot.roc(country$recession[71:123], country$predrfOut[,2], percent=TRUE, col="green", 
           lwd=4, print.auc=TRUE, add=TRUE, print.auc.y=40, direction = "<")
  
  legend("bottomright", legend=c("Probit Regression", "Random Forest"), col=c("blue", "green"), lwd=4)
}



#A function for creating all the plots for a given country.

plotAll <- function(country, path){
  rec <- recession(country, path)
  
  plotRec.in(rec)
  plotRec.out(rec)
  plotAUC.in(rec)
  plotAUC.out(rec)
      

}
