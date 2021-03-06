#' Graph of annual concentration, flow normalized concentration, 
#' and confidence bands for flow normalized concentrations
#' 
#' Uses the output of modelEstimation in the EGRET package (results in the named 
#' list eList), and the data frame CIAnnualResults (produced by EGRETci package 
#' using scripts described in the vignette) to produce a graph of annual 
#' concentration, flow normalized concentration, and confidence bands for 
#' flow-normalized concentrations.  In addition to the arguments listed below, 
#' it will accept any additional arguments that are listed for the EGRET function 
#' plotConcHist.
#'
#' @param eList named list from EGRET package after running modelEstimation
#' @param CIAnnualResults data frame generated from ciBands (includes nBoot, probs, and blockLength attributes)
#' @param yearStart numeric is the calendar year containing the first estimated annual value to be plotted, default is NA (which allows it to be set automatically by the data)
#' @param yearEnd numeric is the calendar year just after the last estimated annual value to be plotted, default is NA (which allows it to be set automatically by the data)
#' @param plotFlowNorm logical variable if TRUE flow normalized line is plotted, if FALSE not plotted 
#' @param col.pred character prediction color
#' @param concMax number specifying the maximum value to be used on the vertical axis, default is NA (which allows it to be set automatically by the data)
#' @param printTitle logical
#' @param cex.main numeric title scale
#' @param \dots graphical parameters
#' @export
#' @importFrom EGRET setupYears
#' @importFrom EGRET setSeasonLabel
#' @importFrom EGRET plotConcHist
#' @examples
#' library(EGRET)
#' eList <- Choptank_eList
#' CIAnnualResults <- Choptank_CIAnnualResults
#' plotConcHistBoot(eList, CIAnnualResults)
#' plotConcHistBoot(eList, CIAnnualResults, yearStart=1990, yearEnd=2002)
#' \dontrun{
#' CIAnnualResults <- ciCalculations(eList, nBoot = 100, blockLength = 200)
#' plotConcHistBoot(eList, CIAnnualResults)
#' }
plotConcHistBoot <- function (eList, CIAnnualResults, yearStart = NA, yearEnd = NA, 
                              plotFlowNorm=TRUE, col.pred="green", concMax = NA,
                              printTitle=TRUE, cex.main=1.1, ...){
  
  nBoot <- attr(CIAnnualResults, "nBoot")
  blockLength <- attr(CIAnnualResults, "blockLength")
  probs <- attr(CIAnnualResults, "probs")
  
  widthCI <- (max(probs) - min(probs))*100
  
  localAnnualResults <- setupYears(paStart = eList$INFO$paStart, paLong = eList$INFO$paLong,
                                   localDaily = eList$Daily)
  periodName <- setSeasonLabel(localAnnualResults)
  title3 <- paste(widthCI,"% CI on FN Concentration, Replicates =",nBoot,"Block=",blockLength,"days")

  title <- paste(eList$INFO$shortName, " ", eList$INFO$paramShortName, 
                   "\n", periodName, "\n",title3)
  
  if(is.na(concMax)){
    numYears <- length(localAnnualResults$DecYear)
    yearStart <- if(is.na(yearStart)) trunc(localAnnualResults$DecYear[1]) else yearStart
    yearEnd <- if(is.na(yearEnd)) trunc(localAnnualResults$DecYear[numYears])+1 else yearEnd
    subAnnualResults<-localAnnualResults[localAnnualResults$DecYear>=yearStart & localAnnualResults$DecYear <= yearEnd,]
    
    annConc <- subAnnualResults$Conc
    concMax <- 1.05*max(c(CIAnnualResults$FNConcHigh,annConc), na.rm=TRUE)
  }
  
  plotConcHist(eList, yearStart = yearStart, yearEnd = yearEnd,
               col.pred=col.pred, printTitle=FALSE, 
               plotFlowNorm = plotFlowNorm, concMax = concMax, ...)
  if(printTitle) {
    title(main=title, cex.main=cex.main)
  }
  
  if(!is.na(yearStart)){
    CIAnnualResults <- CIAnnualResults[CIAnnualResults$Year >= yearStart, ]
  }
  
  if(!is.na(yearEnd)){
    CIAnnualResults <- CIAnnualResults[CIAnnualResults$Year <= yearEnd, ]
  }
  
  lines(CIAnnualResults$Year, CIAnnualResults$FNConcLow,lty=2,col=col.pred)
  lines(CIAnnualResults$Year, CIAnnualResults$FNConcHigh, lty=2,col=col.pred)
  
}

