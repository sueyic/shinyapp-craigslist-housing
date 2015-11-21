# DELETEME?

# We wish to build an application that can predict the price a person is likely
# to pay, given a city, and either number of bedrooms or square feet desired.
# To do this we are going to obtain recent data from craigslist's "apt/housing"
# for a few United States cities and use it to train a model to predict price.



library(httr)
library(plyr)
library(stringr)
library(XML)

URLS = list(
    'honolulu' = 'http://honolulu.craigslist.org/search/apa',
    'kansascity' = 'http://kansascity.craigslist.org/search/apa',
    'losangeles' = 'http://losangeles.craigslist.org/search/apa',
    'minneapolis' = 'http://minneapolis.craigslist.org/search/apa',
    'newyork' = 'http://newyork.craigslist.org/search/aap',
    'philadelphia' = 'http://philadelphia.craigslist.org/search/apa',
    'sfbay' = 'http://sfbay.craigslist.org/search/apa',
    'seattle' = 'http://seattle.craigslist.org/search/apa'
)


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
    }) %>% rename(replace=c('.id' = 'city')) %>% transform(city = factor(city))
}


# This is a data frame with data from all cities.
citiesdf <- getData()

# save citiesdf
if (!file.exists('data')) { dir.create('data') }
saveRDS(citiesdf, 'data/citiesdf.rds')

str(citiesdf)
