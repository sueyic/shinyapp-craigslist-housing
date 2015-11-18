library(ggplot2)
library(httr)
library(plyr)
library(shiny)
library(stringr)
library(XML)

URLS = list(
    'newyork' = 'http://newyork.craigslist.org/search/aap',
    'sfbay' = 'http://sfbay.craigslist.org/search/apa',
    'seattle' = 'http://seattle.craigslist.org/search/apa'
)

fetchTime <- NA
# A combined data frame of all cities data
datadf <- NA

getDataFromUrl <- function(url) {
    cat(sprintf("url: *%s*\n", url));
    
    content <- content(GET(url), as="text")
    parsedHtml <- htmlParse(content, asText=TRUE)
    
    domain <- str_extract(url, 'http://[^.]+.craigslist.org')
    
    posts <- xpathApply(parsedHtml, "//p[@class='row']", fun=function(node) {
        rowHtml <- saveXML(node)
        
        parsedRowHtml <- htmlParse(rowHtml, asText=TRUE)
        date <- xpathSApply(parsedRowHtml, "//time", xmlValue)
        title <- xpathSApply(parsedRowHtml, "//span[@class='pl']/a", xmlValue)
        price <- xpathSApply(parsedRowHtml, "//span[@class='price']", xmlValue)
        housing <- xpathSApply(parsedRowHtml, "//span[@class='housing']", xmlValue)
        housingToks <- strsplit(as.character(housing), '[/ -]+', perl=TRUE)
        bedrooms <- NA
        sqft <- NA
        href <- paste0(
            domain,
            xpathSApply(parsedRowHtml, "//span[@class='pl']/a",
                        function(x) { xmlAttrs(x)[['href']] }))

        if (length(housingToks) == 1) {
            for (tok in housingToks[[1]]) {
                if (grepl('br', tok)) {
                    bedrooms <- tok
                } else if (grepl('ft2', tok)) {
                    sqft <- tok
                }
            }
        }
        
        #cat(sprintf("date: *%s*, title: *%s*, price: *%s*, housing: *%s*, bedrooms: *%s*, sqft: *%s*\n", date, title, price, housing, bedrooms, sqft))
        
        x = list(date=NA, title=NA, price=NA, bedrooms=NA, sqft=NA, href=NA)
        x$date = date
        x$title = title
        x$price = as.numeric(gsub('\\$', '', price))
        x$bedrooms = as.factor(gsub('br', '', bedrooms))
        x$sqft = as.numeric(gsub('ft2', '', sqft))
        x$href = href

        return(x)
    })
 
    df = do.call(rbind.data.frame, posts)
    return(df)
}


# get data for all cities.
getData <- function() {
    ldply(URLS, function(url) {
        cat(sprintf('this url: *%s*', url))
        # try(getDataFromUrl(url))
        
        tryCatch({ 
            getDataFromUrl(url)
        }, error = function(err) {
            # Occasionally getting data fails (exactly, why?). In this case,
            # return an empty data frame for this location.
            print(paste("ERROR getting data from url:  ", url))
            return(data.frame())
        })
    }) %>% rename(replace=c('.id' = 'city'))
}


shinyServer(function(input, output) {
    location <- reactive({
        input$location
    })      
    
    df <- reactive({
        curTime <- Sys.time()
        # Fetch data if we've never fetched it or its been at least 10 minutes since last fetched.
        if (is.na(fetchTime) || as.double(difftime(curTime, fetchTime, units="mins")) > 10) {
            cat(' fetching\n')
            datadf <<- getData()
            fetchTime <<- Sys.time()
        } else {
            cat(' not fetching\n')
        }
        
        loc <- location()
        cat(sprintf('*** loc: %s', loc))
        if (loc == "all") {
            return (datadf)
        } else {
            data <- subset(datadf, city == loc)
            data$city <- NULL
            return (data)
        }
    })    
    
    output$viewTitle <- renderText({ifelse(location() == 'all', 'Data for all locations', paste0('Data for ', location()))})
    

    ### Plots comparing locations ###
    
    output$plotPxLoc <- renderPlot({
        if (location() == "all") {
            g <- ggplot(df(), aes(y=price, x=city)) + geom_violin() +
                labs(title="Price vs City")
        } else {
            g <- NULL
        }
        return (g)
    })
    
    output$plotPxSqft <- renderPlot({
        if (location() == "all") {
            g <- ggplot(df(), aes(x=sqft, y=price, color=city)) + geom_point() +
                labs(title="Price vs Sqft by City")
        } else {
            g <- NULL
        }
        return (g)
    })
    
    output$plotBdrLoc <- renderPlot({
        if (location() == "all") {
            g <- ggplot(df(), aes(x=bedrooms, fill=bedrooms)) + geom_histogram() + coord_flip() + facet_wrap(~ city) + labs(title="Number of Bedrooms per City")
        } else {
            g <- NULL
        }
        return (g)
    })        
    ### Location-specific plots ###
    
    output$pricePxBdr <- renderPlot({
        loc <- location()
        if (loc == "all") {
            g <- NULL
        } else {
            g <- ggplot(df(), aes(x=bedrooms, y=price)) + geom_point() +
                labs(title="Price vs Bedroom")
        }
        return (g)
    })
    
    output$pricePxSqftBdr <- renderPlot({
        loc <- location()
        if (loc == "all") {
            g <- NULL
        } else {
            g <- ggplot(df(), aes(x=sqft, y=price, color=bedrooms)) + geom_point() +
                labs(title="Price vs Sqft by Bedroom")
        }
        return (g)
    })        

    ### Table ###
    output$tbl <- DT::renderDataTable({
        table <- df()
        table$link = paste0('<a href="', table$href, '" target="_blank">link</a>')
        table$href <- NULL
        return (datatable(table, escape=-which(names(df()) %in% c('link'))))
    })

})
