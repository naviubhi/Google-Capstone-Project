install.packages("tidyverse")
install.packages("data.table")
library(tidyverse)
library(data.table)
library(scales)

#-------------------Importing the 12 month CSV files----------------------------
jan_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202201-divvy-tripdata.csv")
feb_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202202-divvy-tripdata.csv")
mar_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202203-divvy-tripdata.csv")
apr_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202204-divvy-tripdata.csv")
may_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202205-divvy-tripdata.csv")
jun_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202206-divvy-tripdata.csv")
jul_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202207-divvy-tripdata.csv")
aug_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202208-divvy-tripdata.csv")
sep_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202209-divvy-publictripdata.csv")
oct_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202210-divvy-tripdata.csv")
nov_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202211-divvy-tripdata.csv")
dec_22 <- read.csv("C:\\Users\\Navi Ubhi\\Documents\\R Data\\202212-divvy-tripdata.csv")

#Checking structure of data
str(jan_22)
str(feb_22)
str(mar_22)
str(apr_22)
str(may_22)
str(jun_22)
str(jul_22)
str(aug_22)
str(sep_22)
str(oct_22)
str(nov_22)
str(dec_22)

#---------------------Data Manipulation / Cleaning------------------------------
#Merge the individual month data into one frame
all_tripdata <-bind_rows(jan_22, feb_22, mar_22, apr_22, may_22, jun_22, jul_22, aug_22, sep_22, oct_22, nov_22, dec_22)

#Checking structure of data and getting a glimpse of the data
str(all_tripdata)
glimpse(all_tripdata)

#Changing 'started_at' data type
all_tripdata$started_at <- as.POSIXct(
  all_tripdata$started_at,
  format = "%Y-%m-%d %H:%M:%S"
  )

#Changing 'ended_at' data type
all_tripdata$ended_at <- as.POSIXct(
  all_tripdata$ended_at,
  format = "%Y-%m-%d %H:%M:%S"
)

#Checking for any inconsistencies in the 'member_casual' and 'rideable_type' columns
unique(all_tripdata$member_casual)
unique(all_tripdata$rideable_type)

#Removing blank results (specifically in start and end station name)
all_tripdata <- all_tripdata %>%
  filter(
    !(is.na(start_station_name) | 
        start_station_name == "")
  ) %>%
  
  filter(
    !(is.na(end_station_name) |
        end_station_name == "")
  )

#Remove results with inconsistent times (where ride length is <0)
all_tripdata <- all_tripdata %>%
  filter(!(ride_length < 0))


#Remove duplicates based on ride ID - no duplicate IDs found
all_tripdata <- all_tripdata [!duplicated(all_tripdata$ride_id),]

#-------------------Creating new columns for data analysis----------------------
#Creating columns for the date, year, month, day, hour, day of week, and ride length to help with analysis 
#Date
all_tripdata$date <- as.Date (
  all_tripdata$started_at,
)

#Year
all_tripdata$year <- format (
    all_tripdata$started_at,
    "%Y"
)

#Month
all_tripdata$month <- format (
  all_tripdata$started_at,
  "%m"
)

all_tripdata$month <- format(as.Date(all_tripdata$date), "%B")

#Day
all_tripdata$day <- format (
  all_tripdata$started_at,
  "%d"
)


#Hour (time of day the ride starts)
all_tripdata$start_hour <- format(
  all_tripdata$started_at,
  "%H"
)

#Day of week
all_tripdata$day_of_week <- format (
  all_tripdata$started_at,
  "%A"
)

#Calculate and create a column for ride length in minutes,
all_tripdata$ride_length <- difftime (
  all_tripdata$ended_at,
  all_tripdata$started_at,
  units = "mins"
)

all_tripdata$ride_length <-  round(all_tripdata$ride_length, 2)

