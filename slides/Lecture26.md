---
title       : Microbial Informatics
subtitle    : Lecture 26
date        : November 25, 2014
author      : Patrick D. Schloss, PhD (microbialinformatics.github.io)
job         : Department of Microbiology & Immunology
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      #
widgets     : mathjax       # {mathjax, quiz, bootstrap}
mode        : standalone    # {selfcontained, standalone, draft}
knit        : slidify::knit2slides

---

## Announcements
* Homework is due tomorrow
  * Remember to supply code with a knitr document
  * Use `source` to load the code from within knitr
  * Results should be embeded in the text so that if I use `echo=F`, so I can still see what happened
* Final project (due 12/16/2014)
  * Email me your idea by Tuesday
  * Should be a program that others can use to do something useful (I have ideas if you need one)
  * Create a public repository with documentation in README file and license



---

## Review

<img src="../img/ruzzle_r1.png", style="margin:0px auto;display:block" width="300">

---

## Overall algorithm possibilities

* Brute force search for all possible words in grid and compare those to the dictionary
* Brute force search for every word in dictionary in the grid
* A hybrid approach where you build words off of every block and end a search string when it is no longer in the dictionary

---

## This was (too) hard...

| Algorithm         | 	Time  | Time (with data structure population) | Requested Primary Memory  |
|-------------------|---------|---------------------------------------|---------------------------|
| Full Enumeration	| 2,5sec+ | 2,5sec+                               | ~6MB                      |
| Active Dictionary	| 150ms	  | 170ms                                 | ~0MB                      |
| Branch and Bound	| 1ms	    | 300ms                                 | ~140MB                    |

* Timings for code written in C (faster than R)
* http://miromannino.com/ruzzle-solver-algorithm/

---

## Some people take this way too seriously

* It uses the Beta Distribution to choose good, but not too good, words (to avoid all the suspects).
* It applies an istintive human reasoning. In this way, the final word list seems written by an human.
* It determines the current round, to change its behavior.
* Sometimes it draws casual words. In this way it never gets 100% of accuracy.
* It limits the number of words (a casual limit, that varies with the current round).
* It limits the number of points (a casual limit, that varies with the current round).
* Dictionary is limited, only a subset of the complete one.

---

## Whoa.

<iframe width="560" height="315" src="//www.youtube.com/embed/F1qxtYLRcos" frameborder="0" allowfullscreen></iframe>

---

## How I did it

* Brute force search for all possible words in grid seemed most intuitive to me
* Neighbors will be the same regardless of the actual tiles
* Read the matrix in as a string and then convert to a matrix
* Start with 2 letter words and find all possible words
* Use all 2 letter words (2-mers) to get 3 letter words (3-mers), etc.
	* Make sure that you don't reuse letters
	* Do up to 10 letter words (10-mers, not exhaustive!)
	* Keep the path as you go
* Identify overlap between all k-mers and the dictionary

---

## Preliminaries


```r
# load the dictionary
dictionary <- scan("http://www.freescrabbledictionary.com/sowpods.txt", what="", skip=2, quiet=T)
dictionary <- toupper(dictionary)

# load the board
# BOIA
# RAMD
# TEHA
# IOCR

#convet the board string to a matrix
boardString <- "BOIARAMDTEHAIOCR"
board <- matrix(unlist(strsplit(boardString, "")), nrow=4, byrow=T)
```

---

## Precompute the neighbors


```r
neighbors <- list()
neighbors[[1]]  <- c(2,5,6)
neighbors[[2]]  <- c(1,3,5,6,7)
neighbors[[3]]  <- c(2,4,6,7,8)
neighbors[[4]]  <- c(3,7,8)
neighbors[[5]]  <- c(1,2,6,9,10)
neighbors[[6]]  <- c(1,2,3,5,7,9,10,11)
neighbors[[7]]  <- c(2,3,4,6,8,10,11,12)
neighbors[[8]]  <- c(3,4,7,11,12)
neighbors[[9]]  <- c(5,6,10,13,14)
neighbors[[10]] <- c(5,6,7,9,11,13,14,15)
neighbors[[11]] <- c(6,7,8,10,12,14,15,16)
neighbors[[12]] <- c(7,8,11,15,16)
neighbors[[13]] <- c(9,10,14)
neighbors[[14]] <- c(9,10,11,13,15)
neighbors[[15]] <- c(10,11,12,14,16)
neighbors[[16]] <- c(11,12,15)
```

---

## Final all possible 2-mers

* For each of the 16 tiles, make a path and a 2-mer for it and all of its neighbors
* Should be 84 2-mers
* Store paths and words as lists where the top-level entry is the length of the word (i.e. `paths[[2]]` contains the paths for the 2 letter words)

---

## R


```r
paths <- list()
words <- list()

this.paths <- numeric()
this.words <- character()

for(i in 1:16){
	word <- paste(board[i], board[neighbors[[i]]], sep="") 
	new.paths <- cbind(rep(i, length(neighbors[[i]])), neighbors[[i]])
	this.words <- c(this.words, word)
	this.paths <- rbind(this.paths, new.paths)
}
paths[[2]] <- this.paths
words[[2]] <- this.words
n.prev <- length(this.words)
n.prev
```

```
## [1] 84
```

---

## The 2-mers


```
##  [1] "BR" "BO" "BA" "RB" "RT" "RO" "RA" "RE" "TR" "TI" "TA" "TE" "TO" "IT"
## [15] "IE" "IO" "OB" "OR" "OA" "OI" "OM" "AB" "AR" "AT" "AO" "AE" "AI" "AM"
## [29] "AH" "ER" "ET" "EI" "EA" "EO" "EM" "EH" "EC" "OT" "OI" "OE" "OH" "OC"
## [43] "IO" "IA" "IM" "IA" "ID" "MO" "MA" "ME" "MI" "MH" "MA" "MD" "MA" "HA"
## [57] "HE" "HO" "HM" "HC" "HD" "HA" "HR" "CE" "CO" "CH" "CA" "CR" "AI" "AM"
## [71] "AD" "DI" "DM" "DH" "DA" "DA" "AM" "AH" "AC" "AD" "AR" "RH" "RC" "RA"
```

---

## What do we know...

* All the 2-mers and their path
* Could now take these and extend them by getting the neigbhor of `paths[[2]][,2]`
* Probably don't need the `for` loop, but we'll leave it for now
* Let's try 3-mers

---


## R


```r
this.paths <- numeric()
this.words <- character()

for(i in 1:n.prev){
	prev <- paths[[2]][i,]
	nextChar <- neighbors[[prev[2]]]
	goodNeighbors <- nextChar[!nextChar %in% prev]
	n.goodneighbors <- length(goodNeighbors)
	new.paths <- cbind(matrix(rep(prev, n.goodneighbors), nrow=n.goodneighbors, byrow=T), goodNeighbors)
	word <- paste(words[[2]][i], board[goodNeighbors], sep="")
	this.words <- c(this.words, word)
	this.paths <- rbind(this.paths, new.paths)
}
paths[[3]] <- this.paths
words[[3]] <- this.words
n.prev <- length(this.words)
n.prev
```

```
## [1] 408
```

---

## The 3-mers


```
##   [1] "BRT" "BRO" "BRA" "BRE" "BOR" "BOA" "BOI" "BOM" "BAR" "BAT" "BAO"
##  [12] "BAE" "BAI" "BAM" "BAH" "RBO" "RBA" "RTI" "RTA" "RTE" "RTO" "ROB"
##  [23] "ROA" "ROI" "ROM" "RAB" "RAT" "RAO" "RAE" "RAI" "RAM" "RAH" "RET"
##  [34] "REI" "REA" "REO" "REM" "REH" "REC" "TRB" "TRO" "TRA" "TRE" "TIE"
##  [45] "TIO" "TAB" "TAR" "TAO" "TAE" "TAI" "TAM" "TAH" "TER" "TEI" "TEA"
##  [56] "TEO" "TEM" "TEH" "TEC" "TOI" "TOE" "TOH" "TOC" "ITR" "ITA" "ITE"
##  [67] "ITO" "IER" "IET" "IEA" "IEO" "IEM" "IEH" "IEC" "IOT" "IOE" "IOH"
##  [78] "IOC" "OBR" "OBA" "ORB" "ORT" "ORA" "ORE" "OAB" "OAR" "OAT" "OAE"
##  [89] "OAI" "OAM" "OAH" "OIA" "OIM" "OIA" "OID" "OMA" "OME" "OMI" "OMH"
## [100] "OMA" "OMD" "OMA" "ABR" "ABO" "ARB" "ART" "ARO" "ARE" "ATR" "ATI"
## [111] "ATE" "ATO" "AOB" "AOR" "AOI" "AOM" "AER" "AET" "AEI" "AEO" "AEM"
## [122] "AEH" "AEC" "AIO" "AIM" "AIA" "AID" "AMO" "AME" "AMI" "AMH" "AMA"
## [133] "AMD" "AMA" "AHE" "AHO" "AHM" "AHC" "AHD" "AHA" "AHR" "ERB" "ERT"
## [144] "ERO" "ERA" "ETR" "ETI" "ETA" "ETO" "EIT" "EIO" "EAB" "EAR" "EAT"
## [155] "EAO" "EAI" "EAM" "EAH" "EOT" "EOI" "EOH" "EOC" "EMO" "EMA" "EMI"
## [166] "EMH" "EMA" "EMD" "EMA" "EHA" "EHO" "EHM" "EHC" "EHD" "EHA" "EHR"
## [177] "ECO" "ECH" "ECA" "ECR" "OTR" "OTI" "OTA" "OTE" "OIT" "OIE" "OER"
## [188] "OET" "OEI" "OEA" "OEM" "OEH" "OEC" "OHA" "OHE" "OHM" "OHC" "OHD"
## [199] "OHA" "OHR" "OCE" "OCH" "OCA" "OCR" "IOB" "IOR" "IOA" "IOM" "IAB"
## [210] "IAR" "IAT" "IAO" "IAE" "IAM" "IAH" "IMO" "IMA" "IME" "IMH" "IMA"
## [221] "IMD" "IMA" "IAM" "IAD" "IDM" "IDH" "IDA" "IDA" "MOB" "MOR" "MOA"
## [232] "MOI" "MAB" "MAR" "MAT" "MAO" "MAE" "MAI" "MAH" "MER" "MET" "MEI"
## [243] "MEA" "MEO" "MEH" "MEC" "MIO" "MIA" "MIA" "MID" "MHA" "MHE" "MHO"
## [254] "MHC" "MHD" "MHA" "MHR" "MAI" "MAD" "MDI" "MDH" "MDA" "MDA" "MAH"
## [265] "MAC" "MAD" "MAR" "HAB" "HAR" "HAT" "HAO" "HAE" "HAI" "HAM" "HER"
## [276] "HET" "HEI" "HEA" "HEO" "HEM" "HEC" "HOT" "HOI" "HOE" "HOC" "HMO"
## [287] "HMA" "HME" "HMI" "HMA" "HMD" "HMA" "HCE" "HCO" "HCA" "HCR" "HDI"
## [298] "HDM" "HDA" "HDA" "HAM" "HAC" "HAD" "HAR" "HRC" "HRA" "CER" "CET"
## [309] "CEI" "CEA" "CEO" "CEM" "CEH" "COT" "COI" "COE" "COH" "CHA" "CHE"
## [320] "CHO" "CHM" "CHD" "CHA" "CHR" "CAM" "CAH" "CAD" "CAR" "CRH" "CRA"
## [331] "AIO" "AIA" "AIM" "AID" "AMO" "AMA" "AME" "AMI" "AMH" "AMD" "AMA"
## [342] "ADI" "ADM" "ADH" "ADA" "DIO" "DIA" "DIM" "DIA" "DMO" "DMA" "DME"
## [353] "DMI" "DMH" "DMA" "DMA" "DHA" "DHE" "DHO" "DHM" "DHC" "DHA" "DHR"
## [364] "DAI" "DAM" "DAM" "DAH" "DAC" "DAR" "AMO" "AMA" "AME" "AMI" "AMH"
## [375] "AMA" "AMD" "AHA" "AHE" "AHO" "AHM" "AHC" "AHD" "AHR" "ACE" "ACO"
## [386] "ACH" "ACR" "ADI" "ADM" "ADH" "ADA" "ARH" "ARC" "RHA" "RHE" "RHO"
## [397] "RHM" "RHC" "RHD" "RHA" "RCE" "RCO" "RCH" "RCA" "RAM" "RAH" "RAC"
## [408] "RAD"
```

---

## Keep going with 4-mers


```r
this.paths <- numeric()
this.words <- character()

for(i in 1:n.prev){
	prev <- paths[[3]][i,]
	nextChar <- neighbors[[prev[3]]]
	goodNeighbors <- nextChar[!nextChar %in% prev]
	n.goodneighbors <- length(goodNeighbors)
	new.paths <- cbind(matrix(rep(prev, n.goodneighbors), nrow=n.goodneighbors, byrow=T), goodNeighbors)
	word <- paste(words[[3]][i], board[goodNeighbors], sep="")
	this.words <- c(this.words, word)
	this.paths <- rbind(this.paths, new.paths)
}
paths[[4]] <- this.paths
words[[4]] <- this.words
n.prev <- length(this.words)
```

---

## The 4-mers


