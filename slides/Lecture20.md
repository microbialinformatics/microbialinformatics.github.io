---
title       : Microbial Informatics
subtitle    : Lecture 20
date        : November 4, 2014
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



---

## Review
* Loops are slow in R beacuase variables are copied, destroyed, and recreated each time a vector is modified
* the apply and replicate suite of commands allow you to minimize your use of explicit loops

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
##              Lean1      Lean2      Lean3      Lean4     Lean5     Lean6
## Species1 0.7320719 0.61367991 0.44710369 0.93737694 0.1545328 0.7581348
## Species2 0.1587366 0.29431957 0.18656555 0.40873243 0.1751768 0.9519493
## Species3 0.7459371 0.14643946 0.37502507 0.83650445 0.2839269 0.3636480
## Species4 0.2116673 0.03895666 0.66441798 0.09118599 0.2525140 0.8759450
## Species5 0.2533841 0.09087869 0.04734376 0.01431301 0.2551368 0.2670180
## Species6 0.7963445 0.57078249 0.90997548 0.38780057 0.8780423 0.2803217
##               Lean7      Lean8      Lean9     Lean10     Obese1    Obese2
## Species1 0.48390810 0.09841650 0.37743814 0.84738340 0.68320363 0.3305247
## Species2 0.10043277 0.05339326 0.64165944 0.39090620 0.61785717 0.2844650
## Species3 0.02560588 0.63525609 0.02907226 0.08486640 0.03923239 0.8935477
## Species4 0.69394501 0.74943690 0.42591778 0.53587751 0.87731287 0.1407579
## Species5 0.12074160 0.12838108 0.08421323 0.08451048 0.67639246 0.3258745
## Species6 0.72716501 0.82467974 0.69858696 0.77484355 0.47065886 0.5433217
##             Obese3     Obese4     Obese5    Obese6    Obese7    Obese8
## Species1 0.7718421 0.02277831 0.89896404 0.2127805 0.1474924 0.8126880
## Species2 0.6259197 0.43031531 0.88595164 0.4238480 0.3491638 0.7818655
## Species3 0.7366177 0.16466986 0.38247831 0.3801840 0.9368757 0.5069368
## Species4 0.9165949 0.99351859 0.25953107 0.4532728 0.9596510 0.4002479
## Species5 0.6271704 0.34291623 0.57269919 0.5209073 0.6038838 0.6461251
## Species6 0.8557418 0.04982476 0.02552185 0.8431182 0.5089379 0.3121548
##             Obese9    Obese10
## Species1 0.5373861 0.02844547
## Species2 0.3988145 0.45445103
## Species3 0.4414108 0.49137888
## Species4 0.1843113 0.76326338
## Species5 0.3180390 0.52756064
## Species6 0.8503138 0.22655002
```

---

## Here's a problem...

* Perform a wilcoxon test on each Species differentiating between lean and obese individuals


* Write R code, without the use of `for` loops that produces the following output:
  * Species5 was significantly different between the two groups
  * In this statement, the "Species5" should be produced by r code
  * Be sure to correct for multiple comparisons!

---

## Here's a problem...

* Perform a wilcoxon test on each Species differentiating between lean and obese individuals


```r
test <- function(x, design){
	p <- wilcox.test(x~design)$p.value
	return(p)
}

p.values <- apply(relabund, 1, test, design=treatments)
padj.values <- p.adjust(p.values)
```

---

## Here's a problem...
* Write R code, without the use of `for` loops that produces the following output:
  * `Species5` was significantly different between the two groups
  * `rownames(relabund)[padj.values<0.05]` was significantly different between the two groups
  * In this statement, the "`Species5`" should be produced by r code
  * In this statement, the "`rownames(relabund)[padj.values<0.05]`" should be produced by r code
* Be sure to correct for multiple comparisons!


---

## Learning objectives

* Understand how to get data in and out of R


---

## Integrating with other software

* **Problem:** We typically have large datasets and need a way to get that
information into the program.  Similarly, we generally have large
amounts of output that we can't just send to the screen.
			
* **Solution:**	We have seen a number of functions already for reading in data and
			in the very first homework you had a function to write out a table.
			R has a number of solutions to do both

---

## `readline`: read a single line from the screen

```
	> readline()
	ab de fg
	[1] "ab de fg"
	
	> readline("enter your name: ")
	Pat Schloss
	 
	> name <- readline("enter your name: ")
	Pat Schloss
	> name
	[1] "Pat Schloss"
```

---

## `scan`: reads in a vector from a file or keyboard

* Imagine a file that contains:

```
	123
	2 4 5
	53
```


```r
scan("file1.txt")
```

```
## [1] 123   2   4   5  53
```
	
* Note that it reads it in as a numeric vector


---
	
## `scan`: reads in a vector from a file or keyboard

* Now imagine a file that contains:

```
	123
	abcd
	2 4 5
	54
```


```r
scan("file2.txt")
```

```
## Error in scan(file, what, nmax, sep, dec, quote, skip, nlines, na.strings, : scan() expected 'a real', got 'abcd'
```

---

## Try again...


```r
scan("file2.txt", what="")
```

```
## [1] "123"  "abcd" "2"    "4"    "5"    "54"
```

* the default is to assume everything is a number

---

## Delimeters

* scan reads things into a vector assuming that any white space separates
	the vector values
	

```r
scan("file2.txt", what="", sep="\n")
```

```
## [1] "123"   "abcd"  "2 4 5" "54"
```

---

## Getting data from the keyboard

```
	> scan("")	#will read from the keyboard
	
	>scan("")
	1:  12 5 2 3
	5:  23 24
	6:
	Read 6 items
	[1] 12  5  2  3 23 24
