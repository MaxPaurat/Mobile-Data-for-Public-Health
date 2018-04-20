#create histograms of travel times between antennas 
#this is the basis for creating an algorthm to extract the typical fast travel time distribution (without stops somewhere)
#ideas: fit gaussian distr. 
# - maybe the modes of transport ( car, plane, ...) should be clustered before?
# - how can I validate the distribution?
#   - definately compare to simple distance-carspeed calculation
#   - validate with results from other orange paper on travel times between cities
#   - crosscheck by adding two (or more) distances that combine to make the journey



#### first try
# First_Site_ID = 1
# 
# Sec_Site_ID = 900
# 
# wenttoFirstSite = rawmobility[rawmobility$site_ID == First_Site_ID, ]
# UserFirst = wenttoFirstSite$user_ID
# 
# #add something here to amke sure the second time is after first
# wenttobothSites = rawmobility[ rawmobility$user_ID == User & rawmobility$site_ID == Sec_Site_ID, ]
# 
# UserFirstandSec = wenttobothSites$user_ID
# 
# 
# 
# Endtime = wenttobothSites$timestamp
#################
#STEPS TO SOLVE THE PROBLEM
#users visits to one site first and then the other

#for user_ID
# visits where First site is visited then second without the first again in between

# find incidence of visit to first
# look to next observation
# if visit to the same site, save the new time as starttime
# if not the same go through further observations of this user to find visit to second site
# lock arrival this time 
# calculate this difference and save to vector of this site combination (has direction)
# continue with this process on this user until no data for this user is left
#################
#second try
# First_Site_ID = 1
# Sec_Site_ID = 900
# 
# rawmobility$user_ID
# 
# for (i in 1:max(rawmobility$user_ID)){
#   if (( rawmobility$user_ID == i) & (First_Site_ID %in% rawmobility$site_ID))
# Time1 = 
# }

#third try (loops are inefficient and should be replaced, append is also inefficient)
# 
# First_Site_ID = 461 # first set the Sites manually, later create a loop
# Sec_Site_ID = 454

#ISSUES:
# - number of travels between some antennas are very low resulting in unreliable traveltime estimates ("peak is less clear")

#To Do 
# - implement typical travel time extraction strategy as in orange paper

travel_time <- array(dim = c(1666,1666,300))

for (First_Site_ID in c(461, 327)){ # these should be all sites 
  for (Sec_Site_ID in c(454, 323)){ # these should be the sites that have health facilities
    
    nummer = 0 # initialize count of travels with this Site combination (see use below)
    
    for (i in 1:max(rawmobility$user_ID)){ # for every user seperate data.frame to work on
      #print(i)
      user = subset(rawmobility, user_ID == i) 
      if (nrow(user) == 0){break}
      #print(user)
      S = NA # set travel start time to NA
      
      for (counter in 1:nrow(user)){ # for all observations of the user (call/sms at a site)
       #print(counter)
        if (user[counter, ]$site_ID == First_Site_ID){ # if user visits first site 
          S = user[counter, ]$timestamp # save travel starttime and date (this gets replaced by the last time the person is at the site)
          #print("I found one!!!")
          
         }
        if (user[counter, ]$site_ID == Sec_Site_ID & is.na(S) == FALSE){ # if user visits second site and has visited first already
          nummer = nummer + 1
          E = user[counter, ]$timestamp # record travel arrival time and date
          travel_time[First_Site_ID, Sec_Site_ID, nummer] = as.numeric(as.POSIXct(E, format = "%Y-%m-%d %H:%M:%S") - as.POSIXct(S, format = "%Y-%m-%d %H:%M:%S")) #as.Date(E) - as_Date(S)) #calculate travel time as difference of S and E
          print("I found one!!!")
          #stop()
        }
      }
    }
    print("done looping")
    if (nummer != 0 ){ 
      hist(travel_time[First_Site_ID, Sec_Site_ID, ], breaks = 0:(max(travel_time[First_Site_ID, Sec_Site_ID, ]+2, na.rm = TRUE)))
    }
  }
}

