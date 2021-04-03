###For Tractors

#Import Libraries
library(tidyverse)
library(RODBC)
library(sp)
library(leaflet)
library(htmltools)
library(magrittr)

###Against TMW Suite Replication
dbhandle <- odbcDriverConnect('driver={SQL Server};
                               server=NFIV-SQLTMW-04;
                               database=TMWSuite;trusted_connection=true')

###Contains SQL that can search radius, polygon, or state lines
TractorLocation <- sqlQuery(dbhandle, 
                            "DECLARE @POLY GEOGRAPHY
DECLARE @POLY2 GEOGRAPHY

SET @POLY= geography::STGeomFromText('POLYGON((-78.622 40.328,
-77.868 40.057,
-76.998 39.720,
-75.777 39.724,
-75.628 39.830,
-75.404 39.794,
-74.725 40.165,
-75.195 40.611,
-75.118 40.961,
-74.974 41.082,
-75.127 41.253,
-75.548 41.226,
-75.831 41.425,
-76.284 41.377,
-76.892 41.157,
-76.945 40.617,
-77.293 40.698,
-77.362 40.845,
-78.364 40.729,
-78.622 40.328))', 4326) --Eastern PA Permit Counties - 
/*Berks
Blair
Bucks
Carbon
Chester
Columbia
Cumberland
Dauphin
Delaware
Huntingdon
Juniata
Lancaster
Lebanon
Lehigh
Luzerne
Mifflin
Monroe
Montgomery
Northampton
Northumberland
Perry
Philadelphia
Schuylkill
York */

SET @POLY2= geography::STGeomFromText('POLYGON((-96.038 33.129,
-97.554 33.230,
-97.639 32.328,
-96.093 32.209,
-96.038 33.129))', 4326) --Dallas-ish

SELECT 
	[TrcNumber] = trc_number
	,[TrcStatus] = trc_status
	,[TrcType] = trc_type2
	,[TrcMake] = trc_make
	,[TrcYear] = trc_year
	,[TrcBranch] = RTRIM(trc_branch)
	,[BranchwithTrc] = CONCAT(RTRIM(trc_branch),'-',trc_number)
	,[TrcGPSDesc] = trc_gps_desc
	,[TrcGPSState] = RIGHT(LEFT(trc_gps_desc, CHARINDEX(', ', trc_gps_desc)+3),2)
	,[TrcGPSDate] = trc_gps_date
	,[TrcLatitude] = ((CONVERT(decimal,(trc_gps_latitude))/60)/60)
	,[TrcLongitude] = ((CONVERT(decimal,(trc_gps_longitude))/60)/60)*-1
	,[WithinEastPA] = geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
		  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY)
	,[WithinDallas] = geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
		  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY2)
FROM tractorprofile 
WHERE
	trc_branch NOT IN ('001','002','003','004','006','UNKNOWN')
	and trc_gps_latitude IS NOT NULL
	and trc_gps_longitude IS NOT NULL
	and trc_status <> 'OUT'
	and trc_number NOT IN ('COLEMAN','I2382','NFITEST2')
	and geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY) = 1
	OR geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY2) = 1
ORDER BY 1")

#glimpse(TractorLocation)
#summary(TractorLocation)

###To just get the headers 
Filtered_TractorLocation <- filter(TractorLocation, TrcBranch=='xxx')

###Export and Overwrite to Local CSV File 
write.table(Filtered_TractorLocation, 
            file="C:/Users/SullivanRy/Documents/twoPolygons_TractorLocations.csv", 
            row.names=F,
            col.names=T,
            sep=",",
            append=FALSE)

