# Craigslist housing data

A project looking at craigslist posts in the "apts/housing" section.

Contents:

- `shinyapp_craigslist_housing_browser`: This is a shiny app to browse recent "apts/housing" posts of several cities and show summary plots. This is where I started. It turned to run a bit slowly.

- `data_processing`: Scripts to download recent "apts/housing" posts of several cities from craigslist and use them to build a couple linear models: (1) Use city and #bedrooms to predict price of apartment, (2) Use city and #bedrooms to predict size of apartment. [Link to writeup](https://github.com/sueyic/shinyapp-craigslist-housing/blob/master/data_processing/data_processing_report.pdf)

- `shinyapp_apartment_pricesize_predictor`: A shiny app that lets the user enter city and desired number of bedrooms, and uses the models to return a predicted price (USD) and size (sqft). Deployed at [https://sueyic.shinyapps.io/shinyapp_apartment_pricesize_predictor](https://sueyic.shinyapps.io/shinyapp_apartment_pricesize_predictor)

