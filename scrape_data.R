library(rvest)
library(DBI)
library(RSQLite)

url <- "https://gasprices.aaa.com/"
webpage <- read_html(url)

# Extract all tables as a list of data frames
tables <- html_table(html_nodes(webpage, "table"), fill = TRUE)

# Access the first table in the list
df <- data.frame("Date" = Sys.Date() - 1, "Regular" = as.double(sub('.', '', tables[[1]][1,2]$Regular)))
df$Date <- as.character(df$Date)

# 2. Connect to SQLite
con <- dbConnect(RSQLite::SQLite(), "local_data.db")

# 3. Check if the table "daily_scrapes" already exists
if (!dbExistsTable(con, "daily_scrapes")) {
  
  # FIRST RUN: Create the table and define types
  dbWriteTable(
    conn = con, 
    name = "daily_scrapes", 
    value = df, 
    field.types = c(Date = "TEXT", Regular = "REAL")
  )
  
} else {
  
  # SUBSEQUENT RUNS: Just append the data
  # The types are already locked in from the first run
  dbWriteTable(
    conn = con, 
    name = "daily_scrapes", 
    value = df, 
    append = TRUE
  )
}

dbDisconnect(con)


