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
metadata <- read.table(file = "wild.metadata.txt", header = T)
rownames(metadata) <- metadata$Group
metadata <- metadata[, -1]
```

---

##	Dot plots
*	The above methods generally involve plotting a numerical value against a categorical value
*	We'd also like to plot numerical variables against each other


```r
plot(metadata$Weight)  # what is this using as an x-axis?
plot(metadata$Weight, metadata$Ear)  # what is this using as an x-axis?\t\t\t
plot(metadata$Ear ~ metadata$Weight)  # what is this using as an x-axis?
```

---

## Fun with plots
* Be sure to see `?plot` and `?plot.default`

```r
plot(metadata$Ear ~ metadata$Weight, col = "blue", pch = 18)
plot(metadata$Ear ~ metadata$Weight, col = "blue", pch = 20)
plot(metadata$Ear ~ metadata$Weight, col = "blue", pch = 20, cex = 2)
```

---

## `points`


```r
plot(metadata[metadata$Sex == "M", "Ear"] ~ metadata[metadata$Sex == "M", "Weight"], 
    col = "blue", pch = 18)
points(metadata[metadata$Sex == "F", "Ear"] ~ metadata[metadata$Sex == "F", 
    "Weight"], col = "pink", pch = 20)
```

---

## A different kind of histogram


```r
m.hist <- hist(metadata$Weight[metadata$Sex == "F"], breaks = 10, ylim = c(0, 
    20), xlim = c(0, 30), col = "pink")
f.hist <- hist(metadata$Weight[metadata$Sex == "M"], breaks = 10, col = "blue", 
    add = T)

plot(m.hist$density ~ m.hist$mids, type = "h", col = "blue", ylim = c(0, 0.2))
points(f.hist$density ~ f.hist$mids, type = "h", col = "red")

plot(m.hist$density ~ m.hist$mids, type = "l", col = "blue", ylim = c(0, 0.2))
points(f.hist$density ~ f.hist$mids, type = "l", col = "red")
```

---

## Legends


```r
legend(x = 20, y = 0.18, legend = c("Female", "Male"), col = c("red", "blue"), 
    lty = 1, lwd = 2)
```


```r
location <- locator(1)
legend(location, legend = c("Female", "Male"), col = c("red", "blue"), lty = 1, 
    lwd = 2)
location
```

---

## Line segments


```r
abline(a = 0.01, b = 0.01)
abline(v = 20, col = "red", lwd = 3)
abline(h = 0.05, col = "blue", lty = 2, lwd = 3)

segments(x0 = 10, x1 = 15, y0 = 0.2, y1 = 0.15)
segments(x0 = c(10, 21), x1 = c(15, 25), y0 = c(0.2, 0.15), y1 = c(0.15, 0.12))
```

---

## Randomness and probabilities
* In science, much of what we do assumes that samples are observed randomly
* We live in a probabilistic world where everything has a probability, even if it is very small

---

## Randomness
> *	Pick a number between 1 and 10 and write it down

---

## Randomness
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
sample(c("H", "T"), 100, replace = T)  # probability of H | T = 0.50
rbinom(10, size = 1, prob = 0.5)  # what if the coin were cooked or you were a hall of fame hitter?
```

* Flipping a cooked coin...

```r
heads <- rbinom(10, size = 1, prob = 0.8)  #\twhat if the coin were cooked or you were a hall of fame hitter?
sum(heads)
```

* Hall of fame hitter...

```r
hits <- rbinom(5, size = 1, prob = 0.3)  #\twhat if the coin were cooked or you were a hall of fame hitter?
sum(hits)
```

---

## What are the odds assuming it's cooked?...


```r
n.heads <- 4
n.flips <- 10
prob <- 0.3
dbinom(n.heads, size = n.flips, prob = prob)
plot(1:n.flips, dbinom(1:n.flips, n.flips, prob), type = "h")
```

---

## What are the odds assuming it's cooked?...

* What are the odds of seeing `n.heads` heads or fewer?

```r
sum(dbinom(0:n.heads, size = n.flips, prob = prob))
pbinom(n.heads, n.flips, prob)  # probability of seeing this count or smaller
1 - pbinom(n.heads, n.flips, prob)  # probability of seeing this count or larger
```

* For a given probability of flipping a heads, how many heads would we see in `n.flips` with a specified probability?

```r
qbinom(0.15, n.flips, prob)
```

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

## Things to think about:  Mice breeding
* What's the probability that a litter of 8 mice will have 4 males?
* What's the probability that a litter of 8 mice will have 6 males?
* What's the probability that a litter of 8 mice will have 6 or more males?

---

## Other important distributions
*	`dunif`, `punif`, `qunif`, `runif`
*	`dnorm`, `pnorm`, `qnorm`, `rnorm`
*	`dbinom`, `pbinom`, `qbinom`, `rbinom`
*	many others...  see pg 332, Appendix C in ISwR

--- .segue .dark

## Questions?

