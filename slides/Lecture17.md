---
title       : Microbial Informatics
subtitle    : Lecture 17
date        : October 23, 2014
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
* Project 1 is due today
* Read ***The Art of R Programming*** (Chapters 6 and 7)





---

## Review
* How to design a small function from pseudocode
* Additional details about vectors and matrices

---

## Learning objectives
* Lists
* Data frames
* Tables
* Factors

---

## Lists
*	a data structure that can combine different data types (eg. numeric, vectors, strings, etc)
* useful for returning complex data structures from functions
* important for organizing data: imagine creating a list for each gene in a genome - gene name, coordinates, length, function, DNA sequence, translated sequence, a reference to experiments, etc...
* Could have a vector of lists... or a data frame...

---

## Creating a list


```r
ps <- list(name=c("Pat", "Schloss"), position="Associate Professor", time.at.um=5)
ps$name
```

```
## [1] "Pat"     "Schloss"
```

```r
ps$position
```

```
## [1] "Associate Professor"
```

```r
ps$time.at.um
```

```
## [1] 5
```

---

## Working with lists


```r
str(ps)
```

```
## List of 3
##  $ name      : chr [1:2] "Pat" "Schloss"
##  $ position  : chr "Associate Professor"
##  $ time.at.um: num 5
```

```r
length(ps)
```

```
## [1] 3
```

```r
names(ps)
```

```
## [1] "name"       "position"   "time.at.um"
```

---

## Working with lists


```r
unlist(ps)
```

```
##                 name1                 name2              position 
##                 "Pat"             "Schloss" "Associate Professor" 
##            time.at.um 
##                   "5"
```

```r
is.vector(unlist(ps))
```

```
## [1] TRUE
```

---
	
##	Accessing elements of a list
	

```r
ps$position
```

```
## [1] "Associate Professor"
```

```r
ps[["position"]]
```

```
## [1] "Associate Professor"
```

```r
ps[[2]]
```

```
## [1] "Associate Professor"
```

```r
ps[2]
```

```
## $position
## [1] "Associate Professor"
```

---
	
## Inserting things into a list


```r
ps$kids.names <- c("mary", "patrick", "joe", "john", "ruth", "jacob", "peter")
ps$kids[3]
```

```
## [1] "joe"
```

```r
ps[[4]][3]
```

```
## [1] "joe"
```

```r
ps$married <- TRUE
```

---


```r
ps
```

```
## $name
## [1] "Pat"     "Schloss"
## 
## $position
## [1] "Associate Professor"
## 
## $time.at.um
## [1] 5
## 
## $kids.names
## [1] "mary"    "patrick" "joe"     "john"    "ruth"    "jacob"   "peter"  
## 
## $married
## [1] TRUE
```

---

## Deleting elements from a list


```r
ps$position <- NULL
ps
```

```
## $name
## [1] "Pat"     "Schloss"
## 
## $time.at.um
## [1] 5
## 
## $kids.names
## [1] "mary"    "patrick" "joe"     "john"    "ruth"    "jacob"   "peter"  
## 
## $married
## [1] TRUE
```

---

##	Applying functions to a list	


```r
data <- list(x=1:10, y=100:110)
lapply(data, median)	#returns a list
```

```
## $x
## [1] 5.5
## 
## $y
## [1] 105
```

```r
sapply(data, median)	#returns a vector
```

```
##     x     y 
##   5.5 105.0
```

---	

## Working with function output


```r
x <- runif(100)
y <- c(rep("red", 50), rep("blue", 50))

t <- t.test(x~y)
str(t)
```

---


```
## List of 9
##  $ statistic  : Named num 0.105
##   ..- attr(*, "names")= chr "t"
##  $ parameter  : Named num 97.6
##   ..- attr(*, "names")= chr "df"
##  $ p.value    : num 0.916
##  $ conf.int   : atomic [1:2] -0.107 0.119
##   ..- attr(*, "conf.level")= num 0.95
##  $ estimate   : Named num [1:2] 0.471 0.465
##   ..- attr(*, "names")= chr [1:2] "mean in group blue" "mean in group red"
##  $ null.value : Named num 0
##   ..- attr(*, "names")= chr "difference in means"
##  $ alternative: chr "two.sided"
##  $ method     : chr "Welch Two Sample t-test"
##  $ data.name  : chr "x by y"
##  - attr(*, "class")= chr "htest"
```

---


```r
t$statistic
```

```
##         t 
## 0.4470755
```

```r
t$parameter
```

```
##       df 
## 97.01836
```

