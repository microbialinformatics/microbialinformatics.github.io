---
title       : Microbial Informatics
subtitle    : Lecture 19
date        : October 30, 2014
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
* Homework is due Friday
 - Note: for histogram problem, you should have the word names on the x-axis and their frequency in the y-axis (`hist` will not work...)
* We will not be meeting on Friday



---

## Review
* Loops: `for`, `while`, `repeat` loops
* Loops are slow in R beacuase variables are copied, destroyed, and recreated each time a vector is modified
* Conditionals: `ifelse` and `if...else if...else`

---

## Learning objectives

* Be able to vectorize loops in R and see the improved speed
* Understand when to use Various flavors of apply
  - `apply`
  - `lapply`
  - `sapply`
  - `mapply`
  - `vapply`
  - `replicate`

---

## Simple vectorization


```r
z <- sum(1:10)

my.sum <- function(x){
	sum <- 0
	for(i in x){
		sum <- sum+i
	}
  return(sum)	
}

my.z <- my.sum(1:10)

z == my.z
```

```
## [1] TRUE
```

---

## `apply`

* As we've seen before if we have a **matrix**, we can't easily perform functions on the rows...


```r
my.matrix <- matrix(runif(100), nrow=25, ncol=4)
mean(my.matrix)
```

```
## [1] 0.4569663
```

* How do we get out the mean for each column?

---

## `apply`

* For the columns...

```r
apply(my.matrix, 2, sum)
```

```
## [1] 11.03565 12.39229 10.82431 11.44439
```

* For the rows...

```r
apply(my.matrix, 1, sum)
```

```
##  [1] 2.6943111 2.0101876 2.9360609 1.2017400 2.0563487 1.8594455 1.0698792
##  [8] 2.2443721 1.7925920 1.5564715 2.3986392 0.6921058 0.9243032 2.4423091
## [15] 2.1361687 2.2463989 1.2584018 1.1983626 1.9852243 2.2287206 2.0006690
## [22] 2.3374191 1.6519987 1.3962797 1.3782208
```

---

## Something more complex...

* What if we want the sum of each column where each value is raised to some arbitrary power?


```r
power <- function(x, pow=2){
	value <- sum(x^pow)
	return(value)
}
```

* We could just loop across the columns and apply our `power` function:


```r
sum.pow <- rep(0, ncol(my.matrix))
for(c in 1:ncol(my.matrix)){
	sum.pow[c] <- power(my.matrix[,c], 3)
}
sum.pow
```

```
## [1] 6.165161 5.160410 5.221504 5.517061
```

---

## Let's try the apply function...


```r
apply(my.matrix, 2, power)
```

```
## [1] 7.636707 7.586525 7.010534 7.436073
```

* and a user defined power (`pow=3`)?


```r
apply(my.matrix, 2, power, pow=3)
```

```
## [1] 6.165161 5.160410 5.221504 5.517061
```

---

## What's going on?

* “Returns a vector or array or list of values obtained by applying a function to margins of an array or matrix.”
* `apply` extracts the rows/columns, converts them to a vector
* The function is applied
* Output generated
* Again, the benefit is seen with larger datasets and more complex functions
* Remember that `apply` uses a matrix as input

---

## What if you want to use a list as your input?


```r
my.list <- list(popA = runif(20), popB = runif(40), popC = runif(25))
my.list
```

```
## $popA
##  [1] 0.789888926 0.732228612 0.593445162 0.458747080 0.294085842
##  [6] 0.107231901 0.629430934 0.178869322 0.314758766 0.782433687
## [11] 0.310015731 0.423296753 0.230681855 0.808566388 0.126439277
## [16] 0.006074851 0.049667654 0.576524630 0.404983133 0.595498108
## 
## $popB
##  [1] 0.65757852 0.88621404 0.65655682 0.49551514 0.26531379 0.71324740
##  [7] 0.98365988 0.26544527 0.88064996 0.05184048 0.71307293 0.15256234
## [13] 0.39815559 0.43867842 0.63324371 0.63029916 0.50362772 0.64338183
## [19] 0.92875425 0.73931652 0.19609726 0.13118313 0.82240801 0.27533289
## [25] 0.09853017 0.07492592 0.82060901 0.15400064 0.70062609 0.09482273
## [31] 0.18038604 0.10514004 0.65993975 0.07324145 0.22970452 0.88344762
## [37] 0.97923670 0.48778723 0.44308235 0.32717377
## 
## $popC
##  [1] 0.28673732 0.90222068 0.42826622 0.73754070 0.86552149 0.90414823
##  [7] 0.75340600 0.40306787 0.05688030 0.21527692 0.83641013 0.26666650
## [13] 0.20038611 0.30979278 0.98551179 0.19881024 0.39904960 0.17845245
## [19] 0.27976597 0.39437142 0.09518894 0.51354819 0.73536761 0.53127758
## [25] 0.06071723
```

---

## Now I want to apply my `power` function to the elements in the list


```r
power(my.list)
```

```
## Error in x^pow: non-numeric argument to binary operator
```

* Ooops!

---

## `lapply` 

* “`lapply` returns a list of the same length as X, each element of which is the result of applying FUN to the corresponding element of X.”
* Give list (or vector) and `lapply` will perform the function over the elements within the list.


```r
lapply(my.list, power)
```