#' plotFluxHistBoot
#'
#' plotFluxHistBoot
#'
#' @param eList named list
#' @param CIAnnualResults data frame from ciBands (needs nBoot, probs, and blockLength attributes)
#' @param yearStart numeric is the calendar year containing the first estimated annual value to be plotted, default is NA (which allows it to be set automatically by the data)
#' @param yearEnd numeric is the calendar year just after the last estimated annual value to be plotted, default is NA (which allows it to be set automatically by the data)
#' @param fluxUnit number representing entry in pre-defined fluxUnit class array. \code{\link{printFluxUnitCheatSheet}}
#' @param fluxMax number specifying the maximum value to be used on the vertical axis, default is NA (which allows it to be set automatically by the data)
#' @param plotFlowNorm logical variable if TRUE flow normalized line is plotted, if FALSE not plotted 
#' @param col.pred character prediction color
#' @param printTitle logical
#' @param cex.main numeric title scale
#' @param \dots graphical parameters
#' @export
#' @importFrom EGRET setupYears
#' @importFrom EGRET setSeasonLabel
#' @importFrom EGRET plotFluxHist
#' @importFrom EGRET fluxConst
#' @examples
#' library(EGRET)
#' eList <- Choptank_eList 
#' CIAnnualResults <- Choptank_CIAnnualResults
#' plotFluxHistBoot(eList, CIAnnualResults, fluxUnit=5)
#' 
#' \dontrun{
#' CIAnnualResults <- ciCalculations(eList, nBoot = 100, blockLength = 200)
#' plotFluxHistBoot(eList, CIAnnualResults, fluxUnit=5)
#' }
plotFluxHistBoot <- function (eList, CIAnnualResults, 
                              yearStart=NA, yearEnd=NA,
                              plotFlowNorm=TRUE, fluxUnit = 9, fluxMax=NA,
                              col.pred="green", printTitle=TRUE, 
                              cex.main=1.1, ...){
  
  nBoot <- attr(CIAnnualResults, "nBoot")
  blockLength <- attr(CIAnnualResults, "blockLength")
  probs <- attr(CIAnnualResults, "probs")
  
  widthCI <- (max(probs) - min(probs))*100
  
  localAnnualResults <- setupYears(paStart = eList$INFO$paStart, paLong = eList$INFO$paLong,
                                   localDaily = eList$Daily)
  periodName <- setSeasonLabel(localAnnualResults)
  title3 <- paste(widthCI,"% CI on FN Flux, Replicates =",nBoot,", Block=",blockLength,"days")
  
  title <- paste(eList$INFO$shortName, " ", eList$INFO$paramShortName, 
                 "\n", periodName, "\n",title3)
  
  if (is.numeric(fluxUnit)) {
    fluxUnit <- fluxConst[shortCode = fluxUnit][[1]]
  } else if (is.character(fluxUnit)) {
    fluxUnit <- fluxConst[fluxUnit][[1]]
  }
  unitFactorReturn <- fluxUnit@unitFactor
  
  if(is.na(fluxMax)){
    numYears <- length(localAnnualResults$DecYear)
    yearStart <- if(is.na(yearStart)) trunc(localAnnualResults$DecYear[1]) else yearStart
    yearEnd <- if(is.na(yearEnd)) trunc(localAnnualResults$DecYear[numYears])+1 else yearEnd
    subAnnualResults<-localAnnualResults[localAnnualResults$DecYear>=yearStart & localAnnualResults$DecYear <= yearEnd,]
    
    annFlux<-unitFactorReturn*subAnnualResults$Flux
    
    fluxMax <- 1.05*max(c(CIAnnualResults$FNFluxHigh*unitFactorReturn,annFlux), na.rm=TRUE)
  }
  
  plotFluxHist(eList, yearStart = yearStart, yearEnd = yearEnd,
               fluxUnit=fluxUnit, col.pred=col.pred,fluxMax=fluxMax,
               plotFlowNorm = plotFlowNorm, printTitle=FALSE,...)
  if (printTitle) {
    title(main=title, cex.main=cex.main)
  }
  
  if(!is.na(yearStart)){
    CIAnnualResults <- CIAnnualResults[CIAnnualResults$Year >= yearStart, ]
  }
  
  if(!is.na(yearEnd)){
    CIAnnualResults <- CIAnnualResults[CIAnnualResults$Year <= yearEnd, ]
  }
  
  lines(CIAnnualResults$Year, CIAnnualResults$FNFluxLow*unitFactorReturn,
        lty=2,col=col.pred)
  lines(CIAnnualResults$Year, CIAnnualResults$FNFluxHigh*unitFactorReturn, 
        lty=2,col=col.pred)
  
}