```
##    [1] "BRTI" "BRTA" "BRTE" "BRTO" "BROA" "BROI" "BROM" "BRAT" "BRAO"
##   [10] "BRAE" "BRAI" "BRAM" "BRAH" "BRET" "BREI" "BREA" "BREO" "BREM"
##   [19] "BREH" "BREC" "BORT" "BORA" "BORE" "BOAR" "BOAT" "BOAE" "BOAI"
##   [28] "BOAM" "BOAH" "BOIA" "BOIM" "BOIA" "BOID" "BOMA" "BOME" "BOMI"
##   [37] "BOMH" "BOMA" "BOMD" "BOMA" "BART" "BARO" "BARE" "BATR" "BATI"
##   [46] "BATE" "BATO" "BAOR" "BAOI" "BAOM" "BAER" "BAET" "BAEI" "BAEO"
##   [55] "BAEM" "BAEH" "BAEC" "BAIO" "BAIM" "BAIA" "BAID" "BAMO" "BAME"
##   [64] "BAMI" "BAMH" "BAMA" "BAMD" "BAMA" "BAHE" "BAHO" "BAHM" "BAHC"
##   [73] "BAHD" "BAHA" "BAHR" "RBOA" "RBOI" "RBOM" "RBAT" "RBAO" "RBAE"
##   [82] "RBAI" "RBAM" "RBAH" "RTIE" "RTIO" "RTAB" "RTAO" "RTAE" "RTAI"
##   [91] "RTAM" "RTAH" "RTEI" "RTEA" "RTEO" "RTEM" "RTEH" "RTEC" "RTOI"
##  [100] "RTOE" "RTOH" "RTOC" "ROBA" "ROAB" "ROAT" "ROAE" "ROAI" "ROAM"
##  [109] "ROAH" "ROIA" "ROIM" "ROIA" "ROID" "ROMA" "ROME" "ROMI" "ROMH"
##  [118] "ROMA" "ROMD" "ROMA" "RABO" "RATI" "RATE" "RATO" "RAOB" "RAOI"
##  [127] "RAOM" "RAET" "RAEI" "RAEO" "RAEM" "RAEH" "RAEC" "RAIO" "RAIM"
##  [136] "RAIA" "RAID" "RAMO" "RAME" "RAMI" "RAMH" "RAMA" "RAMD" "RAMA"
##  [145] "RAHE" "RAHO" "RAHM" "RAHC" "RAHD" "RAHA" "RAHR" "RETI" "RETA"
##  [154] "RETO" "REIT" "REIO" "REAB" "REAT" "REAO" "REAI" "REAM" "REAH"
##  [163] "REOT" "REOI" "REOH" "REOC" "REMO" "REMA" "REMI" "REMH" "REMA"
##  [172] "REMD" "REMA" "REHA" "REHO" "REHM" "REHC" "REHD" "REHA" "REHR"
##  [181] "RECO" "RECH" "RECA" "RECR" "TRBO" "TRBA" "TROB" "TROA" "TROI"
##  [190] "TROM" "TRAB" "TRAO" "TRAE" "TRAI" "TRAM" "TRAH" "TREI" "TREA"
##  [199] "TREO" "TREM" "TREH" "TREC" "TIER" "TIEA" "TIEO" "TIEM" "TIEH"
##  [208] "TIEC" "TIOE" "TIOH" "TIOC" "TABR" "TABO" "TARB" "TARO" "TARE"
##  [217] "TAOB" "TAOR" "TAOI" "TAOM" "TAER" "TAEI" "TAEO" "TAEM" "TAEH"
##  [226] "TAEC" "TAIO" "TAIM" "TAIA" "TAID" "TAMO" "TAME" "TAMI" "TAMH"
##  [235] "TAMA" "TAMD" "TAMA" "TAHE" "TAHO" "TAHM" "TAHC" "TAHD" "TAHA"
##  [244] "TAHR" "TERB" "TERO" "TERA" "TEIO" "TEAB" "TEAR" "TEAO" "TEAI"
##  [253] "TEAM" "TEAH" "TEOI" "TEOH" "TEOC" "TEMO" "TEMA" "TEMI" "TEMH"
##  [262] "TEMA" "TEMD" "TEMA" "TEHA" "TEHO" "TEHM" "TEHC" "TEHD" "TEHA"
##  [271] "TEHR" "TECO" "TECH" "TECA" "TECR" "TOIE" "TOER" "TOEI" "TOEA"
##  [280] "TOEM" "TOEH" "TOEC" "TOHA" "TOHE" "TOHM" "TOHC" "TOHD" "TOHA"
##  [289] "TOHR" "TOCE" "TOCH" "TOCA" "TOCR" "ITRB" "ITRO" "ITRA" "ITRE"
##  [298] "ITAB" "ITAR" "ITAO" "ITAE" "ITAI" "ITAM" "ITAH" "ITER" "ITEA"
##  [307] "ITEO" "ITEM" "ITEH" "ITEC" "ITOE" "ITOH" "ITOC" "IERB" "IERT"
##  [316] "IERO" "IERA" "IETR" "IETA" "IETO" "IEAB" "IEAR" "IEAT" "IEAO"
##  [325] "IEAI" "IEAM" "IEAH" "IEOT" "IEOH" "IEOC" "IEMO" "IEMA" "IEMI"
##  [334] "IEMH" "IEMA" "IEMD" "IEMA" "IEHA" "IEHO" "IEHM" "IEHC" "IEHD"
##  [343] "IEHA" "IEHR" "IECO" "IECH" "IECA" "IECR" "IOTR" "IOTA" "IOTE"
##  [352] "IOER" "IOET" "IOEA" "IOEM" "IOEH" "IOEC" "IOHA" "IOHE" "IOHM"
##  [361] "IOHC" "IOHD" "IOHA" "IOHR" "IOCE" "IOCH" "IOCA" "IOCR" "OBRT"
##  [370] "OBRA" "OBRE" "OBAR" "OBAT" "OBAE" "OBAI" "OBAM" "OBAH" "ORBA"
##  [379] "ORTI" "ORTA" "ORTE" "ORTO" "ORAB" "ORAT" "ORAE" "ORAI" "ORAM"
##  [388] "ORAH" "ORET" "OREI" "OREA" "OREO" "OREM" "OREH" "OREC" "OABR"
##  [397] "OARB" "OART" "OARE" "OATR" "OATI" "OATE" "OATO" "OAER" "OAET"
##  [406] "OAEI" "OAEO" "OAEM" "OAEH" "OAEC" "OAIM" "OAIA" "OAID" "OAME"
##  [415] "OAMI" "OAMH" "OAMA" "OAMD" "OAMA" "OAHE" "OAHO" "OAHM" "OAHC"
##  [424] "OAHD" "OAHA" "OAHR" "OIAB" "OIAR" "OIAT" "OIAE" "OIAM" "OIAH"
##  [433] "OIMA" "OIME" "OIMH" "OIMA" "OIMD" "OIMA" "OIAM" "OIAD" "OIDM"
##  [442] "OIDH" "OIDA" "OIDA" "OMAB" "OMAR" "OMAT" "OMAE" "OMAI" "OMAH"
##  [451] "OMER" "OMET" "OMEI" "OMEA" "OMEO" "OMEH" "OMEC" "OMIA" "OMIA"
##  [460] "OMID" "OMHA" "OMHE" "OMHO" "OMHC" "OMHD" "OMHA" "OMHR" "OMAI"
##  [469] "OMAD" "OMDI" "OMDH" "OMDA" "OMDA" "OMAH" "OMAC" "OMAD" "OMAR"
##  [478] "ABRT" "ABRO" "ABRE" "ABOR" "ABOI" "ABOM" "ARBO" "ARTI" "ARTE"
##  [487] "ARTO" "AROB" "AROI" "AROM" "ARET" "AREI" "AREO" "AREM" "AREH"
##  [496] "AREC" "ATRB" "ATRO" "ATRE" "ATIE" "ATIO" "ATER" "ATEI" "ATEO"
##  [505] "ATEM" "ATEH" "ATEC" "ATOI" "ATOE" "ATOH" "ATOC" "AOBR" "AORB"
##  [514] "AORT" "AORE" "AOIM" "AOIA" "AOID" "AOME" "AOMI" "AOMH" "AOMA"
##  [523] "AOMD" "AOMA" "AERB" "AERT" "AERO" "AETR" "AETI" "AETO" "AEIT"
##  [532] "AEIO" "AEOT" "AEOI" "AEOH" "AEOC" "AEMO" "AEMI" "AEMH" "AEMA"
##  [541] "AEMD" "AEMA" "AEHO" "AEHM" "AEHC" "AEHD" "AEHA" "AEHR" "AECO"
##  [550] "AECH" "AECA" "AECR" "AIOB" "AIOR" "AIOM" "AIMO" "AIME" "AIMH"
##  [559] "AIMA" "AIMD" "AIMA" "AIAM" "AIAD" "AIDM" "AIDH" "AIDA" "AIDA"
##  [568] "AMOB" "AMOR" "AMOI" "AMER" "AMET" "AMEI" "AMEO" "AMEH" "AMEC"
##  [577] "AMIO" "AMIA" "AMID" "AMHE" "AMHO" "AMHC" "AMHD" "AMHA" "AMHR"
##  [586] "AMAI" "AMAD" "AMDI" "AMDH" "AMDA" "AMDA" "AMAH" "AMAC" "AMAD"
##  [595] "AMAR" "AHER" "AHET" "AHEI" "AHEO" "AHEM" "AHEC" "AHOT" "AHOI"
##  [604] "AHOE" "AHOC" "AHMO" "AHME" "AHMI" "AHMA" "AHMD" "AHMA" "AHCE"
##  [613] "AHCO" "AHCA" "AHCR" "AHDI" "AHDM" "AHDA" "AHDA" "AHAM" "AHAC"
##  [622] "AHAD" "AHAR" "AHRC" "AHRA" "ERBO" "ERBA" "ERTI" "ERTA" "ERTO"
##  [631] "EROB" "EROA" "EROI" "EROM" "ERAB" "ERAT" "ERAO" "ERAI" "ERAM"
##  [640] "ERAH" "ETRB" "ETRO" "ETRA" "ETIO" "ETAB" "ETAR" "ETAO" "ETAI"
##  [649] "ETAM" "ETAH" "ETOI" "ETOH" "ETOC" "EITR" "EITA" "EITO" "EIOT"
##  [658] "EIOH" "EIOC" "EABR" "EABO" "EARB" "EART" "EARO" "EATR" "EATI"
##  [667] "EATO" "EAOB" "EAOR" "EAOI" "EAOM" "EAIO" "EAIM" "EAIA" "EAID"
##  [676] "EAMO" "EAMI" "EAMH" "EAMA" "EAMD" "EAMA" "EAHO" "EAHM" "EAHC"
##  [685] "EAHD" "EAHA" "EAHR" "EOTR" "EOTI" "EOTA" "EOIT" "EOHA" "EOHM"
##  [694] "EOHC" "EOHD" "EOHA" "EOHR" "EOCH" "EOCA" "EOCR" "EMOB" "EMOR"
##  [703] "EMOA" "EMOI" "EMAB" "EMAR" "EMAT" "EMAO" "EMAI" "EMAH" "EMIO"
##  [712] "EMIA" "EMIA" "EMID" "EMHA" "EMHO" "EMHC" "EMHD" "EMHA" "EMHR"
##  [721] "EMAI" "EMAD" "EMDI" "EMDH" "EMDA" "EMDA" "EMAH" "EMAC" "EMAD"
##  [730] "EMAR" "EHAB" "EHAR" "EHAT" "EHAO" "EHAI" "EHAM" "EHOT" "EHOI"
##  [739] "EHOC" "EHMO" "EHMA" "EHMI" "EHMA" "EHMD" "EHMA" "EHCO" "EHCA"
##  [748] "EHCR" "EHDI" "EHDM" "EHDA" "EHDA" "EHAM" "EHAC" "EHAD" "EHAR"
##  [757] "EHRC" "EHRA" "ECOT" "ECOI" "ECOH" "ECHA" "ECHO" "ECHM" "ECHD"
##  [766] "ECHA" "ECHR" "ECAM" "ECAH" "ECAD" "ECAR" "ECRH" "ECRA" "OTRB"
##  [775] "OTRO" "OTRA" "OTRE" "OTIE" "OTAB" "OTAR" "OTAO" "OTAE" "OTAI"
##  [784] "OTAM" "OTAH" "OTER" "OTEI" "OTEA" "OTEM" "OTEH" "OTEC" "OITR"
##  [793] "OITA" "OITE" "OIER" "OIET" "OIEA" "OIEM" "OIEH" "OIEC" "OERB"
##  [802] "OERT" "OERO" "OERA" "OETR" "OETI" "OETA" "OEIT" "OEAB" "OEAR"
##  [811] "OEAT" "OEAO" "OEAI" "OEAM" "OEAH" "OEMO" "OEMA" "OEMI" "OEMH"
##  [820] "OEMA" "OEMD" "OEMA" "OEHA" "OEHM" "OEHC" "OEHD" "OEHA" "OEHR"
##  [829] "OECH" "OECA" "OECR" "OHAB" "OHAR" "OHAT" "OHAO" "OHAE" "OHAI"
##  [838] "OHAM" "OHER" "OHET" "OHEI" "OHEA" "OHEM" "OHEC" "OHMO" "OHMA"
##  [847] "OHME" "OHMI" "OHMA" "OHMD" "OHMA" "OHCE" "OHCA" "OHCR" "OHDI"
##  [856] "OHDM" "OHDA" "OHDA" "OHAM" "OHAC" "OHAD" "OHAR" "OHRC" "OHRA"
##  [865] "OCER" "OCET" "OCEI" "OCEA" "OCEM" "OCEH" "OCHA" "OCHE" "OCHM"
##  [874] "OCHD" "OCHA" "OCHR" "OCAM" "OCAH" "OCAD" "OCAR" "OCRH" "OCRA"
##  [883] "IOBR" "IOBA" "IORB" "IORT" "IORA" "IORE" "IOAB" "IOAR" "IOAT"
##  [892] "IOAE" "IOAM" "IOAH" "IOMA" "IOME" "IOMH" "IOMA" "IOMD" "IOMA"
##  [901] "IABR" "IABO" "IARB" "IART" "IARO" "IARE" "IATR" "IATI" "IATE"
##  [910] "IATO" "IAOB" "IAOR" "IAOM" "IAER" "IAET" "IAEI" "IAEO" "IAEM"
##  [919] "IAEH" "IAEC" "IAMO" "IAME" "IAMH" "IAMA" "IAMD" "IAMA" "IAHE"
##  [928] "IAHO" "IAHM" "IAHC" "IAHD" "IAHA" "IAHR" "IMOB" "IMOR" "IMOA"
##  [937] "IMAB" "IMAR" "IMAT" "IMAO" "IMAE" "IMAH" "IMER" "IMET" "IMEI"
##  [946] "IMEA" "IMEO" "IMEH" "IMEC" "IMHA" "IMHE" "IMHO" "IMHC" "IMHD"
##  [955] "IMHA" "IMHR" "IMAD" "IMDH" "IMDA" "IMDA" "IMAH" "IMAC" "IMAD"
##  [964] "IMAR" "IAMO" "IAMA" "IAME" "IAMH" "IAMD" "IAMA" "IADM" "IADH"
##  [973] "IADA" "IDMO" "IDMA" "IDME" "IDMH" "IDMA" "IDMA" "IDHA" "IDHE"
##  [982] "IDHO" "IDHM" "IDHC" "IDHA" "IDHR" "IDAM" "IDAM" "IDAH" "IDAC"
##  [991] "IDAR" "MOBR" "MOBA" "MORB" "MORT" "MORA" "MORE" "MOAB" "MOAR"
## [1000] "MOAT" "MOAE" "MOAI" "MOAH" "MOIA" "MOIA" "MOID" "MABR" "MABO"
## [1009] "MARB" "MART" "MARO" "MARE" "MATR" "MATI" "MATE" "MATO" "MAOB"
## [1018] "MAOR" "MAOI" "MAER" "MAET" "MAEI" "MAEO" "MAEH" "MAEC" "MAIO"
## [1027] "MAIA" "MAID" "MAHE" "MAHO" "MAHC" "MAHD" "MAHA" "MAHR" "MERB"
## [1036] "MERT" "MERO" "MERA" "METR" "METI" "META" "METO" "MEIT" "MEIO"
## [1045] "MEAB" "MEAR" "MEAT" "MEAO" "MEAI" "MEAH" "MEOT" "MEOI" "MEOH"
## [1054] "MEOC" "MEHA" "MEHO" "MEHC" "MEHD" "MEHA" "MEHR" "MECO" "MECH"
## [1063] "MECA" "MECR" "MIOB" "MIOR" "MIOA" "MIAB" "MIAR" "MIAT" "MIAO"
## [1072] "MIAE" "MIAH" "MIAD" "MIDH" "MIDA" "MIDA" "MHAB" "MHAR" "MHAT"
## [1081] "MHAO" "MHAE" "MHAI" "MHER" "MHET" "MHEI" "MHEA" "MHEO" "MHEC"
## [1090] "MHOT" "MHOI" "MHOE" "MHOC" "MHCE" "MHCO" "MHCA" "MHCR" "MHDI"
## [1099] "MHDA" "MHDA" "MHAC" "MHAD" "MHAR" "MHRC" "MHRA" "MAIO" "MAIA"
## [1108] "MAID" "MADI" "MADH" "MADA" "MDIO" "MDIA" "MDIA" "MDHA" "MDHE"
## [1117] "MDHO" "MDHC" "MDHA" "MDHR" "MDAI" "MDAH" "MDAC" "MDAR" "MAHA"
## [1126] "MAHE" "MAHO" "MAHC" "MAHD" "MAHR" "MACE" "MACO" "MACH" "MACR"
## [1135] "MADI" "MADH" "MADA" "MARH" "MARC" "HABR" "HABO" "HARB" "HART"
## [1144] "HARO" "HARE" "HATR" "HATI" "HATE" "HATO" "HAOB" "HAOR" "HAOI"
## [1153] "HAOM" "HAER" "HAET" "HAEI" "HAEO" "HAEM" "HAEC" "HAIO" "HAIM"
## [1162] "HAIA" "HAID" "HAMO" "HAME" "HAMI" "HAMA" "HAMD" "HAMA" "HERB"
## [1171] "HERT" "HERO" "HERA" "HETR" "HETI" "HETA" "HETO" "HEIT" "HEIO"
## [1180] "HEAB" "HEAR" "HEAT" "HEAO" "HEAI" "HEAM" "HEOT" "HEOI" "HEOC"
## [1189] "HEMO" "HEMA" "HEMI" "HEMA" "HEMD" "HEMA" "HECO" "HECA" "HECR"
## [1198] "HOTR" "HOTI" "HOTA" "HOTE" "HOIT" "HOIE" "HOER" "HOET" "HOEI"
## [1207] "HOEA" "HOEM" "HOEC" "HOCE" "HOCA" "HOCR" "HMOB" "HMOR" "HMOA"
## [1216] "HMOI" "HMAB" "HMAR" "HMAT" "HMAO" "HMAE" "HMAI" "HMER" "HMET"
## [1225] "HMEI" "HMEA" "HMEO" "HMEC" "HMIO" "HMIA" "HMIA" "HMID" "HMAI"
## [1234] "HMAD" "HMDI" "HMDA" "HMDA" "HMAC" "HMAD" "HMAR" "HCER" "HCET"
## [1243] "HCEI" "HCEA" "HCEO" "HCEM" "HCOT" "HCOI" "HCOE" "HCAM" "HCAD"
## [1252] "HCAR" "HCRA" "HDIO" "HDIA" "HDIM" "HDIA" "HDMO" "HDMA" "HDME"
## [1261] "HDMI" "HDMA" "HDMA" "HDAI" "HDAM" "HDAM" "HDAC" "HDAR" "HAMO"
## [1270] "HAMA" "HAME" "HAMI" "HAMA" "HAMD" "HACE" "HACO" "HACR" "HADI"
## [1279] "HADM" "HADA" "HARC" "HRCE" "HRCO" "HRCA" "HRAM" "HRAC" "HRAD"
## [1288] "CERB" "CERT" "CERO" "CERA" "CETR" "CETI" "CETA" "CETO" "CEIT"
## [1297] "CEIO" "CEAB" "CEAR" "CEAT" "CEAO" "CEAI" "CEAM" "CEAH" "CEOT"
## [1306] "CEOI" "CEOH" "CEMO" "CEMA" "CEMI" "CEMH" "CEMA" "CEMD" "CEMA"
## [1315] "CEHA" "CEHO" "CEHM" "CEHD" "CEHA" "CEHR" "COTR" "COTI" "COTA"
## [1324] "COTE" "COIT" "COIE" "COER" "COET" "COEI" "COEA" "COEM" "COEH"
## [1333] "COHA" "COHE" "COHM" "COHD" "COHA" "COHR" "CHAB" "CHAR" "CHAT"
## [1342] "CHAO" "CHAE" "CHAI" "CHAM" "CHER" "CHET" "CHEI" "CHEA" "CHEO"
## [1351] "CHEM" "CHOT" "CHOI" "CHOE" "CHMO" "CHMA" "CHME" "CHMI" "CHMA"
## [1360] "CHMD" "CHMA" "CHDI" "CHDM" "CHDA" "CHDA" "CHAM" "CHAD" "CHAR"
## [1369] "CHRA" "CAMO" "CAMA" "CAME" "CAMI" "CAMH" "CAMA" "CAMD" "CAHA"
## [1378] "CAHE" "CAHO" "CAHM" "CAHD" "CAHR" "CADI" "CADM" "CADH" "CADA"
## [1387] "CARH" "CRHA" "CRHE" "CRHO" "CRHM" "CRHD" "CRHA" "CRAM" "CRAH"
## [1396] "CRAD" "AIOB" "AIOR" "AIOA" "AIOM" "AIAB" "AIAR" "AIAT" "AIAO"
## [1405] "AIAE" "AIAM" "AIAH" "AIMO" "AIMA" "AIME" "AIMH" "AIMD" "AIMA"
## [1414] "AIDM" "AIDH" "AIDA" "AMOB" "AMOR" "AMOA" "AMOI" "AMAB" "AMAR"
## [1423] "AMAT" "AMAO" "AMAE" "AMAI" "AMAH" "AMER" "AMET" "AMEI" "AMEA"
## [1432] "AMEO" "AMEH" "AMEC" "AMIO" "AMIA" "AMID" "AMHA" "AMHE" "AMHO"
## [1441] "AMHC" "AMHD" "AMHA" "AMHR" "AMDI" "AMDH" "AMDA" "AMAH" "AMAC"
## [1450] "AMAD" "AMAR" "ADIO" "ADIA" "ADIM" "ADMO" "ADMA" "ADME" "ADMI"
## [1459] "ADMH" "ADMA" "ADHA" "ADHE" "ADHO" "ADHM" "ADHC" "ADHA" "ADHR"
## [1468] "ADAM" "ADAH" "ADAC" "ADAR" "DIOB" "DIOR" "DIOA" "DIOM" "DIAB"
## [1477] "DIAR" "DIAT" "DIAO" "DIAE" "DIAM" "DIAH" "DIMO" "DIMA" "DIME"
## [1486] "DIMH" "DIMA" "DIMA" "DIAM" "DMOB" "DMOR" "DMOA" "DMOI" "DMAB"
## [1495] "DMAR" "DMAT" "DMAO" "DMAE" "DMAI" "DMAH" "DMER" "DMET" "DMEI"
## [1504] "DMEA" "DMEO" "DMEH" "DMEC" "DMIO" "DMIA" "DMIA" "DMHA" "DMHE"
## [1513] "DMHO" "DMHC" "DMHA" "DMHR" "DMAI" "DMAH" "DMAC" "DMAR" "DHAB"
## [1522] "DHAR" "DHAT" "DHAO" "DHAE" "DHAI" "DHAM" "DHER" "DHET" "DHEI"
## [1531] "DHEA" "DHEO" "DHEM" "DHEC" "DHOT" "DHOI" "DHOE" "DHOC" "DHMO"
## [1540] "DHMA" "DHME" "DHMI" "DHMA" "DHMA" "DHCE" "DHCO" "DHCA" "DHCR"
## [1549] "DHAM" "DHAC" "DHAR" "DHRC" "DHRA" "DAIO" "DAIA" "DAIM" "DAMO"
## [1558] "DAMA" "DAME" "DAMI" "DAMH" "DAMA" "DAMO" "DAMA" "DAME" "DAMI"
## [1567] "DAMH" "DAMA" "DAHA" "DAHE" "DAHO" "DAHM" "DAHC" "DAHR" "DACE"
## [1576] "DACO" "DACH" "DACR" "DARH" "DARC" "AMOB" "AMOR" "AMOA" "AMOI"
## [1585] "AMAB" "AMAR" "AMAT" "AMAO" "AMAE" "AMAI" "AMAH" "AMER" "AMET"
## [1594] "AMEI" "AMEA" "AMEO" "AMEH" "AMEC" "AMIO" "AMIA" "AMIA" "AMID"
## [1603] "AMHA" "AMHE" "AMHO" "AMHC" "AMHD" "AMHR" "AMAI" "AMAD" "AMDI"
## [1612] "AMDH" "AMDA" "AHAB" "AHAR" "AHAT" "AHAO" "AHAE" "AHAI" "AHAM"
## [1621] "AHER" "AHET" "AHEI" "AHEA" "AHEO" "AHEM" "AHEC" "AHOT" "AHOI"
## [1630] "AHOE" "AHOC" "AHMO" "AHMA" "AHME" "AHMI" "AHMA" "AHMD" "AHCE"
## [1639] "AHCO" "AHCR" "AHDI" "AHDM" "AHDA" "AHRC" "ACER" "ACET" "ACEI"
## [1648] "ACEA" "ACEO" "ACEM" "ACEH" "ACOT" "ACOI" "ACOE" "ACOH" "ACHA"
## [1657] "ACHE" "ACHO" "ACHM" "ACHD" "ACHR" "ACRH" "ADIO" "ADIA" "ADIM"
## [1666] "ADIA" "ADMO" "ADMA" "ADME" "ADMI" "ADMH" "ADMA" "ADHA" "ADHE"
## [1675] "ADHO" "ADHM" "ADHC" "ADHR" "ADAI" "ADAM" "ARHA" "ARHE" "ARHO"
## [1684] "ARHM" "ARHC" "ARHD" "ARCE" "ARCO" "ARCH" "RHAB" "RHAR" "RHAT"
## [1693] "RHAO" "RHAE" "RHAI" "RHAM" "RHER" "RHET" "RHEI" "RHEA" "RHEO"
## [1702] "RHEM" "RHEC" "RHOT" "RHOI" "RHOE" "RHOC" "RHMO" "RHMA" "RHME"
## [1711] "RHMI" "RHMA" "RHMD" "RHMA" "RHCE" "RHCO" "RHCA" "RHDI" "RHDM"
## [1720] "RHDA" "RHDA" "RHAM" "RHAC" "RHAD" "RCER" "RCET" "RCEI" "RCEA"
## [1729] "RCEO" "RCEM" "RCEH" "RCOT" "RCOI" "RCOE" "RCOH" "RCHA" "RCHE"
## [1738] "RCHO" "RCHM" "RCHD" "RCHA" "RCAM" "RCAH" "RCAD" "RAMO" "RAMA"
## [1747] "RAME" "RAMI" "RAMH" "RAMA" "RAMD" "RAHA" "RAHE" "RAHO" "RAHM"
## [1756] "RAHC" "RAHD" "RACE" "RACO" "RACH" "RADI" "RADM" "RADH" "RADA"
```

---

## Could keep going, but...

* We will now have a lot of repeated code
* The only thing that changes is the number we use to index the previous k-mer length and the current k-mer length
* That for loop is bothersome
* Let's abstract this to make a function

---


```r
getNext <- function(paths, words, new.length){
	length <- new.length - 1
	n.prev <- length(words[[length]])
	this.paths <- numeric()
	this.words <- character()
	
	for(i in 1:n.prev){
		prev <- paths[[length]][i,]
		nextChar <- neighbors[[prev[length]]]
		goodNeighbors <- nextChar[!nextChar %in% prev]
		if(length(goodNeighbors)>0){
			n.goodneighbors <- length(goodNeighbors)
			new.paths <- cbind(matrix(rep(prev, n.goodneighbors), nrow=n.goodneighbors, byrow=T), goodNeighbors)
			word <- paste(words[[length]][i], board[goodNeighbors], sep="")
			this.words <- c(this.words, word)
			this.paths <- rbind(this.paths, new.paths)
		}
	}
	return(list(path=this.paths, word=this.words))
}
```

---

## The 5-mers


```r
update <- getNext(paths, words, 5)
paths[[5]] <- update$path
words[[5]] <- update$word
```

