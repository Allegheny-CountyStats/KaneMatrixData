require(readxl)
require(dplyr)
ST <- read_excel("K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/ScottTwp.xls",
                 skip = 3) %>% 
       mutate(Center = "Scott Twp") %>% 
  select(`Sex`,`Race`, `Admission Date`, `Discharge Date`, `Center`)
RT <- read_excel("K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/RossTwp.xls",
                  skip = 3) %>% 
  mutate(Center = "Ross Twp") %>% 
  select(`Sex`,`Race`, `Admission Date`, `Discharge Date`, `Center`)
MK <- read_excel("K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/McKeesport.xls",
                 skip = 3) %>% 
  mutate(Center = "McKeesport") %>% 
  select(`Sex`,`Race`, `Admission Date`, `Discharge Date`, `Center`)
GH <- read_excel("K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/GlenHazel.xls",
                 skip = 3) %>% 
  mutate(Center = "Glen Hazel") %>% 
  select(`Sex`,`Race`, `Admission Date`, `Discharge Date`, `Center`)
BIND <- bind_rows(ST, RT, MK, GH) 
BIND$Race[BIND$Race == "White, not of Hispanic origin"] <- "White" 
BIND$Race[BIND$Race == "Black, not of Hispanic Origin"] <- "Black"
BIND
write.csv(BIND,
          "K:/CountyStats/Departments/Kane Regional Centers/MatrixCare Data/Combined.csv",
          row.names = F)

