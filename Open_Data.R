require(readxl)
require(dplyr)
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
 mutate(`Admission Date` = as.Date(`Admission Date`, format = "%m/%d/%Y"), 
        `Discharge Date` = as.Date(`Discharge Date`, format = "%m/%d/%Y"))
COMB
write.csv(COMB,
          "K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/Combined.csv",
          row.names = F)

dem_cols <- c("Race", "Sex", "Facility")
first_date <- as.Date("2019-09-17")
last_day <- as.Date("2021-11-08")
dates <- seq.Date(first_date, last_day, by ="day")
daily_pop <- data.frame()
for (date in dates) {
  date <- as.Date(date, origin = "1970-01-01")
  pop_sheet <- subset(COMB, `Admission Date` < date & (`Discharge Date` > date | is.na(`Discharge Date`)))
  
  demos <- pop_sheet %>% 
    group_by(Facility, Race, Sex) %>% 
    tally() %>% 
    rename(`Patient Count` = n) %>% 
    mutate(Date = date) %>% 
    select(Facility, Date, everything())
  daily_pop <- plyr::rbind.fill(daily_pop, demos)
  # print(paste(date, "complete"))
}
write.csv(daily_pop, "K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/Daily_Pop.csv",
          row.names = F)