```
##    [1] "BRTIE" "BRTIO" "BRTAO" "BRTAE" "BRTAI" "BRTAM" "BRTAH" "BRTEI"
##    [9] "BRTEA" "BRTEO" "BRTEM" "BRTEH" "BRTEC" "BRTOI" "BRTOE" "BRTOH"
##   [17] "BRTOC" "BROAT" "BROAE" "BROAI" "BROAM" "BROAH" "BROIA" "BROIM"
##   [25] "BROIA" "BROID" "BROMA" "BROME" "BROMI" "BROMH" "BROMA" "BROMD"
##   [33] "BROMA" "BRATI" "BRATE" "BRATO" "BRAOI" "BRAOM" "BRAET" "BRAEI"
##   [41] "BRAEO" "BRAEM" "BRAEH" "BRAEC" "BRAIO" "BRAIM" "BRAIA" "BRAID"
##   [49] "BRAMO" "BRAME" "BRAMI" "BRAMH" "BRAMA" "BRAMD" "BRAMA" "BRAHE"
##   [57] "BRAHO" "BRAHM" "BRAHC" "BRAHD" "BRAHA" "BRAHR" "BRETI" "BRETA"
##   [65] "BRETO" "BREIT" "BREIO" "BREAT" "BREAO" "BREAI" "BREAM" "BREAH"
##   [73] "BREOT" "BREOI" "BREOH" "BREOC" "BREMO" "BREMA" "BREMI" "BREMH"
##   [81] "BREMA" "BREMD" "BREMA" "BREHA" "BREHO" "BREHM" "BREHC" "BREHD"
##   [89] "BREHA" "BREHR" "BRECO" "BRECH" "BRECA" "BRECR" "BORTI" "BORTA"
##   [97] "BORTE" "BORTO" "BORAT" "BORAE" "BORAI" "BORAM" "BORAH" "BORET"
##  [105] "BOREI" "BOREA" "BOREO" "BOREM" "BOREH" "BOREC" "BOART" "BOARE"
##  [113] "BOATR" "BOATI" "BOATE" "BOATO" "BOAER" "BOAET" "BOAEI" "BOAEO"
##  [121] "BOAEM" "BOAEH" "BOAEC" "BOAIM" "BOAIA" "BOAID" "BOAME" "BOAMI"
##  [129] "BOAMH" "BOAMA" "BOAMD" "BOAMA" "BOAHE" "BOAHO" "BOAHM" "BOAHC"
##  [137] "BOAHD" "BOAHA" "BOAHR" "BOIAR" "BOIAT" "BOIAE" "BOIAM" "BOIAH"
##  [145] "BOIMA" "BOIME" "BOIMH" "BOIMA" "BOIMD" "BOIMA" "BOIAM" "BOIAD"
##  [153] "BOIDM" "BOIDH" "BOIDA" "BOIDA" "BOMAR" "BOMAT" "BOMAE" "BOMAI"
##  [161] "BOMAH" "BOMER" "BOMET" "BOMEI" "BOMEA" "BOMEO" "BOMEH" "BOMEC"
##  [169] "BOMIA" "BOMIA" "BOMID" "BOMHA" "BOMHE" "BOMHO" "BOMHC" "BOMHD"
##  [177] "BOMHA" "BOMHR" "BOMAI" "BOMAD" "BOMDI" "BOMDH" "BOMDA" "BOMDA"
##  [185] "BOMAH" "BOMAC" "BOMAD" "BOMAR" "BARTI" "BARTE" "BARTO" "BAROI"
##  [193] "BAROM" "BARET" "BAREI" "BAREO" "BAREM" "BAREH" "BAREC" "BATRO"
##  [201] "BATRE" "BATIE" "BATIO" "BATER" "BATEI" "BATEO" "BATEM" "BATEH"
##  [209] "BATEC" "BATOI" "BATOE" "BATOH" "BATOC" "BAORT" "BAORE" "BAOIM"
##  [217] "BAOIA" "BAOID" "BAOME" "BAOMI" "BAOMH" "BAOMA" "BAOMD" "BAOMA"
##  [225] "BAERT" "BAERO" "BAETR" "BAETI" "BAETO" "BAEIT" "BAEIO" "BAEOT"
##  [233] "BAEOI" "BAEOH" "BAEOC" "BAEMO" "BAEMI" "BAEMH" "BAEMA" "BAEMD"
##  [241] "BAEMA" "BAEHO" "BAEHM" "BAEHC" "BAEHD" "BAEHA" "BAEHR" "BAECO"
##  [249] "BAECH" "BAECA" "BAECR" "BAIOR" "BAIOM" "BAIMO" "BAIME" "BAIMH"
##  [257] "BAIMA" "BAIMD" "BAIMA" "BAIAM" "BAIAD" "BAIDM" "BAIDH" "BAIDA"
##  [265] "BAIDA" "BAMOR" "BAMOI" "BAMER" "BAMET" "BAMEI" "BAMEO" "BAMEH"
##  [273] "BAMEC" "BAMIO" "BAMIA" "BAMID" "BAMHE" "BAMHO" "BAMHC" "BAMHD"
##  [281] "BAMHA" "BAMHR" "BAMAI" "BAMAD" "BAMDI" "BAMDH" "BAMDA" "BAMDA"
##  [289] "BAMAH" "BAMAC" "BAMAD" "BAMAR" "BAHER" "BAHET" "BAHEI" "BAHEO"
##  [297] "BAHEM" "BAHEC" "BAHOT" "BAHOI" "BAHOE" "BAHOC" "BAHMO" "BAHME"
##  [305] "BAHMI" "BAHMA" "BAHMD" "BAHMA" "BAHCE" "BAHCO" "BAHCA" "BAHCR"
##  [313] "BAHDI" "BAHDM" "BAHDA" "BAHDA" "BAHAM" "BAHAC" "BAHAD" "BAHAR"
##  [321] "BAHRC" "BAHRA" "RBOAT" "RBOAE" "RBOAI" "RBOAM" "RBOAH" "RBOIA"
##  [329] "RBOIM" "RBOIA" "RBOID" "RBOMA" "RBOME" "RBOMI" "RBOMH" "RBOMA"
##  [337] "RBOMD" "RBOMA" "RBATI" "RBATE" "RBATO" "RBAOI" "RBAOM" "RBAET"
##  [345] "RBAEI" "RBAEO" "RBAEM" "RBAEH" "RBAEC" "RBAIO" "RBAIM" "RBAIA"
##  [353] "RBAID" "RBAMO" "RBAME" "RBAMI" "RBAMH" "RBAMA" "RBAMD" "RBAMA"
##  [361] "RBAHE" "RBAHO" "RBAHM" "RBAHC" "RBAHD" "RBAHA" "RBAHR" "RTIEA"
##  [369] "RTIEO" "RTIEM" "RTIEH" "RTIEC" "RTIOE" "RTIOH" "RTIOC" "RTABO"
##  [377] "RTAOB" "RTAOI" "RTAOM" "RTAEI" "RTAEO" "RTAEM" "RTAEH" "RTAEC"
##  [385] "RTAIO" "RTAIM" "RTAIA" "RTAID" "RTAMO" "RTAME" "RTAMI" "RTAMH"
##  [393] "RTAMA" "RTAMD" "RTAMA" "RTAHE" "RTAHO" "RTAHM" "RTAHC" "RTAHD"
##  [401] "RTAHA" "RTAHR" "RTEIO" "RTEAB" "RTEAO" "RTEAI" "RTEAM" "RTEAH"
##  [409] "RTEOI" "RTEOH" "RTEOC" "RTEMO" "RTEMA" "RTEMI" "RTEMH" "RTEMA"
##  [417] "RTEMD" "RTEMA" "RTEHA" "RTEHO" "RTEHM" "RTEHC" "RTEHD" "RTEHA"
##  [425] "RTEHR" "RTECO" "RTECH" "RTECA" "RTECR" "RTOIE" "RTOEI" "RTOEA"
##  [433] "RTOEM" "RTOEH" "RTOEC" "RTOHA" "RTOHE" "RTOHM" "RTOHC" "RTOHD"
##  [441] "RTOHA" "RTOHR" "RTOCE" "RTOCH" "RTOCA" "RTOCR" "ROBAT" "ROBAE"
##  [449] "ROBAI" "ROBAM" "ROBAH" "ROATI" "ROATE" "ROATO" "ROAET" "ROAEI"
##  [457] "ROAEO" "ROAEM" "ROAEH" "ROAEC" "ROAIM" "ROAIA" "ROAID" "ROAME"
##  [465] "ROAMI" "ROAMH" "ROAMA" "ROAMD" "ROAMA" "ROAHE" "ROAHO" "ROAHM"
##  [473] "ROAHC" "ROAHD" "ROAHA" "ROAHR" "ROIAB" "ROIAT" "ROIAE" "ROIAM"
##  [481] "ROIAH" "ROIMA" "ROIME" "ROIMH" "ROIMA" "ROIMD" "ROIMA" "ROIAM"
##  [489] "ROIAD" "ROIDM" "ROIDH" "ROIDA" "ROIDA" "ROMAB" "ROMAT" "ROMAE"
##  [497] "ROMAI" "ROMAH" "ROMET" "ROMEI" "ROMEA" "ROMEO" "ROMEH" "ROMEC"
##  [505] "ROMIA" "ROMIA" "ROMID" "ROMHA" "ROMHE" "ROMHO" "ROMHC" "ROMHD"
##  [513] "ROMHA" "ROMHR" "ROMAI" "ROMAD" "ROMDI" "ROMDH" "ROMDA" "ROMDA"
##  [521] "ROMAH" "ROMAC" "ROMAD" "ROMAR" "RABOI" "RABOM" "RATIE" "RATIO"
##  [529] "RATEI" "RATEO" "RATEM" "RATEH" "RATEC" "RATOI" "RATOE" "RATOH"
##  [537] "RATOC" "RAOIM" "RAOIA" "RAOID" "RAOME" "RAOMI" "RAOMH" "RAOMA"
##  [545] "RAOMD" "RAOMA" "RAETI" "RAETO" "RAEIT" "RAEIO" "RAEOT" "RAEOI"
##  [553] "RAEOH" "RAEOC" "RAEMO" "RAEMI" "RAEMH" "RAEMA" "RAEMD" "RAEMA"
##  [561] "RAEHO" "RAEHM" "RAEHC" "RAEHD" "RAEHA" "RAEHR" "RAECO" "RAECH"
##  [569] "RAECA" "RAECR" "RAIOB" "RAIOM" "RAIMO" "RAIME" "RAIMH" "RAIMA"
##  [577] "RAIMD" "RAIMA" "RAIAM" "RAIAD" "RAIDM" "RAIDH" "RAIDA" "RAIDA"
##  [585] "RAMOB" "RAMOI" "RAMET" "RAMEI" "RAMEO" "RAMEH" "RAMEC" "RAMIO"
##  [593] "RAMIA" "RAMID" "RAMHE" "RAMHO" "RAMHC" "RAMHD" "RAMHA" "RAMHR"
##  [601] "RAMAI" "RAMAD" "RAMDI" "RAMDH" "RAMDA" "RAMDA" "RAMAH" "RAMAC"
##  [609] "RAMAD" "RAMAR" "RAHET" "RAHEI" "RAHEO" "RAHEM" "RAHEC" "RAHOT"
##  [617] "RAHOI" "RAHOE" "RAHOC" "RAHMO" "RAHME" "RAHMI" "RAHMA" "RAHMD"
##  [625] "RAHMA" "RAHCE" "RAHCO" "RAHCA" "RAHCR" "RAHDI" "RAHDM" "RAHDA"
##  [633] "RAHDA" "RAHAM" "RAHAC" "RAHAD" "RAHAR" "RAHRC" "RAHRA" "RETIO"
##  [641] "RETAB" "RETAO" "RETAI" "RETAM" "RETAH" "RETOI" "RETOH" "RETOC"
##  [649] "REITA" "REITO" "REIOT" "REIOH" "REIOC" "REABO" "REATI" "REATO"
##  [657] "REAOB" "REAOI" "REAOM" "REAIO" "REAIM" "REAIA" "REAID" "REAMO"
##  [665] "REAMI" "REAMH" "REAMA" "REAMD" "REAMA" "REAHO" "REAHM" "REAHC"
##  [673] "REAHD" "REAHA" "REAHR" "REOTI" "REOTA" "REOIT" "REOHA" "REOHM"
##  [681] "REOHC" "REOHD" "REOHA" "REOHR" "REOCH" "REOCA" "REOCR" "REMOB"
##  [689] "REMOA" "REMOI" "REMAB" "REMAT" "REMAO" "REMAI" "REMAH" "REMIO"
##  [697] "REMIA" "REMIA" "REMID" "REMHA" "REMHO" "REMHC" "REMHD" "REMHA"
##  [705] "REMHR" "REMAI" "REMAD" "REMDI" "REMDH" "REMDA" "REMDA" "REMAH"
##  [713] "REMAC" "REMAD" "REMAR" "REHAB" "REHAT" "REHAO" "REHAI" "REHAM"
##  [721] "REHOT" "REHOI" "REHOC" "REHMO" "REHMA" "REHMI" "REHMA" "REHMD"
##  [729] "REHMA" "REHCO" "REHCA" "REHCR" "REHDI" "REHDM" "REHDA" "REHDA"
##  [737] "REHAM" "REHAC" "REHAD" "REHAR" "REHRC" "REHRA" "RECOT" "RECOI"
##  [745] "RECOH" "RECHA" "RECHO" "RECHM" "RECHD" "RECHA" "RECHR" "RECAM"
##  [753] "RECAH" "RECAD" "RECAR" "RECRH" "RECRA" "TRBOA" "TRBOI" "TRBOM"
##  [761] "TRBAO" "TRBAE" "TRBAI" "TRBAM" "TRBAH" "TROBA" "TROAB" "TROAE"
##  [769] "TROAI" "TROAM" "TROAH" "TROIA" "TROIM" "TROIA" "TROID" "TROMA"
##  [777] "TROME" "TROMI" "TROMH" "TROMA" "TROMD" "TROMA" "TRABO" "TRAOB"
##  [785] "TRAOI" "TRAOM" "TRAEI" "TRAEO" "TRAEM" "TRAEH" "TRAEC" "TRAIO"
##  [793] "TRAIM" "TRAIA" "TRAID" "TRAMO" "TRAME" "TRAMI" "TRAMH" "TRAMA"
##  [801] "TRAMD" "TRAMA" "TRAHE" "TRAHO" "TRAHM" "TRAHC" "TRAHD" "TRAHA"
##  [809] "TRAHR" "TREIO" "TREAB" "TREAO" "TREAI" "TREAM" "TREAH" "TREOI"
##  [817] "TREOH" "TREOC" "TREMO" "TREMA" "TREMI" "TREMH" "TREMA" "TREMD"
##  [825] "TREMA" "TREHA" "TREHO" "TREHM" "TREHC" "TREHD" "TREHA" "TREHR"
##  [833] "TRECO" "TRECH" "TRECA" "TRECR" "TIERB" "TIERO" "TIERA" "TIEAB"
##  [841] "TIEAR" "TIEAO" "TIEAI" "TIEAM" "TIEAH" "TIEOH" "TIEOC" "TIEMO"
##  [849] "TIEMA" "TIEMI" "TIEMH" "TIEMA" "TIEMD" "TIEMA" "TIEHA" "TIEHO"
##  [857] "TIEHM" "TIEHC" "TIEHD" "TIEHA" "TIEHR" "TIECO" "TIECH" "TIECA"
##  [865] "TIECR" "TIOER" "TIOEA" "TIOEM" "TIOEH" "TIOEC" "TIOHA" "TIOHE"
##  [873] "TIOHM" "TIOHC" "TIOHD" "TIOHA" "TIOHR" "TIOCE" "TIOCH" "TIOCA"
##  [881] "TIOCR" "TABRO" "TABRE" "TABOR" "TABOI" "TABOM" "TARBO" "TAROB"
##  [889] "TAROI" "TAROM" "TAREI" "TAREO" "TAREM" "TAREH" "TAREC" "TAOBR"
##  [897] "TAORB" "TAORE" "TAOIM" "TAOIA" "TAOID" "TAOME" "TAOMI" "TAOMH"
##  [905] "TAOMA" "TAOMD" "TAOMA" "TAERB" "TAERO" "TAEIO" "TAEOI" "TAEOH"
##  [913] "TAEOC" "TAEMO" "TAEMI" "TAEMH" "TAEMA" "TAEMD" "TAEMA" "TAEHO"
##  [921] "TAEHM" "TAEHC" "TAEHD" "TAEHA" "TAEHR" "TAECO" "TAECH" "TAECA"
##  [929] "TAECR" "TAIOB" "TAIOR" "TAIOM" "TAIMO" "TAIME" "TAIMH" "TAIMA"
##  [937] "TAIMD" "TAIMA" "TAIAM" "TAIAD" "TAIDM" "TAIDH" "TAIDA" "TAIDA"
##  [945] "TAMOB" "TAMOR" "TAMOI" "TAMER" "TAMEI" "TAMEO" "TAMEH" "TAMEC"
##  [953] "TAMIO" "TAMIA" "TAMID" "TAMHE" "TAMHO" "TAMHC" "TAMHD" "TAMHA"
##  [961] "TAMHR" "TAMAI" "TAMAD" "TAMDI" "TAMDH" "TAMDA" "TAMDA" "TAMAH"
##  [969] "TAMAC" "TAMAD" "TAMAR" "TAHER" "TAHEI" "TAHEO" "TAHEM" "TAHEC"
##  [977] "TAHOI" "TAHOE" "TAHOC" "TAHMO" "TAHME" "TAHMI" "TAHMA" "TAHMD"
##  [985] "TAHMA" "TAHCE" "TAHCO" "TAHCA" "TAHCR" "TAHDI" "TAHDM" "TAHDA"
##  [993] "TAHDA" "TAHAM" "TAHAC" "TAHAD" "TAHAR" "TAHRC" "TAHRA" "TERBO"
## [1001] "TERBA" "TEROB" "TEROA" "TEROI" "TEROM" "TERAB" "TERAO" "TERAI"
## [1009] "TERAM" "TERAH" "TEIOH" "TEIOC" "TEABR" "TEABO" "TEARB" "TEARO"
## [1017] "TEAOB" "TEAOR" "TEAOI" "TEAOM" "TEAIO" "TEAIM" "TEAIA" "TEAID"
## [1025] "TEAMO" "TEAMI" "TEAMH" "TEAMA" "TEAMD" "TEAMA" "TEAHO" "TEAHM"
## [1033] "TEAHC" "TEAHD" "TEAHA" "TEAHR" "TEOHA" "TEOHM" "TEOHC" "TEOHD"
## [1041] "TEOHA" "TEOHR" "TEOCH" "TEOCA" "TEOCR" "TEMOB" "TEMOR" "TEMOA"
## [1049] "TEMOI" "TEMAB" "TEMAR" "TEMAO" "TEMAI" "TEMAH" "TEMIO" "TEMIA"
## [1057] "TEMIA" "TEMID" "TEMHA" "TEMHO" "TEMHC" "TEMHD" "TEMHA" "TEMHR"
## [1065] "TEMAI" "TEMAD" "TEMDI" "TEMDH" "TEMDA" "TEMDA" "TEMAH" "TEMAC"
## [1073] "TEMAD" "TEMAR" "TEHAB" "TEHAR" "TEHAO" "TEHAI" "TEHAM" "TEHOI"
## [1081] "TEHOC" "TEHMO" "TEHMA" "TEHMI" "TEHMA" "TEHMD" "TEHMA" "TEHCO"
## [1089] "TEHCA" "TEHCR" "TEHDI" "TEHDM" "TEHDA" "TEHDA" "TEHAM" "TEHAC"
## [1097] "TEHAD" "TEHAR" "TEHRC" "TEHRA" "TECOI" "TECOH" "TECHA" "TECHO"
## [1105] "TECHM" "TECHD" "TECHA" "TECHR" "TECAM" "TECAH" "TECAD" "TECAR"
## [1113] "TECRH" "TECRA" "TOIER" "TOIEA" "TOIEM" "TOIEH" "TOIEC" "TOERB"
## [1121] "TOERO" "TOERA" "TOEAB" "TOEAR" "TOEAO" "TOEAI" "TOEAM" "TOEAH"
## [1129] "TOEMO" "TOEMA" "TOEMI" "TOEMH" "TOEMA" "TOEMD" "TOEMA" "TOEHA"
## [1137] "TOEHM" "TOEHC" "TOEHD" "TOEHA" "TOEHR" "TOECH" "TOECA" "TOECR"
## [1145] "TOHAB" "TOHAR" "TOHAO" "TOHAE" "TOHAI" "TOHAM" "TOHER" "TOHEI"
## [1153] "TOHEA" "TOHEM" "TOHEC" "TOHMO" "TOHMA" "TOHME" "TOHMI" "TOHMA"
## [1161] "TOHMD" "TOHMA" "TOHCE" "TOHCA" "TOHCR" "TOHDI" "TOHDM" "TOHDA"
## [1169] "TOHDA" "TOHAM" "TOHAC" "TOHAD" "TOHAR" "TOHRC" "TOHRA" "TOCER"
## [1177] "TOCEI" "TOCEA" "TOCEM" "TOCEH" "TOCHA" "TOCHE" "TOCHM" "TOCHD"
## [1185] "TOCHA" "TOCHR" "TOCAM" "TOCAH" "TOCAD" "TOCAR" "TOCRH" "TOCRA"
## [1193] "ITRBO" "ITRBA" "ITROB" "ITROA" "ITROI" "ITROM" "ITRAB" "ITRAO"
## [1201] "ITRAE" "ITRAI" "ITRAM" "ITRAH" "ITREA" "ITREO" "ITREM" "ITREH"
## [1209] "ITREC" "ITABR" "ITABO" "ITARB" "ITARO" "ITARE" "ITAOB" "ITAOR"
## [1217] "ITAOI" "ITAOM" "ITAER" "ITAEO" "ITAEM" "ITAEH" "ITAEC" "ITAIO"
## [1225] "ITAIM" "ITAIA" "ITAID" "ITAMO" "ITAME" "ITAMI" "ITAMH" "ITAMA"
## [1233] "ITAMD" "ITAMA" "ITAHE" "ITAHO" "ITAHM" "ITAHC" "ITAHD" "ITAHA"
## [1241] "ITAHR" "ITERB" "ITERO" "ITERA" "ITEAB" "ITEAR" "ITEAO" "ITEAI"
## [1249] "ITEAM" "ITEAH" "ITEOH" "ITEOC" "ITEMO" "ITEMA" "ITEMI" "ITEMH"
## [1257] "ITEMA" "ITEMD" "ITEMA" "ITEHA" "ITEHO" "ITEHM" "ITEHC" "ITEHD"
## [1265] "ITEHA" "ITEHR" "ITECO" "ITECH" "ITECA" "ITECR" "ITOER" "ITOEA"
## [1273] "ITOEM" "ITOEH" "ITOEC" "ITOHA" "ITOHE" "ITOHM" "ITOHC" "ITOHD"
## [1281] "ITOHA" "ITOHR" "ITOCE" "ITOCH" "ITOCA" "ITOCR" "IERBO" "IERBA"
## [1289] "IERTA" "IERTO" "IEROB" "IEROA" "IEROI" "IEROM" "IERAB" "IERAT"
## [1297] "IERAO" "IERAI" "IERAM" "IERAH" "IETRB" "IETRO" "IETRA" "IETAB"
## [1305] "IETAR" "IETAO" "IETAI" "IETAM" "IETAH" "IETOH" "IETOC" "IEABR"
## [1313] "IEABO" "IEARB" "IEART" "IEARO" "IEATR" "IEATO" "IEAOB" "IEAOR"
## [1321] "IEAOI" "IEAOM" "IEAIO" "IEAIM" "IEAIA" "IEAID" "IEAMO" "IEAMI"
## [1329] "IEAMH" "IEAMA" "IEAMD" "IEAMA" "IEAHO" "IEAHM" "IEAHC" "IEAHD"
## [1337] "IEAHA" "IEAHR" "IEOTR" "IEOTA" "IEOHA" "IEOHM" "IEOHC" "IEOHD"
## [1345] "IEOHA" "IEOHR" "IEOCH" "IEOCA" "IEOCR" "IEMOB" "IEMOR" "IEMOA"
## [1353] "IEMOI" "IEMAB" "IEMAR" "IEMAT" "IEMAO" "IEMAI" "IEMAH" "IEMIO"
## [1361] "IEMIA" "IEMIA" "IEMID" "IEMHA" "IEMHO" "IEMHC" "IEMHD" "IEMHA"
## [1369] "IEMHR" "IEMAI" "IEMAD" "IEMDI" "IEMDH" "IEMDA" "IEMDA" "IEMAH"
## [1377] "IEMAC" "IEMAD" "IEMAR" "IEHAB" "IEHAR" "IEHAT" "IEHAO" "IEHAI"
## [1385] "IEHAM" "IEHOT" "IEHOC" "IEHMO" "IEHMA" "IEHMI" "IEHMA" "IEHMD"
## [1393] "IEHMA" "IEHCO" "IEHCA" "IEHCR" "IEHDI" "IEHDM" "IEHDA" "IEHDA"
## [1401] "IEHAM" "IEHAC" "IEHAD" "IEHAR" "IEHRC" "IEHRA" "IECOT" "IECOH"
## [1409] "IECHA" "IECHO" "IECHM" "IECHD" "IECHA" "IECHR" "IECAM" "IECAH"
## [1417] "IECAD" "IECAR" "IECRH" "IECRA" "IOTRB" "IOTRO" "IOTRA" "IOTRE"
## [1425] "IOTAB" "IOTAR" "IOTAO" "IOTAE" "IOTAI" "IOTAM" "IOTAH" "IOTER"
## [1433] "IOTEA" "IOTEM" "IOTEH" "IOTEC" "IOERB" "IOERT" "IOERO" "IOERA"
## [1441] "IOETR" "IOETA" "IOEAB" "IOEAR" "IOEAT" "IOEAO" "IOEAI" "IOEAM"
## [1449] "IOEAH" "IOEMO" "IOEMA" "IOEMI" "IOEMH" "IOEMA" "IOEMD" "IOEMA"
## [1457] "IOEHA" "IOEHM" "IOEHC" "IOEHD" "IOEHA" "IOEHR" "IOECH" "IOECA"
## [1465] "IOECR" "IOHAB" "IOHAR" "IOHAT" "IOHAO" "IOHAE" "IOHAI" "IOHAM"
## [1473] "IOHER" "IOHET" "IOHEA" "IOHEM" "IOHEC" "IOHMO" "IOHMA" "IOHME"
## [1481] "IOHMI" "IOHMA" "IOHMD" "IOHMA" "IOHCE" "IOHCA" "IOHCR" "IOHDI"
## [1489] "IOHDM" "IOHDA" "IOHDA" "IOHAM" "IOHAC" "IOHAD" "IOHAR" "IOHRC"
## [1497] "IOHRA" "IOCER" "IOCET" "IOCEA" "IOCEM" "IOCEH" "IOCHA" "IOCHE"
## [1505] "IOCHM" "IOCHD" "IOCHA" "IOCHR" "IOCAM" "IOCAH" "IOCAD" "IOCAR"
## [1513] "IOCRH" "IOCRA" "OBRTI" "OBRTA" "OBRTE" "OBRTO" "OBRAT" "OBRAE"
## [1521] "OBRAI" "OBRAM" "OBRAH" "OBRET" "OBREI" "OBREA" "OBREO" "OBREM"
## [1529] "OBREH" "OBREC" "OBART" "OBARE" "OBATR" "OBATI" "OBATE" "OBATO"
## [1537] "OBAER" "OBAET" "OBAEI" "OBAEO" "OBAEM" "OBAEH" "OBAEC" "OBAIM"
## [1545] "OBAIA" "OBAID" "OBAME" "OBAMI" "OBAMH" "OBAMA" "OBAMD" "OBAMA"
## [1553] "OBAHE" "OBAHO" "OBAHM" "OBAHC" "OBAHD" "OBAHA" "OBAHR" "ORBAT"
## [1561] "ORBAE" "ORBAI" "ORBAM" "ORBAH" "ORTIE" "ORTIO" "ORTAB" "ORTAE"
## [1569] "ORTAI" "ORTAM" "ORTAH" "ORTEI" "ORTEA" "ORTEO" "ORTEM" "ORTEH"
## [1577] "ORTEC" "ORTOI" "ORTOE" "ORTOH" "ORTOC" "ORATI" "ORATE" "ORATO"
## [1585] "ORAET" "ORAEI" "ORAEO" "ORAEM" "ORAEH" "ORAEC" "ORAIM" "ORAIA"
## [1593] "ORAID" "ORAME" "ORAMI" "ORAMH" "ORAMA" "ORAMD" "ORAMA" "ORAHE"
## [1601] "ORAHO" "ORAHM" "ORAHC" "ORAHD" "ORAHA" "ORAHR" "ORETI" "ORETA"
## [1609] "ORETO" "OREIT" "OREIO" "OREAB" "OREAT" "OREAI" "OREAM" "OREAH"
## [1617] "OREOT" "OREOI" "OREOH" "OREOC" "OREMA" "OREMI" "OREMH" "OREMA"
## [1625] "OREMD" "OREMA" "OREHA" "OREHO" "OREHM" "OREHC" "OREHD" "OREHA"
## [1633] "OREHR" "ORECO" "ORECH" "ORECA" "ORECR" "OABRT" "OABRE" "OARTI"
## [1641] "OARTE" "OARTO" "OARET" "OAREI" "OAREO" "OAREM" "OAREH" "OAREC"
## [1649] "OATRB" "OATRE" "OATIE" "OATIO" "OATER" "OATEI" "OATEO" "OATEM"
## [1657] "OATEH" "OATEC" "OATOI" "OATOE" "OATOH" "OATOC" "OAERB" "OAERT"
## [1665] "OAETR" "OAETI" "OAETO" "OAEIT" "OAEIO" "OAEOT" "OAEOI" "OAEOH"
## [1673] "OAEOC" "OAEMI" "OAEMH" "OAEMA" "OAEMD" "OAEMA" "OAEHO" "OAEHM"
## [1681] "OAEHC" "OAEHD" "OAEHA" "OAEHR" "OAECO" "OAECH" "OAECA" "OAECR"
## [1689] "OAIME" "OAIMH" "OAIMA" "OAIMD" "OAIMA" "OAIAM" "OAIAD" "OAIDM"
## [1697] "OAIDH" "OAIDA" "OAIDA" "OAMER" "OAMET" "OAMEI" "OAMEO" "OAMEH"
## [1705] "OAMEC" "OAMIA" "OAMID" "OAMHE" "OAMHO" "OAMHC" "OAMHD" "OAMHA"
## [1713] "OAMHR" "OAMAI" "OAMAD" "OAMDI" "OAMDH" "OAMDA" "OAMDA" "OAMAH"
## [1721] "OAMAC" "OAMAD" "OAMAR" "OAHER" "OAHET" "OAHEI" "OAHEO" "OAHEM"
## [1729] "OAHEC" "OAHOT" "OAHOI" "OAHOE" "OAHOC" "OAHME" "OAHMI" "OAHMA"
## [1737] "OAHMD" "OAHMA" "OAHCE" "OAHCO" "OAHCA" "OAHCR" "OAHDI" "OAHDM"
## [1745] "OAHDA" "OAHDA" "OAHAM" "OAHAC" "OAHAD" "OAHAR" "OAHRC" "OAHRA"
## [1753] "OIABR" "OIARB" "OIART" "OIARE" "OIATR" "OIATI" "OIATE" "OIATO"
## [1761] "OIAER" "OIAET" "OIAEI" "OIAEO" "OIAEM" "OIAEH" "OIAEC" "OIAME"
## [1769] "OIAMH" "OIAMA" "OIAMD" "OIAMA" "OIAHE" "OIAHO" "OIAHM" "OIAHC"
## [1777] "OIAHD" "OIAHA" "OIAHR" "OIMAB" "OIMAR" "OIMAT" "OIMAE" "OIMAH"
## [1785] "OIMER" "OIMET" "OIMEI" "OIMEA" "OIMEO" "OIMEH" "OIMEC" "OIMHA"
## [1793] "OIMHE" "OIMHO" "OIMHC" "OIMHD" "OIMHA" "OIMHR" "OIMAD" "OIMDH"
## [1801] "OIMDA" "OIMDA" "OIMAH" "OIMAC" "OIMAD" "OIMAR" "OIAMA" "OIAME"
## [1809] "OIAMH" "OIAMD" "OIAMA" "OIADM" "OIADH" "OIADA" "OIDMA" "OIDME"
## [1817] "OIDMH" "OIDMA" "OIDMA" "OIDHA" "OIDHE" "OIDHO" "OIDHM" "OIDHC"
## [1825] "OIDHA" "OIDHR" "OIDAM" "OIDAM" "OIDAH" "OIDAC" "OIDAR" "OMABR"
## [1833] "OMARB" "OMART" "OMARE" "OMATR" "OMATI" "OMATE" "OMATO" "OMAER"
## [1841] "OMAET" "OMAEI" "OMAEO" "OMAEH" "OMAEC" "OMAIA" "OMAID" "OMAHE"
## [1849] "OMAHO" "OMAHC" "OMAHD" "OMAHA" "OMAHR" "OMERB" "OMERT" "OMERA"
## [1857] "OMETR" "OMETI" "OMETA" "OMETO" "OMEIT" "OMEIO" "OMEAB" "OMEAR"
## [1865] "OMEAT" "OMEAI" "OMEAH" "OMEOT" "OMEOI" "OMEOH" "OMEOC" "OMEHA"
## [1873] "OMEHO" "OMEHC" "OMEHD" "OMEHA" "OMEHR" "OMECO" "OMECH" "OMECA"
## [1881] "OMECR" "OMIAB" "OMIAR" "OMIAT" "OMIAE" "OMIAH" "OMIAD" "OMIDH"
## [1889] "OMIDA" "OMIDA" "OMHAB" "OMHAR" "OMHAT" "OMHAE" "OMHAI" "OMHER"
## [1897] "OMHET" "OMHEI" "OMHEA" "OMHEO" "OMHEC" "OMHOT" "OMHOI" "OMHOE"
## [1905] "OMHOC" "OMHCE" "OMHCO" "OMHCA" "OMHCR" "OMHDI" "OMHDA" "OMHDA"
## [1913] "OMHAC" "OMHAD" "OMHAR" "OMHRC" "OMHRA" "OMAIA" "OMAID" "OMADI"
## [1921] "OMADH" "OMADA" "OMDIA" "OMDIA" "OMDHA" "OMDHE" "OMDHO" "OMDHC"
## [1929] "OMDHA" "OMDHR" "OMDAI" "OMDAH" "OMDAC" "OMDAR" "OMAHA" "OMAHE"
## [1937] "OMAHO" "OMAHC" "OMAHD" "OMAHR" "OMACE" "OMACO" "OMACH" "OMACR"
## [1945] "OMADI" "OMADH" "OMADA" "OMARH" "OMARC" "ABRTI" "ABRTE" "ABRTO"
## [1953] "ABROI" "ABROM" "ABRET" "ABREI" "ABREO" "ABREM" "ABREH" "ABREC"
## [1961] "ABORT" "ABORE" "ABOIM" "ABOIA" "ABOID" "ABOME" "ABOMI" "ABOMH"
## [1969] "ABOMA" "ABOMD" "ABOMA" "ARBOI" "ARBOM" "ARTIE" "ARTIO" "ARTEI"
## [1977] "ARTEO" "ARTEM" "ARTEH" "ARTEC" "ARTOI" "ARTOE" "ARTOH" "ARTOC"
## [1985] "AROIM" "AROIA" "AROID" "AROME" "AROMI" "AROMH" "AROMA" "AROMD"
## [1993] "AROMA" "ARETI" "ARETO" "AREIT" "AREIO" "AREOT" "AREOI" "AREOH"
## [2001] "AREOC" "AREMO" "AREMI" "AREMH" "AREMA" "AREMD" "AREMA" "AREHO"
## [2009] "AREHM" "AREHC" "AREHD" "AREHA" "AREHR" "ARECO" "ARECH" "ARECA"
## [2017] "ARECR" "ATRBO" "ATROB" "ATROI" "ATROM" "ATREI" "ATREO" "ATREM"
## [2025] "ATREH" "ATREC" "ATIER" "ATIEO" "ATIEM" "ATIEH" "ATIEC" "ATIOE"
## [2033] "ATIOH" "ATIOC" "ATERB" "ATERO" "ATEIO" "ATEOI" "ATEOH" "ATEOC"
## [2041] "ATEMO" "ATEMI" "ATEMH" "ATEMA" "ATEMD" "ATEMA" "ATEHO" "ATEHM"
## [2049] "ATEHC" "ATEHD" "ATEHA" "ATEHR" "ATECO" "ATECH" "ATECA" "ATECR"
## [2057] "ATOIE" "ATOER" "ATOEI" "ATOEM" "ATOEH" "ATOEC" "ATOHE" "ATOHM"
## [2065] "ATOHC" "ATOHD" "ATOHA" "ATOHR" "ATOCE" "ATOCH" "ATOCA" "ATOCR"
## [2073] "AOBRT" "AOBRE" "AORTI" "AORTE" "AORTO" "AORET" "AOREI" "AOREO"
## [2081] "AOREM" "AOREH" "AOREC" "AOIME" "AOIMH" "AOIMA" "AOIMD" "AOIMA"
## [2089] "AOIAM" "AOIAD" "AOIDM" "AOIDH" "AOIDA" "AOIDA" "AOMER" "AOMET"
## [2097] "AOMEI" "AOMEO" "AOMEH" "AOMEC" "AOMIA" "AOMID" "AOMHE" "AOMHO"
## [2105] "AOMHC" "AOMHD" "AOMHA" "AOMHR" "AOMAI" "AOMAD" "AOMDI" "AOMDH"
## [2113] "AOMDA" "AOMDA" "AOMAH" "AOMAC" "AOMAD" "AOMAR" "AERBO" "AERTI"
## [2121] "AERTO" "AEROB" "AEROI" "AEROM" "AETRB" "AETRO" "AETIO" "AETOI"
## [2129] "AETOH" "AETOC" "AEITR" "AEITO" "AEIOT" "AEIOH" "AEIOC" "AEOTR"
## [2137] "AEOTI" "AEOIT" "AEOHM" "AEOHC" "AEOHD" "AEOHA" "AEOHR" "AEOCH"
## [2145] "AEOCA" "AEOCR" "AEMOB" "AEMOR" "AEMOI" "AEMIO" "AEMIA" "AEMID"
## [2153] "AEMHO" "AEMHC" "AEMHD" "AEMHA" "AEMHR" "AEMAI" "AEMAD" "AEMDI"
## [2161] "AEMDH" "AEMDA" "AEMDA" "AEMAH" "AEMAC" "AEMAD" "AEMAR" "AEHOT"
## [2169] "AEHOI" "AEHOC" "AEHMO" "AEHMI" "AEHMA" "AEHMD" "AEHMA" "AEHCO"
## [2177] "AEHCA" "AEHCR" "AEHDI" "AEHDM" "AEHDA" "AEHDA" "AEHAM" "AEHAC"
## [2185] "AEHAD" "AEHAR" "AEHRC" "AEHRA" "AECOT" "AECOI" "AECOH" "AECHO"
## [2193] "AECHM" "AECHD" "AECHA" "AECHR" "AECAM" "AECAH" "AECAD" "AECAR"
## [2201] "AECRH" "AECRA" "AIOBR" "AIORB" "AIORT" "AIORE" "AIOME" "AIOMH"
## [2209] "AIOMA" "AIOMD" "AIOMA" "AIMOB" "AIMOR" "AIMER" "AIMET" "AIMEI"
## [2217] "AIMEO" "AIMEH" "AIMEC" "AIMHE" "AIMHO" "AIMHC" "AIMHD" "AIMHA"
## [2225] "AIMHR" "AIMAD" "AIMDH" "AIMDA" "AIMDA" "AIMAH" "AIMAC" "AIMAD"
## [2233] "AIMAR" "AIAMO" "AIAME" "AIAMH" "AIAMD" "AIAMA" "AIADM" "AIADH"
## [2241] "AIADA" "AIDMO" "AIDME" "AIDMH" "AIDMA" "AIDMA" "AIDHE" "AIDHO"
## [2249] "AIDHM" "AIDHC" "AIDHA" "AIDHR" "AIDAM" "AIDAM" "AIDAH" "AIDAC"
## [2257] "AIDAR" "AMOBR" "AMORB" "AMORT" "AMORE" "AMOIA" "AMOID" "AMERB"
## [2265] "AMERT" "AMERO" "AMETR" "AMETI" "AMETO" "AMEIT" "AMEIO" "AMEOT"
## [2273] "AMEOI" "AMEOH" "AMEOC" "AMEHO" "AMEHC" "AMEHD" "AMEHA" "AMEHR"
## [2281] "AMECO" "AMECH" "AMECA" "AMECR" "AMIOB" "AMIOR" "AMIAD" "AMIDH"
## [2289] "AMIDA" "AMIDA" "AMHER" "AMHET" "AMHEI" "AMHEO" "AMHEC" "AMHOT"
## [2297] "AMHOI" "AMHOE" "AMHOC" "AMHCE" "AMHCO" "AMHCA" "AMHCR" "AMHDI"
## [2305] "AMHDA" "AMHDA" "AMHAC" "AMHAD" "AMHAR" "AMHRC" "AMHRA" "AMAIO"
## [2313] "AMAID" "AMADI" "AMADH" "AMADA" "AMDIO" "AMDIA" "AMDHE" "AMDHO"
## [2321] "AMDHC" "AMDHA" "AMDHR" "AMDAI" "AMDAH" "AMDAC" "AMDAR" "AMAHE"
## [2329] "AMAHO" "AMAHC" "AMAHD" "AMAHR" "AMACE" "AMACO" "AMACH" "AMACR"
## [2337] "AMADI" "AMADH" "AMADA" "AMARH" "AMARC" "AHERB" "AHERT" "AHERO"
## [2345] "AHETR" "AHETI" "AHETO" "AHEIT" "AHEIO" "AHEOT" "AHEOI" "AHEOC"
## [2353] "AHEMO" "AHEMI" "AHEMA" "AHEMD" "AHEMA" "AHECO" "AHECA" "AHECR"
## [2361] "AHOTR" "AHOTI" "AHOTE" "AHOIT" "AHOIE" "AHOER" "AHOET" "AHOEI"
## [2369] "AHOEM" "AHOEC" "AHOCE" "AHOCA" "AHOCR" "AHMOB" "AHMOR" "AHMOI"
## [2377] "AHMER" "AHMET" "AHMEI" "AHMEO" "AHMEC" "AHMIO" "AHMIA" "AHMID"
## [2385] "AHMAI" "AHMAD" "AHMDI" "AHMDA" "AHMDA" "AHMAC" "AHMAD" "AHMAR"
## [2393] "AHCER" "AHCET" "AHCEI" "AHCEO" "AHCEM" "AHCOT" "AHCOI" "AHCOE"
## [2401] "AHCAM" "AHCAD" "AHCAR" "AHCRA" "AHDIO" "AHDIM" "AHDIA" "AHDMO"
## [2409] "AHDME" "AHDMI" "AHDMA" "AHDMA" "AHDAI" "AHDAM" "AHDAM" "AHDAC"
## [2417] "AHDAR" "AHAMO" "AHAME" "AHAMI" "AHAMA" "AHAMD" "AHACE" "AHACO"
## [2425] "AHACR" "AHADI" "AHADM" "AHADA" "AHARC" "AHRCE" "AHRCO" "AHRCA"
## [2433] "AHRAM" "AHRAC" "AHRAD" "ERBOA" "ERBOI" "ERBOM" "ERBAT" "ERBAO"
## [2441] "ERBAI" "ERBAM" "ERBAH" "ERTIO" "ERTAB" "ERTAO" "ERTAI" "ERTAM"
## [2449] "ERTAH" "ERTOI" "ERTOH" "ERTOC" "EROBA" "EROAB" "EROAT" "EROAI"
## [2457] "EROAM" "EROAH" "EROIA" "EROIM" "EROIA" "EROID" "EROMA" "EROMI"
## [2465] "EROMH" "EROMA" "EROMD" "EROMA" "ERABO" "ERATI" "ERATO" "ERAOB"
## [2473] "ERAOI" "ERAOM" "ERAIO" "ERAIM" "ERAIA" "ERAID" "ERAMO" "ERAMI"
## [2481] "ERAMH" "ERAMA" "ERAMD" "ERAMA" "ERAHO" "ERAHM" "ERAHC" "ERAHD"
## [2489] "ERAHA" "ERAHR" "ETRBO" "ETRBA" "ETROB" "ETROA" "ETROI" "ETROM"
## [2497] "ETRAB" "ETRAO" "ETRAI" "ETRAM" "ETRAH" "ETIOH" "ETIOC" "ETABR"
## [2505] "ETABO" "ETARB" "ETARO" "ETAOB" "ETAOR" "ETAOI" "ETAOM" "ETAIO"
## [2513] "ETAIM" "ETAIA" "ETAID" "ETAMO" "ETAMI" "ETAMH" "ETAMA" "ETAMD"
## [2521] "ETAMA" "ETAHO" "ETAHM" "ETAHC" "ETAHD" "ETAHA" "ETAHR" "ETOHA"
## [2529] "ETOHM" "ETOHC" "ETOHD" "ETOHA" "ETOHR" "ETOCH" "ETOCA" "ETOCR"
## [2537] "EITRB" "EITRO" "EITRA" "EITAB" "EITAR" "EITAO" "EITAI" "EITAM"
## [2545] "EITAH" "EITOH" "EITOC" "EIOTR" "EIOTA" "EIOHA" "EIOHM" "EIOHC"
## [2553] "EIOHD" "EIOHA" "EIOHR" "EIOCH" "EIOCA" "EIOCR" "EABRT" "EABRO"
## [2561] "EABOR" "EABOI" "EABOM" "EARBO" "EARTI" "EARTO" "EAROB" "EAROI"
## [2569] "EAROM" "EATRB" "EATRO" "EATIO" "EATOI" "EATOH" "EATOC" "EAOBR"
## [2577] "EAORB" "EAORT" "EAOIM" "EAOIA" "EAOID" "EAOMI" "EAOMH" "EAOMA"
## [2585] "EAOMD" "EAOMA" "EAIOB" "EAIOR" "EAIOM" "EAIMO" "EAIMH" "EAIMA"
## [2593] "EAIMD" "EAIMA" "EAIAM" "EAIAD" "EAIDM" "EAIDH" "EAIDA" "EAIDA"
## [2601] "EAMOB" "EAMOR" "EAMOI" "EAMIO" "EAMIA" "EAMID" "EAMHO" "EAMHC"
## [2609] "EAMHD" "EAMHA" "EAMHR" "EAMAI" "EAMAD" "EAMDI" "EAMDH" "EAMDA"
## [2617] "EAMDA" "EAMAH" "EAMAC" "EAMAD" "EAMAR" "EAHOT" "EAHOI" "EAHOC"
## [2625] "EAHMO" "EAHMI" "EAHMA" "EAHMD" "EAHMA" "EAHCO" "EAHCA" "EAHCR"
## [2633] "EAHDI" "EAHDM" "EAHDA" "EAHDA" "EAHAM" "EAHAC" "EAHAD" "EAHAR"
## [2641] "EAHRC" "EAHRA" "EOTRB" "EOTRO" "EOTRA" "EOTAB" "EOTAR" "EOTAO"
## [2649] "EOTAI" "EOTAM" "EOTAH" "EOITR" "EOITA" "EOHAB" "EOHAR" "EOHAT"
## [2657] "EOHAO" "EOHAI" "EOHAM" "EOHMO" "EOHMA" "EOHMI" "EOHMA" "EOHMD"
## [2665] "EOHMA" "EOHCA" "EOHCR" "EOHDI" "EOHDM" "EOHDA" "EOHDA" "EOHAM"
## [2673] "EOHAC" "EOHAD" "EOHAR" "EOHRC" "EOHRA" "EOCHA" "EOCHM" "EOCHD"
## [2681] "EOCHA" "EOCHR" "EOCAM" "EOCAH" "EOCAD" "EOCAR" "EOCRH" "EOCRA"
## [2689] "EMOBR" "EMOBA" "EMORB" "EMORT" "EMORA" "EMOAB" "EMOAR" "EMOAT"
## [2697] "EMOAI" "EMOAH" "EMOIA" "EMOIA" "EMOID" "EMABR" "EMABO" "EMARB"
## [2705] "EMART" "EMARO" "EMATR" "EMATI" "EMATO" "EMAOB" "EMAOR" "EMAOI"
## [2713] "EMAIO" "EMAIA" "EMAID" "EMAHO" "EMAHC" "EMAHD" "EMAHA" "EMAHR"
## [2721] "EMIOB" "EMIOR" "EMIOA" "EMIAB" "EMIAR" "EMIAT" "EMIAO" "EMIAH"
## [2729] "EMIAD" "EMIDH" "EMIDA" "EMIDA" "EMHAB" "EMHAR" "EMHAT" "EMHAO"
## [2737] "EMHAI" "EMHOT" "EMHOI" "EMHOC" "EMHCO" "EMHCA" "EMHCR" "EMHDI"
## [2745] "EMHDA" "EMHDA" "EMHAC" "EMHAD" "EMHAR" "EMHRC" "EMHRA" "EMAIO"
## [2753] "EMAIA" "EMAID" "EMADI" "EMADH" "EMADA" "EMDIO" "EMDIA" "EMDIA"
## [2761] "EMDHA" "EMDHO" "EMDHC" "EMDHA" "EMDHR" "EMDAI" "EMDAH" "EMDAC"
## [2769] "EMDAR" "EMAHA" "EMAHO" "EMAHC" "EMAHD" "EMAHR" "EMACO" "EMACH"
## [2777] "EMACR" "EMADI" "EMADH" "EMADA" "EMARH" "EMARC" "EHABR" "EHABO"
## [2785] "EHARB" "EHART" "EHARO" "EHATR" "EHATI" "EHATO" "EHAOB" "EHAOR"
## [2793] "EHAOI" "EHAOM" "EHAIO" "EHAIM" "EHAIA" "EHAID" "EHAMO" "EHAMI"
## [2801] "EHAMA" "EHAMD" "EHAMA" "EHOTR" "EHOTI" "EHOTA" "EHOIT" "EHOCA"
## [2809] "EHOCR" "EHMOB" "EHMOR" "EHMOA" "EHMOI" "EHMAB" "EHMAR" "EHMAT"
## [2817] "EHMAO" "EHMAI" "EHMIO" "EHMIA" "EHMIA" "EHMID" "EHMAI" "EHMAD"
## [2825] "EHMDI" "EHMDA" "EHMDA" "EHMAC" "EHMAD" "EHMAR" "EHCOT" "EHCOI"
## [2833] "EHCAM" "EHCAD" "EHCAR" "EHCRA" "EHDIO" "EHDIA" "EHDIM" "EHDIA"
## [2841] "EHDMO" "EHDMA" "EHDMI" "EHDMA" "EHDMA" "EHDAI" "EHDAM" "EHDAM"
## [2849] "EHDAC" "EHDAR" "EHAMO" "EHAMA" "EHAMI" "EHAMA" "EHAMD" "EHACO"
## [2857] "EHACR" "EHADI" "EHADM" "EHADA" "EHARC" "EHRCO" "EHRCA" "EHRAM"
## [2865] "EHRAC" "EHRAD" "ECOTR" "ECOTI" "ECOTA" "ECOIT" "ECOHA" "ECOHM"
## [2873] "ECOHD" "ECOHA" "ECOHR" "ECHAB" "ECHAR" "ECHAT" "ECHAO" "ECHAI"
## [2881] "ECHAM" "ECHOT" "ECHOI" "ECHMO" "ECHMA" "ECHMI" "ECHMA" "ECHMD"
## [2889] "ECHMA" "ECHDI" "ECHDM" "ECHDA" "ECHDA" "ECHAM" "ECHAD" "ECHAR"
## [2897] "ECHRA" "ECAMO" "ECAMA" "ECAMI" "ECAMH" "ECAMA" "ECAMD" "ECAHA"
## [2905] "ECAHO" "ECAHM" "ECAHD" "ECAHR" "ECADI" "ECADM" "ECADH" "ECADA"
## [2913] "ECARH" "ECRHA" "ECRHO" "ECRHM" "ECRHD" "ECRHA" "ECRAM" "ECRAH"
## [2921] "ECRAD" "OTRBO" "OTRBA" "OTROB" "OTROA" "OTROI" "OTROM" "OTRAB"
## [2929] "OTRAO" "OTRAE" "OTRAI" "OTRAM" "OTRAH" "OTREI" "OTREA" "OTREM"
## [2937] "OTREH" "OTREC" "OTIER" "OTIEA" "OTIEM" "OTIEH" "OTIEC" "OTABR"
## [2945] "OTABO" "OTARB" "OTARO" "OTARE" "OTAOB" "OTAOR" "OTAOI" "OTAOM"
## [2953] "OTAER" "OTAEI" "OTAEM" "OTAEH" "OTAEC" "OTAIO" "OTAIM" "OTAIA"
## [2961] "OTAID" "OTAMO" "OTAME" "OTAMI" "OTAMH" "OTAMA" "OTAMD" "OTAMA"
## [2969] "OTAHE" "OTAHM" "OTAHC" "OTAHD" "OTAHA" "OTAHR" "OTERB" "OTERO"
## [2977] "OTERA" "OTEAB" "OTEAR" "OTEAO" "OTEAI" "OTEAM" "OTEAH" "OTEMO"
## [2985] "OTEMA" "OTEMI" "OTEMH" "OTEMA" "OTEMD" "OTEMA" "OTEHA" "OTEHM"
## [2993] "OTEHC" "OTEHD" "OTEHA" "OTEHR" "OTECH" "OTECA" "OTECR" "OITRB"
## [3001] "OITRO" "OITRA" "OITRE" "OITAB" "OITAR" "OITAO" "OITAE" "OITAI"
## [3009] "OITAM" "OITAH" "OITER" "OITEA" "OITEM" "OITEH" "OITEC" "OIERB"
## [3017] "OIERT" "OIERO" "OIERA" "OIETR" "OIETA" "OIEAB" "OIEAR" "OIEAT"
## [3025] "OIEAO" "OIEAI" "OIEAM" "OIEAH" "OIEMO" "OIEMA" "OIEMI" "OIEMH"
## [3033] "OIEMA" "OIEMD" "OIEMA" "OIEHA" "OIEHM" "OIEHC" "OIEHD" "OIEHA"
## [3041] "OIEHR" "OIECH" "OIECA" "OIECR" "OERBO" "OERBA" "OERTI" "OERTA"
## [3049] "OEROB" "OEROA" "OEROI" "OEROM" "OERAB" "OERAT" "OERAO" "OERAI"
## [3057] "OERAM" "OERAH" "OETRB" "OETRO" "OETRA" "OETAB" "OETAR" "OETAO"
## [3065] "OETAI" "OETAM" "OETAH" "OEITR" "OEITA" "OEABR" "OEABO" "OEARB"
## [3073] "OEART" "OEARO" "OEATR" "OEATI" "OEAOB" "OEAOR" "OEAOI" "OEAOM"
## [3081] "OEAIO" "OEAIM" "OEAIA" "OEAID" "OEAMO" "OEAMI" "OEAMH" "OEAMA"
## [3089] "OEAMD" "OEAMA" "OEAHM" "OEAHC" "OEAHD" "OEAHA" "OEAHR" "OEMOB"
## [3097] "OEMOR" "OEMOA" "OEMOI" "OEMAB" "OEMAR" "OEMAT" "OEMAO" "OEMAI"
## [3105] "OEMAH" "OEMIO" "OEMIA" "OEMIA" "OEMID" "OEMHA" "OEMHC" "OEMHD"
## [3113] "OEMHA" "OEMHR" "OEMAI" "OEMAD" "OEMDI" "OEMDH" "OEMDA" "OEMDA"
## [3121] "OEMAH" "OEMAC" "OEMAD" "OEMAR" "OEHAB" "OEHAR" "OEHAT" "OEHAO"
## [3129] "OEHAI" "OEHAM" "OEHMO" "OEHMA" "OEHMI" "OEHMA" "OEHMD" "OEHMA"
## [3137] "OEHCA" "OEHCR" "OEHDI" "OEHDM" "OEHDA" "OEHDA" "OEHAM" "OEHAC"
## [3145] "OEHAD" "OEHAR" "OEHRC" "OEHRA" "OECHA" "OECHM" "OECHD" "OECHA"
## [3153] "OECHR" "OECAM" "OECAH" "OECAD" "OECAR" "OECRH" "OECRA" "OHABR"
## [3161] "OHABO" "OHARB" "OHART" "OHARO" "OHARE" "OHATR" "OHATI" "OHATE"
## [3169] "OHAOB" "OHAOR" "OHAOI" "OHAOM" "OHAER" "OHAET" "OHAEI" "OHAEM"
## [3177] "OHAEC" "OHAIO" "OHAIM" "OHAIA" "OHAID" "OHAMO" "OHAME" "OHAMI"
## [3185] "OHAMA" "OHAMD" "OHAMA" "OHERB" "OHERT" "OHERO" "OHERA" "OHETR"
## [3193] "OHETI" "OHETA" "OHEIT" "OHEAB" "OHEAR" "OHEAT" "OHEAO" "OHEAI"
## [3201] "OHEAM" "OHEMO" "OHEMA" "OHEMI" "OHEMA" "OHEMD" "OHEMA" "OHECA"
## [3209] "OHECR" "OHMOB" "OHMOR" "OHMOA" "OHMOI" "OHMAB" "OHMAR" "OHMAT"
## [3217] "OHMAO" "OHMAE" "OHMAI" "OHMER" "OHMET" "OHMEI" "OHMEA" "OHMEC"
## [3225] "OHMIO" "OHMIA" "OHMIA" "OHMID" "OHMAI" "OHMAD" "OHMDI" "OHMDA"
## [3233] "OHMDA" "OHMAC" "OHMAD" "OHMAR" "OHCER" "OHCET" "OHCEI" "OHCEA"
## [3241] "OHCEM" "OHCAM" "OHCAD" "OHCAR" "OHCRA" "OHDIO" "OHDIA" "OHDIM"
## [3249] "OHDIA" "OHDMO" "OHDMA" "OHDME" "OHDMI" "OHDMA" "OHDMA" "OHDAI"
## [3257] "OHDAM" "OHDAM" "OHDAC" "OHDAR" "OHAMO" "OHAMA" "OHAME" "OHAMI"
## [3265] "OHAMA" "OHAMD" "OHACE" "OHACR" "OHADI" "OHADM" "OHADA" "OHARC"
## [3273] "OHRCE" "OHRCA" "OHRAM" "OHRAC" "OHRAD" "OCERB" "OCERT" "OCERO"
## [3281] "OCERA" "OCETR" "OCETI" "OCETA" "OCEIT" "OCEAB" "OCEAR" "OCEAT"
## [3289] "OCEAO" "OCEAI" "OCEAM" "OCEAH" "OCEMO" "OCEMA" "OCEMI" "OCEMH"
## [3297] "OCEMA" "OCEMD" "OCEMA" "OCEHA" "OCEHM" "OCEHD" "OCEHA" "OCEHR"
## [3305] "OCHAB" "OCHAR" "OCHAT" "OCHAO" "OCHAE" "OCHAI" "OCHAM" "OCHER"
## [3313] "OCHET" "OCHEI" "OCHEA" "OCHEM" "OCHMO" "OCHMA" "OCHME" "OCHMI"
## [3321] "OCHMA" "OCHMD" "OCHMA" "OCHDI" "OCHDM" "OCHDA" "OCHDA" "OCHAM"
## [3329] "OCHAD" "OCHAR" "OCHRA" "OCAMO" "OCAMA" "OCAME" "OCAMI" "OCAMH"
## [3337] "OCAMA" "OCAMD" "OCAHA" "OCAHE" "OCAHM" "OCAHD" "OCAHR" "OCADI"
## [3345] "OCADM" "OCADH" "OCADA" "OCARH" "OCRHA" "OCRHE" "OCRHM" "OCRHD"
## [3353] "OCRHA" "OCRAM" "OCRAH" "OCRAD" "IOBRT" "IOBRA" "IOBRE" "IOBAR"
## [3361] "IOBAT" "IOBAE" "IOBAM" "IOBAH" "IORBA" "IORTI" "IORTA" "IORTE"
## [3369] "IORTO" "IORAB" "IORAT" "IORAE" "IORAM" "IORAH" "IORET" "IOREI"
## [3377] "IOREA" "IOREO" "IOREM" "IOREH" "IOREC" "IOABR" "IOARB" "IOART"
## [3385] "IOARE" "IOATR" "IOATI" "IOATE" "IOATO" "IOAER" "IOAET" "IOAEI"
## [3393] "IOAEO" "IOAEM" "IOAEH" "IOAEC" "IOAME" "IOAMH" "IOAMA" "IOAMD"
## [3401] "IOAMA" "IOAHE" "IOAHO" "IOAHM" "IOAHC" "IOAHD" "IOAHA" "IOAHR"
## [3409] "IOMAB" "IOMAR" "IOMAT" "IOMAE" "IOMAH" "IOMER" "IOMET" "IOMEI"
## [3417] "IOMEA" "IOMEO" "IOMEH" "IOMEC" "IOMHA" "IOMHE" "IOMHO" "IOMHC"
## [3425] "IOMHD" "IOMHA" "IOMHR" "IOMAD" "IOMDH" "IOMDA" "IOMDA" "IOMAH"
## [3433] "IOMAC" "IOMAD" "IOMAR" "IABRT" "IABRO" "IABRE" "IABOR" "IABOM"
## [3441] "IARBO" "IARTI" "IARTE" "IARTO" "IAROB" "IAROM" "IARET" "IAREI"
## [3449] "IAREO" "IAREM" "IAREH" "IAREC" "IATRB" "IATRO" "IATRE" "IATIE"
## [3457] "IATIO" "IATER" "IATEI" "IATEO" "IATEM" "IATEH" "IATEC" "IATOI"
## [3465] "IATOE" "IATOH" "IATOC" "IAOBR" "IAORB" "IAORT" "IAORE" "IAOME"
## [3473] "IAOMH" "IAOMA" "IAOMD" "IAOMA" "IAERB" "IAERT" "IAERO" "IAETR"
## [3481] "IAETI" "IAETO" "IAEIT" "IAEIO" "IAEOT" "IAEOI" "IAEOH" "IAEOC"
## [3489] "IAEMO" "IAEMH" "IAEMA" "IAEMD" "IAEMA" "IAEHO" "IAEHM" "IAEHC"
## [3497] "IAEHD" "IAEHA" "IAEHR" "IAECO" "IAECH" "IAECA" "IAECR" "IAMOB"
## [3505] "IAMOR" "IAMER" "IAMET" "IAMEI" "IAMEO" "IAMEH" "IAMEC" "IAMHE"
## [3513] "IAMHO" "IAMHC" "IAMHD" "IAMHA" "IAMHR" "IAMAD" "IAMDH" "IAMDA"
## [3521] "IAMDA" "IAMAH" "IAMAC" "IAMAD" "IAMAR" "IAHER" "IAHET" "IAHEI"
## [3529] "IAHEO" "IAHEM" "IAHEC" "IAHOT" "IAHOI" "IAHOE" "IAHOC" "IAHMO"
## [3537] "IAHME" "IAHMA" "IAHMD" "IAHMA" "IAHCE" "IAHCO" "IAHCA" "IAHCR"
## [3545] "IAHDM" "IAHDA" "IAHDA" "IAHAM" "IAHAC" "IAHAD" "IAHAR" "IAHRC"
## [3553] "IAHRA" "IMOBR" "IMOBA" "IMORB" "IMORT" "IMORA" "IMORE" "IMOAB"
## [3561] "IMOAR" "IMOAT" "IMOAE" "IMOAH" "IMABR" "IMABO" "IMARB" "IMART"
## [3569] "IMARO" "IMARE" "IMATR" "IMATI" "IMATE" "IMATO" "IMAOB" "IMAOR"
## [3577] "IMAER" "IMAET" "IMAEI" "IMAEO" "IMAEH" "IMAEC" "IMAHE" "IMAHO"
## [3585] "IMAHC" "IMAHD" "IMAHA" "IMAHR" "IMERB" "IMERT" "IMERO" "IMERA"
## [3593] "IMETR" "IMETI" "IMETA" "IMETO" "IMEIT" "IMEIO" "IMEAB" "IMEAR"
## [3601] "IMEAT" "IMEAO" "IMEAH" "IMEOT" "IMEOI" "IMEOH" "IMEOC" "IMEHA"
## [3609] "IMEHO" "IMEHC" "IMEHD" "IMEHA" "IMEHR" "IMECO" "IMECH" "IMECA"
## [3617] "IMECR" "IMHAB" "IMHAR" "IMHAT" "IMHAO" "IMHAE" "IMHER" "IMHET"
## [3625] "IMHEI" "IMHEA" "IMHEO" "IMHEC" "IMHOT" "IMHOI" "IMHOE" "IMHOC"
## [3633] "IMHCE" "IMHCO" "IMHCA" "IMHCR" "IMHDA" "IMHDA" "IMHAC" "IMHAD"
## [3641] "IMHAR" "IMHRC" "IMHRA" "IMADH" "IMADA" "IMDHA" "IMDHE" "IMDHO"
## [3649] "IMDHC" "IMDHA" "IMDHR" "IMDAH" "IMDAC" "IMDAR" "IMAHA" "IMAHE"
## [3657] "IMAHO" "IMAHC" "IMAHD" "IMAHR" "IMACE" "IMACO" "IMACH" "IMACR"
## [3665] "IMADH" "IMADA" "IMARH" "IMARC" "IAMOB" "IAMOR" "IAMOA" "IAMAB"
## [3673] "IAMAR" "IAMAT" "IAMAO" "IAMAE" "IAMAH" "IAMER" "IAMET" "IAMEI"
## [3681] "IAMEA" "IAMEO" "IAMEH" "IAMEC" "IAMHA" "IAMHE" "IAMHO" "IAMHC"
## [3689] "IAMHD" "IAMHA" "IAMHR" "IAMDH" "IAMDA" "IAMAH" "IAMAC" "IAMAD"
## [3697] "IAMAR" "IADMO" "IADMA" "IADME" "IADMH" "IADMA" "IADHA" "IADHE"
## [3705] "IADHO" "IADHM" "IADHC" "IADHA" "IADHR" "IADAM" "IADAH" "IADAC"
## [3713] "IADAR" "IDMOB" "IDMOR" "IDMOA" "IDMAB" "IDMAR" "IDMAT" "IDMAO"
## [3721] "IDMAE" "IDMAH" "IDMER" "IDMET" "IDMEI" "IDMEA" "IDMEO" "IDMEH"
## [3729] "IDMEC" "IDMHA" "IDMHE" "IDMHO" "IDMHC" "IDMHA" "IDMHR" "IDMAH"
## [3737] "IDMAC" "IDMAR" "IDHAB" "IDHAR" "IDHAT" "IDHAO" "IDHAE" "IDHAM"
## [3745] "IDHER" "IDHET" "IDHEI" "IDHEA" "IDHEO" "IDHEM" "IDHEC" "IDHOT"
## [3753] "IDHOI" "IDHOE" "IDHOC" "IDHMO" "IDHMA" "IDHME" "IDHMA" "IDHMA"
## [3761] "IDHCE" "IDHCO" "IDHCA" "IDHCR" "IDHAM" "IDHAC" "IDHAR" "IDHRC"
## [3769] "IDHRA" "IDAMO" "IDAMA" "IDAME" "IDAMH" "IDAMA" "IDAMO" "IDAMA"
## [3777] "IDAME" "IDAMH" "IDAMA" "IDAHA" "IDAHE" "IDAHO" "IDAHM" "IDAHC"
## [3785] "IDAHR" "IDACE" "IDACO" "IDACH" "IDACR" "IDARH" "IDARC" "MOBRT"
## [3793] "MOBRA" "MOBRE" "MOBAR" "MOBAT" "MOBAE" "MOBAI" "MOBAH" "MORBA"
## [3801] "MORTI" "MORTA" "MORTE" "MORTO" "MORAB" "MORAT" "MORAE" "MORAI"
## [3809] "MORAH" "MORET" "MOREI" "MOREA" "MOREO" "MOREH" "MOREC" "MOABR"
## [3817] "MOARB" "MOART" "MOARE" "MOATR" "MOATI" "MOATE" "MOATO" "MOAER"
## [3825] "MOAET" "MOAEI" "MOAEO" "MOAEH" "MOAEC" "MOAIA" "MOAID" "MOAHE"
## [3833] "MOAHO" "MOAHC" "MOAHD" "MOAHA" "MOAHR" "MOIAB" "MOIAR" "MOIAT"
## [3841] "MOIAE" "MOIAH" "MOIAD" "MOIDH" "MOIDA" "MOIDA" "MABRT" "MABRO"
## [3849] "MABRE" "MABOR" "MABOI" "MARBO" "MARTI" "MARTE" "MARTO" "MAROB"
## [3857] "MAROI" "MARET" "MAREI" "MAREO" "MAREH" "MAREC" "MATRB" "MATRO"
## [3865] "MATRE" "MATIE" "MATIO" "MATER" "MATEI" "MATEO" "MATEH" "MATEC"
## [3873] "MATOI" "MATOE" "MATOH" "MATOC" "MAOBR" "MAORB" "MAORT" "MAORE"
## [3881] "MAOIA" "MAOID" "MAERB" "MAERT" "MAERO" "MAETR" "MAETI" "MAETO"
## [3889] "MAEIT" "MAEIO" "MAEOT" "MAEOI" "MAEOH" "MAEOC" "MAEHO" "MAEHC"
## [3897] "MAEHD" "MAEHA" "MAEHR" "MAECO" "MAECH" "MAECA" "MAECR" "MAIOB"
## [3905] "MAIOR" "MAIAD" "MAIDH" "MAIDA" "MAIDA" "MAHER" "MAHET" "MAHEI"
## [3913] "MAHEO" "MAHEC" "MAHOT" "MAHOI" "MAHOE" "MAHOC" "MAHCE" "MAHCO"
## [3921] "MAHCA" "MAHCR" "MAHDI" "MAHDA" "MAHDA" "MAHAC" "MAHAD" "MAHAR"
## [3929] "MAHRC" "MAHRA" "MERBO" "MERBA" "MERTI" "MERTA" "MERTO" "MEROB"
## [3937] "MEROA" "MEROI" "MERAB" "MERAT" "MERAO" "MERAI" "MERAH" "METRB"
## [3945] "METRO" "METRA" "METIO" "METAB" "METAR" "METAO" "METAI" "METAH"
## [3953] "METOI" "METOH" "METOC" "MEITR" "MEITA" "MEITO" "MEIOT" "MEIOH"
## [3961] "MEIOC" "MEABR" "MEABO" "MEARB" "MEART" "MEARO" "MEATR" "MEATI"
## [3969] "MEATO" "MEAOB" "MEAOR" "MEAOI" "MEAIO" "MEAIA" "MEAID" "MEAHO"
## [3977] "MEAHC" "MEAHD" "MEAHA" "MEAHR" "MEOTR" "MEOTI" "MEOTA" "MEOIT"
## [3985] "MEOHA" "MEOHC" "MEOHD" "MEOHA" "MEOHR" "MEOCH" "MEOCA" "MEOCR"
## [3993] "MEHAB" "MEHAR" "MEHAT" "MEHAO" "MEHAI" "MEHOT" "MEHOI" "MEHOC"
## [4001] "MEHCO" "MEHCA" "MEHCR" "MEHDI" "MEHDA" "MEHDA" "MEHAC" "MEHAD"
## [4009] "MEHAR" "MEHRC" "MEHRA" "MECOT" "MECOI" "MECOH" "MECHA" "MECHO"
## [4017] "MECHD" "MECHA" "MECHR" "MECAH" "MECAD" "MECAR" "MECRH" "MECRA"
## [4025] "MIOBR" "MIOBA" "MIORB" "MIORT" "MIORA" "MIORE" "MIOAB" "MIOAR"
## [4033] "MIOAT" "MIOAE" "MIOAH" "MIABR" "MIABO" "MIARB" "MIART" "MIARO"
## [4041] "MIARE" "MIATR" "MIATI" "MIATE" "MIATO" "MIAOB" "MIAOR" "MIAER"
## [4049] "MIAET" "MIAEI" "MIAEO" "MIAEH" "MIAEC" "MIAHE" "MIAHO" "MIAHC"
## [4057] "MIAHD" "MIAHA" "MIAHR" "MIADH" "MIADA" "MIDHA" "MIDHE" "MIDHO"
## [4065] "MIDHC" "MIDHA" "MIDHR" "MIDAH" "MIDAC" "MIDAR" "MHABR" "MHABO"
## [4073] "MHARB" "MHART" "MHARO" "MHARE" "MHATR" "MHATI" "MHATE" "MHATO"
## [4081] "MHAOB" "MHAOR" "MHAOI" "MHAER" "MHAET" "MHAEI" "MHAEO" "MHAEC"
## [4089] "MHAIO" "MHAIA" "MHAID" "MHERB" "MHERT" "MHERO" "MHERA" "MHETR"
## [4097] "MHETI" "MHETA" "MHETO" "MHEIT" "MHEIO" "MHEAB" "MHEAR" "MHEAT"
## [4105] "MHEAO" "MHEAI" "MHEOT" "MHEOI" "MHEOC" "MHECO" "MHECA" "MHECR"
## [4113] "MHOTR" "MHOTI" "MHOTA" "MHOTE" "MHOIT" "MHOIE" "MHOER" "MHOET"
## [4121] "MHOEI" "MHOEA" "MHOEC" "MHOCE" "MHOCA" "MHOCR" "MHCER" "MHCET"
## [4129] "MHCEI" "MHCEA" "MHCEO" "MHCOT" "MHCOI" "MHCOE" "MHCAD" "MHCAR"
## [4137] "MHCRA" "MHDIO" "MHDIA" "MHDIA" "MHDAI" "MHDAC" "MHDAR" "MHACE"
## [4145] "MHACO" "MHACR" "MHADI" "MHADA" "MHARC" "MHRCE" "MHRCO" "MHRCA"
## [4153] "MHRAC" "MHRAD" "MAIOB" "MAIOR" "MAIOA" "MAIAB" "MAIAR" "MAIAT"
## [4161] "MAIAO" "MAIAE" "MAIAH" "MAIDH" "MAIDA" "MADIO" "MADIA" "MADHA"
## [4169] "MADHE" "MADHO" "MADHC" "MADHA" "MADHR" "MADAH" "MADAC" "MADAR"
## [4177] "MDIOB" "MDIOR" "MDIOA" "MDIAB" "MDIAR" "MDIAT" "MDIAO" "MDIAE"
## [4185] "MDIAH" "MDHAB" "MDHAR" "MDHAT" "MDHAO" "MDHAE" "MDHAI" "MDHER"
## [4193] "MDHET" "MDHEI" "MDHEA" "MDHEO" "MDHEC" "MDHOT" "MDHOI" "MDHOE"
## [4201] "MDHOC" "MDHCE" "MDHCO" "MDHCA" "MDHCR" "MDHAC" "MDHAR" "MDHRC"
## [4209] "MDHRA" "MDAIO" "MDAIA" "MDAHA" "MDAHE" "MDAHO" "MDAHC" "MDAHR"
## [4217] "MDACE" "MDACO" "MDACH" "MDACR" "MDARH" "MDARC" "MAHAB" "MAHAR"
## [4225] "MAHAT" "MAHAO" "MAHAE" "MAHAI" "MAHER" "MAHET" "MAHEI" "MAHEA"
## [4233] "MAHEO" "MAHEC" "MAHOT" "MAHOI" "MAHOE" "MAHOC" "MAHCE" "MAHCO"
## [4241] "MAHCR" "MAHDI" "MAHDA" "MAHRC" "MACER" "MACET" "MACEI" "MACEA"
## [4249] "MACEO" "MACEH" "MACOT" "MACOI" "MACOE" "MACOH" "MACHA" "MACHE"
## [4257] "MACHO" "MACHD" "MACHR" "MACRH" "MADIO" "MADIA" "MADIA" "MADHA"
## [4265] "MADHE" "MADHO" "MADHC" "MADHR" "MADAI" "MARHA" "MARHE" "MARHO"
## [4273] "MARHC" "MARHD" "MARCE" "MARCO" "MARCH" "HABRT" "HABRO" "HABRE"
## [4281] "HABOR" "HABOI" "HABOM" "HARBO" "HARTI" "HARTE" "HARTO" "HAROB"
## [4289] "HAROI" "HAROM" "HARET" "HAREI" "HAREO" "HAREM" "HAREC" "HATRB"
## [4297] "HATRO" "HATRE" "HATIE" "HATIO" "HATER" "HATEI" "HATEO" "HATEM"
## [4305] "HATEC" "HATOI" "HATOE" "HATOC" "HAOBR" "HAORB" "HAORT" "HAORE"
## [4313] "HAOIM" "HAOIA" "HAOID" "HAOME" "HAOMI" "HAOMA" "HAOMD" "HAOMA"
## [4321] "HAERB" "HAERT" "HAERO" "HAETR" "HAETI" "HAETO" "HAEIT" "HAEIO"
## [4329] "HAEOT" "HAEOI" "HAEOC" "HAEMO" "HAEMI" "HAEMA" "HAEMD" "HAEMA"
## [4337] "HAECO" "HAECA" "HAECR" "HAIOB" "HAIOR" "HAIOM" "HAIMO" "HAIME"
## [4345] "HAIMA" "HAIMD" "HAIMA" "HAIAM" "HAIAD" "HAIDM" "HAIDA" "HAIDA"
## [4353] "HAMOB" "HAMOR" "HAMOI" "HAMER" "HAMET" "HAMEI" "HAMEO" "HAMEC"
## [4361] "HAMIO" "HAMIA" "HAMID" "HAMAI" "HAMAD" "HAMDI" "HAMDA" "HAMDA"
## [4369] "HAMAC" "HAMAD" "HAMAR" "HERBO" "HERBA" "HERTI" "HERTA" "HERTO"
## [4377] "HEROB" "HEROA" "HEROI" "HEROM" "HERAB" "HERAT" "HERAO" "HERAI"
## [4385] "HERAM" "HETRB" "HETRO" "HETRA" "HETIO" "HETAB" "HETAR" "HETAO"
## [4393] "HETAI" "HETAM" "HETOI" "HETOC" "HEITR" "HEITA" "HEITO" "HEIOT"
## [4401] "HEIOC" "HEABR" "HEABO" "HEARB" "HEART" "HEARO" "HEATR" "HEATI"
## [4409] "HEATO" "HEAOB" "HEAOR" "HEAOI" "HEAOM" "HEAIO" "HEAIM" "HEAIA"
## [4417] "HEAID" "HEAMO" "HEAMI" "HEAMA" "HEAMD" "HEAMA" "HEOTR" "HEOTI"
## [4425] "HEOTA" "HEOIT" "HEOCA" "HEOCR" "HEMOB" "HEMOR" "HEMOA" "HEMOI"
## [4433] "HEMAB" "HEMAR" "HEMAT" "HEMAO" "HEMAI" "HEMIO" "HEMIA" "HEMIA"
## [4441] "HEMID" "HEMAI" "HEMAD" "HEMDI" "HEMDA" "HEMDA" "HEMAC" "HEMAD"
## [4449] "HEMAR" "HECOT" "HECOI" "HECAM" "HECAD" "HECAR" "HECRA" "HOTRB"
## [4457] "HOTRO" "HOTRA" "HOTRE" "HOTIE" "HOTAB" "HOTAR" "HOTAO" "HOTAE"
## [4465] "HOTAI" "HOTAM" "HOTER" "HOTEI" "HOTEA" "HOTEM" "HOTEC" "HOITR"
## [4473] "HOITA" "HOITE" "HOIER" "HOIET" "HOIEA" "HOIEM" "HOIEC" "HOERB"
## [4481] "HOERT" "HOERO" "HOERA" "HOETR" "HOETI" "HOETA" "HOEIT" "HOEAB"
## [4489] "HOEAR" "HOEAT" "HOEAO" "HOEAI" "HOEAM" "HOEMO" "HOEMA" "HOEMI"
## [4497] "HOEMA" "HOEMD" "HOEMA" "HOECA" "HOECR" "HOCER" "HOCET" "HOCEI"
## [4505] "HOCEA" "HOCEM" "HOCAM" "HOCAD" "HOCAR" "HOCRA" "HMOBR" "HMOBA"
## [4513] "HMORB" "HMORT" "HMORA" "HMORE" "HMOAB" "HMOAR" "HMOAT" "HMOAE"
## [4521] "HMOAI" "HMOIA" "HMOIA" "HMOID" "HMABR" "HMABO" "HMARB" "HMART"
## [4529] "HMARO" "HMARE" "HMATR" "HMATI" "HMATE" "HMATO" "HMAOB" "HMAOR"
## [4537] "HMAOI" "HMAER" "HMAET" "HMAEI" "HMAEO" "HMAEC" "HMAIO" "HMAIA"
## [4545] "HMAID" "HMERB" "HMERT" "HMERO" "HMERA" "HMETR" "HMETI" "HMETA"
## [4553] "HMETO" "HMEIT" "HMEIO" "HMEAB" "HMEAR" "HMEAT" "HMEAO" "HMEAI"
## [4561] "HMEOT" "HMEOI" "HMEOC" "HMECO" "HMECA" "HMECR" "HMIOB" "HMIOR"
## [4569] "HMIOA" "HMIAB" "HMIAR" "HMIAT" "HMIAO" "HMIAE" "HMIAD" "HMIDA"
## [4577] "HMIDA" "HMAIO" "HMAIA" "HMAID" "HMADI" "HMADA" "HMDIO" "HMDIA"
## [4585] "HMDIA" "HMDAI" "HMDAC" "HMDAR" "HMACE" "HMACO" "HMACR" "HMADI"
## [4593] "HMADA" "HMARC" "HCERB" "HCERT" "HCERO" "HCERA" "HCETR" "HCETI"
## [4601] "HCETA" "HCETO" "HCEIT" "HCEIO" "HCEAB" "HCEAR" "HCEAT" "HCEAO"
## [4609] "HCEAI" "HCEAM" "HCEOT" "HCEOI" "HCEMO" "HCEMA" "HCEMI" "HCEMA"
## [4617] "HCEMD" "HCEMA" "HCOTR" "HCOTI" "HCOTA" "HCOTE" "HCOIT" "HCOIE"
## [4625] "HCOER" "HCOET" "HCOEI" "HCOEA" "HCOEM" "HCAMO" "HCAMA" "HCAME"
## [4633] "HCAMI" "HCAMA" "HCAMD" "HCADI" "HCADM" "HCADA" "HCRAM" "HCRAD"
## [4641] "HDIOB" "HDIOR" "HDIOA" "HDIOM" "HDIAB" "HDIAR" "HDIAT" "HDIAO"
## [4649] "HDIAE" "HDIAM" "HDIMO" "HDIMA" "HDIME" "HDIMA" "HDIMA" "HDIAM"
## [4657] "HDMOB" "HDMOR" "HDMOA" "HDMOI" "HDMAB" "HDMAR" "HDMAT" "HDMAO"
## [4665] "HDMAE" "HDMAI" "HDMER" "HDMET" "HDMEI" "HDMEA" "HDMEO" "HDMEC"
## [4673] "HDMIO" "HDMIA" "HDMIA" "HDMAI" "HDMAC" "HDMAR" "HDAIO" "HDAIA"
## [4681] "HDAIM" "HDAMO" "HDAMA" "HDAME" "HDAMI" "HDAMA" "HDAMO" "HDAMA"
## [4689] "HDAME" "HDAMI" "HDAMA" "HDACE" "HDACO" "HDACR" "HDARC" "HAMOB"
## [4697] "HAMOR" "HAMOA" "HAMOI" "HAMAB" "HAMAR" "HAMAT" "HAMAO" "HAMAE"
## [4705] "HAMAI" "HAMER" "HAMET" "HAMEI" "HAMEA" "HAMEO" "HAMEC" "HAMIO"
## [4713] "HAMIA" "HAMIA" "HAMID" "HAMAI" "HAMAD" "HAMDI" "HAMDA" "HACER"
## [4721] "HACET" "HACEI" "HACEA" "HACEO" "HACEM" "HACOT" "HACOI" "HACOE"
## [4729] "HADIO" "HADIA" "HADIM" "HADIA" "HADMO" "HADMA" "HADME" "HADMI"
## [4737] "HADMA" "HADAI" "HADAM" "HARCE" "HARCO" "HRCER" "HRCET" "HRCEI"
## [4745] "HRCEA" "HRCEO" "HRCEM" "HRCOT" "HRCOI" "HRCOE" "HRCAM" "HRCAD"
## [4753] "HRAMO" "HRAMA" "HRAME" "HRAMI" "HRAMA" "HRAMD" "HRACE" "HRACO"
## [4761] "HRADI" "HRADM" "HRADA" "CERBO" "CERBA" "CERTI" "CERTA" "CERTO"
## [4769] "CEROB" "CEROA" "CEROI" "CEROM" "CERAB" "CERAT" "CERAO" "CERAI"
## [4777] "CERAM" "CERAH" "CETRB" "CETRO" "CETRA" "CETIO" "CETAB" "CETAR"
## [4785] "CETAO" "CETAI" "CETAM" "CETAH" "CETOI" "CETOH" "CEITR" "CEITA"
## [4793] "CEITO" "CEIOT" "CEIOH" "CEABR" "CEABO" "CEARB" "CEART" "CEARO"
## [4801] "CEATR" "CEATI" "CEATO" "CEAOB" "CEAOR" "CEAOI" "CEAOM" "CEAIO"
## [4809] "CEAIM" "CEAIA" "CEAID" "CEAMO" "CEAMI" "CEAMH" "CEAMA" "CEAMD"
## [4817] "CEAMA" "CEAHO" "CEAHM" "CEAHD" "CEAHA" "CEAHR" "CEOTR" "CEOTI"
## [4825] "CEOTA" "CEOIT" "CEOHA" "CEOHM" "CEOHD" "CEOHA" "CEOHR" "CEMOB"
## [4833] "CEMOR" "CEMOA" "CEMOI" "CEMAB" "CEMAR" "CEMAT" "CEMAO" "CEMAI"
## [4841] "CEMAH" "CEMIO" "CEMIA" "CEMIA" "CEMID" "CEMHA" "CEMHO" "CEMHD"
## [4849] "CEMHA" "CEMHR" "CEMAI" "CEMAD" "CEMDI" "CEMDH" "CEMDA" "CEMDA"
## [4857] "CEMAH" "CEMAD" "CEMAR" "CEHAB" "CEHAR" "CEHAT" "CEHAO" "CEHAI"
## [4865] "CEHAM" "CEHOT" "CEHOI" "CEHMO" "CEHMA" "CEHMI" "CEHMA" "CEHMD"
## [4873] "CEHMA" "CEHDI" "CEHDM" "CEHDA" "CEHDA" "CEHAM" "CEHAD" "CEHAR"
## [4881] "CEHRA" "COTRB" "COTRO" "COTRA" "COTRE" "COTIE" "COTAB" "COTAR"
## [4889] "COTAO" "COTAE" "COTAI" "COTAM" "COTAH" "COTER" "COTEI" "COTEA"
## [4897] "COTEM" "COTEH" "COITR" "COITA" "COITE" "COIER" "COIET" "COIEA"
## [4905] "COIEM" "COIEH" "COERB" "COERT" "COERO" "COERA" "COETR" "COETI"
## [4913] "COETA" "COEIT" "COEAB" "COEAR" "COEAT" "COEAO" "COEAI" "COEAM"
## [4921] "COEAH" "COEMO" "COEMA" "COEMI" "COEMH" "COEMA" "COEMD" "COEMA"
## [4929] "COEHA" "COEHM" "COEHD" "COEHA" "COEHR" "COHAB" "COHAR" "COHAT"
## [4937] "COHAO" "COHAE" "COHAI" "COHAM" "COHER" "COHET" "COHEI" "COHEA"
## [4945] "COHEM" "COHMO" "COHMA" "COHME" "COHMI" "COHMA" "COHMD" "COHMA"
## [4953] "COHDI" "COHDM" "COHDA" "COHDA" "COHAM" "COHAD" "COHAR" "COHRA"
## [4961] "CHABR" "CHABO" "CHARB" "CHART" "CHARO" "CHARE" "CHATR" "CHATI"
## [4969] "CHATE" "CHATO" "CHAOB" "CHAOR" "CHAOI" "CHAOM" "CHAER" "CHAET"
## [4977] "CHAEI" "CHAEO" "CHAEM" "CHAIO" "CHAIM" "CHAIA" "CHAID" "CHAMO"
## [4985] "CHAME" "CHAMI" "CHAMA" "CHAMD" "CHAMA" "CHERB" "CHERT" "CHERO"
## [4993] "CHERA" "CHETR" "CHETI" "CHETA" "CHETO" "CHEIT" "CHEIO" "CHEAB"
## [5001] "CHEAR" "CHEAT" "CHEAO" "CHEAI" "CHEAM" "CHEOT" "CHEOI" "CHEMO"
## [5009] "CHEMA" "CHEMI" "CHEMA" "CHEMD" "CHEMA" "CHOTR" "CHOTI" "CHOTA"
## [5017] "CHOTE" "CHOIT" "CHOIE" "CHOER" "CHOET" "CHOEI" "CHOEA" "CHOEM"
## [5025] "CHMOB" "CHMOR" "CHMOA" "CHMOI" "CHMAB" "CHMAR" "CHMAT" "CHMAO"
## [5033] "CHMAE" "CHMAI" "CHMER" "CHMET" "CHMEI" "CHMEA" "CHMEO" "CHMIO"
## [5041] "CHMIA" "CHMIA" "CHMID" "CHMAI" "CHMAD" "CHMDI" "CHMDA" "CHMDA"
## [5049] "CHMAD" "CHMAR" "CHDIO" "CHDIA" "CHDIM" "CHDIA" "CHDMO" "CHDMA"
## [5057] "CHDME" "CHDMI" "CHDMA" "CHDMA" "CHDAI" "CHDAM" "CHDAM" "CHDAR"
## [5065] "CHAMO" "CHAMA" "CHAME" "CHAMI" "CHAMA" "CHAMD" "CHADI" "CHADM"
## [5073] "CHADA" "CHRAM" "CHRAD" "CAMOB" "CAMOR" "CAMOA" "CAMOI" "CAMAB"
## [5081] "CAMAR" "CAMAT" "CAMAO" "CAMAE" "CAMAI" "CAMAH" "CAMER" "CAMET"
## [5089] "CAMEI" "CAMEA" "CAMEO" "CAMEH" "CAMIO" "CAMIA" "CAMIA" "CAMID"
## [5097] "CAMHA" "CAMHE" "CAMHO" "CAMHD" "CAMHR" "CAMAI" "CAMAD" "CAMDI"
## [5105] "CAMDH" "CAMDA" "CAHAB" "CAHAR" "CAHAT" "CAHAO" "CAHAE" "CAHAI"
## [5113] "CAHAM" "CAHER" "CAHET" "CAHEI" "CAHEA" "CAHEO" "CAHEM" "CAHOT"
## [5121] "CAHOI" "CAHOE" "CAHMO" "CAHMA" "CAHME" "CAHMI" "CAHMA" "CAHMD"
## [5129] "CAHDI" "CAHDM" "CAHDA" "CADIO" "CADIA" "CADIM" "CADIA" "CADMO"
## [5137] "CADMA" "CADME" "CADMI" "CADMH" "CADMA" "CADHA" "CADHE" "CADHO"
## [5145] "CADHM" "CADHR" "CADAI" "CADAM" "CARHA" "CARHE" "CARHO" "CARHM"
## [5153] "CARHD" "CRHAB" "CRHAR" "CRHAT" "CRHAO" "CRHAE" "CRHAI" "CRHAM"
## [5161] "CRHER" "CRHET" "CRHEI" "CRHEA" "CRHEO" "CRHEM" "CRHOT" "CRHOI"
## [5169] "CRHOE" "CRHMO" "CRHMA" "CRHME" "CRHMI" "CRHMA" "CRHMD" "CRHMA"
## [5177] "CRHDI" "CRHDM" "CRHDA" "CRHDA" "CRHAM" "CRHAD" "CRAMO" "CRAMA"
## [5185] "CRAME" "CRAMI" "CRAMH" "CRAMA" "CRAMD" "CRAHA" "CRAHE" "CRAHO"
## [5193] "CRAHM" "CRAHD" "CRADI" "CRADM" "CRADH" "CRADA" "AIOBR" "AIOBA"
## [5201] "AIORB" "AIORT" "AIORA" "AIORE" "AIOAB" "AIOAR" "AIOAT" "AIOAE"
## [5209] "AIOAM" "AIOAH" "AIOMA" "AIOME" "AIOMH" "AIOMD" "AIOMA" "AIABR"
## [5217] "AIABO" "AIARB" "AIART" "AIARO" "AIARE" "AIATR" "AIATI" "AIATE"
## [5225] "AIATO" "AIAOB" "AIAOR" "AIAOM" "AIAER" "AIAET" "AIAEI" "AIAEO"
## [5233] "AIAEM" "AIAEH" "AIAEC" "AIAMO" "AIAME" "AIAMH" "AIAMD" "AIAMA"
## [5241] "AIAHE" "AIAHO" "AIAHM" "AIAHC" "AIAHD" "AIAHA" "AIAHR" "AIMOB"
## [5249] "AIMOR" "AIMOA" "AIMAB" "AIMAR" "AIMAT" "AIMAO" "AIMAE" "AIMAH"
## [5257] "AIMER" "AIMET" "AIMEI" "AIMEA" "AIMEO" "AIMEH" "AIMEC" "AIMHA"
## [5265] "AIMHE" "AIMHO" "AIMHC" "AIMHD" "AIMHA" "AIMHR" "AIMDH" "AIMDA"
## [5273] "AIMAH" "AIMAC" "AIMAD" "AIMAR" "AIDMO" "AIDMA" "AIDME" "AIDMH"
## [5281] "AIDMA" "AIDHA" "AIDHE" "AIDHO" "AIDHM" "AIDHC" "AIDHA" "AIDHR"
## [5289] "AIDAM" "AIDAH" "AIDAC" "AIDAR" "AMOBR" "AMOBA" "AMORB" "AMORT"
## [5297] "AMORA" "AMORE" "AMOAB" "AMOAR" "AMOAT" "AMOAE" "AMOAI" "AMOAH"
## [5305] "AMOIA" "AMOID" "AMABR" "AMABO" "AMARB" "AMART" "AMARO" "AMARE"
## [5313] "AMATR" "AMATI" "AMATE" "AMATO" "AMAOB" "AMAOR" "AMAOI" "AMAER"
## [5321] "AMAET" "AMAEI" "AMAEO" "AMAEH" "AMAEC" "AMAIO" "AMAID" "AMAHE"
## [5329] "AMAHO" "AMAHC" "AMAHD" "AMAHA" "AMAHR" "AMERB" "AMERT" "AMERO"
## [5337] "AMERA" "AMETR" "AMETI" "AMETA" "AMETO" "AMEIT" "AMEIO" "AMEAB"
## [5345] "AMEAR" "AMEAT" "AMEAO" "AMEAI" "AMEAH" "AMEOT" "AMEOI" "AMEOH"
## [5353] "AMEOC" "AMEHA" "AMEHO" "AMEHC" "AMEHD" "AMEHA" "AMEHR" "AMECO"
## [5361] "AMECH" "AMECA" "AMECR" "AMIOB" "AMIOR" "AMIOA" "AMIAB" "AMIAR"
## [5369] "AMIAT" "AMIAO" "AMIAE" "AMIAH" "AMIDH" "AMIDA" "AMHAB" "AMHAR"
## [5377] "AMHAT" "AMHAO" "AMHAE" "AMHAI" "AMHER" "AMHET" "AMHEI" "AMHEA"
## [5385] "AMHEO" "AMHEC" "AMHOT" "AMHOI" "AMHOE" "AMHOC" "AMHCE" "AMHCO"
## [5393] "AMHCA" "AMHCR" "AMHDI" "AMHDA" "AMHAC" "AMHAD" "AMHAR" "AMHRC"
## [5401] "AMHRA" "AMDIO" "AMDIA" "AMDHA" "AMDHE" "AMDHO" "AMDHC" "AMDHA"
## [5409] "AMDHR" "AMDAH" "AMDAC" "AMDAR" "AMAHA" "AMAHE" "AMAHO" "AMAHC"
## [5417] "AMAHD" "AMAHR" "AMACE" "AMACO" "AMACH" "AMACR" "AMADI" "AMADH"
## [5425] "AMARH" "AMARC" "ADIOB" "ADIOR" "ADIOA" "ADIOM" "ADIAB" "ADIAR"
## [5433] "ADIAT" "ADIAO" "ADIAE" "ADIAM" "ADIAH" "ADIMO" "ADIMA" "ADIME"
## [5441] "ADIMH" "ADIMA" "ADMOB" "ADMOR" "ADMOA" "ADMOI" "ADMAB" "ADMAR"
## [5449] "ADMAT" "ADMAO" "ADMAE" "ADMAI" "ADMAH" "ADMER" "ADMET" "ADMEI"
## [5457] "ADMEA" "ADMEO" "ADMEH" "ADMEC" "ADMIO" "ADMIA" "ADMHA" "ADMHE"
## [5465] "ADMHO" "ADMHC" "ADMHA" "ADMHR" "ADMAH" "ADMAC" "ADMAR" "ADHAB"
## [5473] "ADHAR" "ADHAT" "ADHAO" "ADHAE" "ADHAI" "ADHAM" "ADHER" "ADHET"
## [5481] "ADHEI" "ADHEA" "ADHEO" "ADHEM" "ADHEC" "ADHOT" "ADHOI" "ADHOE"
## [5489] "ADHOC" "ADHMO" "ADHMA" "ADHME" "ADHMI" "ADHMA" "ADHCE" "ADHCO"
## [5497] "ADHCA" "ADHCR" "ADHAM" "ADHAC" "ADHAR" "ADHRC" "ADHRA" "ADAMO"
## [5505] "ADAMA" "ADAME" "ADAMI" "ADAMH" "ADAHA" "ADAHE" "ADAHO" "ADAHM"
## [5513] "ADAHC" "ADAHR" "ADACE" "ADACO" "ADACH" "ADACR" "ADARH" "ADARC"
## [5521] "DIOBR" "DIOBA" "DIORB" "DIORT" "DIORA" "DIORE" "DIOAB" "DIOAR"
## [5529] "DIOAT" "DIOAE" "DIOAM" "DIOAH" "DIOMA" "DIOME" "DIOMH" "DIOMA"
## [5537] "DIOMA" "DIABR" "DIABO" "DIARB" "DIART" "DIARO" "DIARE" "DIATR"
## [5545] "DIATI" "DIATE" "DIATO" "DIAOB" "DIAOR" "DIAOM" "DIAER" "DIAET"
## [5553] "DIAEI" "DIAEO" "DIAEM" "DIAEH" "DIAEC" "DIAMO" "DIAME" "DIAMH"
## [5561] "DIAMA" "DIAMA" "DIAHE" "DIAHO" "DIAHM" "DIAHC" "DIAHA" "DIAHR"
## [5569] "DIMOB" "DIMOR" "DIMOA" "DIMAB" "DIMAR" "DIMAT" "DIMAO" "DIMAE"
## [5577] "DIMAH" "DIMER" "DIMET" "DIMEI" "DIMEA" "DIMEO" "DIMEH" "DIMEC"
## [5585] "DIMHA" "DIMHE" "DIMHO" "DIMHC" "DIMHA" "DIMHR" "DIMAH" "DIMAC"
## [5593] "DIMAR" "DIAMO" "DIAMA" "DIAME" "DIAMH" "DIAMA" "DMOBR" "DMOBA"
## [5601] "DMORB" "DMORT" "DMORA" "DMORE" "DMOAB" "DMOAR" "DMOAT" "DMOAE"
## [5609] "DMOAI" "DMOAH" "DMOIA" "DMOIA" "DMABR" "DMABO" "DMARB" "DMART"
## [5617] "DMARO" "DMARE" "DMATR" "DMATI" "DMATE" "DMATO" "DMAOB" "DMAOR"
## [5625] "DMAOI" "DMAER" "DMAET" "DMAEI" "DMAEO" "DMAEH" "DMAEC" "DMAIO"
## [5633] "DMAIA" "DMAHE" "DMAHO" "DMAHC" "DMAHA" "DMAHR" "DMERB" "DMERT"
## [5641] "DMERO" "DMERA" "DMETR" "DMETI" "DMETA" "DMETO" "DMEIT" "DMEIO"
## [5649] "DMEAB" "DMEAR" "DMEAT" "DMEAO" "DMEAI" "DMEAH" "DMEOT" "DMEOI"
## [5657] "DMEOH" "DMEOC" "DMEHA" "DMEHO" "DMEHC" "DMEHA" "DMEHR" "DMECO"
## [5665] "DMECH" "DMECA" "DMECR" "DMIOB" "DMIOR" "DMIOA" "DMIAB" "DMIAR"
## [5673] "DMIAT" "DMIAO" "DMIAE" "DMIAH" "DMHAB" "DMHAR" "DMHAT" "DMHAO"
## [5681] "DMHAE" "DMHAI" "DMHER" "DMHET" "DMHEI" "DMHEA" "DMHEO" "DMHEC"
## [5689] "DMHOT" "DMHOI" "DMHOE" "DMHOC" "DMHCE" "DMHCO" "DMHCA" "DMHCR"
## [5697] "DMHAC" "DMHAR" "DMHRC" "DMHRA" "DMAIO" "DMAIA" "DMAHA" "DMAHE"
## [5705] "DMAHO" "DMAHC" "DMAHR" "DMACE" "DMACO" "DMACH" "DMACR" "DMARH"
## [5713] "DMARC" "DHABR" "DHABO" "DHARB" "DHART" "DHARO" "DHARE" "DHATR"
## [5721] "DHATI" "DHATE" "DHATO" "DHAOB" "DHAOR" "DHAOI" "DHAOM" "DHAER"
## [5729] "DHAET" "DHAEI" "DHAEO" "DHAEM" "DHAEC" "DHAIO" "DHAIM" "DHAIA"
## [5737] "DHAMO" "DHAME" "DHAMI" "DHAMA" "DHAMA" "DHERB" "DHERT" "DHERO"
## [5745] "DHERA" "DHETR" "DHETI" "DHETA" "DHETO" "DHEIT" "DHEIO" "DHEAB"
## [5753] "DHEAR" "DHEAT" "DHEAO" "DHEAI" "DHEAM" "DHEOT" "DHEOI" "DHEOC"
## [5761] "DHEMO" "DHEMA" "DHEMI" "DHEMA" "DHEMA" "DHECO" "DHECA" "DHECR"
## [5769] "DHOTR" "DHOTI" "DHOTA" "DHOTE" "DHOIT" "DHOIE" "DHOER" "DHOET"
## [5777] "DHOEI" "DHOEA" "DHOEM" "DHOEC" "DHOCE" "DHOCA" "DHOCR" "DHMOB"
## [5785] "DHMOR" "DHMOA" "DHMOI" "DHMAB" "DHMAR" "DHMAT" "DHMAO" "DHMAE"
## [5793] "DHMAI" "DHMER" "DHMET" "DHMEI" "DHMEA" "DHMEO" "DHMEC" "DHMIO"
## [5801] "DHMIA" "DHMIA" "DHMAI" "DHMAC" "DHMAR" "DHCER" "DHCET" "DHCEI"
## [5809] "DHCEA" "DHCEO" "DHCEM" "DHCOT" "DHCOI" "DHCOE" "DHCAM" "DHCAR"
## [5817] "DHCRA" "DHAMO" "DHAMA" "DHAME" "DHAMI" "DHAMA" "DHACE" "DHACO"
## [5825] "DHACR" "DHARC" "DHRCE" "DHRCO" "DHRCA" "DHRAM" "DHRAC" "DAIOB"
## [5833] "DAIOR" "DAIOA" "DAIOM" "DAIAB" "DAIAR" "DAIAT" "DAIAO" "DAIAE"
## [5841] "DAIAM" "DAIAH" "DAIMO" "DAIMA" "DAIME" "DAIMH" "DAIMA" "DAMOB"
## [5849] "DAMOR" "DAMOA" "DAMOI" "DAMAB" "DAMAR" "DAMAT" "DAMAO" "DAMAE"
## [5857] "DAMAI" "DAMAH" "DAMER" "DAMET" "DAMEI" "DAMEA" "DAMEO" "DAMEH"
## [5865] "DAMEC" "DAMIO" "DAMIA" "DAMHA" "DAMHE" "DAMHO" "DAMHC" "DAMHA"
## [5873] "DAMHR" "DAMAH" "DAMAC" "DAMAR" "DAMOB" "DAMOR" "DAMOA" "DAMOI"
## [5881] "DAMAB" "DAMAR" "DAMAT" "DAMAO" "DAMAE" "DAMAI" "DAMAH" "DAMER"
## [5889] "DAMET" "DAMEI" "DAMEA" "DAMEO" "DAMEH" "DAMEC" "DAMIO" "DAMIA"
## [5897] "DAMIA" "DAMHA" "DAMHE" "DAMHO" "DAMHC" "DAMHR" "DAMAI" "DAHAB"
## [5905] "DAHAR" "DAHAT" "DAHAO" "DAHAE" "DAHAI" "DAHAM" "DAHER" "DAHET"
## [5913] "DAHEI" "DAHEA" "DAHEO" "DAHEM" "DAHEC" "DAHOT" "DAHOI" "DAHOE"
## [5921] "DAHOC" "DAHMO" "DAHMA" "DAHME" "DAHMI" "DAHMA" "DAHCE" "DAHCO"
## [5929] "DAHCR" "DAHRC" "DACER" "DACET" "DACEI" "DACEA" "DACEO" "DACEM"
## [5937] "DACEH" "DACOT" "DACOI" "DACOE" "DACOH" "DACHA" "DACHE" "DACHO"
## [5945] "DACHM" "DACHR" "DACRH" "DARHA" "DARHE" "DARHO" "DARHM" "DARHC"
## [5953] "DARCE" "DARCO" "DARCH" "AMOBR" "AMOBA" "AMORB" "AMORT" "AMORA"
## [5961] "AMORE" "AMOAB" "AMOAR" "AMOAT" "AMOAE" "AMOAI" "AMOAH" "AMOIA"
## [5969] "AMOIA" "AMOID" "AMABR" "AMABO" "AMARB" "AMART" "AMARO" "AMARE"
## [5977] "AMATR" "AMATI" "AMATE" "AMATO" "AMAOB" "AMAOR" "AMAOI" "AMAER"
## [5985] "AMAET" "AMAEI" "AMAEO" "AMAEH" "AMAEC" "AMAIO" "AMAIA" "AMAID"
## [5993] "AMAHE" "AMAHO" "AMAHC" "AMAHD" "AMAHR" "AMERB" "AMERT" "AMERO"
## [6001] "AMERA" "AMETR" "AMETI" "AMETA" "AMETO" "AMEIT" "AMEIO" "AMEAB"
## [6009] "AMEAR" "AMEAT" "AMEAO" "AMEAI" "AMEAH" "AMEOT" "AMEOI" "AMEOH"
## [6017] "AMEOC" "AMEHA" "AMEHO" "AMEHC" "AMEHD" "AMEHR" "AMECO" "AMECH"
## [6025] "AMECR" "AMIOB" "AMIOR" "AMIOA" "AMIAB" "AMIAR" "AMIAT" "AMIAO"
## [6033] "AMIAE" "AMIAH" "AMIAD" "AMIDH" "AMIDA" "AMHAB" "AMHAR" "AMHAT"
## [6041] "AMHAO" "AMHAE" "AMHAI" "AMHER" "AMHET" "AMHEI" "AMHEA" "AMHEO"
## [6049] "AMHEC" "AMHOT" "AMHOI" "AMHOE" "AMHOC" "AMHCE" "AMHCO" "AMHCR"
## [6057] "AMHDI" "AMHDA" "AMHRC" "AMAIO" "AMAIA" "AMAID" "AMADI" "AMADH"
## [6065] "AMDIO" "AMDIA" "AMDIA" "AMDHA" "AMDHE" "AMDHO" "AMDHC" "AMDHR"
## [6073] "AMDAI" "AHABR" "AHABO" "AHARB" "AHART" "AHARO" "AHARE" "AHATR"
## [6081] "AHATI" "AHATE" "AHATO" "AHAOB" "AHAOR" "AHAOI" "AHAOM" "AHAER"
## [6089] "AHAET" "AHAEI" "AHAEO" "AHAEM" "AHAEC" "AHAIO" "AHAIM" "AHAIA"
## [6097] "AHAID" "AHAMO" "AHAME" "AHAMI" "AHAMA" "AHAMD" "AHERB" "AHERT"
## [6105] "AHERO" "AHERA" "AHETR" "AHETI" "AHETA" "AHETO" "AHEIT" "AHEIO"
## [6113] "AHEAB" "AHEAR" "AHEAT" "AHEAO" "AHEAI" "AHEAM" "AHEOT" "AHEOI"
## [6121] "AHEOC" "AHEMO" "AHEMA" "AHEMI" "AHEMA" "AHEMD" "AHECO" "AHECR"
## [6129] "AHOTR" "AHOTI" "AHOTA" "AHOTE" "AHOIT" "AHOIE" "AHOER" "AHOET"
## [6137] "AHOEI" "AHOEA" "AHOEM" "AHOEC" "AHOCE" "AHOCR" "AHMOB" "AHMOR"
## [6145] "AHMOA" "AHMOI" "AHMAB" "AHMAR" "AHMAT" "AHMAO" "AHMAE" "AHMAI"
## [6153] "AHMER" "AHMET" "AHMEI" "AHMEA" "AHMEO" "AHMEC" "AHMIO" "AHMIA"
## [6161] "AHMIA" "AHMID" "AHMAI" "AHMAD" "AHMDI" "AHMDA" "AHCER" "AHCET"
## [6169] "AHCEI" "AHCEA" "AHCEO" "AHCEM" "AHCOT" "AHCOI" "AHCOE" "AHDIO"
## [6177] "AHDIA" "AHDIM" "AHDIA" "AHDMO" "AHDMA" "AHDME" "AHDMI" "AHDMA"
## [6185] "AHDAI" "AHDAM" "AHRCE" "AHRCO" "ACERB" "ACERT" "ACERO" "ACERA"
## [6193] "ACETR" "ACETI" "ACETA" "ACETO" "ACEIT" "ACEIO" "ACEAB" "ACEAR"
## [6201] "ACEAT" "ACEAO" "ACEAI" "ACEAM" "ACEAH" "ACEOT" "ACEOI" "ACEOH"
## [6209] "ACEMO" "ACEMA" "ACEMI" "ACEMH" "ACEMA" "ACEMD" "ACEHA" "ACEHO"
## [6217] "ACEHM" "ACEHD" "ACEHR" "ACOTR" "ACOTI" "ACOTA" "ACOTE" "ACOIT"
## [6225] "ACOIE" "ACOER" "ACOET" "ACOEI" "ACOEA" "ACOEM" "ACOEH" "ACOHA"
## [6233] "ACOHE" "ACOHM" "ACOHD" "ACOHR" "ACHAB" "ACHAR" "ACHAT" "ACHAO"
## [6241] "ACHAE" "ACHAI" "ACHAM" "ACHER" "ACHET" "ACHEI" "ACHEA" "ACHEO"
## [6249] "ACHEM" "ACHOT" "ACHOI" "ACHOE" "ACHMO" "ACHMA" "ACHME" "ACHMI"
## [6257] "ACHMA" "ACHMD" "ACHDI" "ACHDM" "ACHDA" "ACRHA" "ACRHE" "ACRHO"
## [6265] "ACRHM" "ACRHD" "ADIOB" "ADIOR" "ADIOA" "ADIOM" "ADIAB" "ADIAR"
## [6273] "ADIAT" "ADIAO" "ADIAE" "ADIAM" "ADIAH" "ADIMO" "ADIMA" "ADIME"
## [6281] "ADIMH" "ADIMA" "ADIAM" "ADMOB" "ADMOR" "ADMOA" "ADMOI" "ADMAB"
## [6289] "ADMAR" "ADMAT" "ADMAO" "ADMAE" "ADMAI" "ADMAH" "ADMER" "ADMET"
## [6297] "ADMEI" "ADMEA" "ADMEO" "ADMEH" "ADMEC" "ADMIO" "ADMIA" "ADMIA"
## [6305] "ADMHA" "ADMHE" "ADMHO" "ADMHC" "ADMHR" "ADMAI" "ADHAB" "ADHAR"
## [6313] "ADHAT" "ADHAO" "ADHAE" "ADHAI" "ADHAM" "ADHER" "ADHET" "ADHEI"
## [6321] "ADHEA" "ADHEO" "ADHEM" "ADHEC" "ADHOT" "ADHOI" "ADHOE" "ADHOC"
## [6329] "ADHMO" "ADHMA" "ADHME" "ADHMI" "ADHMA" "ADHCE" "ADHCO" "ADHCR"
## [6337] "ADHRC" "ADAIO" "ADAIA" "ADAIM" "ADAMO" "ADAMA" "ADAME" "ADAMI"
## [6345] "ADAMH" "ARHAB" "ARHAR" "ARHAT" "ARHAO" "ARHAE" "ARHAI" "ARHAM"
## [6353] "ARHER" "ARHET" "ARHEI" "ARHEA" "ARHEO" "ARHEM" "ARHEC" "ARHOT"
## [6361] "ARHOI" "ARHOE" "ARHOC" "ARHMO" "ARHMA" "ARHME" "ARHMI" "ARHMA"
## [6369] "ARHMD" "ARHCE" "ARHCO" "ARHDI" "ARHDM" "ARHDA" "ARCER" "ARCET"
## [6377] "ARCEI" "ARCEA" "ARCEO" "ARCEM" "ARCEH" "ARCOT" "ARCOI" "ARCOE"
## [6385] "ARCOH" "ARCHA" "ARCHE" "ARCHO" "ARCHM" "ARCHD" "RHABR" "RHABO"
## [6393] "RHARB" "RHART" "RHARO" "RHARE" "RHATR" "RHATI" "RHATE" "RHATO"
## [6401] "RHAOB" "RHAOR" "RHAOI" "RHAOM" "RHAER" "RHAET" "RHAEI" "RHAEO"
## [6409] "RHAEM" "RHAEC" "RHAIO" "RHAIM" "RHAIA" "RHAID" "RHAMO" "RHAME"
## [6417] "RHAMI" "RHAMA" "RHAMD" "RHAMA" "RHERB" "RHERT" "RHERO" "RHERA"
## [6425] "RHETR" "RHETI" "RHETA" "RHETO" "RHEIT" "RHEIO" "RHEAB" "RHEAR"
## [6433] "RHEAT" "RHEAO" "RHEAI" "RHEAM" "RHEOT" "RHEOI" "RHEOC" "RHEMO"
## [6441] "RHEMA" "RHEMI" "RHEMA" "RHEMD" "RHEMA" "RHECO" "RHECA" "RHOTR"
## [6449] "RHOTI" "RHOTA" "RHOTE" "RHOIT" "RHOIE" "RHOER" "RHOET" "RHOEI"
## [6457] "RHOEA" "RHOEM" "RHOEC" "RHOCE" "RHOCA" "RHMOB" "RHMOR" "RHMOA"
## [6465] "RHMOI" "RHMAB" "RHMAR" "RHMAT" "RHMAO" "RHMAE" "RHMAI" "RHMER"
## [6473] "RHMET" "RHMEI" "RHMEA" "RHMEO" "RHMEC" "RHMIO" "RHMIA" "RHMIA"
## [6481] "RHMID" "RHMAI" "RHMAD" "RHMDI" "RHMDA" "RHMDA" "RHMAC" "RHMAD"
## [6489] "RHCER" "RHCET" "RHCEI" "RHCEA" "RHCEO" "RHCEM" "RHCOT" "RHCOI"
## [6497] "RHCOE" "RHCAM" "RHCAD" "RHDIO" "RHDIA" "RHDIM" "RHDIA" "RHDMO"
## [6505] "RHDMA" "RHDME" "RHDMI" "RHDMA" "RHDMA" "RHDAI" "RHDAM" "RHDAM"
## [6513] "RHDAC" "RHAMO" "RHAMA" "RHAME" "RHAMI" "RHAMA" "RHAMD" "RHACE"
## [6521] "RHACO" "RHADI" "RHADM" "RHADA" "RCERB" "RCERT" "RCERO" "RCERA"
## [6529] "RCETR" "RCETI" "RCETA" "RCETO" "RCEIT" "RCEIO" "RCEAB" "RCEAR"
## [6537] "RCEAT" "RCEAO" "RCEAI" "RCEAM" "RCEAH" "RCEOT" "RCEOI" "RCEOH"
## [6545] "RCEMO" "RCEMA" "RCEMI" "RCEMH" "RCEMA" "RCEMD" "RCEMA" "RCEHA"
## [6553] "RCEHO" "RCEHM" "RCEHD" "RCEHA" "RCOTR" "RCOTI" "RCOTA" "RCOTE"
## [6561] "RCOIT" "RCOIE" "RCOER" "RCOET" "RCOEI" "RCOEA" "RCOEM" "RCOEH"
## [6569] "RCOHA" "RCOHE" "RCOHM" "RCOHD" "RCOHA" "RCHAB" "RCHAR" "RCHAT"
## [6577] "RCHAO" "RCHAE" "RCHAI" "RCHAM" "RCHER" "RCHET" "RCHEI" "RCHEA"
## [6585] "RCHEO" "RCHEM" "RCHOT" "RCHOI" "RCHOE" "RCHMO" "RCHMA" "RCHME"
## [6593] "RCHMI" "RCHMA" "RCHMD" "RCHMA" "RCHDI" "RCHDM" "RCHDA" "RCHDA"
## [6601] "RCHAM" "RCHAD" "RCAMO" "RCAMA" "RCAME" "RCAMI" "RCAMH" "RCAMA"
## [6609] "RCAMD" "RCAHA" "RCAHE" "RCAHO" "RCAHM" "RCAHD" "RCADI" "RCADM"
## [6617] "RCADH" "RCADA" "RAMOB" "RAMOR" "RAMOA" "RAMOI" "RAMAB" "RAMAR"
## [6625] "RAMAT" "RAMAO" "RAMAE" "RAMAI" "RAMAH" "RAMER" "RAMET" "RAMEI"
## [6633] "RAMEA" "RAMEO" "RAMEH" "RAMEC" "RAMIO" "RAMIA" "RAMIA" "RAMID"
## [6641] "RAMHA" "RAMHE" "RAMHO" "RAMHC" "RAMHD" "RAMAI" "RAMAD" "RAMDI"
## [6649] "RAMDH" "RAMDA" "RAHAB" "RAHAR" "RAHAT" "RAHAO" "RAHAE" "RAHAI"
## [6657] "RAHAM" "RAHER" "RAHET" "RAHEI" "RAHEA" "RAHEO" "RAHEM" "RAHEC"
## [6665] "RAHOT" "RAHOI" "RAHOE" "RAHOC" "RAHMO" "RAHMA" "RAHME" "RAHMI"
## [6673] "RAHMA" "RAHMD" "RAHCE" "RAHCO" "RAHDI" "RAHDM" "RAHDA" "RACER"
## [6681] "RACET" "RACEI" "RACEA" "RACEO" "RACEM" "RACEH" "RACOT" "RACOI"
## [6689] "RACOE" "RACOH" "RACHA" "RACHE" "RACHO" "RACHM" "RACHD" "RADIO"
## [6697] "RADIA" "RADIM" "RADIA" "RADMO" "RADMA" "RADME" "RADMI" "RADMH"
## [6705] "RADMA" "RADHA" "RADHE" "RADHO" "RADHM" "RADHC" "RADAI" "RADAM"
```

