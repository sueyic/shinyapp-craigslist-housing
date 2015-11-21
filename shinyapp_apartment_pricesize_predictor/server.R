library(ggplot2)

pricemod <- readRDS('data/pricemod.rds')
sqftmod <- readRDS('data/sqftmod.rds')

shinyServer(function(input, output) {
    
    
    output$predictedPrice <- renderText({
        test <- data.frame(city=input$selCity, bedrooms=as.numeric(input$selBedrooms))
        predict(pricemod, newdata = test)
    })
    output$predictedSize <- renderText({
        test <- data.frame(city=input$selCity, bedrooms=as.numeric(input$selBedrooms))
        predict(sqftmod, newdata = test)
    })
})
