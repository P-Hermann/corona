# this script pulls in historical data for each state of Covid-19 infections
# data source: covid tracking project
# data pulled as of 8/25/2020
# data could be combined with daily function call to api to get current numbers

##### Load packages #####
check.packages <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, library, character.only = TRUE)
}

packages <- c("tidyverse", "data.table", "httr", "jsonlite")

check.packages(packages)

##### connect to api and pull data #####
stateCodes <- tolower(state.abb)

StateURL <- paste0("https://api.covidtracking.com/v1/states/", stateCodes[1], "/daily.json")

res <- GET(StateURL)

stateHistoryData <- fromJSON(rawToChar(res$content))


for (i in 2:length(stateCodes)){
  
  StateURL <- paste0("https://api.covidtracking.com/v1/states/", stateCodes[i], "/daily.json")
  
  res <- GET(StateURL) # call api for one state
  
  
  data <- fromJSON(rawToChar(res$content)) # create data frame for that state
  
  stateHistoryData <- stateHistoryData %>%
    bind_rows(data)
  
  rm(data)
  
}

##### FORMAT DATA #####