---

## Put it together


```r
getKMers <- function(maxKmer=10){
	paths <- list()
	words <- list()
	paths[[1]] <- matrix(1:16, ncol=1)
	words[[1]] <- matrix(as.vector(board), ncol=1)

	for(i in 2:maxKmer){
		update <- getNext(paths, words, i)
		paths[[i]] <- update$path
		words[[i]] <- update$word
	}
	return(list(path=paths, word=words))
}
```

---

## Run it... ... slow


```r
start <- proc.time()
final <- getKMers(7)
end <- proc.time()
end-start
```

```
##    user  system elapsed 
##  67.907   7.296  75.270
```

---

## This gets out of hand fast...

<img src="assets/fig/unnamed-chunk-12-1.png" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" style="display: block; margin: auto;" />

---



## About those `for` loops...


```r
getNext <- function(paths, words, new.length){
	length <- new.length - 1
	n.prev <- length(words[[length]])
	this.paths <- numeric()
	this.words <- character()
	
	for(i in 1:n.prev){
		prev <- paths[[length]][i,]
		nextChar <- neighbors[[prev[length]]]
		goodNeighbors <- nextChar[!nextChar %in% prev]
		if(length(goodNeighbors)>0){
			n.goodneighbors <- length(goodNeighbors)
			new.paths <- cbind(matrix(rep(prev, n.goodneighbors), nrow=n.goodneighbors, byrow=T), goodNeighbors)
			word <- paste(words[[length]][i], board[goodNeighbors], sep="")
			this.words <- c(this.words, word)
			this.paths <- rbind(this.paths, new.paths)
		}
	}
	return(list(path=this.paths, word=this.words))
}
```

