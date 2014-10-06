--- 
title       : Microbial Informatics
subtitle    : Lecture 11
date        : October 3, 2014
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
* Homework 3 is out
* For the next two Fridays, the first hour of class will be a lecture
* Read ***Introduction to Statistics with R*** (Chapter 9: Power analysis and Chapter 7: ANOVA and Kruskal Wallis)

--- 

## Review: What test should you use?
> *	You measure the cytokine concentrations in the cecum of 10 mice that are your controls and 10 mice that have been challenged with C. difficile.  You want to know whether C. difficile has significantly altered the cytokine concentration.
> *	You sample the feces of 100 people, 50 are lean and 50 are obese.  You want to determine whether there's an association between obesity and the presence/absence of Pseudomonas in feces.
> *	You are interested in the effects of a DSS treatment on the abundance of Firmicutes in the gut.  In your experiment you collect a fecal sample from before and after the treatment and use qPCR to quantify the Firmicutes from 10 mice.

--- 

## Review: What test should you use?
> *	You are performing a study testing different commercial probiotics that all claim that Bifidobacterium will colonize to a level of 5x10^8.  You sample 20 people that took the Jamie Lee Curtis brand probiotic and want to know whether the manufacturer's claim is supported
> *	It has been claimed that 10% of people harbor Bacteroides fragilis.  You sample the feces of 100 individuals and culture for B. fragilis.  Do 10% of people harbor B. fragilis?




---

## Learning objectives
* Be able to understand the components of experimental design that affect your Type I and II errors

---

## Motivation
* We want to know whehter we correctly designed our mouse study so that we could have differentiate the weights of the PL and PMG mice if they were actually different

---

## Sampling from a population


```r
range <- seq(12, 22, 0.5)
plot(x = range, dnorm(range, 17, 2), type = "l", ylab = "Density", xlab = "Weight (g)", 
    ylim = c(0, 0.6), lwd = 2)

sim1 <- rnorm(20, 17, 2)
sim2 <- rnorm(20, 17, 2)

sim1.h <- hist(sim1, breaks = 10, plot = FALSE)
points(sim1.h$mids, sim1.h$density, type = "l", col = "red", lwd = 2)

sim2.h <- hist(sim2, breaks = 10, plot = FALSE)
points(sim2.h$mids, sim2.h$density, type = "l", col = "blue", lwd = 2)
```

---

<img src="assets/fig/population.png" title="plot of chunk population" alt="plot of chunk population" style="display: block; margin: auto;" />
* Sample 1: Mean=16.5686; SE=0.4298
* Sample 2: Mean=16.9563; SE=0.4709
* Are these samples significantly different from each other?

---


```r
t.test(sim1, sim2)
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  sim1 and sim2
## t = 0.1968, df = 195.3, p-value = 0.8442
## alternative hypothesis: true difference in means is not equal to 0
## 95 percent confidence interval:
##  -0.5347  0.6533
## sample estimates:
## mean of x mean of y 
##     16.95     16.89
```

* No.
* How can we replicate this 1000 times? What would happen?

---

## If we repeated this 1000 times, what would happen?


```r
t.test(rnorm(20, 17, 2), rnorm(20, 17, 2))
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  rnorm(20, 17, 2) and rnorm(20, 17, 2)
## t = 0.9921, df = 37.68, p-value = 0.3275
## alternative hypothesis: true difference in means is not equal to 0
## 95 percent confidence interval:
##  -0.7551  2.2057
## sample estimates:
## mean of x mean of y 
##     16.98     16.25
```

---

## If we repeated this 1000 times, what would happen?


```r
t.test(rnorm(20, 17, 2), rnorm(20, 17, 2))$p.value
```

```
## [1] 0.7176
```

---

## If we repeated this 1000 times, what would happen?


```r
p <- replicate(1000, t.test(rnorm(20, 17, 2), rnorm(20, 17, 2))$p.value)
summary(p)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  0.0002  0.2560  0.5020  0.5010  0.7450  1.0000
```

* Huh.
* Our smallest value is 2.4325 &times; 10<sup>-4</sup>. How is that possible?
* What fraction of our tests had a p-value under 0.05?

---

## If we repeated this 1000 times, what would happen?


```r
sum(p<0.05) / 1000
```

```
## [1] 0.064
```

* What is this called?

---

## What if there was a 1 gram difference in weights?