```r
t$p.value
```

```
## [1] 0.655817
```

```r
t$estimate
```

```
## mean in group blue  mean in group red 
##          0.4656561          0.4411594
```

---

## Data frame
- like a matrix, but each column can have a different mode
-	We saw these in the first several classes when you were looking at the metadata file
-	A data frame is really a multidimensional list

---

## Creating a data frame


```r
name <- c("Schloss", "Young" , "Mobley", "SwansonJ")
rank <- c("Asst", "Assoc", "Chair", "Full")
cool <- c(10, 1, 9, 8)
directory <- data.frame(name, rank, cool)
directory
```

```
##       name  rank cool
## 1  Schloss  Asst   10
## 2    Young Assoc    1
## 3   Mobley Chair    9
## 4 SwansonJ  Full    8
```

---

## Accessing columns of a dataframe


```r
directory[,1]
```

```
## [1] Schloss  Young    Mobley   SwansonJ
## Levels: Mobley Schloss SwansonJ Young
```

```r
directory[,"name"]
```

```
## [1] Schloss  Young    Mobley   SwansonJ
## Levels: Mobley Schloss SwansonJ Young
```

---

## Accessing rows of a dataframe


```r
directory[1,]
```

```
##      name rank cool
## 1 Schloss Asst   10
```

```r
directory[directory$name=="Schloss",]
```

```
##      name rank cool
## 1 Schloss Asst   10
```

```r
rownames(directory) <- directory$name
directory["Schloss",]
```

```
##            name rank cool
## Schloss Schloss Asst   10
```

---

## Factors
*	Vector that can contain only predefined values and is used to store categorical data.	


```r
x <- factor(c("a", "b", "b", "c", "d"))
x
```

```
## [1] a b b c d
## Levels: a b c d
```

```r
str(x)
```

```
##  Factor w/ 4 levels "a","b","c","d": 1 2 2 3 4
```

```r
levels(x)
```

```
## [1] "a" "b" "c" "d"
```

---

## Oops! have to define the values a priori


```r
x[2] <- "e"
```

```
## Warning in `[<-.factor`(`*tmp*`, 2, value = "e"): invalid factor level, NA
## generated
```

```r
x
```

```
## [1] a    <NA> b    c    d   
## Levels: a b c d
```

---

## Define the values *a priori*


```r
x <- factor(c("a", "b", "b", "c", "d"), levels=c("a", "b", "c", "d", "e"))
x
```

```
## [1] a b b c d
## Levels: a b c d e
```

```r
levels(x)
```

```
## [1] "a" "b" "c" "d" "e"
```

```r
table(x)
```

```
## x
## a b c d e 
## 1 2 1 1 0
```

---

## Notice a difference?


```r
x <- factor(c("a", "b", "b", "c", "d"), levels=c("a", "e", "b", "c", "d"))
x
```

```
## [1] a b b c d
## Levels: a e b c d
```

```r
levels(x)
```

```
## [1] "a" "e" "b" "c" "d"
```

```r
table(x)
```

```
## x
## a e b c d 
## 1 0 2 1 1
```

---
	
##	Applying functions to factors: split
* splits a vector into groups


```r
set.seed(2)
ages <- sample(20:40, 20, replace=TRUE)
gender <- factor(sample(c("Female", "Male"), 20, replace=TRUE))
pol <- factor(sample(c("D", "R", "I"), 20, replace=TRUE))
split(ages, gender)
```

```
## $Female
##  [1] 34 23 39 39 22 37 31 31 25 24 21
## 
## $Male
## [1] 23 32 29 35 23 28 37 40 29
```

---

##	Applying functions to factors: cut

* generate factors based on pre-defined bins
	

```r
range <- seq(20,40,5)
segments <- cut(ages, range)	#(20,30]: 20 < x <= 30
table(segments)
```

```
## segments
## (20,25] (25,30] (30,35] (35,40] 
##       5       7       5       2
```

---

##	Applying functions to factors: cut

* ... or let cut figure out the breaks for you


```r
segments <- cut(ages, 5)
table(segments)
```

```
## segments
##   (20,23.6] (23.6,27.2] (27.2,30.8] (30.8,34.4]   (34.4,38] 
##           1          10           2           4           3
```

---

##	Applying functions to factors: cut

* ... or make equally abundant groups


```r
range <- quantile(ages)
segments <- cut(ages, range)
table(segments)
```

```
## segments
##   (20,25] (25,26.5] (26.5,33]   (33,38] 
##         5         4         7         3
```

--- .segue .dark

## Questions?
