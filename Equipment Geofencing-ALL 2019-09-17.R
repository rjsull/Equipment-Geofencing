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
                            "DECLARE @STARTDATE AS DATETIME
DECLARE @TRACTOR AS VARCHAR(6)
DECLARE @PC AS VARCHAR(3)
DECLARE @LAT VARCHAR(10)
DECLARE @LONG VARCHAR(10)
DECLARE @GEO1 GEOGRAPHY
DECLARE @POLY GEOGRAPHY
DECLARE @STATE0 AS VARCHAR(2)
DECLARE @STATE1 AS VARCHAR(2)
DECLARE @STATE2 AS VARCHAR(2)
DECLARE @STATE3 AS VARCHAR(2)
DECLARE @MILES AS INT

SET @STARTDATE = DATEADD(DAY,-1,getdate())
SET @TRACTOR = '191005'
SET @PC = '883'
SET @LAT='37.5848' --Center of Kentucky
SET @LONG='-84.6243' 
SET @GEO1= geography::Point(@LAT, @LONG, 4326)
SET @POLY= geography::STGeomFromText('POLYGON((-84.358 39.653, -82.348 37.649, 
      -85.348 36.658, -88.358 37.658, -84.358 39.653))', 4326)
SET @STATE0 = 'NJ' -- Seach State
SET @STATE1 = 'NY' -- Seach State
SET @STATE2 = 'MA' -- Seach State
SET @STATE3 = 'CT' -- Seach State
SET @MILES = 3000

SELECT -- top 100
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
	/*,[TrcPoint] = geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60)*-1,0), 4326) */
	/*,[SearchPoint] = @GEO1 */
	/*,[DistanceFromPoint] = ROUND(@GEO1.STDistance(geography::Point(
	  ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326))/1609.34,2)*/
	  /*StartPoint.STDistance(EndPoint), SRID = 4326, 1609.34 meters-miles conversion*/
	/*,[SearchPolygon] = @POLY*/
	/*,[WithinPolygon] = 
		CASE 
		WHEN geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
		  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY) = 0 
		THEN 1
		ELSE 0
		END*/
	/*,[SearchState] = CONCAT(@STATE0,@STATE1,@STATE2,@STATE3)*/
FROM tractorprofile 
WHERE
	--and 
	--trc_number = @Tractor
	--trc_number NOT IN ('171306','173032','193066','163025','163035','173087','193117','101096','BRE461','173234','BRE453')
	--and 
	--trc_branch = @PC
	--and 
	--and 
	trc_branch NOT IN ('001','002','003','004','006','UNKNOWN')
	--and trc_number LIKE 'BR%'
	and trc_gps_latitude IS NOT NULL
	and trc_gps_longitude IS NOT NULL
	and trc_status <> 'OUT'
	/*and @GEO1.STDistance(geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326))/1609.34 < @Miles*/
	/*and geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY) = 0*/
	/*and RIGHT(LEFT(trc_gps_desc, CHARINDEX(', ', trc_gps_desc)+3),2) IN (@STATE0,@STATE1,@STATE2,@STATE3)*/
ORDER BY 1")

#glimpse(TractorLocation)
#summary(TractorLocation)

###To just get the headers 
Filtered_TractorLocation <- filter(TractorLocation, TrcBranch=='xxx')

###Export and Overwrite to Local CSV File 
write.table(Filtered_TractorLocation, 
            file="C:/Users/SullivanRy/Documents/ALL_TractorLocations.csv", 
            row.names=F,
            col.names=T,
            sep=",",
            append=FALSE)