```

* Note that to stop reading data in you give it a blank line


---

## `read.table`
* Reading in a table, every row has to have the same number of columns
*	Imagine a file that contains:

```
name	age sex
pat		36	M
john	22	M
susan	55	F
```


```r
read.table("table.txt", header=TRUE)
```

```
##    name age sex
## 1   pat  36   M
## 2  john  22   M
## 3 susan  55   F
```

---

## `read.table`
* We'd like to get row names for our table


```r
read.table("table.txt", header=TRUE, row.names=1)
```

```
##       age sex
## pat    36   M
## john   22   M
## susan  55   F
```

*	note that these commands would not have worked with the scan function since it is a mixture of text and numbers
* numerous other options for read.table including skipping rows, different delimeters, etc.

---

## You can read from the internet


```r
data <- read.csv("http://archive.ics.uci.edu/ml/machine-learning-databases/echocardiogram/echocardiogram.data", 
    header = F)
head(data)
```

```
##   V1 V2 V3 V4    V5     V6    V7 V8    V9   V10  V11 V12 V13
## 1 11  0 71  0 0.260      9 4.600 14     1     1 name   1   0
## 2 19  0 72  0 0.380      6 4.100 14 1.700 0.588 name   1   0
## 3 16  0 55  0 0.260      4 3.420 14     1     1 name   1   0
## 4 57  0 60  0 0.253 12.062 4.603 16 1.450 0.788 name   1   0
## 5 19  1 57  0 0.160     22 5.750 18 2.250 0.571 name   1   0
## 6 26  0 68  0 0.260      5 4.310 12     1 0.857 name   1   0
```

* Note that `read.csv` is a special version of `read.table` for reading data talbe sthat are separated by commas 

---

##	Reading in lines of files


```r
c <- file("file2.txt", open="r")
readLines(c, n=1)
readLines(c, n=1)
readLines(c, n=1)
readLines(c, n=1)
readLines(c, n=1)
```

```
## [1] "123"
## [1] "abcd"
## [1] "2 4 5"
## [1] "54"
## character(0)
```

---

## Be sure to `close` the file when you're done!


```r
close(c)
```

---
	
## `print`

* Writes to the screen


```r
x <- 1:3
print(x^2)
```

```
## [1] 1 4 9
```

* This is useful for outputting data from within functions if you are trying to debug your code

---

## `cat`

* Write to the screen, must provide your own newline character


```r
cat(x, "abc", x^2)
```

```
## 1 2 3 abc 1 4 9
```

```r
cat(x, "abc", x^2, "\n")
```

```
## 1 2 3 abc 1 4 9
```

* Not all implementations of R include a newline character with the cat function, so including the `\n` is useful to just to be safe

---

## `write.table`: structured writing to a file


```r
head(data)
```

```
##   V1 V2 V3 V4    V5     V6    V7 V8    V9   V10  V11 V12 V13
## 1 11  0 71  0 0.260      9 4.600 14     1     1 name   1   0
## 2 19  0 72  0 0.380      6 4.100 14 1.700 0.588 name   1   0
## 3 16  0 55  0 0.260      4 3.420 14     1     1 name   1   0
## 4 57  0 60  0 0.253 12.062 4.603 16 1.450 0.788 name   1   0
## 5 19  1 57  0 0.160     22 5.750 18 2.250 0.571 name   1   0
## 6 26  0 68  0 0.260      5 4.310 12     1 0.857 name   1   0
```

```r
colnames(data) <- LETTERS[1:ncol(data)]
rownames(data) <- 1:nrow(data)
write.table(file="ecg.data", data)
```

---

## File output:


```bash
head ecg.data
```

```
## "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
## "1" "11" "0" "71" 0 "0.260" "9" "4.600" "14" "1" "1" "name" "1" "0"
## "2" "19" "0" "72" 0 "0.380" "6" "4.100" "14" "1.700" "0.588" "name" "1" "0"
## "3" "16" "0" "55" 0 "0.260" "4" "3.420" "14" "1" "1" "name" "1" "0"
## "4" "57" "0" "60" 0 "0.253" "12.062" "4.603" "16" "1.450" "0.788" "name" "1" "0"
## "5" "19" "1" "57" 0 "0.160" "22" "5.750" "18" "2.250" "0.571" "name" "1" "0"
## "6" "26" "0" "68" 0 "0.260" "5" "4.310" "12" "1" "0.857" "name" "1" "0"
## "7" "13" "0" "62" 0 "0.230" "31" "5.430" "22.5" "1.875" "0.857" "name" "1" "0"
## "8" "50" "0" "60" 0 "0.330" "8" "5.250" "14" "1" "1" "name" "1" "0"
## "9" "19" "0" "46" 0 "0.340" "0" "5.090" "16" "1.140" "1.003" "name" "1" "0"
```

* Again, many options for altering how the output looks

---

## Unstructured writing to a file

* `cat`:

```r
	cat("abc\n", file="u")
	cat("def\n", file="u", append=T)
```

* `write`:

```r
	write(x, file="filename", sep= " ")
	write(x, file="filename", append=T, sep= "\t")
	write(x, "")
```

```
## 1 2 3
```

* Note that the `append=T` prevents the file from being written over

---

##	Basic file operations

* `file.info("data")`:	tells file size, creation time, etc
* `dir()`:	gives the directory contents for the specified dir
* `list.files()`:	same as dir()
* `file.exists()`:	tells whether a file exists, duh.
* `getwd()`:	tells you where you are in the file tree
* `setwd()`:	allows you to change the current directory

--- .segue .dark

## Questions?
