--- 
title       : Microbial Informatics
subtitle    : Lecture 04
date        : September 12, 2014
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
* No class on Thursday (9/18) or Friday (9/19).

--- 

## Review
> * Comments
 * Use your varible names as comments
 * Comment your code with # (console) or ## (knitr)
> * Variables hold information
 * **Numeric/double/integer:** counts of things, measurements
 * **Characters/strings:** DNA sequence, amino acids, names
 * **Logical:** is something true or not
 * **Functions:** more complex...

---

## Learning objectives
* Review different data types
* Learn how to create and manipulate vectors

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
x & y           # bitwise AND operator (vectors)
x || y          # OR operator
x | y			# bitwise OR operator (vectors)
x == y          # is equal operator
x != y          # is not equal operator
```

* Logical variables will be very useful when selecting subsets of data to work with

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

##	Converting


```r
as.numeric(x)
as.logical(x)
as.character(x)
```

* There are other conversions that can be done. How would you figure out which converters are out there?
* Be sure to understand the "side effects" of the conversions

---

## Types of containers
* Vectors
* List
* Matrix
* Table
* Data table
* Factors
*	We will go through these more in detail throughout the course and especially in second half of the course

---

##	Vectors

* One-dimensional sets of values of the same type
* Everything in R is some form of a vector
* You can read in vectors from a file or create them on the fly.  Four common ways of creating a vector include using `c()`, `:`, `rep()`, `seq()`.  Here are several examples:


```r
19:55                   # list the values from 19 to 55 by ones
c(1,2,3,4)              # concatenate 1, 2, 3, 4, 5 into a vector
rep("red", 5)           # repeat "red" five times
seq(1,10,by=3)          # list the values from 1 to 10 by 3's
seq(1,10,length.out=20) # list 20 evenly spaced elements from 1 to 10
seq(1,10,len=20)        # same thing; arguments of any function can be 
c(rep("red", 5), rep("white", 5), rep("blue", 5))
rep(c(0,1), 10)
countToTen <- 1:10
```


---

## Operations act on vectors


```r
countToTen <- 1:10
length(countToTen)
countToTen
countToTen^2
countToTen > 5
typeof(countToTen)
is.vector(countToTen)  
```

---

## Indexing into vectors
* Note that in contrast to many programming languages, vectors in R are indexed such that the first value is 1 NOT 0.

	

```r
code <- c("A", "T", "G", "C")

code[2]				# get the second element
code[0]				# errr...
code[-1]			# remove the first element
code[c(1,2)]		# get the first and second elements
code[code > "M"]	# get any element greater than "M"
```

* What does this do?


```r
code[length(code)]
```

---

## Defining a vector


```r
z <- numeric(5)			#	This creates a numerical vector with 5 zeros
z[3] <- 10
z
z[1:3] <- 5
z
z[10] <- pi				#	NA's are inserted between 5 and 9
z[4] <- "R rocks!"		#	everything changes to a character

t <- character(5)
t[4] <- "DNA rocks!"
```

---

## Indexing by characters

* You can also create vectors that are indexed by character strings
* In some programming languages these are called hash-maps or look-up tables.


```r
v <- numeric(0)
v["A"] <- 1.23498
v["T"] <- 2.2342
v["C"] <- 3
v["G"] <- 4
v["A"]
v[["A"]]      # strips the name associated with value 1

v2 <- c(A=1.23498,T=2.2342,C=3,G=4)
```

---

## Naming cells in your vectors


```r
names(v)
names(v) <- c("A", "B", "C", "D")
names(v) <- NULL  # this removes names attribute
```

---

## Sorting vectors


```r
z <- runif(10)  #generates a vector with 10 random numbers in it
z
sort(z)	#sort the vector
order(z)	#get the correct order of the elements in the vector

#sort a vector, matrix, data frame using the order command
o <- order(z)
z[o]
```

---

## For Tuesday
* Start working on new assignment that will be posted this weekend
* Read ***Introduction to Statistics with R*** (Chapters 1 and 2)


--- .segue .dark

## Questions?

