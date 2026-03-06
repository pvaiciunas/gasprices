library(rvest)
library(DBI)
library(RSQLite)

url <- "https://gasprices.aaa.com/"
webpage <- read_html(url)

# Extract all tables as a list of data frames
tables <- html_table(html_nodes(webpage, "table"), fill = TRUE)

# Access the first table in the list
df <- data.frame(Date = Sys.Date(), b = tables[[1]][1,2])
df[1,2] <- as.numeric(sub('.', '', df[1,2]))

# 2. Connect to SQLite file in the same folder
# 'local_data.db' will be stored in your GitHub repo
con <- dbConnect(RSQLite::SQLite(), "local_data.db")

# 3. Write data
dbWriteTable(con, "daily_scrapes", df, append = TRUE)
dbDisconnect(con)