#Repeat in intervals, append the table
repeat {
  ###Contains SQL that can search radius, polygon, or state lines
  TractorLocation <- sqlQuery(dbhandle, 
                              "DECLARE @POLY GEOGRAPHY
DECLARE @POLY2 GEOGRAPHY

SET @POLY= geography::STGeomFromText('POLYGON((-78.622 40.328,
-77.868 40.057,
-76.998 39.720,
-75.777 39.724,
-75.628 39.830,
-75.404 39.794,
-74.725 40.165,
-75.195 40.611,
-75.118 40.961,
-74.974 41.082,
-75.127 41.253,
-75.548 41.226,
-75.831 41.425,
-76.284 41.377,
-76.892 41.157,
-76.945 40.617,
-77.293 40.698,
-77.362 40.845,
-78.364 40.729,
-78.622 40.328))', 4326) --Eastern PA Permit Counties - 
/*Berks
Blair
Bucks
Carbon
Chester
Columbia
Cumberland
Dauphin
Delaware
Huntingdon
Juniata
Lancaster
Lebanon
Lehigh
Luzerne
Mifflin
Monroe
Montgomery
Northampton
Northumberland
Perry
Philadelphia
Schuylkill
York */

SET @POLY2= geography::STGeomFromText('POLYGON((-96.038 33.129,
-97.554 33.230,
-97.639 32.328,
-96.093 32.209,
-96.038 33.129))', 4326) --Dallas-ish

SELECT 
	[TrcNumber] = trc_number
	,[TrcStatus] = trc_status
	,[TrcType] = trc_type2
	,[TrcMake] = trc_make
	,[TrcYear] = trc_year
	,[TrcBranch] = RTRIM(trc_branch)
	,[BranchwithTrc] = CONCAT(RTRIM(trc_branch),'-',trc_number)
	,[TrcGPSDesc] = trc_gps_desc
	,[TrcGPSState] = RIGHT(LEFT(trc_gps_desc, CHARINDEX(', ', trc_gps_desc)+3),2)
	,[TrcGPSDate] = trc_gps_date
	,[TrcLatitude] = ((CONVERT(decimal,(trc_gps_latitude))/60)/60)
	,[TrcLongitude] = ((CONVERT(decimal,(trc_gps_longitude))/60)/60)*-1
	,[WithinEastPA] = geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
		  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY)
	,[WithinDallas] = geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
		  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY2)
FROM tractorprofile 
WHERE
	trc_branch NOT IN ('001','002','003','004','006','UNKNOWN')
	and trc_gps_latitude IS NOT NULL
	and trc_gps_longitude IS NOT NULL
	and trc_status <> 'OUT'
	and trc_number NOT IN ('COLEMAN','I2382','NFITEST2')
	and geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY) = 1
	OR geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY2) = 1
