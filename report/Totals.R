rm(list=ls())
setwd('/Users/xavierhoenner/Work/Reports/reporting/report/TotalPlots')
dir.create(format(Sys.Date(),'%B %Y'))
setwd(format(Sys.Date(),'%B %Y'))

library(RPostgreSQL);library(gmt);library(plyr);
options(warn=2);
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "harvest", host = 'dbprod.emii.org.au', user = 'xavier', port = '5432', password = 'MicroCuts2001!')

dat <- dbGetQuery(con, "SELECT * FROM reporting.monthly_snapshot;")
dbDisconnect(con);
dbUnloadDriver(drv);

## Prepare for plotting
data <- data.frame(dat$timestamp,dat$facility,dat$subfacility, dat$data_type, dat$no_projects, dat$no_instruments, dat$no_deployments, dat$no_data, dat$no_data2, dat$no_data3, dat$no_data4)
colnames(data) <- c('timestamp','facility','subfacility','data_type','no_projects','no_instruments', 'no_deployments','no_data','no_data2','no_data3','no_data4')

argo <- data.frame(data$timestamp[which(data$facility == 'Argo')], data$no_data2[which(data$facility == 'Argo')], data$no_data3[which(data$facility == 'Argo')])
colnames(argo) <- c('timestamp','no_profiles','no_measurements')

soop <- data.frame(data$timestamp[which(data$facility == 'SOOP' & data$data_type == 'TOTAL')], data$no_data[which(data$facility == 'SOOP' & data$data_type == 'TOTAL')], data$no_data2[which(data$facility == 'SOOP' & data$data_type == 'TOTAL')])
colnames(soop) <- c('timestamp','no_data_files','no_measurements')

abos <- data.frame(data$timestamp[which(data$facility == 'ABOS' & data$data_type == 'TOTAL')], data$no_deployments[which(data$facility == 'ABOS' & data$data_type == 'TOTAL')], data$no_data[which(data$facility == 'ABOS' & data$data_type == 'TOTAL')])
colnames(abos) <- c('timestamp','no_deployments','no_data_files')

anfog <- data.frame(data$timestamp[which(data$facility == 'ANFOG' & data$data_type == 'TOTAL')], data$no_deployments[which(data$facility == 'ANFOG' & data$data_type == 'TOTAL')], data$no_data[which(data$facility == 'ANFOG' & data$data_type == 'TOTAL')])
colnames(anfog) <- c('timestamp','no_deployments','no_measurements')

auv <- data.frame(data$timestamp[which(data$facility == 'AUV')], data$no_instruments[which(data$facility == 'AUV')], data$no_data[which(data$facility == 'AUV')])
colnames(auv) <- c('timestamp','no_deployments','no_images')
auv <- auv[-which(as.character(auv$timestamp) == '2015-09-01 07:31:52'),]

anmn <- data.frame(data$timestamp[which(data$facility == 'ANMN' & data$subfacility == 'NRS, RMA, and AM')], data$no_deployments[which(data$facility == 'ANMN' & data$subfacility == 'NRS, RMA, and AM')], data$no_data2[which(data$facility == 'ANMN' & data$subfacility == 'NRS, RMA, and AM')])
colnames(anmn) <- c('timestamp','no_deployments','no_data_files') ## Always 54 sites

acorn <- data.frame(data$timestamp[which(data$facility == 'ACORN' & data$data_type != 'TOTAL')], data$data_type[which(data$facility == 'ACORN' & data$data_type != 'TOTAL')], data$no_data[which(data$facility == 'ACORN' & data$data_type != 'TOTAL')])
colnames(acorn) <- c('timestamp','data_type','no_data_files')
acorn <- acorn[-grep('TOTAL*',acorn$data_type),]
acorn$data_type[which(acorn$data_type == 'Gridded product - non QC')] <- 'Hourly vectors - non QC'
acorn$data_type[which(acorn$data_type == 'Gridded product - QC')] <- 'Hourly vectors - QC'
time <- unique(acorn$timestamp)
acorn2 <- data.frame(matrix(ncol=2,nrow=length(time)))
for (i in 1:length(time)){
	acorn2[i,1] <- sum(acorn$no_data_files[which(acorn$timestamp == time[i] & (acorn$data_type == 'Hourly vectors - non QC' | acorn$data_type == 'Hourly vectors - QC'))])
	acorn2[i,2] <- sum(acorn$no_data_files[which(acorn$timestamp == time[i] & (acorn$data_type == 'Radials - non QC' | acorn$data_type == 'Radials - QC'))])
}
acorn <- cbind(time,acorn2); rm(acorn2); rm(time);
colnames(acorn) <- c('timestamp','no_vector_files','no_radial_files')

