--- 
title       : Microbial Informatics
subtitle    : Lecture 08
date        : September 25, 2014
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

---

##	Let's get R to do it for us

> * Use the `sample` command to randomly draw a number from a range of integers
> ```{r}
r<-sample(1:10, 10, replace=T)
r
```

> * What should these look like?
> ```{r}
hist(r)
stripchart(r, method="jitter")
plot(r)
summary(r)
```

---

##	How do we get a more reliable shape to our distribution?

> * What happens if we run the following repeatedly?
> ```{r}						
r<-sample(1:10, 1000, replace=T)
hist(r, xlim=c(0,10), breaks=seq(0,10, 1))
```

> * We can "fix" the distribution:
> ```{r}						
set.seed(1)
r<-sample(1:10, 1000, replace=T)
hist(r, xlim=c(0,10), breaks=seq(0,10, 1))
```

> * Being able to set the random seed is an importat feature for reproducible reserach

---

##	There are discrete and continuous variables
> *	***Discrete:*** Hits in baseball, number of infected mice, number of people   
> ```{r}						
r<-sample(1:10, 1000, replace=T)
plot(r, ylim=c(0,10))
```

> *	***Continuous:*** Weight, temperature, concentrations  
> ```{r}						
r<-runif(1000, min=1, max=10)
plot(r, ylim=c(0,10))
```

> * Notice a difference?

---

## Binomial distribution

* Flipping a fair coin...

```r
sample(c("H", "T"), 100, replace=T)		# probability of H | T = 0.50
```

```
##   [1] "T" "H" "H" "T" "T" "H" "T" "H" "T" "H" "H" "T" "T" "T" "H" "H" "T"
##  [18] "T" "T" "H" "H" "H" "H" "H" "H" "T" "H" "H" "T" "H" "H" "H" "H" "H"
##  [35] "H" "H" "T" "H" "H" "H" "T" "T" "H" "H" "H" "H" "T" "H" "H" "T" "T"
##  [52] "H" "H" "T" "H" "T" "T" "T" "H" "T" "H" "T" "H" "T" "H" "T" "T" "T"
##  [69] "H" "H" "T" "H" "T" "H" "T" "T" "H" "H" "T" "T" "H" "H" "T" "T" "T"
##  [86] "H" "T" "H" "H" "H" "H" "T" "H" "T" "H" "H" "H" "T" "H" "T"
```

```r
rbinom(10, size=1, prob=0.5)			# what if the coin were cooked or you were a hall of fame hitter?
```

```
##  [1] 0 1 1 0 1 0 0 0 1 1
```

* Flipping a cooked coin...

```r
heads <- rbinom(10, size=1, prob=0.8)			#	what if the coin were cooked or you were a hall of fame hitter?
sum(heads)
```

```
## [1] 7
```

* Hall of fame hitter...

```r
hits <- rbinom(5, size=1, prob=0.3)			#	what if the coin were cooked or you were a hall of fame hitter?
sum(hits)
```

```
## [1] 2
```

---

## Other distribution functions

* `rbinom`: random samples
  * Draw random values from a binomial distribution
  * Example: Have the computer flip a coin for you
* `dbinom`: distribution function
  * Probability of drawing a certain number of something from a binomial distribution
  * Example: Probability of getting 1 head out of 10 coin flips

---

## Other distribution functions

* `pbinom`: cumulative distribution function
  * Probability of drawing a certain number of something or fewere froma  binomial distribution
  * Example: Probability of geting 1 or fewer heads out of 10 coin flips
* `qbinom`: inverse cumulative distribution function
  * Given a probability, return the number whose cumulative distribution matches the probability
	* Example: Number of heads (and fewer) you should expect to get 25% of the time when you make 10 flips

---

## Example

* You have a mouse breeding colony and you are disapointed because the mom you were counting on to give you an even mix of males and females has given you 2 males and 8 females.
* Do you think something is wrong with her?
* You could rebread her a bunch and see, but that will get expensive and take a long time.
* Is there a faster way?


```r
breedings <- 1000
npups <- 10
p.males <- 0.5
obs.males <- 2
```

---

## Number of males you get if you rebread her 1000 times and she has 10 pups per litter


```r
r <- rbinom(breedings, npups, p.males)
r.hist <- hist(r, plot = FALSE, breaks = seq(-0.5, 10.5, 1))
par(mar = c(5, 5, 0.5, 0.5))
plot(r.hist$density ~ r.hist$mids, type = "h", lwd = 2, xlab = "Number of male mice", 
    ylab = "Density", xlim = c(0, 10))
arrows(x0 = 2, x1 = 2, y0 = 0.15, y1 = 0.08, lwd = 2, col = "red")
```

<img src="assets/fig/unnamed-chunk-14.png" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" style="display: block; margin: auto;" />

---

## Fraction of those 1000 times where you get two males (empirical)


```r
n.two <- sum(r == obs.males)
p.two.empirical <- n.two / breedings
p.two.empirical
```

```
## [1] 0.04
```

---

## Built in R function: `dbinom`


```r
p.two.R <- dbinom(2, 10, 0.5)
p.two.R
```

```
## [1] 0.04395
```

```r
p.two.empirical - p.two.R
```

```
## [1] -0.003945
```

* How would you reduce the difference?

---

## Number of males you get if you rebread her 1000 times and she has 10 pups per litter


```r
plot(r.hist$density ~ r.hist$mids, type = "h", lwd = 2, xlab = "Number of male mice", 
    ylab = "Density", xlim = c(0, 10))
points(x = 0:10, dbinom(0:10, 10, 0.5), col = "red", lwd = 3, type = "l", lty = 1)
```

<img src="assets/fig/unnamed-chunk-17.png" title="plot of chunk unnamed-chunk-17" alt="plot of chunk unnamed-chunk-17" style="display: block; margin: auto;" />

---

## Fraction of those 1000 times where you get two or fewer males (empirical and `pbinom`)


```r
n.two.or.fewer <- sum(r <= obs.males)
p.two.or.fewer.empirical <- n.two.or.fewer / breedings
p.two.or.fewer.empirical
```

```
## [1] 0.053
```

```r
p.two.or.fewer.R <- pbinom(2, 10, 0.5)
p.two.or.fewer.R
```

```
## [1] 0.05469
```

```r
p.two.or.fewer.empirical-p.two.or.fewer.R
```

```
## [1] -0.001687
```

---

## How many females should we expect to have 90% of the time?


```r
inv.cdf <- qbinom(0.9, 10, 0.5)  
```

* In a litter of 10 mice, we should expect to have as many as 7 females in 90% of our litters

---

## Things to think about: Baseball...
*	What is the probability of a 0.300 hiter going 0 for 4?
* What is the probability of a 0.300 hiter going 4 for 4?
*	What's the probability of replicating Joe DiMaggio's 56 game hitting streak?
*	What's the probability of another person matching the streak next season?

---

## Things to think about: DNA sequencing
* If sequencing errors are random and 1% of base calls are errors, then...
* ...what fraction of 250 bp sequences would have more than one error?
* ...if you had 1 million sequences, how many would have the exact same error?

---

## Other important distributions
*	`dunif`, `punif`, `qunif`, `runif`
*	`dnorm`, `pnorm`, `qnorm`, `rnorm`
*	`dbinom`, `pbinom`, `qbinom`, `rbinom`
*	many others...  see pg 332, Appendix C in ISwR

--- .segue .dark

## Questions?