---

## Let's define a new function

* Take contents of `for` loop from `getNext` and use it to make a function `cat` (conCATenate)
* Modify `getNext` to create `getNext2`, which calls `cat`
* Also, we're getting nailed on recreating a new list every time we add a new k-mer. Let's drop the word list and create it at the end when we have all of the paths

---

## New `cat` function


```r
cat <- function(i, length, paths){
	prev <- paths[[length]][i,]
	nextChar <- neighbors[[prev[length]]]
	goodNeighbors <- nextChar[!nextChar %in% prev]
	if(length(goodNeighbors)>0){
		n.goodneighbors <- length(goodNeighbors)
		new.paths <- cbind(matrix(rep(prev, n.goodneighbors), nrow=n.goodneighbors, byrow=T), goodNeighbors)
		return(new.paths)
	} else{
		return(NULL);  #needed in case there are no neighbors remaining
	}
}
```

---

## New `getNext2` function


```r
getNext2 <- function(new.length, paths){
	length <- new.length - 1
	n.prev <- nrow(paths[[length]])
	path.list <- sapply(1:n.prev, cat, length, paths)  #<-- This replaces for loop
	return(do.call(rbind, path.list))
}
```

---

## Try again...


```r
start <- proc.time()

paths <- list()

paths[[1]] <- matrix(1:16, ncol=1)
for(l in 2:10){
	paths[[l]] <- getNext2(l, paths)
}

end <- proc.time()
end-start
```

