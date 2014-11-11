---
title       : Microbial Informatics
subtitle    : Lecture 22
date        : November 11, 2014
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
* A new homework has been posted and is due on November 22nd
  * work with a partner
  * no more than one explicit loop
* Will have lab period on Friday
* Read Chapters 11 in TAoRP for background material on what is discussed today



---

## Review
* String manipulation
* Understand how to work with and manipulate character variables
* What do the following do?


```r
rev("abcdef")
paste(rev(unlist(strsplit("abcdef", ""))), collapse="")
```

---

## Learning objectives
* Finish discussing how to format output



---

## Formatting text output with `sprintf`


```r
i <- 8
sprintf("the square of %d is %d", i, i^2)
```

```
## [1] "the square of 8 is 64"
```

```r
sprintf("the square root of %d is %6.2f", i, sqrt(i))
```

```
## [1] "the square root of 8 is   2.83"
```

```r
sprintf("%d times 1e6 is %.3e", i, i * 1e6)
```

```
## [1] "8 times 1e6 is 8.000e+06"
```

---

## Things to notice

* `%s` reserves the place for an string
* `%d` reserves the place for an integer
* `%f` reserves the place for an decimal number
* `%e` reserves the place for an number in scientific notation
* For `%f` and `%e` the format is `%m.n`. `n` indicates the number of values to the right of the decimal place to include and `m` indicates the total number of spaces to allot the string
* The output is a string
* Of course, you can do all of this in the text block of a knitr document

---

## Another useful way to format output to text


```r
format(x, trim = FALSE, digits = NULL, nsmall = 0L,
       justify = c("left", "right", "centre", "none"),
       width = NULL, na.encode = TRUE, scientific = NA,
       big.mark = "",   big.interval = 3L,
       small.mark = "", small.interval = 5L,
       decimal.mark = ".", zero.print = NULL,
       drop0trailing = FALSE, ...)`
```

* `x` is a number
* `trim` is whether to right justify numbers to a common width
* `digits` is the maximum number of significant digits
* `nsmall` is the minimum number of digits to the right of the decimal 

---

## Special vectors


```r
letters[1:5]
```

```
## [1] "a" "b" "c" "d" "e"
```

```r
LETTERS[1:5]
```

```
## [1] "A" "B" "C" "D" "E"
```

---

## Special functions to manipulate character vectors


```r
toupper(letters[1:5])
```

```
## [1] "A" "B" "C" "D" "E"
```

```r
tolower(LETTERS[1:5])
```

```
## [1] "a" "b" "c" "d" "e"
```

---

## Searching for sub-strings

*	`grep(pattern, x)` - "Get Regular ExPression"


```r
grep("A", c("ATA", "CCC", "CTA"))
```

```
## [1] 1 3
```

```r
grep("G", c("ATA", "CCC", "CTA"))
```

```
## integer(0)
```

* `grep` tells you which elements of x have the pattern

---

## Searching for sub-strings

*	`grepl(pattern, x)` - "Get Regular ExPression" logic-based


```r
grep("A", c("ATA", "CCC", "CTA"))
```

```
## [1] 1 3
```

```r
grep("G", c("ATA", "CCC", "CTA"))
```

```
## integer(0)
```

* `grepl` tells you whether or not each element of x ahs the pattern

---

## Where in the string does the pattern match?

*	`regexpr(pattern, x)` - identify the starting position of the pattern in x


```r
regexpr("ATG", "CTATGCATGC")
```

```
## [1] 3
## attr(,"match.length")
## [1] 3
## attr(,"useBytes")
## [1] TRUE
```

---

## But what if the pattern appears multiple times?

*	`gregexpr(pattern, x)` - 	identify the starting position of the pattern throughout x ~ global


```r
gregexpr("ATG", "CTATGCATGC")
```

```
## [[1]]
## [1] 3 7
## attr(,"match.length")
## [1] 3 3
## attr(,"useBytes")
## [1] TRUE
```

---

## Find and replace

*	`sub(pattern, replacement, x)` - SUBstitute the PATTERN with the REPLACEMENT


```r
sub("T", "U", "CTATGCATGC")
```

```
## [1] "CUATGCATGC"
```

* Notice anything odd? What command do you think would fix this?

---

## A global find and replace

*	`gsub(pattern, replacement, x)` - replaces all instances


```r
gsub("T", "U", "CTATGCATGC")
```

```
## [1] "CUAUGCAUGC"
```

---

## How would you get the complement of a DNA sequence using `gsub`?


```r
dna <- "CTATGCATGC"
```


The complement should be GATACGTACG

---

## A specialized find and replace

* `chartr(findChars, replaceChars, x)`


```r
chartr("T", "A", "CTATGCATGC")
```

```
## [1] "CAAAGCAAGC"
```

```r
chartr("TA", "AT", "CTATGCATGC")
```

```
## [1] "CATAGCTAGC"
```

```r
chartr("TACG", "ATGC", "CTATGCATGC")
```

```
## [1] "GATACGTACG"
```

---

## Getting a bit more sophisticated

*	Ignoring the case of the text
	

```r
grep("g", "ATGCATGC")
```

```
## integer(0)
```

```r
grep("g", "ATGCATGC", ignore.case=T)
```

```
## [1] 1
```

---

## Getting a bit more sophisticated

*	Location
	- ^	-	Beginning of a string
	- $	-	End of a string
	

```r
grep("^ATG", vectorOfGenes)
grep("TAA$", vectorOfGenes)
```

---

## Combining searches

*	|	-	Matches with either the expression before or after the pipe


```r
grep("TAA$|TAG$", vectorOfGenes)
```

---

## Let's revisit the metadata file


```r
metadata <- read.table(file="wild.metadata.txt", header=T)
head(metadata)
```

```
##     Group Date ET Station  SP Sex Age Repro Weight Ear
## 1  5_25m3 5_25  3    BB18  PL   M   J   ABD    7.5  13
## 2  5_25m4 5_25  4     K19  PL   M   A   SCR   16.0  15
## 3  5_26m1 5_26  1     A12  PL   F   A    NE   19.5  14
## 4  5_26m9 5_26  9      M9  PL   F   A    NE   25.0  13
## 5 5_31m11 5_31 11      F2 PMG   F   J    NT   16.0  18
## 6  5_31m2 5_31  2     CC4  PL   M  SA   ABD   15.0  14
```

* The `Date` column is the date that the mice were captured in `M_DD` format. Can you convert this column into "Month Day, Year" format? Assume the year was 2011.

--- .segue .dark

## Questions?