aatams_sattag <- data.frame(data$timestamp[which(data$facility == 'AATAMS' & data$data_type == 'Delayed mode CTD data')], data$no_data[which(data$facility == 'AATAMS' & data$data_type == 'Delayed mode CTD data')], data$no_data2[which(data$facility == 'AATAMS' & data$data_type == 'Delayed mode CTD data')])
colnames(aatams_sattag) <- c('timestamp','no_profiles','no_measurements')

# aatams_acoustic <- data.frame(data$timestamp[which(data$subfacility == 'Acoustic tagging - Species' & data$data_type == 'Other stats')], data$no_deployments[which(data$subfacility == 'Acoustic tagging - Species' & data$data_type == 'Other stats')], data$no_data2[which(data$subfacility == 'Acoustic tagging - Species' & data$data_type == 'Other stats')])
# colnames(aatams_acoustic) <- c('timestamp','no_transmitters','no_detections')

faimms <- data.frame(data$timestamp[which(data$facility == 'FAIMMS')], data$no_data[which(data$facility == 'FAIMMS')], data$no_data2[which(data$facility == 'FAIMMS')])
colnames(faimms) <- c('timestamp','no_qc_datasets','no_measurements')

srs <- data.frame(data$timestamp[which(data$facility == 'SRS')], data$no_data[which(data$facility == 'SRS')], data$no_data2[which(data$facility == 'SRS')])
colnames(srs) <- c('timestamp','no_measurements','no_gridded_images')




##########################################################################################
##########################################################################################
#################################### PLOTTING MADNESS ####################################
##########################################################################################
##########################################################################################

