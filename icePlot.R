# Seasonal ice hockey playability prediction
# visualization and jugdement of predictive model quality
# Berry Boessenkool, berry-b@gmx.de, June + Sept 2019

# in optimization, use plot=FALSE to only compute the model goodness of fit 
# measured with the correct classification rate (CCR) of the prediction

icePlot <- function(
days,             # (sequential) calender dates
ice,              # TRUE/FALSE vector - actual playing possibility
model=NULL,       # TRUE/FALSE vector - model prediction (optional)
winter_only=TRUE, # cut to the playing season January-March?
plot=TRUE,        # plot figure? 
label_gof=TRUE,   # Label CCR?
main="Ice hockey Potsdam", # Graph title
...               # Aguments passed to points (beware some are hard coded, like x,y,pch,col,cex)
)
{
# input checks:
stopifnot(length(days)==length(ice))
if(!is.null(model)) stopifnot(length(days)==length(model))  
# cut to season:
if(winter_only)
  {
  winter <- format(days,"%m-%d") %in% format(as.Date("2016-01-01")+0:90,"%m-%d")
  days  <-  days[winter]
  ice   <-   ice[winter]
  model <- model[winter]
  }
#
# helper function to add points at day of year (doy):
add_doys <- function(dates, offset=0, ...)
  {
  doy <- tapply(dates, format(dates, "%Y"), function(d) as.Date(format(d, "2016-%m-%d")))
  for(y in names(doy)) 
    {
    doy_i <- doy[[y]]
    ycoord <- rep(as.numeric(y), length(doy_i))
    points(doy_i, ycoord-offset, ...)
    }
  }
#
# compute model goodness of fit:
# correct classification rate
if(!is.null(model))
  {
  # True positives + negatives:
  TP <- ice & model
  TN <- !ice & !model
  ccr <- (sum(TP)+sum(TN))/length(days)
  } else
  ccr <- NA
#
# plot:
if(plot)
  {
  op <- par(mar=c(3,4,2,0.5))
  on.exit(par(op), add=TRUE)
  # empty graph, axes etc:
  minyear <- as.numeric(format(min(days),"%Y"))
  maxyear <- as.numeric(format(max(days),"%Y"))
  plot(as.Date("2016-01-01")+c(0,90), c(1,1), type="n", ylim=c(maxyear, minyear), 
       xaxt="n", ylab="Year", xlab="", yaxt="n", main=main)
  berryFunctions::monthAxis(mlabels=month.abb, yformat=" ", quiet=TRUE, 
                            ytcl=par("tcl"), mcex=1, mline=-0.5)
  title(xlab="Date", line=1.7)
  abline(h=minyear:maxyear, col=8)
  axis(2, minyear:maxyear, las=1, mgp=c(3,0.7,0))
  # add points for actual playing days:
  add_doys(days[ice], offset=0.02, col="blue", pch="*", cex=1.2, ...)  # -0.02 offset to have the stars on the line
  #
  if(!is.null(model))
  # add points for model prediction
  add_doys(days[model], col="grey", pch="|", cex=1.2, ...)
  if(label_gof & !is.na(ccr)) mtext(paste0("Correct: ", 
                                    berryFunctions::round0(ccr*100,1), "%"), 
                                    line=1, adj=1, outer=FALSE, col=8)
  } # plot end
# output:
return(c(ccr=ccr))
} # icePlot function end




if(!requireNamespace("berryFunctions", quietly=TRUE)) 
  stop("please first run:\ninstall.packages('berryFunctions')" )
