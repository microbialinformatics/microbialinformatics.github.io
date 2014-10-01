--- 
title       : Microbial Informatics
subtitle    : Lecture 10
date        : October 2, 2014
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
* Read ***Introduction to Statistics with R*** (Chapter 5: T- and Wilcoxon tests)

--- 

## Review
* Human are poor sources of random numbers!
* Can perform simulations using random number generators
* Binomial distribution is a discrete distribution
* Several `xbinom` functions in R



---

## Learning objectives
* How to generate tabular data
* How to test associations between tabular data

---


```r
opts_chunk$get()
```

```
## $eval
## [1] TRUE
## 
## $echo
## [1] TRUE
## 
## $results
## [1] "markup"
## 
## $tidy
## [1] FALSE
## 
## $tidy.opts
## NULL
## 
## $collapse
## [1] FALSE
## 
## $prompt
## [1] FALSE
## 
## $comment
## [1] "##"
## 
## $highlight
## [1] TRUE
## 
## $strip.white
## [1] TRUE
## 
## $size
## [1] "normalsize"
## 
## $background
## [1] "#F7F7F7"
## 
## $cache
## [1] TRUE
## 
## $cache.path
## [1] ".cache/"
## 
## $cache.vars
## NULL
## 
## $cache.lazy
## [1] TRUE
## 
## $dependson
## NULL
## 
## $autodep
## [1] FALSE
## 
## $fig.keep
## [1] "high"
## 
## $fig.show
## [1] "asis"
## 
## $fig.align
## [1] "default"
## 
## $fig.path
## [1] "assets/fig/"
## 
## $dev
## [1] "png"
## 
## $dev.args
## NULL
## 
## $dpi
## [1] 72
## 
## $fig.ext
## NULL
## 
## $fig.width
## [1] 7
## 
## $fig.height
## [1] 7
## 
## $fig.env
## [1] "figure"
## 
## $fig.cap
## NULL
## 
## $fig.scap
## NULL
## 
## $fig.lp
## [1] "fig:"
## 
## $fig.subcap
## NULL
## 
## $fig.pos
## [1] ""
## 
## $out.width
## NULL
## 
## $out.height
## NULL
## 
## $out.extra
## NULL
## 
## $fig.retina
## [1] 1
## 
## $external
## [1] TRUE
## 
## $sanitize
## [1] FALSE
## 
## $interval
## [1] 1
## 
## $aniopts
## [1] "controls,loop"
## 
## $warning
## [1] TRUE
## 
## $error
## [1] TRUE
## 
## $message
## [1] TRUE
## 
## $render
## NULL
## 
## $ref.label
## NULL
## 
## $child
## NULL
## 
## $engine
## [1] "R"
## 
## $split
## [1] FALSE
## 
## $include
## [1] TRUE
## 
## $purl
## [1] TRUE
```

---

## Let's get some data to work with...


```r
metadata <- read.table(file="wild.metadata.txt", header=T)
rownames(metadata) <- metadata$Group
metadata <- metadata[,-1]
```

---

## The table command

* Will convert your observations (individuals by variables) into tables (varaibles by variables)


```r
table(metadata$Sex)
```

```
## 
##  F  M 
## 60 51
```

```r
table(metadata$Sex, metadata$SP)
```

```
##    
##     PL PMG
##   F 24  36
##   M 34  17
```

```r
table(metadata$Sex, metadata$SP, metadata$Repro)
```

```
## , ,  = A
## 
##    
##     PL PMG
##   F  0   0
##   M  3   0
## 
## , ,  = ABD
## 
##    
##     PL PMG
##   F  0   0
##   M  7   1
## 
## , ,  = N
## 
##    
##     PL PMG
##   F  1   2
##   M  0   0
## 
## , ,  = NE
## 
##    
##     PL PMG
##   F 12  15
##   M  0   0
## 
## , ,  = NT
## 
##    
##     PL PMG
##   F 11  19
##   M  0   0
## 
## , ,  = SCR
## 
##    
##     PL PMG
##   F  0   0
##   M 24  16
```

---

##	Generating marginal sums


```r
sex.sp <- table(metadata$Sex, metadata$SP)
margin.table(sex.sp)
```

```
## [1] 111
```

```r
margin.table(sex.sp, 1)
```

```
## 
##  F  M 
## 60 51
```

```r
margin.table(sex.sp, 2)
```

```
## 
##  PL PMG 
##  58  53
```

---

## Generating relative abundance tables


```r
prop.table(sex.sp)
```

```
##    
##         PL    PMG
##   F 0.2162 0.3243
##   M 0.3063 0.1532
```

```r
prop.table(sex.sp, 1)
```

```
##    
##         PL    PMG
##   F 0.4000 0.6000
##   M 0.6667 0.3333
```

```r
prop.table(sex.sp, 2)
```

```
##    
##         PL    PMG
##   F 0.4138 0.6792
##   M 0.5862 0.3208
```

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
```

```
## [1] 0.05469
```

```r
2*pbinom(2, 10, 0.5)
```

```
## [1] 0.1094
```

```r
binom.test(2, 10, 0.5)
```

```
## 
## 	Exact binomial test
## 
## data:  2 and 10
## number of successes = 2, number of trials = 10, p-value = 0.1094
## alternative hypothesis: true probability of success is not equal to 0.5
## 95 percent confidence interval:
##  0.02521 0.55610
## sample estimates:
## probability of success 
##                    0.2
```

```r
binom.test(2, 10, 0.5, alternative="less")
```

```
## 
## 	Exact binomial test
## 
## data:  2 and 10
## number of successes = 2, number of trials = 10, p-value = 0.05469
## alternative hypothesis: true probability of success is less than 0.5
## 95 percent confidence interval:
##  0.0000 0.5069
## sample estimates:
## probability of success 
##                    0.2
```

---

====================================================================================


Testing a hypothesis - two "independent" proportions - are two proportions the same?


lewitt.success <- c(9,4)
lewitt.failure <- c(3, 9)
lewitt.total <- lewitt.success + lewitt.failure

*	Different methods...
	-	Test of proportions

	prop.test(lewitt.success, lewitt.total)
			
	
	
	-	Fisher exact test - imagine a 2x2 table and the cells are a, b, c, d going from left to right and top-down
	-	p = [(a+b)!(c+d)!(a+c)!(b+d)!] / [a!b!c!d!]
	-	Odds ratio: [p1 / (1-p1)] / [p2 / (1-p2)]
	-	requires a matrix
	
	lewitt.matrix <- matrix(c(lewitt.success, lewitt.failure), nrow=2)



--- .segue .dark

## Questions?
