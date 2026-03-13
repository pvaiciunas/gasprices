library(rvest)
library(DBI)
library(RSQLite)

url <- "https://gasprices.aaa.com/"
webpage <- read_html(url)

# Extract all tables as a list of data frames
tables <- html_table(html_nodes(webpage, "table"), fill = TRUE)

# Access the first table in the list
df <- data.frame("Date" = Sys.Date(), "Regular" = as.double(sub('.', '', tables[[1]][1,2]$Regular)))
df$Date <- as.character(df$Date)

# 2. Connect to SQLite
con <- dbConnect(RSQLite::SQLite(), "local_data.db")

# Only append if the Date doesn't already exist in the database
existing_dates <- dbGetQuery(con, "SELECT Date FROM daily_scrapes")$Date

# Filter 'df' to only include rows where Date is NOT in the database
new_data <- df %>% filter(!(as.character(Date) %in% existing_dates))

if (nrow(new_data) > 0) {
  dbWriteTable(con, "daily_scrapes", new_data, append = TRUE)
  message("Added new records.")
} else {
  message("No new data to add today.")
}

dbDisconnect(con)


