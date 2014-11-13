---
title       : Microbial Informatics
subtitle    : Lecture 23
date        : November 13, 2014
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
* Homework is due on November 22nd
  * work with a partner
  * no more than one explicit loop
* Will have lab period on Friday
* Read Chapters 11 in TAoRP for background material on what is discussed today



---

## Review
* String manipulation
* Understand how to work with and manipulate character variables
* Exercise from Tuesday...

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

---

## How to do it...


```r
metadata <- read.table(file="wild.metadata.txt", header=T)

fixDate <- function(m_d, year=2011){
	m.d <- unlist(strsplit(x=m_d, split="_"))
	m.d <- as.numeric(m.d)

	month <- month.name[m.d[1]]
	day <- m.d[1]
	format.date <- paste0(month, " ", day, ", ", year)
	return(format.date)
}

date <- as.character(metadata$Date)
nice.dates <- sapply(date, fixDate)
names(nice.dates) <- NULL
```

---


```
##   [1] "May 5, 2011"  "May 5, 2011"  "May 5, 2011"  "May 5, 2011" 
##   [5] "May 5, 2011"  "May 5, 2011"  "May 5, 2011"  "May 5, 2011" 
##   [9] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [13] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [17] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [21] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [25] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [29] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [33] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [37] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [41] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [45] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [49] "June 6, 2011" "June 6, 2011" "June 6, 2011" "June 6, 2011"
##  [53] "June 6, 2011" "June 6, 2011" "July 7, 2011" "July 7, 2011"
##  [57] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [61] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [65] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [69] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [73] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [77] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [81] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [85] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [89] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [93] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
##  [97] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
## [101] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
## [105] "July 7, 2011" "July 7, 2011" "July 7, 2011" "July 7, 2011"
## [109] "July 7, 2011" "July 7, 2011" "July 7, 2011"
```

---

## Learning objectives
* Making "generic" regular expressions
* "Generic" find and replace

---

## Motivational questions

> * How would you...
	* find a motif in an amino acid sequence?
	* find a gene?
	* parse a file name to see what type of file it is?
	* list a bunch of files where you don't know its name, but they have a similar format?

	
> * Regular expressions!

---

##	Repeated elements

* `+`	-	Matches preceeding character 1 or more times


```r
grep("a+", c("baa", "woof"))	
```

```
## [1] 1
```

* `?`	-	Matches preceeding character 0 or 1 time
	

```r
grep("colou?r", c("color", "colour"))
```

```
## [1] 1 2
```
	
* `*`	-	Matches preceeding character 0 or more times


```r
grep("ab*c", c("ac", "abc", "abbc", "abbbc"))
```

```
## [1] 1 2 3 4
```

---

## You can define the repeat length

* `{}`	-	Matches user defined number of times
	

```r
grep("ab{2}c", c("ac", "abc", "abbc", "abbbc"))
```

```
## [1] 3
```

* `{,}`	-	Matches user defined number of times (range)
	

```r
grep("ab{1,2}c", c("ac", "abc", "abbc", "abbbc"))
```

```
## [1] 2 3
```

```r
grep("ab{,2}c", c("ac", "abc", "abbc", "abbbc"))
```

```
## [1] 1 2 3 4
```

---

## Metacharacters

* A character with a special meaning that should not be interpreted literally
* Memorize these...
	* `.` - Any character
	* `\\d` - Any number
	* `\\w` - Any alphanumeric character
	*	`\\s`	-	Any whitespace characters (`<space>`, `\\t`, `\\n`)
	* `\\D` - Anything but a number
	* `\\W` - Any whitespace character
	* `\\S` - Any non-whitespace character

---

## `.`	-	Any character


```r
grep("A.G", c("ACG", "ATG", "ATTG"))
```

```
## [1] 1 2
```

```r
grep("A.+G", c("ACG", "ATG", "ATTG"))
```

```
## [1] 1 2 3
```


---

## `\\d`	-	Any number
	

```r
grep("\\d", c("ATG", "123"))
```

```
## [1] 2
```

---

## `\\w` -	Any alphanumeric character


```r
grep("\\w", c("ATG", "123"))
```

```
## [1] 1 2
```

---

## `\\s`	-	Whitespace characters
	

```r
grep("\\s", c("A G", "ATG"))
```

```
## [1] 1
```

---

## Opposites

* ``\\D``	-	Any non-numeric characters
	

```r
grep("\\D", c("ATG", "123"))
```

```
## [1] 1
```

* `\\W`	-	Any non-alphanumeric characters
	

```r
grep("\\W", c("ATG", "123"))
```

```
## integer(0)
```

*	`\\S`	-	Any non-space characters


```r
grep("\\S", c("A G", "ATG"))	#why does this come up as 1,2?
```

```
## [1] 1 2
```

---

## How to search for a quantifier?

* `\\` -	When used to precede a quantifier or metacharacter, it expresses that character
	

```r
grep("\\+", c("2+2", "2-2", "2.2"))
```

```
## [1] 1
```

```r
grep("\\.", c("2+2", "2-2", "2.2"))
```

```
## [1] 3
```


```r
grep("\\(\\d{3}\\)\\d{3}-\\d{4}", "(734)867-5301")
```

```
## [1] 1
```

---

## Define your own metacharacters!

*	`[]` -	Match any of the characters in the brackets
	

```r
grep("[ATGCU]", c("ATG", "123"))
```

```
## [1] 1
```

```r
grep("[AG2]", c("ATG", "123"))
```

