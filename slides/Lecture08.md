--- 
title       : Microbial Informatics
subtitle    : Lecture 08
date        : September 26, 2014
author      : Patrick D. Schloss, PhD (microbialinformatics.github.io)
job         : Department of Microbiology & Immunology
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : standalone    # {selfcontained, standalone, draft}
knit        : slidify::knit2slides

--- 

## Announcements
* Homework 2 due today
* Homework 3 is out
* Read ***Introduction to Statistics with R*** (Chapter 8)

--- 

## Review
* Histograms
* Box plots
* Bar plots
* Strip charts



---

## Learning objectives
* Graphics
  * Dot plots
  * Legends
  * Line segments
* Random variables

---

## Let's get some data


```r
metadata <- read.table(file="wild.metadata.txt", header=T)
```

```
## Warning: cannot open file 'wild.metadata.txt': No such file or directory
```

```
## Error: cannot open the connection
```

```r
rownames(metadata) <- metadata$Group
```

```
## Error: object 'metadata' not found
```

```r
metadata <- metadata[,-1]
```

```
## Error: object 'metadata' not found
```

---

##	Dot plots
*	The above methods generally involve plotting a numerical value against a categorical value
*	We'd also like to plot numerical variables against each other


```r
	plot(metadata$Weight)				# what is this using as an x-axis?
```

```
## Error: object 'metadata' not found
```

```r
	plot(metadata$Weight, metadata$Ear)			# what is this using as an x-axis?			
```

```
## Error: object 'metadata' not found
```

```r
	plot(metadata$Ear~metadata$Weight)			# what is this using as an x-axis?
```

```
## Error: object 'metadata' not found
```

---

## Fun with plots
* Be sure to see `?plot` and `?plot.default`

```r
	plot(metadata$Ear~metadata$Weight, col="blue", pch=18)
```

```
## Error: object 'metadata' not found
```

```r
	plot(metadata$Ear~metadata$Weight, col="blue", pch=20)
```

```
## Error: object 'metadata' not found
```

```r
	plot(metadata$Ear~metadata$Weight, col="blue", pch=20, cex=2)
```

```
## Error: object 'metadata' not found
```

---

## `points`


```r
	plot(metadata[metadata$Sex=="M","Ear"]~metadata[metadata$Sex=="M","Weight"], col="blue", pch=18)
```

```
## Error: object 'metadata' not found
```

```r
	points(metadata[metadata$Sex=="F","Ear"]~metadata[metadata$Sex=="F","Weight"], col="pink", pch=20)
```

```
## Error: object 'metadata' not found
```

---

## A different kind of histogram


```r
m.hist <- hist(metadata$Weight[metadata$Sex=="F"], breaks=10, ylim=c(0,20), xlim=c(0,30), col="pink")
```

```
## Error: object 'metadata' not found
```

```r
f.hist <- hist(metadata$Weight[metadata$Sex=="M"], breaks=10, col="blue", add=T)
```

```
## Error: object 'metadata' not found
```

```r
plot(m.hist$density~m.hist$mids, type="h", col="blue", ylim=c(0,0.2))
```

```
## Error: object 'm.hist' not found
```

```r
points(f.hist$density~f.hist$mids, type="h", col="red")
```

```
## Error: object 'f.hist' not found
```

```r
plot(m.hist$density~m.hist$mids, type="l", col="blue", ylim=c(0,0.2))
```

```
## Error: object 'm.hist' not found
```

```r
points(f.hist$density~f.hist$mids, type="l", col="red")
```

```
## Error: object 'f.hist' not found
```

---

## Legends


```r
legend(x=20, y=0.18, legend=c("Female", "Male"), col=c("red", "blue"), lty=1, lwd=2)
```

```
## Error: plot.new has not been called yet
```


```r
location <- locator(1)
```

```
## Error: plot.new has not been called yet
```

```r
legend(location, legend=c("Female", "Male"), col=c("red", "blue"), lty=1, lwd=2)
```

```
## Error: object 'location' not found
```

```r
location
```

```
## Error: object 'location' not found
```

---

## Line segments


```r
abline(a=0.01, b=0.01)
```

```
## Error: plot.new has not been called yet
```

```r
abline(v=20, col="red", lwd=3)
```

```
## Error: plot.new has not been called yet
```

```r
abline(h=0.05, col="blue", lty=2, lwd=3)
```

```
## Error: plot.new has not been called yet
```

```r
segments(x0=10, x1=15, y0=0.20, y1=0.15)
```

```
## Error: plot.new has not been called yet
```

```r
segments(x0=c(10, 21), x1=c(15, 25), y0=c(0.20, 0.15), y1=c(0.15, 0.12))
```

```
## Error: plot.new has not been called yet
```

---

## Randomness and probabilities
* In science, much of what we do assumes that samples are observed randomly
* We live in a probabilistic world where everything has a probability, even if it is very small

---

## Randomness
> *	Pick a number between 1 and 10 and write it down
> *	What would you expect a random sampling of the numbers from 1 to 10 to look like?
> *	What would it depend on?
> *	Mean?
> *	Min?
> *	Max?
> *	What type of plot would we use?

--- .segue .dark

## Questions?

