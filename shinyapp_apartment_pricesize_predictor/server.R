library(ggplot2)

pricemod <- readRDS('data/pricemod.rds')
sqftmod <- readRDS('data/sqftmod.rds')

shinyServer(function(input, output) {
    
    
    output$predictedPrice <- renderText({
        test <- data.frame(city=input$selCity, bedrooms=as.numeric(input$selBedrooms))
        prediction <- predict(pricemod, newdata = test) 
        paste0('$ ', round(prediction, 2))
    })
    output$predictedSize <- renderText({
        test <- data.frame(city=input$selCity, bedrooms=as.numeric(input$selBedrooms))
        prediction <- predict(sqftmod, newdata = test)
        paste0(round(prediction, 2), ' sqft')
    })
})