#' saveCB
#'
#' saveCB
#'
#' @param eList named list with at least the Daily, Sample, and INFO dataframes
#' @export
#' @examples
#' library(EGRET)
#' eList <- Choptank_eList
#' \dontrun{
#' saveCB(eList)
#' }
saveCB<-function(eList){ 
  INFO <-eList$INFO
  saveName <- paste0(INFO$staAbbrev,".",INFO$constitAbbrev,".CB.RData")
  save.image(file = saveName)
  message("Saved to: ",getwd(),"/",saveName)
}

#' bootAnnual
#'
#' bootAnnual One bootstrap run.
#'
#' @param eList named list with at least the Daily, Sample, and INFO dataframes
#' @param blockLength integer suggested value is 200
#' @export
#' @importFrom EGRET as.egret
#' @importFrom EGRET estSurfaces
#' @importFrom EGRET setupYears
#' @importFrom EGRET estDailyFromSurfaces
#' @examples
#' library(EGRET)
#' eList <- Choptank_eList
#' \dontrun{
#' annualResults <- bootAnnual(eList)
#' }
bootAnnual <- function(eList, blockLength=200){
  Sample <- eList$Sample
  Daily <- eList$Daily
  INFO <- eList$INFO
  paStart <- 10
  paLong <- 12
  
  if(!is.null(INFO$paLong)){
    paLong <- INFO$paLong
  }  
  if(!is.null(INFO$paStart)){
    paStart <- INFO$paStart
  }
  
  bootSample <- blockSample(Sample, blockLength)
  eListBoot <- as.egret(INFO,Daily,bootSample,NA)
  surfaces1<-estSurfaces(eListBoot)
  eListBoot<-as.egret(INFO,Daily,bootSample,surfaces1)
  Daily1<-estDailyFromSurfaces(eListBoot)
  annualResults1 <- setupYears(Daily1, paStart=paStart, paLong=paLong)
  annualResults1$year <- as.integer(annualResults1$DecYear)
  annualResults <- annualResults1[,c("year","FNConc","FNFlux")]
  
  attr(annualResults, "blockLength") <- blockLength
  return(annualResults)
}