```
## [1] 1 2
```

---

## Define your own metacharacters 

* `[-]` - Match any of the characters including & between them...
	

```r
grep("[a-z]",  c("ATG", "123"))
```

```
## integer(0)
```

```r
grep("[a-zA-Z]",  c("ATG", "123"))
```

```
## [1] 1
```

```r
grep("[a-zA-Z0-9]",  c("ATG", "123"))
```

```
## [1] 1 2
```

---

## Be exclusive...

* `[^]` -	Don't match any of the characters in the brackets...


```r
grep("[^AGTC]", c("ATG", "123"))
```

```
## [1] 2
```

```r
grep("[^NU]", c("ATG", "AUG", "ANN"))
```

```
## [1] 1 2 3
```

---

## Replacements with `sub`/`gsub`
	
* Within the pattern you can use parentheses to identify sub-patterns that you 
	manipulate in the replacement
	

```r
gsub("ATG(CAG)", "AAA\\1", "ATGCAG")
```

```
## [1] "AAACAG"
```

```r
gsub("(ATG)(CAG)", "\\1AAA\\2", "ATGCAG")
```

```
## [1] "ATGAAACAG"
```

```r
gsub("(A.G)(C.G)", "\\1AAA\\2", c("ATGCAG","AAGCTG"))
```

```
## [1] "ATGAAACAG" "AAGAAACTG"
```

---

## Let's go back to that example from Tuesday...


```r
metadata <- read.table(file="wild.metadata.txt", header=T)

fixDate <- function(m_d, year=2011){
	m.d <- unlist(strsplit(x=m_d, split="_"))
	m.d <- as.numeric(m.d)

	month <- month.name[m.d[1]]
	day <- m.d[1]
	format.date <- paste0(month, " ", day, ", ", year)
	return(format.date)
}

date <- as.character(metadata$Date)
nice.dates <- sapply(date, fixDate)
names(nice.dates) <- NULL
```

* What could we do differently now?

---

## New and improved date converter


```r
month <- as.numeric(gsub("^(\\d+)_\\d+", "\\1", metadata$Date))
day <- gsub("^\\d+_(\\d+)", "\\1", metadata$Date)
year <- "2011"
paste0(month.name[month], " ", day, ", ", year)
```

```
##   [1] "May 25, 2011"  "May 25, 2011"  "May 26, 2011"  "May 26, 2011" 
##   [5] "May 31, 2011"  "May 31, 2011"  "May 31, 2011"  "May 31, 2011" 
##   [9] "June 14, 2011" "June 14, 2011" "June 15, 2011" "June 15, 2011"
##  [13] "June 15, 2011" "June 15, 2011" "June 15, 2011" "June 15, 2011"
##  [17] "June 15, 2011" "June 15, 2011" "June 15, 2011" "June 15, 2011"
##  [21] "June 16, 2011" "June 16, 2011" "June 16, 2011" "June 16, 2011"
##  [25] "June 16, 2011" "June 16, 2011" "June 17, 2011" "June 17, 2011"
##  [29] "June 17, 2011" "June 1, 2011"  "June 1, 2011"  "June 1, 2011" 
##  [33] "June 29, 2011" "June 29, 2011" "June 29, 2011" "June 29, 2011"
##  [37] "June 29, 2011" "June 29, 2011" "June 29, 2011" "June 2, 2011" 
##  [41] "June 2, 2011"  "June 2, 2011"  "June 2, 2011"  "June 30, 2011"
##  [45] "June 30, 2011" "June 30, 2011" "June 30, 2011" "June 30, 2011"
##  [49] "June 30, 2011" "June 5, 2011"  "June 5, 2011"  "June 5, 2011" 
##  [53] "June 5, 2011"  "June 5, 2011"  "July 13, 2011" "July 13, 2011"
##  [57] "July 13, 2011" "July 13, 2011" "July 13, 2011" "July 13, 2011"
##  [61] "July 13, 2011" "July 13, 2011" "July 13, 2011" "July 13, 2011"
##  [65] "July 13, 2011" "July 13, 2011" "July 14, 2011" "July 14, 2011"
##  [69] "July 14, 2011" "July 14, 2011" "July 14, 2011" "July 14, 2011"
##  [73] "July 14, 2011" "July 14, 2011" "July 14, 2011" "July 14, 2011"
##  [77] "July 14, 2011" "July 14, 2011" "July 14, 2011" "July 14, 2011"
##  [81] "July 14, 2011" "July 14, 2011" "July 14, 2011" "July 14, 2011"
##  [85] "July 14, 2011" "July 14, 2011" "July 14, 2011" "July 14, 2011"
##  [89] "July 14, 2011" "July 2, 2011"  "July 2, 2011"  "July 2, 2011" 
##  [93] "July 2, 2011"  "July 2, 2011"  "July 2, 2011"  "July 2, 2011" 
##  [97] "July 2, 2011"  "July 2, 2011"  "July 2, 2011"  "July 2, 2011" 
## [101] "July 2, 2011"  "July 3, 2011"  "July 3, 2011"  "July 3, 2011" 
## [105] "July 3, 2011"  "July 3, 2011"  "July 3, 2011"  "July 3, 2011" 
## [109] "July 3, 2011"  "July 3, 2011"  "July 3, 2011"
```

---

## How would you write a pattern to...

* find a motif in an amino acid sequence?
* find a gene?
* parse a file name to see what type of file it is?
* list a bunch of files where you don't know its name, but they have a similar format?




--- .segue .dark

## Questions?

