---
title       : Microbial Informatics
subtitle    : Lecture 18
date        : October 28, 2014
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
* We will not be meeting on Friday
* Read ***The Art of R Programming*** (Chapter 7)



---

## Review
* Lists
* Data frames
* Factors

---

## Learning objectives

* Understand how to direct flow through a program using loops and conditionals

---

## Control statements
*	Much of what we've been doing so far follows a very linear path.  "Do this,
	then that, and then do this."  In more complicated programs, you will want  
	the program to have some intelligence and make decisions.  That is where
	control statements come in to play.
*	Today we'll discuss two forms of control statements:
	- loops
	- conditionals

---

## Loops
*	Recall that many things can be vectorized within R.  So while you could 
	write a loop to calcualte the square root of every number between 1 and 100,
	it's far more efficient to create a vector and run sqrt on the vector.
* There are a set of "apply" functions that we'll cover later that largely allow
  us to eliminate the need for explicit loops	

---

## `for` loops over a range of variables...


```r
for(i in 1:10){
#	do something clever
}
```

* This is essentially saying we'll do something with i=1, then repeat it with i=2, ... i=10.  Then we'll stop.
* *i* is called an index varaible and can be a number or string.  the numbers need not be sequential think of indexing over different start codon positions in a genome or indexing over all possible codons
* Recall that `1:10` is a vector

---

## `for` loops over a vector...


```r
x <- seq(2,100,2)
for(i in x){
#	do something clever...
}
```

or


```r
x <- c("red", "green", "blue")
for(i in x){
#	do something clever...
}
```

---

## What if you want to count down?


```r
for(i in 10:1){
	i
}
print("blast off!")
```

```
## [1] "blast off!"
```

Hmmm. What went wrong?

---

## What if you want to count down?

Within a loop (or any function) you have to explicitly tell R to output the value of a variable


```r
for(i in 10:1){
	print(i)
}
print("blast off!")
```

```
## [1] 10
## [1] 9
## [1] 8
## [1] 7
## [1] 6
## [1] 5
## [1] 4
## [1] 3
## [1] 2
## [1] 1
## [1] "blast off!"
```


---

## What if we want to save each step to a vector?


```r
for(i in 1:10){
	squares[i] <- i^2
}
```

```
## Error in squares[i] <- i^2: object 'squares' not found
```

```r
squares
```

```
## Error in eval(expr, envir, enclos): object 'squares' not found
```

What's wrong?

---

## What if we want to save each step to a vector?

Have to create vector before starting loop:


```r
squares <- vector()
for(i in 1:10){
	squares[i] <- i^2
}
squares
```

```
##  [1]   1   4   9  16  25  36  49  64  81 100
```

---

## A better practice

Have to create vector before starting loop:


```r
squares <- rep(NA, 10)
#squares <- rep(0, 10)
for(i in 1:9){
	squares[i] <- i^2
}
squares
```

```
##  [1]  1  4  9 16 25 36 49 64 81 NA
```

---

## Can you spot the difference?


```r
	x<-c(5,12,13)
	for(i in x)	{	print(x^2)	}
	for(i in x)	{	print(i^2)	}
```

---

## Can you spot the difference?


```r
	x<-c(5,12,13)
	for(i in x)	{	print(x^2)	}
```

```
## [1]  25 144 169
## [1]  25 144 169
## [1]  25 144 169
```

```r
	for(i in x)	{	print(i^2)	}
```

```
## [1] 25
## [1] 144
## [1] 169
```

---

## `while` loops...


```r
i<-1
while(i <= 10){
	print(i)
}
```

Notice anything wrong with this statement?

---

## `while` loops

You have to modify the index within the loop because `i` will always be less than or equal to 10:


```r
i<-1
while(i <= 10){
	i<-i+3
	print(i)
}
```

---

## `break`-ing while loops

* The `break` command breaks you out of the current loop
* Can be used with `for` and `repeat` loops


```r
x<-0;
while(TRUE){
  x<-rnorm(1);
  print(x)
  if(x<0){	break	}
}
```

---
	
## `repeat` loops...


```r
x<-0;
repeat {
  x<-rnorm(1);
  print(x)
  if(x<0){	break	}
}
```

```
## [1] 1.258434
## [1] 0.1496421
## [1] -0.6827691
```

--- &twocol

##	`next`...

* the next command allows us to skip the remainder of the iteration and return
	to the top of the loop block...
	
*** {name: left}

```r
counter <- 0
while(counter < 10){
	x<-rnorm(1);
	if(x<0){	next	}
	print(x)
	counter <- counter+1
}
```

*** {name: right}

```
## [1] 0.3141362
## [1] 0.4966642
## [1] 0.9285402
## [1] 2.262056
## [1] 0.3757543
## [1] 1.150501
## [1] 0.09672476
## [1] 1.104058
## [1] 1.085318
## [1] 0.5036225
```

---

## Why should you avoid loops?
*	R objects are immutable / unchangeable.
* To assign a value to a variable, R operations reassign values to given objects
* To do this they have to come up with new space in RAM to store information
*	Recall the following...


```r
	squared[i] <- i^2
```

---

## Looking under the hood...

*	The `i^2` clearly costs some unit of time, but look at the "squared[i] <-" part.
* Each cycle through the loop is doing this


```r
	squared <- "[<-"(squared,i,value=i^2)
```

* The `<-` part is a function!

---

## In this statement...
*	A copy of `squared` is being made, element `i` is changed to `i^2`
	and the resulting vector is reassigned to `squared`.  The end result is to
	re-assign the entire vector because you changed one value.
* When you vectorize an operation you are really removing a number of these steps. Consider this:


```r
squared <- (1:10)^2
```

* There is only one assignment operation

---

## Conditionals

*	We've already seen conditionals throughout the course when we filtered the `metadata` table
* Sometimes we'd like to have a program bifurcate at a given step based on user input or the behavior of the data.
* For example, if a start and stop codon are less than 300 bp apart, then we'll ignore it. Otherwise, let's translate it to amino acids


---

## `ifelse`

* Familiar with `ifelse` from Excel? It's the same in R...


```r
ifelse(LOGICALTEST, Do this if TRUE, Do this if FALSE)
```

* An example:


```r
x <- seq(1, 100, 5)
ifelse(x>40, "old", "young")
```

```
##  [1] "young" "young" "young" "young" "young" "young" "young" "young"
##  [9] "old"   "old"   "old"   "old"   "old"   "old"   "old"   "old"  
## [17] "old"   "old"   "old"   "old"
```

---

## Building longer and longer ifelse statements can be tedious...
	

```r
x <- seq(1, 100, 5)
ifelse(x<10, "kid", ifelse(x<20, "adolscent", "adult"))
```

```
##  [1] "kid"       "kid"       "adolscent" "adolscent" "adult"    
##  [6] "adult"     "adult"     "adult"     "adult"     "adult"    
## [11] "adult"     "adult"     "adult"     "adult"     "adult"    
## [16] "adult"     "adult"     "adult"     "adult"     "adult"
```

---

## Alternatively: `if... else if...else`	


```r
for(age in x){
		if(age < 10){		#age has to be an atomic varaible
			print("kid")
		} else if(age<20) {
			print("adolescent")
		} else {
			print("ancient")
		}
	}
```

```
## [1] "kid"
## [1] "kid"
## [1] "adolescent"
## [1] "adolescent"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
## [1] "ancient"
```

--- .segue .dark

## Questions?