```
##    user  system elapsed 
##  22.720   0.247  22.973
```

* The lingering `for` loop is still a problem

---

## Now we need to translate our paths to words

* Let's look an an example (ignore the "goodNeighbors")...


```r
paths[[9]][1,]
```

```
##                                                                       
##             1             2             3             4             7 
##                                           goodNeighbors 
##             6             5             9            10
```

```r
board[paths[[9]][1,]]
```

```
## [1] "B" "R" "T" "I" "E" "A" "O" "I" "M"
```

```r
paste(board[paths[[9]][1,]], collapse="")
```

```
## [1] "BRTIEAOIM"
```

---

## Think about the data structure we have

* It's a list where each value of paths is a different k-mer size
* Within each k-mer is a matrix of n rows and k columns
* To tranlate the entire list we need to...
  * Translate each matrix
  * Translate each row of each matrix
* Then glue it all together as a big vector of words

---

## R


```r
translate.vector <- function(x){
	paste(board[x], collapse="")
}

translate.matrix <- function(x){
	apply(x, 1, translate.vector)
}

words <- list()
words <- lapply(paths, translate.matrix)
words.vector <- unlist(words)
```

---

## What do these words look like?


```r
length(words.vector)
```

```
## [1] 1626160
```

```r
sort(words.vector)[1:100]
```