#Create column for seasons of year
all_tripdata <- all_tripdata %>% mutate(
  season = 
    case_when(month == "January" ~ "Winter",
              month == "February" ~ "Winter",
              month == "March" ~ "Spring",
              month == "April" ~ "Spring",
              month == "May" ~ "Spring",
              month == "June" ~ "Summer",
              month == "July" ~ "Summer",
              month == "August" ~ "Summer",
              month == "September" ~ "Fall",
              month == "October" ~ "Fall",
              month == "November" ~ "Fall",
              month == "December" ~ "Winter")
)

#Create column for time of day
all_tripdata <- all_tripdata %>% mutate(
  time_of_day = 
    case_when(start_hour == "00" ~ "Night",
              start_hour == "01" ~ "Night",
              start_hour == "02" ~ "Night",
              start_hour == "03" ~ "Night",
              start_hour == "04" ~ "Night",
              start_hour == "05" ~ "Night",
              start_hour == "06" ~ "Morning",
              start_hour == "07" ~ "Morning",
              start_hour == "08" ~ "Morning",
              start_hour == "09" ~ "Morning",
              start_hour == "10" ~ "Morning",
              start_hour == "11" ~ "Morning",
              start_hour == "12" ~ "Afternoon",
              start_hour == "13" ~ "Afternoon",
              start_hour == "14" ~ "Afternoon",
              start_hour == "15" ~ "Afternoon",
              start_hour == "16" ~ "Afternoon",
              start_hour == "17" ~ "Afternoon",
              start_hour == "18" ~ "Evening",
              start_hour == "19" ~ "Evening",
              start_hour == "20" ~ "Evening",
              start_hour == "21" ~ "Evening",
              start_hour == "22" ~ "Night",
              start_hour == "23" ~ "Night")
)

#Ordering the data by day of week and by month
all_tripdata$day_of_week <- ordered(all_tripdata$day_of_week,
                                    levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
)

all_tripdata$month <- ordered(all_tripdata$month, 
                              levels=c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
)

#-------------------------------ANALYSIS----------------------------------------
#Finding the mean, median, min, and max ride length by rider type
all_tripdata %>%
  group_by(member_casual) %>%
  summarise(avg_ride_length = mean(ride_length), median_ride_length = median(ride_length), min_ride_length = min(ride_length), max_ride_length = max(ride_length))

#---------------------DAY OF WEEK--------------------
#Finding the number of rides each day of the week based on the rider type
all_tripdata_by_day <- all_tripdata %>%
  group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>%
  arrange(member_casual, day_of_week)

#View summary
head(all_tripdata,14)

#Visual plot - total rides by day of week based on the rider type
all_tripdata %>%
  group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>%
  arrange(member_casual, day_of_week) %>%
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  scale_y_continuous(labels = label_comma())+
  geom_col(position = "dodge") + labs(title = "Total Number of Rides based on Day of Week",
  x = "Day of Week", y = "Total Number of Rides") +
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))

#------------------------MONTH-----------------------
#Visual plot - total rides by month based on the rider type
all_tripdata %>%
  group_by(member_casual, month) %>%
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>%
  arrange(member_casual, month) %>%
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) +
  scale_y_continuous(labels = label_comma())+
  geom_col(position = "dodge") + labs(title = "Total Number of Rides based on Month",
  x = "Month", y = "Total Number of Rides") +
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))

#------------------------HOUR------------------------
#Visual plot - most popular time of day to ride based on rider type
all_tripdata %>%
  group_by(member_casual, start_hour) %>% 
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>% 
  ggplot(aes(x=start_hour,y=number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") + labs(title = "Total Number of Rides per hour", x = "Hour", y = "Total Number of Rides") +
  scale_y_continuous(labels = label_comma())+
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))

#----------------------BIKE TYPE---------------------
#Filter to MEMBER only
all_tripdata_member <- filter(all_tripdata, member_casual == "member")

#Visual Plot - total rides for members by month based on Rideable type 
all_tripdata_member %>%
  group_by(rideable_type, month) %>% 
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>% 
  arrange(rideable_type, month) %>%
  ggplot(aes(x = month, y = number_of_rides, fill = rideable_type)) +
  geom_col(position = "dodge") + labs(title = "Total Number of Member Rides per month", x = "Month", y = "Total Number of Rides") +
  scale_y_continuous(labels = label_comma())+
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))

