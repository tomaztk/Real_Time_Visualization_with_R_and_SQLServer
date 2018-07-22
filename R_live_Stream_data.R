#########################################################
#Author: Tomaz Kastrun
#Date: 20.07.2018
#
#Visualizing real-time data stream  
#using R (and environments) and Microsoft SQL Server
########################################################
library(RODBC)


# create env for storing the variables/data frames between the functions
assign("getREnvironment", new.env(), envir = .GlobalEnv)

# Function to read data from SQL Server
getSQLServerData <- function()
{
  #extract environment settings for storing data
  getREnvironment <- get("getREnvironment", envir = .GlobalEnv, mode = "environment")
  #get the SQL Server data
  con <- odbcDriverConnect('driver={SQL Server};server=TOMAZK\\MSSQLSERVER2017;database=test;trusted_connection=true')
  db_df <- sqlQuery(con, 'select TOP 20 id, num from LiveStatsFromSQLServer ORDER BY id DESC')
  close(con)
  #overwrite existing data with new data
  df_overwrite <- db_df
  getREnvironment$db_df <- data.frame(df_overwrite)
  try(assign("getREnvironment", getREnvironment, envir = .GlobalEnv))
  invisible()  
}

# Plot graph 
n=1000 #nof iterations
windowQuery=20 # syncronised with TOP clause in SELECT statement
for (i in 1:(n-windowQuery)) {
  flush.console()
  getSQLServerData()
  getREnvironment <- get("getREnvironment", envir = .GlobalEnv, mode = "environment")
  data <- getREnvironment$db_df
  plot( data$id, data$num, type='l',main='Realtime data from SQL Server')
  Sys.sleep(0.5)
}
