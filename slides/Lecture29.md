---
title       : Microbial Informatics
subtitle    : Lecture 29
date        : December 5, 2014
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
* Final project (due 12/16/2014)
  * Should be a program that others can use to do something useful (I have ideas if you need one, but really...)
	* Would be smart to include a test file
	* Create a public repository with documentation in README file and license
* Will have class on Friday, but not next Tuesday



---

## Review
* We've talked a lot about the R programming language and how we can do it to
	do useful things and help with our analyses
* The tools you have now will enable you to do many many things
* TDD is a software development process that results in a rapid development cycle

---

## Learning objectives
* Variable scoping
* Software licensing

---

## Variable scoping

* To this point we've largely ignored the issue of where our variables live and where they're "allowed to go"
* This has to do with a concept of variable scoping and the various environments that are used within R

---

## Consider this example...


```r
dna <- "ATGCCTGACCTTTGCATACAA"

getRevComp <- function(sequence){
	rev.sequence <- paste(rev(unlist(strsplit(sequence, ""))), collapse="")
	comp.rev.sequence <- chartr("ATGC", "TACG", rev.sequence)
	return(comp.rev.sequence)
}
```

* Where can `dna` be used?
* Where can `getRevComp` be used?
* Where can `rev.sequence` be used?

---

## What happens if...


```r
getRevComp <- function(sequence){
	rev.sequence <- paste(rev(unlist(strsplit(sequence, ""))), collapse="")
	comp.rev.sequence <- chartr("ATGC", "TACG", rev.sequence)
	print(dna, "")  <----
	return(comp.rev.sequence)
}
getRevComp(dna)
```

---

## What happens if...


```r
rev.sequence
```

```
## Error in eval(expr, envir, enclos): object 'rev.sequence' not found
```

---

## What happens if...


```r
getRevComp <- function(sequence){
	rev.sequence <- paste(rev(unlist(strsplit(sequence, ""))), collapse="")
	comp.rev.sequence <- chartr("ATGC", "TACG", rev.sequence)
	dna <- comp.rev.sequence
	return(comp.rev.sequence)
}

dna
getRevComp(dna)
dna
```

```
## [1] "ATGCCTGACCTTTGCATACAA"
## [1] "TTGTATGCAAAGGTCAGGCAT"
## [1] "ATGCCTGACCTTTGCATACAA"
```

---

## What's happening locally?


```r
ls()
```

```
## [1] "dna"        "encoding"   "getRevComp" "inputFile"
```

---

## Quick summary

> * At the time `getRevComp` is created, there are the objects `rev.sequence` and `comp.rev.sequence` created within getRevComp, plus those objects from the environment `getRevComp` is sitting in, namely `dna`
> * But it is important to note that the reverse is not true. The outermost environment is not affected by what goes on inside `getRevComp` (e.g. `dna` was n ot changed). This means that functions have no *side effects*
> * So you can have name conflicts between the objects within and outside your functions, but this is generally not a good idea. Sometimes people will use `l_` as a prefix on all variables within a function.
> * Upshot is that objects exist within a heirarchy

---

## How do we write up the heirarchy?

* As we've seen we can only read variables from up the heirarchy. We can't write variables up the heirarchy
* Unless we use the superassignment (`<<-`) operator


```r
getRevComp <- function(sequence){
	rev.sequence <- paste(rev(unlist(strsplit(sequence, ""))), collapse="")
	comp.rev.sequence <- chartr("ATGC", "TACG", rev.sequence)
	dna <<- comp.rev.sequence
	return(comp.rev.sequence)
}
dna
getRevComp(dna)
dna
```

```
## [1] "ATGCCTGACCTTTGCATACAA"
## [1] "TTGTATGCAAAGGTCAGGCAT"
## [1] "TTGTATGCAAAGGTCAGGCAT"
```

---

## Should you use the superassignment operator?

* This creates **global variables**, which are controversial
* Problems caused by potential side effects and difficulty debugging code
* Benefits are that they can make the code easier to read/write

> * Be careful

---

## [Licensing](http://www.astrobetter.com/the-whys-and-hows-of-licensing-scientific-code/)

* A legally-binding agreement which governs the use and redistribution of software
* Can range from being proprietary (e.g. M$ Windows/OS X) to open source (e.g. Linux/R)
* You need a license


## [Cost of code](http://www.howtogeek.com/howto/31717/what-do-the-phrases-free-speech-vs.-free-beer-really-mean/)

* Can be $$$ or free (as in speech) or free (as in beer)
* Beer
  * No cost
  * No expectations of how used
  * Source code not necessarily open (e.g. Java)
* Speech
  * Free to use as you want
  * Free to see how it works
  * Free to distribute how you'd like
  * Free to improve

---

## [Why do you need a license on your code?](http://www.astrobetter.com/the-whys-and-hows-of-licensing-scientific-code/)

* "Unlicensed code is closed code, so any open license is better than none"
* If you want others to see and use your code (which is why you're doing it), then you need a license
* Once you select a license, include it with your code - GitHub will provide you with a license
* You generally want to use a Free and Open Source Software (FOSS) license
* You do not necessarily lose copywright protecton

---

## [Use a GNU Public License (GPL)-compatible license](http://www.astrobetter.com/the-whys-and-hows-of-licensing-scientific-code/) 

* [GPL License](http://www.gnu.org/licenses/gpl.html)
* Guarantees the freedom of users to use, copy, and modify code
* Copyrights are maintained
* May charge for software or (re)distribute for free
* May only be combined with other code that uses GPL

---

## [Use a permissive, BSD/MIT-style license](http://www.astrobetter.com/the-whys-and-hows-of-licensing-scientific-code/) 

* [BSD](http://opensource.org/licenses/BSD-2-Clause)/[MIT](http://opensource.org/licenses/MIT) licenses are compatible with a GPL license
* Copyrights are maintained
* May be combined with code using any other license
* Easier for others (including commercial companies) to incorporate your work
* Minimal difference between BSD and MIT licenses

---

## Conclusion

* Reproducible research is critical to doing good science
* Making data analysis scripts and other code open is critical to reproduciblity
* R is a great tool for doing your analysis

---

## Going forward

* Learn another language (Python)
* Datbases (SQL)
* Evangelize to your labmates and PI
  * Use collaborative features within GitHub
  * Develop and distribute your code
  * Work on another groups prooject

--- .segue .dark

## Questions?