ORDER BY 1")
  
  glimpse(TractorLocation)
  summary(TractorLocation)
  
  ###If you need to filter results of SQL query
  Filtered_TractorLocation <- filter(TractorLocation, TrcBranch!='xxx')
  
  ###Back to entire SQL output
  Filtered_TractorLocation <- TractorLocation
  
  ###Create Data Frame to define Lat Long of Equipment
  df <- data.frame(longitude = Filtered_TractorLocation$TrcLongitude, 
                   latitude = Filtered_TractorLocation$TrcLatitude)
  
  #Make Custom Icon
  TractorWest <- makeIcon(
    iconUrl = "C:/Users/SullivanRy/Documents/R/projects & history/WTruck.png",
    iconWidth = 35, iconHeight = 35,
    iconAnchorX = 0, iconAnchorY = 0)
  
  ###Plot on Leaflet Map-OSM
  trcmap <- leaflet(df) %>% 
    addTiles() %>%
    addMarkers(
      clusterOptions = markerClusterOptions(), 
      label=Filtered_TractorLocation$BranchwithTrc,
      labelOptions = labelOptions(noHide = F, textsize = "12px"),
      icon = TractorWest,
      popup = ~paste0("<strong>","Tractor PC: ","<strong>",Filtered_TractorLocation$TrcBranch,
                      "<br/>Tractor Number: ", Filtered_TractorLocation$TrcNumber,
                      "<br/>Status: ", Filtered_TractorLocation$TrcStatus,
                      "<br/>Location: ", Filtered_TractorLocation$TrcGPSDesc,
                      "<br/>Last Ping: ", Filtered_TractorLocation$TrcGPSDate)
    ) %>%
    ###Include Live Weather Overlay
    addWMSTiles(
      "http://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r.cgi",
      layers = "nexrad-n0r-900913",
      options = WMSTileOptions(format = "image/png", transparent = TRUE),
      attribution = "Weather data © 2012 IEM Nexrad") 
  
  ###Return the Map
  trcmap
  
  ###Export and Overwrite to Local CSV File 
  write.table(Filtered_TractorLocation, 
              file="C:/Users/SullivanRy/Documents/twoPolygons_TractorLocations.csv", 
              row.names=F,
              col.names=F,
              sep=",",
              append=TRUE)
  
  ###Save Current Tractor Image 
  htmlwidgets::saveWidget(trcmap, file = "C:/Users/SullivanRy/Documents/twoPolygons_TractorLocations.html")
  
  ###Read in the pings data 
  TrcPings <- read.csv("C:/Users/SullivanRy/Documents/twoPolygons_TractorLocations.csv",header=TRUE)
  
  ###Create Color Palette 
  df3 <- data.frame(TrcNumber = unique(TrcPings$TrcNumber))
  df3$TrcColor <- factor(sample.int(nrow(df3), nrow(df3), FALSE))
  factpal <- colorFactor(topo.colors(nrow(df3)), df3$TrcColor)
  
  ###Join Colors to table
  TrcPings <- merge(x = TrcPings, y = df3, by = "TrcNumber", all.x = TRUE)
  
  ###Sort by Tractor and Ping Date-Times
  TrcPings <- TrcPings[order(TrcPings$TrcColor,TrcPings$TrcNumber,TrcPings$TrcGPSDate ),]
  
  ###Create Map with Circles
  trclines <- leaflet() %>% 
    addTiles() %>%
    addCircles(data = TrcPings,
               lng = TrcPings$TrcLongitude, 
               lat = TrcPings$TrcLatitude,
               radius = 1700,
               stroke = TRUE,
               opacity = 5,
               weight = 1,
               fillColor = ~factpal(TrcPings$TrcColor),
               fillOpacity = 1,
               highlightOptions = highlightOptions(color = "white", weight = 2,
                                                   bringToFront = TRUE),
               group = "Pings",
               popup = ~paste0("<strong>","Tractor PC: ","<strong>",TrcPings$TrcBranch,
                               "<br/>Tractor Number: ", TrcPings$TrcNumber,
                               "<br/>Status: ", TrcPings$TrcStatus,
                               "<br/>Location: ", TrcPings$TrcGPSDesc,
                               "<br/>Date-Time: ", TrcPings$TrcGPSDate)) %>% 
    addLayersControl(
      overlayGroups = c("Pings","Trail"),
      #overlayGroups = c(TrcPings$TrcBranch),
      options = layersControlOptions(collapsed = FALSE)
    )
  ###Loop for Lines by Group
  for(x in levels(TrcPings$TrcColor)){
    trclines = addPolylines(trclines,
                            data = TrcPings[TrcPings$TrcColor == x,], 
                            lng = ~ TrcLongitude, #TrcPings$TrcLongitude, 
                            lat = ~ TrcLatitude, #TrcPings$TrcLatitude,
                            color= "blue",
                            group = "Trail",
                            weight = 3)
  }
  
  ###Return the Map
  trclines
  
  ###Remove TrcColor Column for replacement
    ###ADJUST FOR THE NUMBER OF COLUMNS IF ADDING IN SEARCH STATES, POLYGONS, OR POINTS
  TrcPings <- TrcPings[-c(15)]
  
  ###Write Back Sorted Table
  write.table(TrcPings, 
              file="C:/Users/SullivanRy/Documents/twoPolygons_TractorLocations.csv", 
              row.names=F,
              col.names=T,
              sep=",",
              append=FALSE)
  
  ###Save Current Tractor Lines 
  htmlwidgets::saveWidget(trclines, file = "C:/Users/SullivanRy/Documents/twoPolygons_TractorLocationsLines.html")
  
  #Specify how long between intervals 
  Sys.sleep(900) # Wait n seconds
}
