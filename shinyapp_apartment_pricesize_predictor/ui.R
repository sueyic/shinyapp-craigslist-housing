library(shiny)
library(DT)

cities <- readRDS('data/cities.rds')
cityChoices = list()
for(c in cities) { cityChoices[[c]] = c }

bedroomChoices = as.list(1:4)

shinyUI(fluidPage(

    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),

    # Application title
    titlePanel("Apartment price and size predictor"),

    # Sidebar
    sidebarLayout(
        sidebarPanel(
            p("This app will predict the apartment price (USD) and size (sqft) for a given city and desired number of bedrooms."),

            p(
                span("The data is trained from craigslist postings in the 'apts/housing' category, 100 posts from each of several cities. Only several cities are supported. A writeup for how the models were made is available on github "),
                a("here", href="https://github.com/sueyic/shinyapp-craigslist-housing/blob/master/data_processing/data_processing_report.pdf")
            )
        ),

        mainPanel(
            h2('Select your desired city and number of bedrooms'),

            radioButtons("selCity", label = h3("Select city"),
                        choices = cityChoices, selected = cityChoices[[1]],
                        inline=TRUE),

            radioButtons("selBedrooms", label = h3("Select number of bedrooms"),
                        choices = bedroomChoices, selected = 1,
                        inline=TRUE),

            br(),
            h2('Predictions'),

            fluidRow(
                column(4, div(class="predbox",
                    h4('Predicted price (USD)'),
                    textOutput('predictedPrice')
                )),
                column(4, div(class="predbox",
                    h4('Predicted size'),
                    textOutput('predictedSize')
                )),
                column(4, div(class="predbox",
                    h4('Predicted price/size'),
                    textOutput('predictedPricePerSize')
                ))
            )

        )
    )
))