#' ciBands
#'
#' ciBands
#'
#' @param repAnnualResults named list returned from bootstrapping process
#' @param eList named list
#' @param probs vector high and low confidence interval percentages
#' @export
#' @importFrom EGRET setupYears
#' @examples
#' library(EGRET)
#' eList <- Choptank_eList
#' nBoot <- 100
#' blockLength <- 200
#' \dontrun{
#' 
#' repAnnualResults <- vector(mode = "list", length = nBoot)
#' for(n = 1:nBoot){
#'    annualResults <- bootAnnual(eList, blockLength) 
#'    repAnnualResults[[n]] <- bootAnnual(eList, blockLength)
#' }
#' 
#' CIAnnualResults <- ciBands(eList, repAnnualResults)
#' 
#' }
ciBands <- function(eList, repAnnualResults, probs=c(0.05,0.95)){

  if(length(probs) != 2){
    stop("Please provide only lower and upper limit in the probs argument")
  }

  paStart <- 10
  paLong <- 12
  
  INFO <- eList$INFO
  
  if(!is.null(INFO$paLong)){
    paLong <- INFO$paLong
  }
  
  if(!is.null(INFO$paStart)){
    paStart <- INFO$paStart
  }
  
  AnnualResults <- setupYears(eList$Daily, paLong = paLong, paStart=paStart)
  
  nBoot <- length(repAnnualResults)
  numYears <- nrow(repAnnualResults[[1]])
  yearStart <- repAnnualResults[[1]][1,1]
  blockLength <- attr(repAnnualResults[[1]], "blockLength")
  
  manyAnnualResults <- array(NA, dim=c(numYears,2,nBoot))
  for (i in 1:nBoot){
    manyAnnualResults[,1,i] <- 2*log(AnnualResults$FNConc) - log(repAnnualResults[[i]]$FNConc)
    manyAnnualResults[,2,i] <- 2*log(AnnualResults$FNFlux) - log(repAnnualResults[[i]]$FNFlux)
  }
  
  CIAnnualResults <- data.frame(matrix(ncol = 5, nrow = numYears))
  names(CIAnnualResults) <- c("Year","FNConcLow","FNConcHigh","FNFluxLow","FNFluxHigh")
  
  for(iYear in 1:numYears) {
    quantConc <- quantile(manyAnnualResults[iYear,1,1:nBoot],prob=probs,type=6)
    quantFlux <- quantile(manyAnnualResults[iYear,2,1:nBoot],prob=probs,type=6)
    
    CIAnnualResults$Year[iYear] <- AnnualResults$DecYear[iYear]
    CIAnnualResults$FNConcLow[iYear] <- exp(quantConc[1])
    CIAnnualResults$FNConcHigh[iYear] <- exp(quantConc[2])
    CIAnnualResults$FNFluxLow[iYear] <- exp(quantFlux[1])
    CIAnnualResults$FNFluxHigh[iYear] <- exp(quantFlux[2])
  }
  
  attr(CIAnnualResults, "nBoot") <- nBoot
  attr(CIAnnualResults, "probs") <- probs
  attr(CIAnnualResults, "blockLength") <- blockLength
  
  return(CIAnnualResults)
}

