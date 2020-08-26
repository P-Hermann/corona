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

packages <- c("stringr", "tidyverse", "data.table", "httr", "jsonlite")

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

##### format data #####
stateHistoryData <- stateHistoryData %>%
  mutate(year = str_sub(date, start = 0, end = 4),
         month = str_sub(date, start = 5, end = 6),
         day = str_sub(date, start = 7, end = 8)) %>%
  mutate(date = as.Date(ISOdate(year, month, day)))

testResults <- stateHistoryData %>%
  rename(positiveCumulative = positive, negativeCumulative = negative) %>%
  select(date, state, positiveCumulative, negativeCumulative,
         hospitalizedCurrently, hospitalizedCumulative,
         positiveIncrease, negativeIncrease)

##### combined us patterns #####
testResults %>%
  group_by(date) %>%
  summarise(CumulativeInfections = sum(positiveCumulative),
            NewPositives = sum(positiveIncrease)) %>%
  ggplot(aes(x = date, y = NewPositives)) +
  geom_line()

testResults %>%
  group_by(date) %>%
  summarise(CumulativeInfections = sum(positiveCumulative),
            NewPositives = sum(positiveIncrease)) %>%
  ggplot(aes(x = date, y = CumulativeInfections)) +
  geom_line()

