incidents <- read.csv("severe_incidents.csv")
firehouses <- read.csv("FDNY_Firehouse_Listing.csv")

incidents <- incidents %>% drop_na(c('Latitude', 'Longitude'))
incident_loc <- incidents[c('Latitude', 'Longitude')] 
firehouses <- firehouses %>% drop_na(c('Latitude', 'Longitude'))
firehouse_loc <- firehouses[c('Latitude', 'Longitude')] 

nearest_fh <- nn2(firehouse_loc, query=incident_loc, k=1)$nn.dists
incidents$nearest_fh <- as.numeric(nearest_fh)
incidents$Borough <- as.factor(incidents$BOROUGH_DESC)

incidents$incident_time <- parse_date_time(incidents$INCIDENT_DATE_TIME, c('%m/%d/%Y %I:%M:%S %p'), exact = TRUE)
incidents$arriv_time <- parse_date_time(incidents$ARRIVAL_DATE_TIME, c('%m/%d/%Y %I:%M:%S %p'), exact = TRUE)
incidents$response_time <- as.numeric(as.duration(incidents$incident_time %--% incidents$arriv_time))
incidents_scatter <- incidents[c('nearest_fh', 'response_time')]

plot <- ggplot(incidents %>% filter(nearest_fh < 0.03) %>% 
                 filter(response_time <700), aes(x=nearest_fh, y=response_time)) +
  geom_point(aes(color=Borough)) + geom_smooth(color = 'red') + 
  labs(x="Distance from Nearest Firehouse",
       y="Response Time (Minutes)",
       title="Plot of Response Time vs Distance from Nearest Firehouse") +
  theme_bw()
plot