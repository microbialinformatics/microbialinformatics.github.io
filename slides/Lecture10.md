--- 
title       : Microbial Informatics
subtitle    : Lecture 10
date        : October 2, 2014
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
* Read ***Introduction to Statistics with R*** (Chapter 5: T- and Wilcoxon tests)

--- 

## Review
* Human are poor sources of random numbers!
* Can perform simulations using random number generators
* Binomial distribution is a discrete distribution
* Several `xbinom` functions in R



---

## Learning objectives
* Describe the different types of hypotheses
* How to test associations between tabular data
* How to generate tabular data

---

## Testing a hypothesis

*	What is a hypothesis?
    - Testable
    - Falsifiable
    - Leads to predictions
    - Cannot prove a hypothesis is true!
* What's are null and alternative hypotheses? 
    - Null hypothesis is the hypothesis you are trying to reject
    - Cannot prove a null hypothesis true, can only reject

---

## Remember: everything is probabilistic

* Errors
    - Type I: Falsely rejecting a null hypothesis
    - Type II: Falsely supporting a null hypothesis
* P-value
    - The probability that you would see something as extreme or more so if the null hypothesis is true (Type I)
    - Generally willing to accept a Type I error of 0.05
* Power
    - The ability to reject a null hypothesis if false (Type II)
    - Generally desire a power of 0.80

---

## Two types of tests

*	Single tailed
    * Probability that the difference is greater than expected
    * Example: Are there more males than females?
* Two-tailed:
    * Probability that the difference is greater or less than expected
    * Example: Is there a difference in the number of males and females?

---

## Testing

*	How would we know whether we had a even sampling of M & F in the previous example?
	-	How to test?
	-	Binomial distribution
	

```r
pbinom(2, 10, 0.5)
2 * pbinom(2, 10, 0.5)
binom.test(2, 10, 0.5)
binom.test(2, 10, 0.5, alternative = "less")
```

---

## Let's get some data to play with...


```r
metadata <- read.table(file = "wild.metadata.txt", header = T)
rownames(metadata) <- metadata$Group
metadata <- metadata[, -1]
```

---

## An aside: the table commands

* Will convert your observations (individuals by variables) into tables (varaibles by variables)


```r
table(metadata$Sex)
table(metadata$Sex, metadata$SP)
table(metadata$Sex, metadata$SP, metadata$Repro)
```

---

##	Generating marginal sums


```r
sex.sp <- table(metadata$Sex, metadata$SP)
margin.table(sex.sp)
margin.table(sex.sp, 1)
margin.table(sex.sp, 2)
```

---

## Generating relative abundance tables


```r
prop.table(sex.sp)
prop.table(sex.sp, 1)
prop.table(sex.sp, 2)
```

---

## Is there a difference in the sex-species ratio?


```
##    
##     PL PMG
##   F 24  36
##   M 34  17
```

* What would you expect if there was no difference in the ratio?

---

## Is there a species bias?


```r
species.sums <- margin.table(sex.sp, 2)
binom.test(species.sums)
```

```
## 
## 	Exact binomial test
## 
## data:  species.sums
## number of successes = 58, number of trials = 111, p-value = 0.7044
## alternative hypothesis: true probability of success is not equal to 0.5
## 95 percent confidence interval:
##  0.4256 0.6182
## sample estimates:
## probability of success 
##                 0.5225
```

---

## Is there a sex bias?


```r
sex.sums <- margin.table(sex.sp, 1)
binom.test(sex.sums)
```

```
## 
## 	Exact binomial test
## 
## data:  sex.sums
## number of successes = 60, number of trials = 111, p-value = 0.4478
## alternative hypothesis: true probability of success is not equal to 0.5
## 95 percent confidence interval:
##  0.4433 0.6355
## sample estimates:
## probability of success 
##                 0.5405
```

---

## Is the sex/species distribution the same?

* What would be expected?


```r
frac.male <- sex.sums["M"]/sum(sex.sums)
frac.female <- 1 - frac.male
frac.sex <- c(F = frac.female, M = frac.male)

frac.pl <- species.sums["PL"]/sum(species.sums)
frac.pmg <- 1 - frac.pl
frac.species <- c(PL = frac.pl, PMG = frac.pmg)

expected <- frac.sex %*% t(frac.species)
expected <- expected * sum(sex.sp)
expected
```

```
##      PL.PL PMG.PL
## [1,] 31.35  28.65
## [2,] 26.65  24.35
```


---

## What is the difference between what we expected and what we observed?

$$\chi^2 =\sum \frac{(O_{ij}-E_{ij})^2}{E_{ij}}$$

* Test against a ChiSquared distribution with: $$df=(n_{row}-1)(n_{col}-1)$$

---

## ChiSquared distribution

*	The distribution of a sum of the squares of k indepdentently sampled normal random variables, where k is the degrees of freedom
* Procedure to create an empirical distribution
    1.	Draw k random variables from a normal distribution with mean 0.0 and standard deviation of 1.0
    2.	Square each of them
    3.  Sum them
    4.	Repeat many times and keep track of how many times you see each value
* Interested in the proportion of the distribution larger than our test statistic

---

## What is the difference between what we expected and what we observed?


```r
chi.sq <- sum((expected - sex.sp)^2/expected)
df <- (nrow(sex.sp) - 1) * (ncol(sex.sp) - 1)
plot(seq(0, 20, 0.05), dchisq(seq(0, 20, 0.05), df = df), type = "l", xlab = "ChiSquared Statistic", 
    ylab = "Probability with 1 degree of freedom")
arrows(x0 = chi.sq, x1 = chi.sq, y0 = 0.4, y1 = 0.05, lwd = 2, col = "red")
```

<img src="assets/fig/unnamed-chunk-10.png" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" style="display: block; margin: auto;" />

---
	
## Fisher exact test

* Imagine a 2x2 table and the cells are a, b, c, d going from left to right and top-down
* The probability of seeing a specific table format...

$$P=\frac{(a+b)!(c+d)!(a+c)!(b+d)!}{a!b!c!d!}$$

* Need to then find probability of more extreme tables via permutation
* Can be computationally intensive	

---
	
## Fisher exact test in R


```r
fisher.test(sex.sp)
```

```
## 
## 	Fisher's Exact Test for Count Data
## 
## data:  sex.sp
## p-value = 0.007411
## alternative hypothesis: true odds ratio is not equal to 1
## 95 percent confidence interval:
##  0.1418 0.7765
## sample estimates:
## odds ratio 
##     0.3368
```

---

## Test of proportions

* Null: the fraction of males is the same in both species


```r
males <- sex.sp["M", ]
prop.test(males, species.sums)
```

```
## 
## 	2-sample test for equality of proportions with continuity
## 	correction
## 
## data:  males out of species.sums
## X-squared = 6.825, df = 1, p-value = 0.00899
## alternative hypothesis: two.sided
## 95 percent confidence interval:
##  0.06891 0.46199
## sample estimates:
## prop 1 prop 2 
## 0.5862 0.3208
```

---

## Conclusions

* Generall need at least 5 observations per cell of your table (rule of thumb)
* Fisher exact test is best approach, but can be computationally demanding
* Test possible with more that two levels per factor, but may be necessary use simulations to build distributions

--- .segue .dark

## Questions?
