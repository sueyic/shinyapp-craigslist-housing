library(shiny)
library(DT)

cities <- readRDS('data/cities.rds')
cityChoices = list()
for(c in cities) { cityChoices[[c]] = c }

bedroomChoices = as.list(1:4)

shinyUI(fluidPage(
    
    # Application title
    titlePanel("Apartment price and size predictor"),
    
    # Sidebar
    sidebarLayout(
        sidebarPanel(
            p("This app will predict the apartment price (USD) and size (sqft) for a given city and desired number of bedrooms."),
            
            p("The data is trained from craigslist postings in the 'apts/housing' category, 100 posts from each of several cities. Only several cities are supported. A writeup for how the models were made is available on github here.")
        ),
        

        mainPanel(
            h2('Select your desired city and number of bedrooms'),
            
            selectInput("selCity", label = h3("Select city"), 
                        choices = cityChoices, selected = cityChoices[[1]]),

            selectInput("selBedrooms", label = h3("Select number of bedrooms"), 
                        choices = bedroomChoices, selected = 1),
            
            hr(),
            
            p(
                span('Predicted price (USD): '),
                textOutput('predictedPrice')
            ),

            p(
                span('Predicted size (sqft): '),
                textOutput('predictedSize')
            )
            
        )
    )
))