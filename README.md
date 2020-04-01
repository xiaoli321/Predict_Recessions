# Predicting Recessions for the G7 Countries using a Random Forest #

## Introduction ##

This project compare the ability of a probit and a random forest model in predicting recessions. The explaintory variables of the model include variables term spread (10 yield - 3 month yield), Debt Service Ratio, Priavate Credit to GDP and the house price to rent ratio. The main idea of the model is that where there is a high level of debt (Private Credit to GDP) and a overvaluation of assets that serves as collateral (House price to rent ratio) then if consumer cannot afford to pay their loans (Debt Service Ratio) a finanical crisis will ensue. Since a recession almost always follows a financial crisis, thus by predicting finacial crisis, one can predict recessions. In addition, the term spread is also used since it has been should to be a good predictor of recession.

The AUROC criterion is used to gauage the performance of the probit and random forest models. Both model have an average AUROC of over 90% in sample for the G7 countries. However out of sample the random forest model has an average AUROC of 79% while the probit model has an average of 61%.

The reason the random forest model signifcently outperforms the probit model out of sample is because the ramdom forest uses a bootstraped sample of the original sample, thus reducing overfitting. Also since many of the explaintory variables behave similarly (ie. spike prior to a recession) the probit model suffers from multicollinarity which results in poor out of sample results. Meanwhile, since the random forest is not regression based, it does not suffer from issues like multicollinarity or spurious regression.  

## Dataset ##
Dataset for model can be found here -> https://drive.google.com/open?id=1UbXGOyE6pCyRZ3eupC5EUv3D5e7sI4tD

Note that model makes estimations in real time. Some variables like Private credit to GDP are released with a 2 quarter lag.

## Addtional details of the model ##
Additional details of the model can be found here -> https://drive.google.com/open?id=1nfTctQ92lN3OmjJmkhKej8UWyXWGVgMF

## Example and source code output ##

Example and output of source code can be found on page 5 of the following link -> https://drive.google.com/open?id=1khGxfK3zJV-UkVRZdBmriNJUlIOG1thv