##############################
#### Plot totals -- AATAMS SATTAG
jpeg(paste('Totals_AATAMS_SATTAG_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(aatams_sattag$timestamp, aatams_sattag$no_profiles, pch=16, xlab="", ylab="", 
   type="b",col="black", main="Animal tracking (satellite) - Number of profiles and measurements", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of profiles",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(aatams_sattag$timestamp, aatams_sattag$no_measurements, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of measurements",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(aatams_sattag$timestamp[1],tail(aatams_sattag$timestamp,1), by = "month")[seq(1,length(seq(aatams_sattag$timestamp[1],tail(aatams_sattag$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of profiles","Number of measurements"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()

##############################
#### Plot totals -- AATAMS Acoustic
jpeg(paste('Totals_AATAMS_Acoustic_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(aatams_acoustic$timestamp, aatams_acoustic$no_transmitters, pch=16, xlab="", ylab="", 
   type="b",col="black", main="Animal tracking (acoustic) - Number of transmitters and detections", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of transmitters",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(aatams_acoustic$timestamp, aatams_acoustic$no_detections, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of detections",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(aatams_acoustic$timestamp[1],tail(aatams_acoustic$timestamp,1), by = "month")[seq(1,length(seq(aatams_acoustic$timestamp[1],tail(aatams_acoustic$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of transmitters","Number of detections"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()

##############################
#### Plot totals -- Argo
jpeg(paste('Totals_Argo_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(argo$timestamp, argo$no_profiles, pch=16, xlab="", ylab="", 
   type="b",col="black", main="Argo - Number of profiles and measurements", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of profiles",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(argo$timestamp, argo$no_measurements, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of measurements",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(argo$timestamp[1],tail(argo$timestamp,1), by = "month")[seq(1,length(seq(argo$timestamp[1],tail(argo$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of profiles","Number of measurements"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()


##############################
#### Plot totals -- ABOS
jpeg(paste('Totals_ABOS_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(abos$timestamp, abos$no_deployments, pch=16, xlab="", ylab="", 
   type="b",col="black", main="ABOS - Number of deployments and QC'd data files", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of deployments",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(abos$timestamp, abos$no_data_files, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of QC'd data files",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(abos$timestamp[1],tail(abos$timestamp,1), by = "month")[seq(1,length(seq(abos$timestamp[1],tail(abos$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of deployments","Number of QC'd data files"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()

##############################
#### Plot totals -- ACORN
jpeg(paste('Totals_ACORN_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(acorn$timestamp, acorn$no_vector_files, pch=16, xlab="", ylab="", 
   type="b",col="black", main="ACORN - Number of vector and radial data files", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of vector data files",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(acorn$timestamp, acorn$no_radial_files, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of radial data files",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(acorn$timestamp[1],tail(acorn$timestamp,1), by = "month")[seq(1,length(seq(acorn$timestamp[1],tail(acorn$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of vector data files","Number of radial data files"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()

##############################
#### Plot totals -- ANFOG
jpeg(paste('Totals_ANFOG_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(anfog$timestamp, anfog$no_deployments, pch=16, xlab="", ylab="", 
   type="b",col="black", main="ANFOG - Number of deployments and measurements", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of deployments",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(anfog$timestamp, anfog$no_measurements, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of measurements",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(anfog$timestamp[1],tail(anfog$timestamp,1), by = "month")[seq(1,length(seq(anfog$timestamp[1],tail(anfog$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of deployments","Number of measurements"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()

##############################
#### Plot totals -- ANMN
jpeg(paste('Totals_ANMN_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(anmn$timestamp, anmn$no_deployments, pch=16, xlab="", ylab="", 
   type="b",col="black", main="ANMN - Number of deployments and QC'd data files", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of deployments",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(anmn$timestamp, anmn$no_data_files, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of QC'd data files",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(anmn$timestamp[1],tail(anmn$timestamp,1), by = "month")[seq(1,length(seq(anmn$timestamp[1],tail(anmn$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of deployments","Number of QC'd data files"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()

##############################
#### Plot totals -- AUV
jpeg(paste('Totals_AUV_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(auv$timestamp, auv$no_deployments, pch=16, xlab="", ylab="", 
   type="b",col="black", main="AUV - Number of deployments and images", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of deployments",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(auv$timestamp, auv$no_images, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of images",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(auv$timestamp[1],tail(auv$timestamp,1), by = "month")[seq(1,length(seq(auv$timestamp[1],tail(auv$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of deployments","Number of images"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()

##############################
#### Plot totals -- FAIMMS
jpeg(paste('Totals_FAIMMS_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(faimms$timestamp, faimms$no_measurements, pch=16, xlab="", ylab="", 
   type="b",col="black", main="FAIMMS - Number of measurements and QC'd datasets", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of measurements",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(faimms$timestamp, faimms$no_qc_datasets, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of QC'd datasets",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(faimms$timestamp[1],tail(faimms$timestamp,1), by = "month")[seq(1,length(seq(faimms$timestamp[1],tail(faimms$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of measurements","Number of QC'd datasets"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()

##############################
#### Plot totals -- SOOP
jpeg(paste('Totals_SOOP_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(soop$timestamp, soop$no_data_files, pch=16, xlab="", ylab="", 
   type="b",col="black", main="SOOP - Number of no_data_files and measurements", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of data files",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(soop$timestamp, soop$no_measurements, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of measurements",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(soop$timestamp[1],tail(soop$timestamp,1), by = "month")[seq(1,length(seq(soop$timestamp[1],tail(soop$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of data files","Number of measurements"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()

##############################
#### Plot totals -- SRS
jpeg(paste('Totals_SRS_',Sys.Date(),'.jpeg',sep=''), width = 800, height = 600, units = 'px', quality = 100)
par(mar=c(5, 6.5, 4, 6.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(srs$timestamp, srs$no_gridded_images, pch=16, xlab="", ylab="", 
   type="b",col="black", main="SRS - Number of gridded images and measurements", axes=FALSE)
axis(2, col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of gridded images",side=2,line=5)
box()

## Plot the second plot and put axis scale on right
par(new=TRUE)
plot(srs$timestamp, srs$no_measurements, pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of measurements",side=4,col="red",line=5) 
axis(4, col="red",col.axis="red",las=1, cex = 2)

## Draw the time axis
axis.POSIXct(1, at = seq(srs$timestamp[1],tail(srs$timestamp,1), by = "month")[seq(1,length(seq(srs$timestamp[1],tail(srs$timestamp,1), by = "month")),2)], format = '%b %Y')
mtext("Date",side=1,col="black",line=2.5)  

## Add Legend
legend("topleft",legend=c("Number of gridded images","Number of measurements"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))
dev.off()