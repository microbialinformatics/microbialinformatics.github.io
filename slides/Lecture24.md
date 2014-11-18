---
title       : Microbial Informatics
subtitle    : Lecture 24
date        : November 18, 2014
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
* Will have lab period on Friday
* Final project
  * Due 12/16/2014 (date that final exam is scheduled)
  * Should be a program that others can use to do something useful
  * I have ideas if you need one
  * Create a public repository with documentation in README file and license



---

## Review
* String manipulation

---

## Five remaining lectures

* Experiment: Let's write some programs together
* Learning goals: 
  * Apply what we've been learning in class
  * Collaborate
* I have no idea how this will work out

---

## Problem definition

* Vince Young got my wife and I addicted to the iPhone app called [Ruzzle](http://www.ruzzle-game.com)
* It's a 4 by 4 board filled with tiles
* Each tile has a point value associated with it that is proportional to the probability of seeing it in a word (think Scrabble)
* Sometimes there are double letter and double word tiles
* You have two minutes to get as many words as possible
* I'm not very good.

---

<iframe src="http://player.vimeo.com/video/42698299" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

---

## Point values


```r
point.values = c(
  'A' = 1,  'B' = 3,  'C' = 3,  'D' = 2,
  'E' = 1,  'F' = 4,  'G' = 2,  'H' = 4,
  'I' = 1,  'J' = 8,  'K' = 5,  'L' = 1,
  'M' = 3,  'N' = 1,  'O' = 1,  'P' = 3,
  'Q' = 10, 'R' = 1,  'S' = 1,  'T' = 1,
  'U' = 1,  'V' = 4,  'W' = 4,  'X' = 8,
  'Y' = 4,  'Z' = 10
)
```

---

## Example dictionary

* The official Scrabble word list: [SOWPODS](http://www.freescrabbledictionary.com/sowpods.txt)

---

## Example board: Round 1

<img src="../img/ruzzle_r1.png", style="margin:0px auto;display:block" width="300">

---

## Example board: Round 2

<img src="../img/ruzzle_r2.png", style="margin:0px auto;display:block" width="300">

---

## Example board: Round 3

<img src="../img/ruzzle_r3.png", style="margin:0px auto;display:block" width="300">

---

## Organization:

* [GitHub repository](https://github.com/microbialinformatics/ruzzle_cheat)
* Need to develop broad pseudocode, have class break into groups of 2 or 3
* Will need to define inputs and outputs so we can work concurrently