```
##   [1] "A"          "A"          "A"          "AB"         "ABO"       
##   [6] "ABOI"       "ABOIA"      "ABOIAD"     "ABOIADA"    "ABOIADAC"  
##  [11] "ABOIADACE"  "ABOIADACEH" "ABOIADACEI" "ABOIADACEM" "ABOIADACEO"
##  [16] "ABOIADACER" "ABOIADACET" "ABOIADACH"  "ABOIADACHE" "ABOIADACHM"
##  [21] "ABOIADACHO" "ABOIADACHR" "ABOIADACO"  "ABOIADACOE" "ABOIADACOH"
##  [26] "ABOIADACOI" "ABOIADACOT" "ABOIADACR"  "ABOIADACRH" "ABOIADAH"  
##  [31] "ABOIADAHC"  "ABOIADAHCE" "ABOIADAHCO" "ABOIADAHCR" "ABOIADAHE" 
##  [36] "ABOIADAHEC" "ABOIADAHEI" "ABOIADAHEM" "ABOIADAHEO" "ABOIADAHER"
##  [41] "ABOIADAHET" "ABOIADAHM"  "ABOIADAHME" "ABOIADAHO"  "ABOIADAHOC"
##  [46] "ABOIADAHOE" "ABOIADAHOI" "ABOIADAHOT" "ABOIADAHR"  "ABOIADAHRC"
##  [51] "ABOIADAM"   "ABOIADAME"  "ABOIADAMEC" "ABOIADAMEH" "ABOIADAMEI"
##  [56] "ABOIADAMEO" "ABOIADAMER" "ABOIADAMET" "ABOIADAMH"  "ABOIADAMHC"
##  [61] "ABOIADAMHE" "ABOIADAMHO" "ABOIADAMHR" "ABOIADAR"   "ABOIADARC" 
##  [66] "ABOIADARCE" "ABOIADARCH" "ABOIADARCO" "ABOIADARH"  "ABOIADARHC"
##  [71] "ABOIADARHE" "ABOIADARHM" "ABOIADARHO" "ABOIADH"    "ABOIADHA"  
##  [76] "ABOIADHAC"  "ABOIADHACE" "ABOIADHACO" "ABOIADHACR" "ABOIADHAM" 
##  [81] "ABOIADHAME" "ABOIADHAR"  "ABOIADHARC" "ABOIADHC"   "ABOIADHCA" 
##  [86] "ABOIADHCAM" "ABOIADHCAR" "ABOIADHCE"  "ABOIADHCEI" "ABOIADHCEM"
##  [91] "ABOIADHCEO" "ABOIADHCER" "ABOIADHCET" "ABOIADHCO"  "ABOIADHCOE"
##  [96] "ABOIADHCOI" "ABOIADHCOT" "ABOIADHCR"  "ABOIADHCRA" "ABOIADHE"
```

---

## A lot of that is jibberish

* Need to cross reference our 1626160 words with the dictionary


```r
overlap <- intersect(words.vector, dictionary)

length(overlap)
```

```
## [1] 329
```

```r
sort(overlap)[1:100]
```

```
##   [1] "AB"       "ABO"      "ABOMA"    "ABORE"    "ABORT"    "ACE"     
##   [7] "ACER"     "ACERB"    "ACETA"    "ACETAMID" "ACH"      "ACHE"    
##  [13] "AD"       "AE"       "AERO"     "AH"       "AHA"      "AHEM"    
##  [19] "AI"       "AIA"      "AID"      "AIM"      "AIMER"    "AM"      
##  [25] "AMA"      "AMAH"     "AMATE"    "AMI"      "AMIA"     "AMID"    
##  [31] "AMORET"   "AMORT"    "AR"       "ARB"      "ARC"      "ARCH"    
##  [37] "ARCHAEI"  "ARCHEI"   "ARCHER"   "ARCO"     "ARE"      "ARECA"   
##  [43] "ARET"     "ARHAT"    "AROID"    "AROMA"    "ART"      "ARTI"    
##  [49] "AT"       "ATE"      "ATOC"     "BA"       "BAH"      "BAHADA"  
##  [55] "BAM"      "BAR"      "BARE"     "BAT"      "BATE"     "BO"      
##  [61] "BOA"      "BOAR"     "BOART"    "BOAT"     "BOATER"   "BOATIE"  
##  [67] "BOI"      "BOMA"     "BOR"      "BORA"     "BORATE"   "BORE"    
##  [73] "BORT"     "BRA"      "BRAE"     "BRAHMA"   "BRAID"    "BRAME"   
##  [79] "BRAT"     "BREAM"    "BRECHAM"  "BREI"     "BRO"      "BROMATE" 
##  [85] "BROME"    "BROMID"   "CAD"      "CADI"     "CAM"      "CAMA"    
##  [91] "CAME"     "CAMEO"    "CAMERA"   "CAMO"     "CAR"      "CERO"    
##  [97] "CERT"     "CH"       "CHA"      "CHAD"
```

---

## Recall how we might sort these by length?


