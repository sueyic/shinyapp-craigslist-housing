library(ggplot2)

pricemod <- readRDS('data/pricemod.rds')
sqftmod <- readRDS('data/sqftmod.rds')

shinyServer(function(input, output) {

    getPredPrice <- reactive({
        test <- data.frame(city=input$selCity, bedrooms=as.numeric(input$selBedrooms))
        prediction <- predict(pricemod, newdata = test)
    })

    getPredSize <- reactive({
        test <- data.frame(city=input$selCity, bedrooms=as.numeric(input$selBedrooms))
        prediction <- predict(sqftmod, newdata = test)
    })

    output$predictedPrice <- renderText(paste0('$ ', round(getPredPrice(), 2)))

    output$predictedSize <- renderText(paste0(round(getPredSize(), 2), ' sqft'))

    output$predictedPricePerSize <- renderText({
        paste0(round(getPredPrice() / getPredSize(), 2), ' $/sqft')
    })
})
