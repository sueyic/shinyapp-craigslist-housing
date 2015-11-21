library(shiny)
library(DT)

shinyUI(fluidPage(
    
    # Application title
    titlePanel("Craigslist housing browser"),
    
    # Sidebar with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(
            p("This app retrieves the latest 100 \"apts/housing\" posts from craigslist for each of several metro areas in the USA. The data is at most 10 minutes old (it is fetched on the fly if it is more than 10 minutes old."),
            
            p("Choose from the options below for summaries of the data."),
            
            radioButtons("location", label = h3("Choose summary"),
                         choices = list("Overview (compare cities)" = "all",
                                        "New York" = "newyork",
                                        "SF Bay" = "sfbay",
                                        "Seattle" = "seattle"), selected = "newyork")
        ),
        

        mainPanel(
            h3(verbatimTextOutput('viewTitle')),
    
            conditionalPanel(condition = "input.location == 'all'",
                             plotOutput('plotPxLoc'),
                             plotOutput('plotPxSqft'),
                             plotOutput('plotBdrLoc')
                             ),
                    
            conditionalPanel(condition = "input.location != 'all'",
                             plotOutput('plotPxBdr'),
                             plotOutput('plotPxSqftBdr')),
            
            DT::dataTableOutput('tbl')
        )
    )
))