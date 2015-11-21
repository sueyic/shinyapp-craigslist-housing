# Read data.
citiesdf <- readRDS('data/citiesdf.rds')
str(citiesdf)


# From the summary we can see that sometimes bedrooms and sqft are NA.
summary(citiesdf)


# Lets impute the bedrooms and sqft so that we can use them in model building.
# Amateur alert!!!
library(Hmisc)
citiesdf.ar <- aregImpute(~ bedrooms + sqft, data=citiesdf, n.impute=1)

# Create a new data frame with the imputed bedrooms and sqft.
citiesdf.imp <- citiesdf
citiesdf.imp$bedrooms[as.numeric(row.names(citiesdf.ar$imputed$bedrooms))] <- citiesdf.ar$imputed$bedrooms
citiesdf.imp$sqft[as.numeric(row.names(citiesdf.ar$imputed$sqft))] <- citiesdf.ar$imputed$sqft


# We want to be able to predict (1) price based on city and bedrooms,
# (2) sqft based on city and bedrooms. Lets train a linear model for each.
# Well, at least we're getting p-value < .05 on each.
pricemod <- lm(price ~ city + bedrooms, citiesdf)
summary(pricemod)
# 
# Call:
#     lm(formula = price ~ city + bedrooms, data = citiesdf)
# 
# Residuals:
#     Min     1Q Median     3Q    Max 
# -2609   -803   -191    255 159096 
# 
# Coefficients:
#     Estimate Std. Error t value Pr(>|t|)  
# (Intercept)       1634.16     896.50   1.823   0.0688 .
# citykansascity   -1495.90    1004.15  -1.490   0.1367  
# citylosangeles    -185.24    1019.67  -0.182   0.8559  
# cityminneapolis  -1076.38     998.85  -1.078   0.2816  
# citynewyork        -36.42     996.97  -0.037   0.9709  
# cityphiladelphia -1283.21    1001.56  -1.281   0.2005  
# cityseattle       1036.04     999.95   1.036   0.3005  
# citysfbay          577.28    1003.60   0.575   0.5653  
# bedrooms           366.71     231.92   1.581   0.1143  
# ---
#     Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# 
# Residual standard error: 6093 on 702 degrees of freedom
# (89 observations deleted due to missingness)
# Multiple R-squared:  0.0232,	Adjusted R-squared:  0.01207 
# F-statistic: 2.084 on 8 and 702 DF,  p-value: 0.03516
saveRDS(pricemod, 'data/pricemod.rds')


sqftmod <- lm(sqft ~ city + bedrooms, citiesdf)
# summary(sqftmod)
# 
# Call:
#     lm(formula = sqft ~ city + bedrooms, data = citiesdf)
# 
# Residuals:
#     Min      1Q  Median      3Q     Max 
# -1123.4  -305.9  -106.0   132.7 13774.5 
# 
# Coefficients:
#     Estimate Std. Error t value Pr(>|t|)    
# (Intercept)          6.91     169.15   0.041   0.9674    
# citykansascity     131.51     189.21   0.695   0.4874    
# citylosangeles     111.14     194.47   0.571   0.5680    
# cityminneapolis    376.88     188.26   2.002   0.0459 *  
#     citynewyork         34.04     270.83   0.126   0.9000    
# cityphiladelphia    19.46     244.99   0.079   0.9367    
# cityseattle        207.18     182.13   1.138   0.2559    
# citysfbay          350.06     198.12   1.767   0.0779 .  
# bedrooms           474.50      45.10  10.520   <2e-16 ***
#     ---
#     Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# 
# Residual standard error: 1024 on 450 degrees of freedom
# (341 observations deleted due to missingness)
# Multiple R-squared:  0.2241,	Adjusted R-squared:  0.2103 
# F-statistic: 16.24 on 8 and 450 DF,  p-value: < 2.2e-16
saveRDS(sqftmod, 'data/sqftmod.rds')
