require(readxl)
require(dplyr)
# this can help read date fields
require(readr)
library(lubridate)
ST <- read_excel("K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/ScottTwp.xls",
                 skip = 3) %>% 
       mutate(Facility = "Scott Twp") %>% 
  select(`Sex`,`Race`, `Admission Date`, `Discharge Date`, `Facility`)
RT <- read_excel("K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/RossTwp.xls",
                  skip = 3) %>% 
  mutate(Facility = "Ross Twp") %>% 
  select(`Sex`,`Race`, `Admission Date`, `Discharge Date`, `Facility`)
MK <- read_excel("K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/McKeesport.xls",
                 skip = 3) %>% 
  mutate(Facility = "McKeesport") %>% 
  select(`Sex`,`Race`, `Admission Date`, `Discharge Date`, `Facility`)
GH <- read_excel("K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/GlenHazel.xls",
                 skip = 3) %>% 
  mutate(Facility = "Glen Hazel") %>% 
  select(`Sex`,`Race`, `Admission Date`, `Discharge Date`, `Facility`)
BIND <- bind_rows(ST, RT, MK, GH)
BIND$Race[BIND$Race == "White, not of Hispanic origin"] <- "White" 
BIND$Race[BIND$Race == "Black, not of Hispanic Origin"] <- "Black"
COMB <- filter(BIND, !is.na(Sex))  %>% 
  # change admission and discharge date into date format as they were char. Y indicate 4 digit year. y inidcate 2 digit year.
 mutate(`Admission Date` = as.Date(`Admission Date`, format = "%m/%d/%Y"), 
        `Discharge Date` = as.Date(`Discharge Date`, format = "%m/%d/%Y"))
COMB
write.csv(COMB,
          "K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/Combined.csv",
          row.names = F)
#define the columns that patient count is going to be based on. Counts are separate by these variables.
dem_cols <- c("Race", "Sex", "Facility")
# define the first date in the date list we want to include in the output. 
#To continue with the existing data, hard coded with a specific date
first_date <- as.Date("2020-02-01")
# define the last date in the date list we want to include in the output. As downloaded as of 11/8, hard code it.
last_day <- as.Date("2021-12-01")
# make the list of all dates between first date and last date just made. 
dates <- seq.Date(first_date, last_day, by ="day")
# build the data frame
daily_pop <- data.frame()
# set up the rows. each date is in each row. for each date, do the following:
for (date in dates) {
  # make the dates in date format
  date <- as.Date(date, origin = "1970-01-01")
  # collect all patients before a "date", which is dynamic, 
  # and these patients should not have been discharged to be counted. 
  # so their discharge dates were after the "date" or no discharge date.
  pop_sheet <- subset(COMB, `Admission Date` < date & (`Discharge Date` > date | is.na(`Discharge Date`)))
  # assemble the rows and columns and count patients. assign the patient data to demos
  demos <- pop_sheet %>% 
    # and group them by the 3 variables which counts base on
    group_by(Facility, Race, Sex) %>% 
    # and create a new column showing the counts 
    tally() %>% 
    # give the new column a new name
    rename(`Patient Count` = n) %>% 
    # and make the Date column the dates in the date list
    mutate(Date = date) %>% 
    # and arrange the columns - have facility the 1st column and Date the 2nd and all other columns in Pop_Sheet
    select(Facility, Date, everything())
  # append all dates together into daily_pop instead of overwriting
  daily_pop <- plyr::rbind.fill(daily_pop, demos)
  # print(paste(date, "complete"))
}
# save the output
write.csv(daily_pop, "K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/Daily_Pop_2_1_2020.csv",
          row.names = F)
