library(rvest)
library(lubridate)
library(dplyr)
library(DBI)
library(RSQLite)

url <- "https://gasprices.aaa.com/"
webpage <- read_html(url)

# Extract all tables as a list of data frames
tables <- webpage %>% html_nodes("table") %>% html_table(fill = TRUE)

# Access the first table in the list
df <- tables[[1]][1,2] 
df <- mutate(df, Date = today("EST"), .before = Regular)

# 2. Connect to SQLite file in the same folder
# 'local_data.db' will be stored in your GitHub repo
con <- dbConnect(RSQLite::SQLite(), "local_data.db")

# 3. Write data
dbWriteTable(con, "daily_scrapes", df, append = TRUE)
dbDisconnect(con)