#Visual Plot - total rides for members by day of week based on Rideable type 
all_tripdata_member %>%
  group_by(rideable_type, day_of_week) %>% 
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>% 
  arrange(rideable_type, day_of_week) %>%
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = rideable_type)) +
  geom_col(position = "dodge") + labs(title = "Total Number of Member Rides per Day", x = "Day of week", y = "Total Number of Rides") +
  scale_y_continuous(labels = label_comma())+
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))

#Visual Plot - total rides for members by hour based on Rideable type
all_tripdata_member %>%
  group_by(rideable_type, start_hour) %>% 
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>% 
  arrange(rideable_type, start_hour) %>%
  ggplot(aes(x = start_hour, y = number_of_rides, fill = rideable_type)) +
  geom_col(position = "dodge") + labs(title = "Total Number of Member Rides per hour", x = "Hour of day", y = "Total Number of Rides") +
  scale_y_continuous(labels = label_comma())+
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))


#Filter to CASUAL only
all_tripdata_casual <- filter(all_tripdata, member_casual == "casual")

#Visual Plot - total rides for casual by month based on Rideable type 
all_tripdata_casual %>%
  group_by(rideable_type, month) %>% 
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>% 
  arrange(rideable_type, month) %>%
  ggplot(aes(x = month, y = number_of_rides, fill = rideable_type)) +
  geom_col(position = "dodge") + labs(title = "Total Number of Casual Rides per month", x = "Month", y = "Total Number of Rides") +
  scale_y_continuous(labels = label_comma())+
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))

#Visual Plot - total rides for casual by day of week based on Rideable type 
all_tripdata_casual %>%
  group_by(rideable_type, day_of_week) %>% 
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>% 
  arrange(rideable_type, day_of_week) %>%
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = rideable_type)) +
  geom_col(position = "dodge") + labs(title = "Total Number of Casual Rides per Day", x = "Day of week", y = "Total Number of Rides") +
  scale_y_continuous(labels = label_comma())+
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))

#Visual Plot - total rides for casual by hour based on Rideable type
all_tripdata_casual %>%
  group_by(rideable_type, start_hour) %>% 
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>% 
  arrange(rideable_type, start_hour) %>%
  ggplot(aes(x = start_hour, y = number_of_rides, fill = rideable_type)) +
  geom_col(position = "dodge") + labs(title = "Total Number of Casual Rides per hour", x = "Hour of day", y = "Total Number of Rides") +
  scale_y_continuous(labels = label_comma())+
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))

#Total rides by Bike Type
all_tripdata %>%
  group_by(rideable_type, member_casual) %>% 
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>%
  arrange(rideable_type, member_casual) %>%
  ggplot(aes(x = rideable_type, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") + labs(title = "Total rides by Rideable type", x = "Bike type", y = "Total Number of Rides") +
  scale_y_continuous(labels = label_comma())+
  theme_minimal() + theme(axis.text.x = element_text(angle = 60, hjust = 1))

#--------------------START STATION-------------------
#Most popular start station for CASUAL (top 10)
popular_start_station <- all_tripdata_casual %>%
  group_by(start_station_name) %>%
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>%
  arrange(start_station_name, number_of_rides, average_duration)

head(arrange(popular_start_station, desc(number_of_rides)),10)


#Most popular start station for MEMBERS (top 10)
popular_start_station_member <- all_tripdata_member %>%
  group_by(start_station_name) %>%
  summarise(number_of_rides=n(), average_duration = mean(ride_length)) %>%
  arrange(start_station_name, number_of_rides, average_duration)

head(arrange(popular_start_station_member, desc(number_of_rides)),10)

#-------------------EXPORTING DATA-------------------
#Exporting Data for Tableau visualization 
fwrite(all_tripdata,"All_TripData.csv")
