## Script developed by Xavier Hoenner, created on 9 Sep 2015
## Last modified on 16 Apr 2019

library(RPostgreSQL);library(gmt);library(plyr); library(RPostgres);
options(warn=2);
source('config.conf')
con <- dbConnect(RPostgres::Postgres(), dbname = "harvest", host = HOST, user = USER, port = '5432', password = PASS)

dat <- dbGetQuery(con, "SELECT * FROM dw_aatams_acoustic.aatams_acoustic_species_all_deployments_view;")
dbDisconnect(con);

dat$first_detection <- strptime(as.character(dat$first_detection),'%Y-%m-%d', tz ='UTC')
dat$last_detection <- strptime(as.character(dat$last_detection),'%Y-%m-%d', tz ='UTC')
dat$embargo_date <- strptime(as.character(dat$embargo_date),'%Y-%m-%d', tz ='UTC')
data <- dat[-which(is.na(dat$embargo_date) == T),]

## Plot embargo data
# data <- data[-which(data$embargo_date < Sys.time()),] ## only plot data after current date
data <- data[order(data$embargo_date),]

emb <- unique(data$embargo_date)

res <- data.frame(matrix(ncol=2,nrow=length(emb)))
for (i in 1:length(emb)){
	res[i,1] <- length(data$transmitter_id[which(data$embargo_date > emb[i])]) ## Number of transmitters embargoed
	res[i,2] <- sum(as.numeric(as.character(data$no_detections[which(data$embargo_date > emb[i])]))) ## Number of transmitters embargoed
}

res <- cbind(emb,res)

outfile <- paste(file.path(SHERYL_PATH),'eMII_data_report/AATAMS_EmbargoPlots/EmbargoPlot_',        Sys.Date(),'.jpeg',sep='')
jpeg(outfile, width = 800, height = 600, units = 'px', quality = 100)


## add extra space to right margin of plot within frame
par(mar=c(5, 5, 4, 7.5) + 0.1, cex.lab = 1.5)

## Plot first set of data and draw its axis
plot(res[,1], res[,2], pch=16, xlab="", ylab="", 
   type="b",col="black", main="Tags and detections embargoed")
# axis(2, ylim=c(0,1),col="black",las=1)  ## las=1 makes horizontal labels
mtext("Number of tags embargoed",side=2,line=3.5, cex = 1.2)
box()

## Allow a second plot on the same graph
par(new=TRUE)

## Plot the second plot and put axis scale on right
plot(res[,1], round(res[,3]/1000000,1), pch=15,  xlab="", ylab="", 
    axes=FALSE, type="b", col="red", cex.lab = 5)
## a little farther out (line=4) to make room for labels
mtext("Number of detections embargoed (in millions)",side=4,col="red",line=5, cex = 1.2) 
axis(4, ylim=c(0,7000), col="red",col.axis="red",las=1, cex = 2)
abline(v= Sys.time(), lty = 'dashed', pch = 1.5);

## Draw the time axis
# axis(1,pretty(range(time),10))
mtext("Date",side=1,col="black",line=2.5);
mtext(format(Sys.time(),'%b %Y'), side = 1, at = Sys.time(), line = 0.5, las =2, cex = 1.2);

## Add Legend
legend("topright",legend=c("Number of tags embargoed","Number of detections embargoed (in millions)"),
  text.col=c("black","red"),pch=c(16,15),col=c("black","red"))

dev.off()
flask_figure <-paste('../figures/eMII_data_report/AATAMS_EmbargoPlots/EmbargoPlot_',Sys.Date(),'.jpeg',sep='')
file.copy(outfile,flask_figure)

