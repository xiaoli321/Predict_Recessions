# Predicting Recessions for the G7 Countries with Machine Learning #

## Introduction ##

This project compare the ability of a probit and a random forest model in predicting recessions 12 months ahead. The explaintory variables of the model are the term spread (10 yield - 3 month yield), Debt Service Ratio, Priavate Credit to GDP and the house price to rent ratio. The main idea of the model is that when there is a high level of debt (Private Credit to GDP) and a overvaluation of assets that serves as collateral (House price to rent ratio) then if consumer cannot afford to pay their loans (Debt Service Ratio) a finanical crisis will ensue. Since a recession almost always follows a financial crisis, thus by predicting finacial crisis, one can predict recessions. In addition, the term spread is also used since it has been shown to be a good predictor of recession.

Recession dates are defined using the Economic Cycle Research Institute (ECRI) dates for business cycle peaks and troughs.

The AUROC criterion is used to gauage the performance of the probit and random forest models. Both model have an average AUROC of over 90% in sample for the G7 countries. However, out of sample, the random forest model has an average AUROC of 79% while the probit model has an average of 61%.

The random forest model signifcently outperforms the probit model out of sample because the ramdom forest uses a bootstraped sample of the original sample, thus reducing overfitting. Also, many of the explaintory variables behave similarly (ie. spike prior to a recession). Thus, the probit model suffers from multicollinarity resulting in poor out of sample results. Meanwhile, the random forest is not regression based, so it does not suffer from issues like multicollinarity or spurious regression.  

## In Sample Result for USA ##

![plot](https://github.com/xiaoli321/Predict_Recessions/blob/master/images/image.png?raw=true)

_Model parameters estimated using data from Q1 1988 - Q1 2019._

_Out of Sample Results for the US and results for other G7 countries can be found in the links below._

## Results for other G7 countries ##

Additional results can be found here -> https://drive.google.com/open?id=1ORYaAcCYyxFyZ5wVra2ARjGm-4m51MSK

## Dataset ##
Dataset for model can be found here -> https://drive.google.com/open?id=1UbXGOyE6pCyRZ3eupC5EUv3D5e7sI4tD

## Instructions on using this model ##

1. Download the dataset for the model.
2. Save the `source_code.R` file and open it in R.
3. Save the path where the dataset is stored in R e.g. `path <- "C:/Users/..."` .
4. Create a vector in R with all the G7 countries you are interested in e.g. `countries <- c("CAN", "USA", "UK")` .
5. Use the `plotNations` function to plot the probability of recession graphs e.g. `plotNations(countries, path)` .

## Additional details of the model ##
Additional details of the model can be found here -> https://drive.google.com/open?id=1FflmT5IRhrdnuuJlBLJJJszvv45b3SoH