#Repeat in intervals, append the table
repeat {
  ###Contains SQL that can search radius, polygon, or state lines
  TractorLocation <- sqlQuery(dbhandle, 
                              "DECLARE @STARTDATE AS DATETIME
DECLARE @TRACTOR AS VARCHAR(6)
DECLARE @PC AS VARCHAR(3)
DECLARE @LAT VARCHAR(10)
DECLARE @LONG VARCHAR(10)
DECLARE @GEO1 GEOGRAPHY
DECLARE @POLY GEOGRAPHY
DECLARE @STATE0 AS VARCHAR(2)
DECLARE @STATE1 AS VARCHAR(2)
DECLARE @STATE2 AS VARCHAR(2)
DECLARE @STATE3 AS VARCHAR(2)
DECLARE @MILES AS INT

SET @STARTDATE = DATEADD(DAY,-1,getdate())
SET @TRACTOR = '191005'
SET @PC = '883'
SET @LAT='37.5848' --Center of Kentucky
SET @LONG='-84.6243' 
SET @GEO1= geography::Point(@LAT, @LONG, 4326)
SET @POLY= geography::STGeomFromText('POLYGON((-84.358 39.653, -82.348 37.649, 
      -85.348 36.658, -88.358 37.658, -84.358 39.653))', 4326)
SET @STATE0 = 'NJ' -- Seach State
SET @STATE1 = 'NY' -- Seach State
SET @STATE2 = 'MA' -- Seach State
SET @STATE3 = 'CT' -- Seach State
SET @MILES = 3000

SELECT -- top 100
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
	/*,[TrcPoint] = geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60)*-1,0), 4326) */
	/*,[SearchPoint] = @GEO1 */
	/*,[DistanceFromPoint] = ROUND(@GEO1.STDistance(geography::Point(
	  ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326))/1609.34,2)*/
	  /*StartPoint.STDistance(EndPoint), SRID = 4326, 1609.34 meters-miles conversion*/
	/*,[SearchPolygon] = @POLY*/
	/*,[WithinPolygon] = 
		CASE 
		WHEN geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
		  ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY) = 0 
		THEN 1
		ELSE 0
		END*/
	/*,[SearchState] = CONCAT(@STATE0,@STATE1,@STATE2,@STATE3)*/
FROM tractorprofile 
WHERE
	--and 
	--trc_number = @Tractor
	--trc_number NOT IN ('171306','173032','193066','163025','163035','173087','193117','101096','BRE461','173234','BRE453')
	--and 
	--trc_branch = @PC
	--and 
	--and 
	trc_branch NOT IN ('001','002','003','004','006','UNKNOWN')
	--and trc_number LIKE 'BR%'
	and trc_gps_latitude IS NOT NULL
	and trc_gps_longitude IS NOT NULL
	and trc_status <> 'OUT'
	/*and @GEO1.STDistance(geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326))/1609.34 < @Miles*/
	/*and geography::Point(ISNULL(((CONVERT(decimal,(trc_gps_latitude))/60)/60),0),
	ISNULL(((CONVERT(decimal,(trc_gps_longitude))/60)/60),0)*-1, 4326).STIntersects(@POLY) = 0*/
	/*and RIGHT(LEFT(trc_gps_desc, CHARINDEX(', ', trc_gps_desc)+3),2) IN (@STATE0,@STATE1,@STATE2,@STATE3)*/
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
              file="C:/Users/SullivanRy/Documents/ALL_TractorLocations.csv", 
              row.names=F,
              col.names=F,
              sep=",",
              append=TRUE)
  
  ###Save Current Tractor Image 
  htmlwidgets::saveWidget(trcmap, file = "C:/Users/SullivanRy/Documents/ALL_TractorLocations.html")
  
  ###Read in the pings data 
  TrcPings <- read.csv("ALL_TractorLocations.csv",header=TRUE)
  
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
  TrcPings <- TrcPings[-c(13)]
  
  ###Write Back Sorted Table
  write.table(TrcPings, 
              file="C:/Users/SullivanRy/Documents/ALL_TractorLocations.csv", 
              row.names=F,
              col.names=T,
              sep=",",
              append=FALSE)
  
  ###Save Current Tractor Lines 
  htmlwidgets::saveWidget(trclines, file = "C:/Users/SullivanRy/Documents/ALL_TractorLocationsLines.html")
  
  #Specify how long between intervals 
  Sys.sleep(1800) # Wait n seconds
}
