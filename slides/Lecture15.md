--- 
title       : Microbial Informatics
subtitle    : Lecture 15
date        : October 6, 2014
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
* Project 1 is due on the 24th
* The first hour of tomorrow's class will be a lecture
* No class on Tuesday (stud section)
* Read ***The Art of R Programming*** (Chapters 2 and 3)





---

## Review


---

## Learning objectives

---

## Motivation  

*	Imagine you need to calculate dilutions for a 96-well plate so that you have 10 ng / ul DNA solutions.
	-	Is it best to do each calculation on a calculator?
	-	What might go wrong?
	-	Most of you would likely use an Excel spreadsheet with a lot of copying and pasting of equations
	-	Now what if one of your labmates would like to do the same calculations?
* What are the tedious, error prone activities you do in the lab?

---

##	Possible areas where you and your lab might find a program useful...
-	Generating a graph - automation
-	Processing data from 96 well plates
	*	ELISAs
	*	growth curves
-	Primer design
-	Assessing DNA sequence quality
-	Non-standard statistical analysis
-	Simulations
-	Simple tasks but with a ton of data (determine the GC content of a genome)

---

##	Programming in science is important for several reasons...
-	Calculations can be complicated/difficult and easy to screw up
-	Program encapsulate functionality that can be easily repeated and transferred
-	With proper documentation it is easy for others to see what format the data need to be in and understand what is going on.  Think of the t.test function...

--- 

## Going forward

*	The remainder of the semester will address more advanced concepts that are necessary for programming within R and that can be easily transferred to other programming languages.
* Each of these concepts has parallels in other languages.

---

## Programming with R
*	R is a high level programming language
	-	To sum a vector of numbers you can just use the "sum" command
	-	In other languages you'd have to use a for loop
	-	This is good and bad.  Good because it's easier to program, bad because it can make the same code slower in R than the other languages
*	The two most significant tools you can make use of, regardless of the programming language, are pseudocode and comments.

---

##	Pseudocode
- informal description of how a program or component of a program will function.  It is designed for human to read, not the computer
-	It is a good practice to first write the pseudocode and then the R syntax
-	Think of it as you would an outline for a manuscript you are writing

---

##	Comments
- In R, a comment is indicated with a # sign
-	Never too many comments, difficult to remember what you meant in your code a month later or for someone else to read your mind
-	Helpful to indicate what is going on at each step, indicate inputs, outputs, defaults
-	Can put #'s at the beginning of each line in your pseudocode and then fill in the actual code

---

## An exercise

Imagine you have a bacterial genome and you want to find all of the open reading frames (ORFs).  What might the pseudocode look like?

> 1.	Get a list of all of the start and stop codons in all frames
> 2.	Determine which frame each codon belongs to
> 3.	For every start codon determine the length of the putative gene
> 4.	Apply some minimum length criteria
> 5.	Select the putative ORFs that are long and non-overlapping
> 6.	Output:	ORF coordinates, DNA sequence, translated protein sequence

---

## Translating pseudocode

*	You can then take each of these steps and make the pseudocode more specific (indenting is helpful)...
*  Get a list of all of the start and stop codons in all six frames.

```
for position in the genome
	codon = that base plus the next two bases
	if codon == "ATG" then save that position as a start codon
	if codon == "TAG", "TAA", or "TGA" then save that position as a stop codon

return list of start and stop codon positions
```

---

##	There are many ways that you could do this
-	For example, you could find all the start/stop codons in the +1 frame, +2, etc. instead of finding the frame after you find the start stop codons
-	Choice is a matter of...
	-	style
	-	complexity
	-	speed 
	-	memory requirement

---

##	As you plan your pseudocode, you might start to realize that you have some choices
-	Alternate start codons?
-	Minimum ORF length
-	Allow overlap in ORFs
-	Sequence complexity
-	etc...

---

##	Functions
-	The code you've written so far has been to put everythign in one file in a stream of consciousness format
-	Problems with this approach...
	-	Repeated code
	-	Bad organization
	-	Difficult to debug

---

##	Functions
-	Functions allow us to encapsulate specific tasks.
-	Ideally, each function only does one thing (e.g. sum, mean, etc)
-	Advantage being that if a new algorithm came up to calcualte the mean then you would just change that section of code instead of that code throughout the manuscript

---

## Basic syntax

```
myFunction <- function(arguements){
	# insert special sauce
}
myFunction()
```

* The function returns the last command entered
* Usually want to use `return` function to be safe

```
myFunction <- function(arguements){
	# insert special sauce
	return(output)
}
myFunction()
```


---

## Evolution of a function in R



```r
x <- 1:10

sum.squared <- function(x){
	squared <- x^2
	sum.sq <- sum(squared)
	return(sum.sq)
}

sum.squared(x)
```

```
## [1] 385
```

---

## Evolution of a function in R


```r
sum.squared <- function(x){
	sum.sq <- sum(x^2)
	return(sum.sq)
}

sum.squared(x)
```

```
## [1] 385
```


---

## Evolution of a function in R


```r
sum.squared <- function(x){
	return(sum(x^2))
}

sum.squared(x)
```

```
## [1] 385
```

---

## Evolution of a function in R


```r
sum.squared <- function(x){
	sum(x^2)
}
sum.squared(x)
```

```
## [1] 385
```

---

## Evolution of a function in R


```r
sum.squared <- function(x) sum(x^2)
sum.squared(x)
```

```
## [1] 385
```

---

## Evolution of a function in R


```r
sum(x^2)
```

```
## [1] 385
```

---

## Evolution of a function in R

* Consider where you want to be on this continuum from a three line function to no function at all.
* Readability
* Maintainability
* Ability to expand features

---

## Output...
*	Either the result of the return command or the last variable that is created
*	Think about... this example only returns a single value.  How would you get back more complex data like the summary command does?

---

## Default inputs:


```r
sum.squared <- function(x, mu=0){
	sum((x-mu)^2)
}
sum.squared(x)
```

```
## [1] 385
```

```r
sum.squared(x, 3)
```

```
## [1] 145
```

---

## Scope...

* Variables only exist within the braces


```r
sum.squared <- function(x){
	sum.sq <- sum(x^2)
}
sum.squared(c(1,2,3))
```

* Where is the output???


```r
sum.sq
```

```
## Error: object 'sum.sq' not found
```

---

## Exercise: ChiSquared distribution revisited

*	The distribution of a sum of the squares of k indepdentently sampled normal random variables, where k is the degrees of freedom
* Procedure to create an empirical distribution
    1.	Draw k random variables from a normal distribution with mean 0.0 and standard deviation of 1.0
    2.	Square each of them
    3.  Sum them
    4.	Repeat many times and keep track of how many times you see each value
* Interested in the proportion of the distribution larger than our test statistic

--- .segue .dark

## Questions?