```
## $popA
## [1] 4.811932
## 
## $popB
## [1] 12.88558
## 
## $popC
## [1] 7.411836
```

* Note that it returns a list.

---

## `sapply` 

* "`sapply` is a user-friendly version of lapply by default returning a vector or matrix if appropriate"
* If your output has the same length you can use the `sapply` option and you will get a vector as output


```r
sapply(my.list, power)
```

```
##      popA      popB      popC 
##  4.811932 12.885584  7.411836
```

* Remember that you can give it a vector as well

---

## `vapply` 

* “`vapply` is similar to sapply, but has a pre-specified type of return value, so it can be safer (and sometimes faster) to use.”
* The syntax is a bit different: `vapply(X, FUN, FUN.VALUE, ...)` where `FUN.VALUE` is a vector with the name of the output from the function and its initial value


```r
vapply(my.list, power, c(value=0))
```

```
##      popA      popB      popC 
##  4.811932 12.885584  7.411836
```

---

## `mapply`

* What if you have two vectors that you want to feed to a function?
* Say I want to raise each value to the power of it's position in the vector
* "`mapply` is a multivariate version of sapply. mapply applies FUN to the first elements of each (…) argument, the second elements, the third elements, and so on"


```r
my.vector <- runif(10)
my.powers <- 1:10
mapply(power, x=my.vector, pow=my.powers)
```

```
##  [1] 4.171556e-01 7.897012e-01 4.681264e-01 6.333021e-01 8.812617e-01
##  [6] 1.022080e-04 1.656555e-04 3.573678e-07 4.372390e-03 5.555364e-04
```

* Note that the function goes first and then the two vectors

---

## `replicate`

* Already saw this with the X^2 distribution homework problem...


```r
chi.sq <- function(k){
	rand.chisq <- sum(rnorm(k)^2)
	return(rand.chisq)
}

values <- replicate(1000, chi.sq(k=3))
head(values)
```

```
## [1] 4.465741 4.659456 2.113572 4.509903 4.487471 2.440302
```

* Note that you need an actual function call for the second replicate arguement.

---

## Here's a problem...

* We have a table of relative abundances...


```r
relabund <- matrix(rep(runif(20000)), ncol=20, nrow=100)
relabund[5,] <- c(runif(10,0,0.4), runif(10, 0.3,0.7))
colnames(relabund) <- c(paste0("Lean", 1:10), paste0("Obese", 1:10))
rownames(relabund) <- paste0("Species", 1:100)
treatments <- c(rep("lean", 10), rep("obese", 10))

head(relabund)
```

```
##               Lean1     Lean2     Lean3     Lean4      Lean5      Lean6
## Species1 0.45992030 0.1428930 0.4322384 0.3729109 0.05659417 0.06476572
## Species2 0.03645101 0.5725126 0.9252554 0.6107523 0.11545734 0.11449512
## Species3 0.77170892 0.6552959 0.8607983 0.4644144 0.33418951 0.44612894
## Species4 0.75570539 0.7634057 0.1559501 0.5506424 0.69429557 0.84163000
## Species5 0.32899703 0.3241863 0.1874539 0.2455034 0.25689773 0.36368362
## Species6 0.47711036 0.5511257 0.6855532 0.5031633 0.06045581 0.39569183
##              Lean7     Lean8     Lean9    Lean10     Obese1    Obese2
## Species1 0.6779481 0.5738132 0.8175298 0.8428322 0.65944885 0.4919339
## Species2 0.1648704 0.7982613 0.2866036 0.7992521 0.04250725 0.6212290
## Species3 0.8140707 0.3656166 0.1883101 0.7702504 0.30776358 0.1351630
## Species4 0.5965393 0.3391652 0.8025482 0.2769966 0.49466093 0.2824831
## Species5 0.1236927 0.3888515 0.3009191 0.1555885 0.39248920 0.4272460
## Species6 0.1396910 0.2977878 0.7089633 0.7007966 0.94012800 0.6098367
##              Obese3    Obese4    Obese5    Obese6     Obese7     Obese8
## Species1 0.42922560 0.7522052 0.2156365 0.7145572 0.81468404 0.17986371
## Species2 0.03288946 0.3474433 0.4942115 0.8332294 0.55526575 0.04792325
## Species3 0.39247333 0.5468630 0.2921891 0.5850028 0.68829769 0.22548501
## Species4 0.74335846 0.9107194 0.6471540 0.6923879 0.47329088 0.28037523
## Species5 0.34735529 0.6330881 0.3266993 0.5208572 0.65454003 0.57744110
## Species6 0.94926348 0.1203434 0.8804260 0.1353925 0.03820587 0.60905916
##              Obese9   Obese10
## Species1 0.58361216 0.3560410
## Species2 0.60881250 0.9367382
## Species3 0.27749078 0.5503687
## Species4 0.09470825 0.8734746
## Species5 0.60896504 0.5688232
## Species6 0.35554762 0.6061802
```

---

## Here's a problem...

* Perform a wilcoxon test on each Species differentiating between lean and obese individuals


* Write R code, without the use of `for` loops that produces the following output:
  * Species5 was significantly different between the two groups
  * In this statement, the "Species5" should be produced by r code
  * Be sure to correct for multiple comparisons!

--- .segue .dark

## Questions?