```
##   [1] "ACETAMID" "RACEMOID" "BROMATE"  "BRECHAM"  "TOHEROA"  "MARCHER" 
##   [7] "HAEMOID"  "DIORAMA"  "ARCHAEI"  "RADIATE"  "BROMID"   "BRAHMA"  
##  [13] "BORATE"   "BOATIE"   "BOATER"   "BAHADA"   "RAMADA"   "RETAMA"  
##  [19] "TOCHER"   "OMERTA"   "AMORET"   "IMARET"   "MATIER"   "MACHER"  
##  [25] "HAMADA"   "HEMOID"   "HAMATE"   "CHARET"   "CAMERA"   "DACOIT"  
##  [31] "ARCHER"   "ARCHEI"   "RAMATE"   "RACHET"   "BROME"    "BRAID"   
##  [37] "BRAME"    "BREAM"    "BOART"    "ROATE"    "ROMEO"    "RATIO"   
##  [43] "RAMET"    "REHAB"    "TREMA"    "TABOR"    "TAMER"    "TERAI"   
##  [49] "ORATE"    "OATER"    "ABORT"    "ABORE"    "ABOMA"    "AROID"   
##  [55] "AROMA"    "ARECA"    "AIMER"    "AMORT"    "OCHER"    "MORAT"   
##  [61] "MORAE"    "MATER"    "MAHOE"    "METRO"    "MACER"    "MACHE"   
##  [67] "MACHO"    "MARCH"    "HAREM"    "HATER"    "HAOMA"    "HEART"   
##  [73] "COHAB"    "CHART"    "CHARE"    "CHERT"    "CHEAT"    "CHEMO"   
##  [79] "CHOTA"    "CAMEO"    "CRAME"    "AMATE"    "DIMER"    "DHOTI"   
##  [85] "DAMAR"    "DACHA"    "ACERB"    "ACETA"    "ARHAT"    "RACER"   
##  [91] "RACHE"    "RADIO"    "BRAT"     "BRAE"     "BREI"     "BORT"    
##  [97] "BORA"     "BORE"     "BOAR"     "BOAT"     "BOMA"     "BARE"    
## [103] "BATE"     "ROAM"     "ROMA"     "RATE"     "RATO"     "RAIA"    
## [109] "RAID"     "RAMI"     "REAM"     "TRAM"     "TIER"     "TARO"    
## [115] "TARE"     "TAME"     "TAHA"     "TAHR"     "TEAR"     "TEAM"    
## [121] "TEHR"     "TECH"     "TOEA"     "ITEM"     "IOTA"     "OMER"    
## [127] "ARTI"     "ARET"     "ATOC"     "AERO"     "AMIA"     "AMID"    
## [133] "AMAH"     "AHEM"     "ECHO"     "ECAD"     "OCHE"     "MORT"    
## [139] "MORA"     "MORE"     "MOAT"     "MOAI"     "MART"     "MARE"    
## [145] "MATE"     "MAID"     "META"     "MEAT"     "MACE"     "MACH"    
## [151] "MARC"     "HART"     "HARO"     "HARE"     "HATE"     "HAET"    
## [157] "HAEM"     "HAME"     "HERB"     "HERO"     "HEAR"     "HEAT"    
## [163] "HOTE"     "HOER"     "CERT"     "CERO"     "COTE"     "COIT"    
## [169] "CHAR"     "CHAT"     "CHAO"     "CHAI"     "CHAM"     "CHER"    
## [175] "CHAD"     "CAMO"     "CAMA"     "CAME"     "CADI"     "CRAM"    
## [181] "DIME"     "DAME"     "DACE"     "ACER"     "ACHE"     "ARCO"    
## [187] "ARCH"     "RHEA"     "RACE"     "RACH"     "BRO"      "BRA"     
## [193] "BOR"      "BOA"      "BOI"      "BAR"      "BAT"      "BAM"     
## [199] "BAH"      "ROB"      "ROM"      "RAT"      "RAI"      "RAM"     
## [205] "RAH"      "RET"      "REI"      "REO"      "REM"      "REH"     
## [211] "REC"      "TIE"      "TAB"      "TAR"      "TAO"      "TAE"     
## [217] "TAI"      "TAM"      "TEA"      "TEC"      "TOE"      "TOC"     
## [223] "ITA"      "OBA"      "ORB"      "ORT"      "ORA"      "ORE"     
## [229] "OAR"      "OAT"      "ABO"      "ARB"      "ART"      "ARE"     
## [235] "ATE"      "AIM"      "AIA"      "AID"      "AMI"      "AMA"     
## [241] "AHA"      "ERA"      "ETA"      "EAR"      "EAT"      "EMO"     
## [247] "ECO"      "ECH"      "OHM"      "OCH"      "OCA"      "MOB"     
## [253] "MOR"      "MOA"      "MOI"      "MAR"      "MAT"      "MAE"     
## [259] "MET"      "MID"      "MHO"      "MAD"      "MAC"      "HAT"     
## [265] "HAO"      "HAE"      "HAM"      "HER"      "HET"      "HEM"     
## [271] "HOT"      "HOI"      "HOE"      "HOC"      "HAD"      "COT"     
## [277] "CHA"      "CHE"      "CAM"      "CAD"      "CAR"      "DIM"     
## [283] "DAM"      "DAH"      "ACE"      "ACH"      "ARC"      "RHO"     
## [289] "RAD"      "BO"       "BA"       "RE"       "TI"       "TA"      
## [295] "TE"       "TO"       "IT"       "IO"       "OB"       "OR"      
## [301] "OI"       "OM"       "AB"       "AR"       "AT"       "AE"      
## [307] "AI"       "AM"       "AH"       "ER"       "ET"       "EA"      
## [313] "EM"       "EH"       "OE"       "OH"       "ID"       "MO"      
## [319] "MA"       "ME"       "MI"       "HA"       "HE"       "HO"      
## [325] "HM"       "CH"       "AD"       "DI"       "DA"
```

---

## Now we need to recover the paths


```r
getPath <- function(word){
	wordLength <- nchar(word)
	hit <- which(words[[wordLength]] == word)
	path <- paths[[wordLength]][hit,]
	if(length(hit) > 1){
		path.strings <- apply(path, 1, paste, collapse=",")	
		path.strings <- paste(path.strings, collapse=" / ")
	} else {
		path.strings <- paste(path, collapse=",")
	}
	return(path.strings)
}

sapply(overlap, getPath)
```

---

                                                           BO 
                                                        "1,5" 
                                                           BA 
                                                        "1,6" 
                                                           RE 
                                                        "2,7" 
                                                           TI 
                                                        "3,4" 
                                                           TA 
                                                        "3,6" 
                                                           TE 
                                                        "3,7" 
                                                           TO 
                                                        "3,8" 
                                                           IT 
                                                        "4,3" 
                                                           IO 
                                                  "4,8 / 9,5" 
                                                           OB 
                                                        "5,1" 
                                                           OR 
                                                        "5,2" 
                                                           OI 
                                                  "5,9 / 8,4" 
                                                           OM 
                                                       "5,10" 
                                                           AB 
                                                        "6,1" 
                                                           AR 
                                                "6,2 / 15,16" 
                                                           AT 
                                                        "6,3" 
                                                           AE 
                                                        "6,7" 
                                                           AI 
                                                 "6,9 / 13,9" 
                                                           AM 
                                       "6,10 / 13,10 / 15,10" 
                                                           AH 
                                               "6,11 / 15,11" 
                                                           ER 
                                                        "7,2" 
                                                           ET 
                                                        "7,3" 
                                                           EA 
                                                        "7,6" 
                                                           EM 
                                                       "7,10" 
                                                           EH 
                                                       "7,11" 
                                                           OE 
                                                        "8,7" 
                                                           OH 
                                                       "8,11" 
                                                           ID 
                                                       "9,14" 
                                                           MO 
                                                       "10,5" 
                                                           MA 
                                       "10,6 / 10,13 / 10,15" 
                                                           ME 
                                                       "10,7" 
                                                           MI 
                                                       "10,9" 
                                                           HA 
                                               "11,6 / 11,15" 
                                                           HE 
                                                       "11,7" 
                                                           HO 
                                                       "11,8" 
                                                           HM 
                                                      "11,10" 
                                                           CH 
                                                      "12,11" 
                                                           AD 
                                              "13,14 / 15,14" 
                                                           DI 
                                                       "14,9" 
                                                           DA 
                                              "14,13 / 14,15" 
                                                          BRO 
                                                      "1,2,5" 
                                                          BRA 
                                                      "1,2,6" 
                                                          BOR 
                                                      "1,5,2" 
                                                          BOA 
                                                      "1,5,6" 
                                                          BOI 
                                                      "1,5,9" 
                                                          BAR 
                                                      "1,6,2" 
                                                          BAT 
                                                      "1,6,3" 
                                                          BAM 
                                                     "1,6,10" 
                                                          BAH 
                                                     "1,6,11" 
                                                          ROB 
                                                      "2,5,1" 
                                                          ROM 
                                                     "2,5,10" 
                                                          RAT 
                                                      "2,6,3" 
                                                          RAI 
                                                      "2,6,9" 
                                                          RAM 
                                          "2,6,10 / 16,15,10" 
                                                          RAH 
                                          "2,6,11 / 16,15,11" 
                                                          RET 
                                                      "2,7,3" 
                                                          REI 
                                                      "2,7,4" 
                                                          REO 
                                                      "2,7,8" 
                                                          REM 
                                                     "2,7,10" 
                                                          REH 
                                                     "2,7,11" 
                                                          REC 
                                                     "2,7,12" 
                                                          TIE 
                                                      "3,4,7" 
                                                          TAB 
                                                      "3,6,1" 
                                                          TAR 
                                                      "3,6,2" 
                                                          TAO 
                                                      "3,6,5" 
                                                          TAE 
                                                      "3,6,7" 
                                                          TAI 
                                                      "3,6,9" 
                                                          TAM 
                                                     "3,6,10" 
                                                          TEA 
                                                      "3,7,6" 
                                                          TEC 
                                                     "3,7,12" 
                                                          TOE 
                                                      "3,8,7" 
                                                          TOC 
                                                     "3,8,12" 
                                                          ITA 
                                                      "4,3,6" 
                                                          OBA 
                                                      "5,1,6" 
                                                          ORB 
                                                      "5,2,1" 
                                                          ORT 
                                                      "5,2,3" 
                                                          ORA 
                                                      "5,2,6" 
                                                          ORE 
                                                      "5,2,7" 
                                                          OAR 
                                                      "5,6,2" 
                                                          OAT 
                                                      "5,6,3" 
                                                          ABO 
                                                      "6,1,5" 
                                                          ARB 
                                                      "6,2,1" 
                                                          ART 
                                                      "6,2,3" 
                                                          ARE 
                                                      "6,2,7" 
                                                          ATE 
                                                      "6,3,7" 
                                                          AIM 
                                           "6,9,10 / 13,9,10" 
                                                          AIA 
                                            "6,9,13 / 13,9,6" 
                                                          AID 
                                           "6,9,14 / 13,9,14" 
                                                          AMI 
                                 "6,10,9 / 13,10,9 / 15,10,9" 
                                                          AMA 
"6,10,13 / 6,10,15 / 13,10,6 / 13,10,15 / 15,10,6 / 15,10,13" 
                                                          AHA 
                                          "6,11,15 / 15,11,6" 
                                                          ERA 
                                                      "7,2,6" 
                                                          ETA 
                                                      "7,3,6" 
                                                          EAR 
                                                      "7,6,2" 
                                                          EAT 
                                                      "7,6,3" 
                                                          EMO 
                                                     "7,10,5" 
                                                          ECO 
                                                     "7,12,8" 
                                                          ECH 
                                                    "7,12,11" 
                                                          OHM 
                                                    "8,11,10" 
                                                          OCH 
                                                    "8,12,11" 
                                                          OCA 
                                                    "8,12,15" 
                                                          MOB 
                                                     "10,5,1" 
                                                          MOR 
                                                     "10,5,2" 
                                                          MOA 
                                                     "10,5,6" 
                                                          MOI 
                                                     "10,5,9" 
                                                          MAR 
                                          "10,6,2 / 10,15,16" 
                                                          MAT 
                                                     "10,6,3" 
                                                          MAE 
                                                     "10,6,7" 
                                                          MET 
                                                     "10,7,3" 
                                                          MID 
                                                    "10,9,14" 
                                                          MHO 
                                                    "10,11,8" 
                                                          MAD 
                                        "10,13,14 / 10,15,14" 
                                                          MAC 
                                                   "10,15,12" 
                                                          HAT 
                                                     "11,6,3" 
                                                          HAO 
                                                     "11,6,5" 
                                                          HAE 
                                                     "11,6,7" 
                                                          HAM 
                                         "11,6,10 / 11,15,10" 
                                                          HER 
                                                     "11,7,2" 
                                                          HET 
                                                     "11,7,3" 
                                                          HEM 
                                                    "11,7,10" 
                                                          HOT 
                                                     "11,8,3" 
                                                          HOI 
                                                     "11,8,4" 
                                                          HOE 
                                                     "11,8,7" 
                                                          HOC 
                                                    "11,8,12" 
                                                          HAD 
                                                   "11,15,14" 
                                                          COT 
                                                     "12,8,3" 
                                                          CHA 
                                         "12,11,6 / 12,11,15" 
                                                          CHE 
                                                    "12,11,7" 
                                                          CAM 
                                                   "12,15,10" 
                                                          CAD 
                                                   "12,15,14" 
                                                          CAR 
                                                   "12,15,16" 
                                                          DIM 
                                                    "14,9,10" 
                                                          DAM 
                                        "14,13,10 / 14,15,10" 
                                                          DAH 
                                                   "14,15,11" 
                                                          ACE 
                                                    "15,12,7" 
                                                          ACH 
                                                   "15,12,11" 
                                                          ARC 
                                                   "15,16,12" 
                                                          RHO 
                                                    "16,11,8" 
                                                          RAD 
                                                   "16,15,14" 
                                                         BRAT 
                                                    "1,2,6,3" 
                                                         BRAE 
                                                    "1,2,6,7" 
                                                         BREI 
                                                    "1,2,7,4" 
                                                         BORT 
                                                    "1,5,2,3" 
                                                         BORA 
                                                    "1,5,2,6" 
                                                         BORE 
                                                    "1,5,2,7" 
                                                         BOAR 
                                                    "1,5,6,2" 
                                                         BOAT 
                                                    "1,5,6,3" 
                                                         BOMA 
                           "1,5,10,6 / 1,5,10,13 / 1,5,10,15" 
                                                         BARE 
                                                    "1,6,2,7" 
                                                         BATE 
                                                    "1,6,3,7" 
                                                         ROAM 
                                                   "2,5,6,10" 
                                                         ROMA 
                           "2,5,10,6 / 2,5,10,13 / 2,5,10,15" 
                                                         RATE 
                                                    "2,6,3,7" 
                                                         RATO 
                                                    "2,6,3,8" 
                                                         RAIA 
                                                   "2,6,9,13" 
                                                         RAID 
                                                   "2,6,9,14" 
                                                         RAMI 
                                      "2,6,10,9 / 16,15,10,9" 
                                                         REAM 
                                                   "2,7,6,10" 
                                                         TRAM 
                                                   "3,2,6,10" 
                                                         TIER 
                                                    "3,4,7,2" 
                                                         TARO 
                                                    "3,6,2,5" 
                                                         TARE 
                                                    "3,6,2,7" 
                                                         TAME 
                                                   "3,6,10,7" 
                                                         TAHA 
                                                  "3,6,11,15" 
                                                         TAHR 
                                                  "3,6,11,16" 
                                                         TEAR 
                                                    "3,7,6,2" 
                                                         TEAM 
                                                   "3,7,6,10" 
                                                         TEHR 
                                                  "3,7,11,16" 
                                                         TECH 
                                                  "3,7,12,11" 
                                                         TOEA 
                                                    "3,8,7,6" 
                                                         ITEM 
                                                   "4,3,7,10" 
                                                         IOTA 
                                                    "4,8,3,6" 
                                                         OMER 
                                                   "5,10,7,2" 
                                                         ARTI 
                                                    "6,2,3,4" 
                                                         ARET 
                                                    "6,2,7,3" 
                                                         ATOC 
                                                   "6,3,8,12" 
                                                         AERO 
                                                    "6,7,2,5" 
                                                         AMIA 
             "6,10,9,13 / 13,10,9,6 / 15,10,9,6 / 15,10,9,13" 
                                                         AMID 
                        "6,10,9,14 / 13,10,9,14 / 15,10,9,14" 
                                                         AMAH 
         "6,10,15,11 / 13,10,6,11 / 13,10,15,11 / 15,10,6,11" 
                                                         AHEM 
                                     "6,11,7,10 / 15,11,7,10" 
                                                         ECHO 
                                                  "7,12,11,8" 
                                                         ECAD 
                                                 "7,12,15,14" 
                                                         OCHE 
                                                  "8,12,11,7" 
                                                         MORT 
                                                   "10,5,2,3" 
                                                         MORA 
                                                   "10,5,2,6" 
                                                         MORE 
                                                   "10,5,2,7" 
                                                         MOAT 
                                                   "10,5,6,3" 
                                                         MOAI 
                                                   "10,5,6,9" 
                                                         MART 
                                                   "10,6,2,3" 
                                                         MARE 
                                                   "10,6,2,7" 
                                                         MATE 
                                                   "10,6,3,7" 
                                                         MAID 
                                     "10,6,9,14 / 10,13,9,14" 
                                                         META 
                                                   "10,7,3,6" 
                                                         MEAT 
                                                   "10,7,6,3" 
                                                         MACE 
                                                 "10,15,12,7" 
                                                         MACH 
                                                "10,15,12,11" 
                                                         MARC 
                                                "10,15,16,12" 
                                                         HART 
                                                   "11,6,2,3" 
                                                         HARO 
                                                   "11,6,2,5" 
                                                         HARE 
                                                   "11,6,2,7" 
                                                         HATE 
                                                   "11,6,3,7" 
                                                         HAET 
                                                   "11,6,7,3" 
                                                         HAEM 
                                                  "11,6,7,10" 
                                                         HAME 
                                     "11,6,10,7 / 11,15,10,7" 
                                                         HERB 
                                                   "11,7,2,1" 
                                                         HERO 
                                                   "11,7,2,5" 
                                                         HEAR 
                                                   "11,7,6,2" 
                                                         HEAT 
                                                   "11,7,6,3" 
                                                         HOTE 
                                                   "11,8,3,7" 
                                                         HOER 
                                                   "11,8,7,2" 
                                                         CERT 
                                                   "12,7,2,3" 
                                                         CERO 
                                                   "12,7,2,5" 
                                                         COTE 
                                                   "12,8,3,7" 
                                                         COIT 
                                                   "12,8,4,3" 
                                                         CHAR 
                                    "12,11,6,2 / 12,11,15,16" 
                                                         CHAT 
                                                  "12,11,6,3" 
                                                         CHAO 
                                                  "12,11,6,5" 
                                                         CHAI 
                                                  "12,11,6,9" 
                                                         CHAM 
                                   "12,11,6,10 / 12,11,15,10" 
                                                         CHER 
                                                  "12,11,7,2" 
                                                         CHAD 
                                                "12,11,15,14" 
                                                         CAMO 
                                                 "12,15,10,5" 
                                                         CAMA 
                                   "12,15,10,6 / 12,15,10,13" 
                                                         CAME 
                                                 "12,15,10,7" 
                                                         CADI 
                                                 "12,15,14,9" 
                                                         CRAM 
                                                "12,16,15,10" 
                                                         DIME 
                                                  "14,9,10,7" 
                                                         DAME 
                                    "14,13,10,7 / 14,15,10,7" 
                                                         DACE 
                                                 "14,15,12,7" 
                                                         ACER 
                                                  "15,12,7,2" 
                                                         ACHE 
                                                 "15,12,11,7" 
                                                         ARCO 
                                                 "15,16,12,8" 
                                                         ARCH 
                                                "15,16,12,11" 
                                                         RHEA 
                                                  "16,11,7,6" 
                                                         RACE 
                                                 "16,15,12,7" 
                                                         RACH 
                                                "16,15,12,11" 
                                                        BROME 
                                                 "1,2,5,10,7" 
                                                        BRAID 
                                                 "1,2,6,9,14" 
                                                        BRAME 
                                                 "1,2,6,10,7" 
                                                        BREAM 
                                                 "1,2,7,6,10" 
                                                        BOART 
                                                  "1,5,6,2,3" 
                                                        ROATE 
                                                  "2,5,6,3,7" 
                                                        ROMEO 
                                                 "2,5,10,7,8" 
                                                        RATIO 
                                                  "2,6,3,4,8" 
                                                        RAMET 
                                  "2,6,10,7,3 / 16,15,10,7,3" 
                                                        REHAB 
                                                 "2,7,11,6,1" 
                                                        TREMA 
                     "3,2,7,10,6 / 3,2,7,10,13 / 3,2,7,10,15" 
                                                        TABOR 
                                                  "3,6,1,5,2" 
                                                        TAMER 
                                                 "3,6,10,7,2" 
                                                        TERAI 
                                                  "3,7,2,6,9" 
                                                        ORATE 
                                                  "5,2,6,3,7" 
                                                        OATER 
                                                  "5,6,3,7,2" 
                                                        ABORT 
                                                  "6,1,5,2,3" 
                                                        ABORE 
                                                  "6,1,5,2,7" 
                                                        ABOMA 
                                  "6,1,5,10,13 / 6,1,5,10,15" 
                                                        AROID 
                                                 "6,2,5,9,14" 
                                                        AROMA 
                                  "6,2,5,10,13 / 6,2,5,10,15" 
                                                        ARECA 
                                                "6,2,7,12,15" 
                                                        AIMER 
                                   "6,9,10,7,2 / 13,9,10,7,2" 
                                                        AMORT 
                     "6,10,5,2,3 / 13,10,5,2,3 / 15,10,5,2,3" 
                                                        OCHER 
                                                "8,12,11,7,2" 
                                                        MORAT 
                                                 "10,5,2,6,3" 
                                                        MORAE 
                                                 "10,5,2,6,7" 
                                                        MATER 
                                                 "10,6,3,7,2" 
                                                        MAHOE 
                                 "10,6,11,8,7 / 10,15,11,8,7" 
                                                        METRO 
                                                 "10,7,3,2,5" 
                                                        MACER 
                                               "10,15,12,7,2" 
                                                        MACHE 
                                              "10,15,12,11,7" 
                                                        MACHO 
                                              "10,15,12,11,8" 
                                                        MARCH 
                                             "10,15,16,12,11" 
                                                        HAREM 
                                                "11,6,2,7,10" 
                                                        HATER 
                                                 "11,6,3,7,2" 
                                                        HAOMA 
                                "11,6,5,10,13 / 11,6,5,10,15" 
                                                        HEART 
                                                 "11,7,6,2,3" 
                                                        COHAB 
                                                "12,8,11,6,1" 
                                                        CHART 
                                                "12,11,6,2,3" 
                                                        CHARE 
                                                "12,11,6,2,7" 
                                                        CHERT 
                                                "12,11,7,2,3" 
                                                        CHEAT 
                                                "12,11,7,6,3" 
                                                        CHEMO 
                                               "12,11,7,10,5" 
                                                        CHOTA 
                                                "12,11,8,3,6" 
                                                        CAMEO 
                                               "12,15,10,7,8" 
                                                        CRAME 
                                              "12,16,15,10,7" 
                                                        AMATE 
                                  "13,10,6,3,7 / 15,10,6,3,7" 
                                                        DIMER 
                                                "14,9,10,7,2" 
                                                        DHOTI 
                                                "14,11,8,3,4" 
                                                        DAMAR 
               "14,13,10,6,2 / 14,13,10,15,16 / 14,15,10,6,2" 
                                                        DACHA 
                                              "14,15,12,11,6" 
                                                        ACERB 
                                                "15,12,7,2,1" 
                                                        ACETA 
                                                "15,12,7,3,6" 
                                                        ARHAT 
                                               "15,16,11,6,3" 
                                                        RACER 
                                               "16,15,12,7,2" 
                                                        RACHE 
                                              "16,15,12,11,7" 
                                                        RADIO 
                                               "16,15,14,9,5" 
                                                       BROMID 
                                              "1,2,5,10,9,14" 
                                                       BRAHMA 
                            "1,2,6,11,10,13 / 1,2,6,11,10,15" 
                                                       BORATE 
                                                "1,5,2,6,3,7" 
                                                       BOATIE 
                                                "1,5,6,3,4,7" 
                                                       BOATER 
                                                "1,5,6,3,7,2" 
                                                       BAHADA 
                                            "1,6,11,15,14,13" 
                                                       RAMADA 
                          "2,6,10,13,14,15 / 2,6,10,15,14,13" 
                                                       RETAMA 
                              "2,7,3,6,10,13 / 2,7,3,6,10,15" 
                                                       TOCHER 
                                              "3,8,12,11,7,2" 
                                                       OMERTA 
                                               "5,10,7,2,3,6" 
                                                       AMORET 
               "6,10,5,2,7,3 / 13,10,5,2,7,3 / 15,10,5,2,7,3" 
                                                       IMARET 
                                               "9,10,6,2,7,3" 
                                                       MATIER 
                                               "10,6,3,4,7,2" 
                                                       MACHER 
                                            "10,15,12,11,7,2" 
                                                       HAMADA 
                        "11,6,10,13,14,15 / 11,6,10,15,14,13" 
                                                       HEMOID 
                                             "11,7,10,5,9,14" 
                                                       HAMATE 
                                             "11,15,10,6,3,7" 
                                                       CHARET 
                                              "12,11,6,2,7,3" 
                                                       CAMERA 
                                             "12,15,10,7,2,6" 
                                                       DACOIT 
                                             "14,15,12,8,4,3" 
                                                       ARCHER 
                                            "15,16,12,11,7,2" 
                                                       ARCHEI 
                                            "15,16,12,11,7,4" 
                                                       RAMATE 
                                             "16,15,10,6,3,7" 
                                                       RACHET 
                                            "16,15,12,11,7,3" 
                                                      BROMATE 
                                             "1,2,5,10,6,3,7" 
                                                      BRECHAM 
                       "1,2,7,12,11,6,10 / 1,2,7,12,11,15,10" 
                                                      TOHEROA 
                                             "3,8,11,7,2,5,6" 
                                                      MARCHER 
                                         "10,15,16,12,11,7,2" 
                                                      HAEMOID 
                                           "11,6,7,10,5,9,14" 
                                                      DIORAMA 
                        "14,9,5,2,6,10,13 / 14,9,5,2,6,10,15" 
                                                      ARCHAEI 
                                          "15,16,12,11,6,7,4" 
                                                      RADIATE 
                                           "16,15,14,9,6,3,7" 
                                                     ACETAMID 
                                        "15,12,7,3,6,10,9,14" 
                                                     RACEMOID 
                                       "16,15,12,7,10,5,9,14" 

---

## Things that still could be done...

* Calculate scores
* Return highest scoring path
* Figure out how to get rid of `for` loop
* Try other algorithm approaches and see if they are more practical (Remember we only go up to 10-mers)
* Pre-screen dictionary (e.g. exclude words with "X" since they aren't on our board)
* Test with other boards

--- .segue .dark

## Questions?
