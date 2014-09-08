--- 
title       : Microbial Informatics
subtitle    : Lecture 03
date        : September 8, 2014
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
* No class on Thursday. We will use first hour of Friday's lab to cover Thursday's material and then I will turn you loose to work on the lab material.
* Some of you have gotten comments back from me already about your "Pull Requests". Responding to these will enable you to get a better grade if you can satisfy what I comment on.
* Note that problems 2 and 3 need to be submitted as pull requests to different repositories as indicated in the assignment materials
* My office is 1520A, not 1150, MSRB I [sorry!]  

--- 

## Learning objectives
* Finalize introduction to git
* Introduce R language

--- 



--- 

## Philosophy...
*	Think of this as a foreign language class.
*	There's a lot of vocabulary to learn in R, but a lot of it you can create on your own.  E.g. sum command
*	Today we will be learning the basic parts of speech
*	Later we will learn about sentence structure
*	Programming languages have similar parts of speech and sentence structure, it's just a matter of getting the syntax right
*	The hard part is getting the *thinking* right!

---

## Starting / running / quitting R
*	Many ways to customize your version of R
*	Get working directory: `getwd()`
*	Set working directory: Files -> More -> Change working directory
*	Quit R: `q()`
* If there is a `+` instead of `>` as the prompt: Hit `Control+C` or `esc`
* up arrow allows you to cycle through your history (it's also in the top right corner)
* hitting tab from the command line auto-completes command and file names


---

## Looking for help...
*	google
*	?heatmap
*	apropos("heat")
*	example(heatmap)

---

## Overgrown calculator...

```r
2+2
exp(10)
sin(2*pi)
log(pi)
log2(pi)
log10(pi)
sqrt(pi)
abs(pi)
floor(pi)
ceiling(pi)
5 %% 2
```

--- 

## Can generate plots


```r
plot(x=1:10,y=(1:10)^2)
```

![plot of chunk unnamed-chunk-2](assets/fig/unnamed-chunk-2.png) 

---

##	Can do statistics


```r
	t.test(x=c(1:10),y=c(7:20))
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  c(1:10) and c(7:20)
## t = -5.435, df = 21.98, p-value = 1.855e-05
## alternative hypothesis: true difference in means is not equal to 0
## 95 percent confidence interval:
##  -11.053  -4.947
## sample estimates:
## mean of x mean of y 
##       5.5      13.5
```

---

## Variables
*	assignment: "<-" or "="


```r
	x <- 3
	x
```

```
## [1] 3
```

```r
	x * 3
```

```
## [1] 9
```

*	List current variables: `ls()`
*	Remove a varaible: `rm(x)`

---

## Comment as you code
*	Make variable names meaningful don't start with numbers can include periods / underscores try to avoid "reserved" names
*	Good variable names are a type of commenting

```r
 officeNumber <- "1520A"
 officeBuilding <- "MSRB I"
```
*	Comments tell you what you meant so that when you come back to it in a year you know what you were doing.


```r
	#this is a comment
```

*	Comments are a required part of your assignments

--- &vcenter
 
The most important person to write your code for is you. In a year from now.

---

## Types of variables


```r
	typeof(x)
```

```
## [1] "double"
```

*	Numeric/double/integer: counts of things, measurements
*	Characters/strings: DNA sequence, amino acids, names
* Logical: is something true or not

---

## Numerical varaibles


```r
x <- pi
y <- 2
z <- -3
```

---

## String variables


```r
office <- "1520A MSRB I"
grade <- "A"
genome <- "ATGCATCGTCCCGT"
```

* **Note:** the the grade value is in quotes. What happens if it is not in quotes?

---


##	Logical values as inputs (T/F; 1/0)


```r
	x <- TRUE
	y <- FALSE
	
	!x              # NOT operator
	x && y          # AND operator
	x & y           # bitwise AND operator (mainly for vectors)
	x || y          # OR operator
	x | y			# bitwise OR operator (mainly for vectors)
	x == y          # is equal operator
	x != y          # is not equal operator
```

---

## Logical values as outptus on numbers


```r
	x <- 5
	y <- 3
	
	x > y          # greater than operator
	x >= y         # greater than or equal to operator
	x < y          # less than operator
	x <= y         # less than  or equal tooperator
	x == y         # is equal to operator
	x != y         # is not equal to operator
```

---

## Logical values as outptus on strings


```r
	x <- "ATG"
	y <- "CCC"
	
	x > y          # greater than operator
	x >= y         # greater than or equal to operator
	x < y          # less than operator
	x <= y         # less than  or equal tooperator
	x == y         # is equal to operator
	x != y         # is not equal to operator
```

---



---



---



---

## For Friday
* Continue to work your way through the assignment


--- .segue .dark

## Questions?

