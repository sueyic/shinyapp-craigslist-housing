# Read data.
citiesdf <- readRDS('data/citiesdf.rds')
str(citiesdf)


# From the summary we can see that sometimes bedrooms and sqft are NA.
summary(citiesdf)


# Lets impute the bedrooms and sqft so that we can use them in model building.
# Amateur alert!!!
# library(Hmisc)
# citiesdf.ar <- aregImpute(~ bedrooms + sqft, data=citiesdf, n.impute=1)
# 
# # Create a new data frame with the imputed bedrooms and sqft.
# citiesdf.imp <- citiesdf
# citiesdf.imp$bedrooms[as.numeric(row.names(citiesdf.ar$imputed$bedrooms))] <- citiesdf.ar$imputed$bedrooms
# citiesdf.imp$sqft[as.numeric(row.names(citiesdf.ar$imputed$sqft))] <- citiesdf.ar$imputed$sqft


# We want to be able to predict (1) price based on city and bedrooms,
# (2) sqft based on city and bedrooms. Lets train a linear model for each.
# Well, at least we're getting p-value < .05 on each.
pricemod <- lm(price ~ city + bedrooms, citiesdf)
summary(pricemod)
saveRDS(pricemod, 'data/pricemod.rds')


sqftmod <- lm(sqft ~ city + bedrooms, citiesdf)
summary(sqftmod)
saveRDS(sqftmod, 'data/sqftmod.rds')