#' plotHistogramTrend
#'
#' plotHistogramTrend
#'
#' @param eList named list with at least the Daily, Sample, and INFO dataframes. Created from the EGRET package, after running \code{\link[EGRET]{modelEstimation}}.
#' @param eBoot named list. Returned from \code{\link{wBT}}.
#' @param caseSetUp data frame. Returned from \code{\link{trendSetUp}}.
#' @param xSeq vector defaults to seq(-100,100,10). It is recommended to try the default
#' first. The first argument in the seq function needs to be lower than the minimum value, the second argument 
#' needs to be higher than the highest value, both should probably be multiples of 10 or 20, 
#' and the third argument should probably be 5 or 10.  Finally, it is good to have the first and second arguments straddle zero. 
#' @param flux logical if TRUE, plots flux results, if FALSE plots concentration
#' @param printTitle logical if TRUE, includes title
#' @param cex.main numeric title font size
#' @param col.fill character fill color
#' @param \dots base R graphical parameters that can be passed to the hist function
#' @export
#' @examples
#' library(EGRET)
#' eList <- Choptank_eList
#' eBoot <- Choptank_eBoot
#' caseSetUp <- Choptank_caseSetUp
#' plotHistogramTrend(eList, eBoot, caseSetUp, flux=FALSE)
#' 
#' \dontrun{
#' caseSetUp <- trendSetUp(eList)
#' eBoot <- wBT(eList,caseSetUp)
#' plotHistogramTrend(eList, eBoot, caseSetUp,  
#'                    flux=FALSE, xSeq = seq(-20,60,5))
#' plotHistogramTrend(eList, eBoot, caseSetUp, 
#'                    flux=TRUE, xSeq = seq(-20,60,5))
#' }
plotHistogramTrend <- function (eList, eBoot, caseSetUp, xSeq=seq(-100,100,10), 
                                flux=TRUE, printTitle=TRUE, cex.main=1.1, col.fill="grey",...){
  
  periodName <- setSeasonLabel(data.frame(PeriodStart = eList$INFO$paStart, 
                                          PeriodLong = eList$INFO$paLong))
  if (flux) {
    change <- 100 * eBoot$bootOut$estF/eBoot$bootOut$baseFlux
    reps <- eBoot$pFlux
    xlabel <- "Flux trend, in %"
    titleWord <- "Flux"
  } else {
    change <- 100 * eBoot$bootOut$estC/eBoot$bootOut$baseConc
    reps <- eBoot$pConc
    xlabel <- "Concentration trend, in %"
    titleWord <- "Concentration"
  }
  
  titleToPrint <- ifelse(printTitle, 
                         paste("Histogram of trend in", 
                               eList$INFO$paramShortName, "\nFlow Normalized", titleWord, 
                               caseSetUp$year1, "to", caseSetUp$year2, "\n", eList$INFO$shortName, 
                               periodName), "")
  hist(reps, breaks = xSeq, yaxs = "i", xaxs = "i", tcl = 0.5, 
       main = titleToPrint, freq = FALSE, xlab = xlabel, col = col.fill, 
       cex.main = cex.main, ...)
  abline(v = change, lwd = 3, lty = 2)
  abline(v = 0, lwd = 3)
  box()
  axis(3, tcl = 0.5, labels = FALSE)
  axis(4, tcl = 0.5, labels = FALSE)
}
  
#' ciCalculations
#'
#' Interactive function to calculate WRTDS confidence bands
#'
#' @param eList named list
#' @param \dots optionally include nBoot, blockLength, or widthCI
#' @export
#' @importFrom EGRET modelEstimation
#' @examples
#' library(EGRET)
#' eList <- Choptank_eList
#' \dontrun{
#' CIAnnualResults <- ciCalculations(eList)
#' }
ciCalculations <- function (eList,...){
  
  matchReturn <- list(...)
  
  if(!is.null(matchReturn$nBoot)){
    nBoot <- matchReturn$nBoot
  } else {
    message("Enter nBoot, the number of bootstrap replicates to be used, typically 100")
    nBoot <- as.numeric(readline())
    cat("nBoot = ",nBoot," this is the number of replicates that will be run\n")
  }
  
  if(!is.null(matchReturn$blockLength)){
    blockLength <- matchReturn$blockLength
  } else {
    message("Enter blockLength, in days, typically 200 is a good choice")
    blockLength <- as.numeric(readline())
  }
  
  if(!is.null(matchReturn$widthCI)){
    widthCI <- matchReturn$widthCI
  } else {
    message("Enter confidence interval, for example 90 represents a 90% confidence interval,")
    message("the low and high returns are 5 and 95 % respectively")
    widthCI <-  as.numeric(readline())
  }
  
  ciLower <- (50-(widthCI/2))/100
  ciUpper <- (50+(widthCI/2))/100
  probs <- c(ciLower,ciUpper)
  
  repAnnualResults <- vector(mode = "list", length = nBoot)
  
  cat("\nRunning the EGRET standard modelEstimation first to have that as a baseline for the Confidence Bands")
  eList <- modelEstimation(eList)
  
  for(n in 1:nBoot){
    repAnnualResults[[n]] <- bootAnnual(eList, blockLength)
  }
  
  CIAnnualResults <- ciBands(eList, repAnnualResults, probs)
  
  return(CIAnnualResults)

}
