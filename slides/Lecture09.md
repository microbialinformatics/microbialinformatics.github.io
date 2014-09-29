--- 
title       : Microbial Informatics
subtitle    : Lecture 09
date        : September 30, 2014
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
* Homework 3 is out
* For the next two Fridays, the first hour of class will be a lecture
* Read ***Introduction to Statistics with R*** (Chapter 8: Tabular data)

--- 

## Review
* Human are poor sources of random numbers!



---

## Learning objectives
* Random variables

---

## Randomness and probabilities
* In science, much of what we do assumes that samples are observed randomly
* We live in a probabilistic world where everything has a probability, even if it is very small

---

## Randomness
*	Pick a number between 1 and 10 and write it down
*	What would you expect a random sampling of the numbers from 1 to 10 to look like?
*	What would it depend on?
*	Mean?
*	Min?
*	Max?
*	What type of plot would we use?

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

> * Flipping a fair coin...
> ```{r}
sample(c("H", "T"), 100, replace=T)
rbinom(10, size=1, prob=0.5)
```

> * Flipping a cooked coin...
> ```{r}
heads <- rbinom(10, size=1, prob=0.8)
sum(heads)
```

> * Hall of fame hitter...
> ```{r}
hits <- rbinom(5, size=1, prob=0.3)
sum(hits)
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

<img src="assets/fig/unnamed-chunk-3.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />

---

## Fraction of those 1000 times where you get two males (empirical)


```r
n.two <- sum(r == obs.males)
p.two.empirical <- n.two / breedings
p.two.empirical
```

```
## [1] 0.046
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
## [1] 0.002055
```

* How would you reduce the difference?

---

## Number of males you get if you rebread her 1000 times and she has 10 pups per litter


```r
plot(r.hist$density ~ r.hist$mids, type = "h", lwd = 2, xlab = "Number of male mice", 
    ylab = "Density", xlim = c(0, 10))
points(x = 0:10, dbinom(0:10, 10, 0.5), col = "red", lwd = 3, type = "l", lty = 1)
```

<img src="assets/fig/unnamed-chunk-6.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />

---

## Fraction of those 1000 times where you get two or fewer males (empirical and `pbinom`)


```r
n.two.or.fewer <- sum(r <= obs.males)
p.two.or.fewer.empirical <- n.two.or.fewer / breedings
p.two.or.fewer.empirical
```

```
## [1] 0.054
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
## [1] -0.0006875
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