```r
p <- replicate(1000, t.test(rnorm(20, 16, 2), rnorm(20, 17, 2))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.349
```


---

## What if there was a 2 gram difference in weights?


```r
p <- replicate(1000, t.test(rnorm(20, 16, 2), rnorm(20, 17, 2))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.335
```


```r
p <- replicate(1000, t.test(rnorm(20, 16, 2), rnorm(20, 18, 2))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.867
```

---

## What if there was a 1 gram difference in weights, but we had more mice?


```r
p <- replicate(1000, t.test(rnorm(20, 16, 2), rnorm(20, 17, 2))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.358
```


```r
p <- replicate(1000, t.test(rnorm(40, 16, 2), rnorm(40, 17, 2))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.609
```

---

## What if there was a 1 gram difference in weights, but we had less variation?


```r
p <- replicate(1000, t.test(rnorm(20, 16, 2), rnorm(20, 17, 2))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.333
```


```r
p <- replicate(1000, t.test(rnorm(40, 16, 1.5), rnorm(40, 17, 1.5))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.861
```

---

## What if there was a 1 gram difference in weights, but we used a non-parametric test?


```r
p <- replicate(1000, t.test(rnorm(20, 16, 2), rnorm(20, 17, 2))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.316
```


```r
p <- replicate(1000, wilcox.test(rnorm(20, 16, 2), rnorm(20, 17, 2))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.317
```

---

## What are we measuring?

> * Power or 1-Type II error
> * Affected by...
>    * the effect size
>    * the variation in data
>    * the number of individuals in each sample
>    * the Type I error threshold
>    * the test
> * If we know all of these parameters we can estimate our power and we can quanity the requirements to get a specific power

---

## What is a relevant effect size?

> * We may be able to detect an average difference in weight of 0.01 g, do we care?
> * We may not be able to detect a difference in weight of 10 g, do we care?
> * The effect size we seek to measure must be biologicaly relevant!

---

## Motivation

* We want to know whehter we correctly designed our mouse study so that we could have differentiate the weights of the PL and PMG mice if they were actually different
  * PL: 16.0259 (N=58; SD=4.7113)
  * PMG: 17.0333 (N=60; SD=4.9471)
* Let's assume our SD is 4.8.
* How many mice per group do we need to detect a difference of 1 g?


```r
p <- replicate(1000, t.test(rnorm(58, 16, 4.8), rnorm(60, 17, 4.8))$p.value)
sum(p<0.05) / 1000
```

```
## [1] 0.21
```

---

## Motivation


```r
N <- seq(50,500,10)

getPower <- function(N){
	p.values <- replicate(1000, t.test(rnorm(N, 16, 4.8), rnorm(N, 17, 4.8))$p.value)
	power <- sum(p.values<0.05)/1000
	return(power)
}

power.curve <- sapply(N, getPower)
```

---

## Motivation

<img src="assets/fig/unnamed-chunk-18.png" title="plot of chunk unnamed-chunk-18" alt="plot of chunk unnamed-chunk-18" style="display: block; margin: auto;" />

---

## How to do this in R


```r
power.t.test(n=NULL, delta=1.0, sd=4.8, sig.level=0.05, power=0.8)	#what's the required N?
power.t.test(n=60, delta=1.0, sd=4.8, sig.level=0.05, power=NULL)	#what's the power?
power.t.test( n=60, delta=1.0, sd=NULL, sig.level=0.05, power=0.8)	#what's the required sd?
power.t.test(n=60, delta=NULL, sd=4.8, sig.level=0.05, power=0.8)	#what's the required N?
```

---

## How did our simulation do?


```r
power.t.test(n=NULL, delta=1.0, sd=4.8, sig.level=0.05, power=0.8)	#what's the required N?
```

```
## 
##      Two-sample t test power calculation 
## 
##               n = 362.6
##           delta = 1
##              sd = 4.8
##       sig.level = 0.05
##           power = 0.8
##     alternative = two.sided
## 
## NOTE: n is number in *each* group
```

* Not bad!

---

## Other power calculators in R


```r
power.t.test(n=NULL, delta=0.5, sd=2, sig.level=0.05, power=0.9, type="one.sample")
power.t.test(n=NULL, delta=0.5, sd=2, sig.level=0.05, power=0.9, type="paired")

power.prop.test(power=0.80, p1=0.15, p2=0.30)	#test of proportions
```


--- .segue .dark

## Questions?
