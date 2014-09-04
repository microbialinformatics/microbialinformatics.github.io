--- 
title       : Microbial Informatics
subtitle    : Lecture 02
date        : September 4, 2014
author      : Patrick D. Schloss, PhD (microbialinformatics.github.io)
job         : Department of Microbiology & Immunology
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : standalone    # {selfcontained, standalone, draft}
knit        : slidify::knit2slides

--- 

## Learning objectives
* Introduce RStudio
* Introduce knitr
* Describe how to generate a document in markdown
* Differentiate between different flavors of markdown

--- &vcenter

<img src="assets/img/RStudioWebSite.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
* The RStudio website has a lot of support built into it with miniature tutorials, videos, etc


--- &vcenter

<img src="assets/img/RStudioWindows.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes

* This is what's called an IDE: integrated development environment
* It is important to note that you don't need RStudio to run R. I frequently do everything from the command line using a text editor
* The main window is made up of four panes: source code (up left), console (bot left), history/environment (up right), and display (bot right)
* There are a variety of widgets on the screen that you can explore throughout the semester

--- &vcenter

<img src="assets/img/RStudioPrefernecesGen.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
* There are many settings you can change in the preferences pane
* Here are the general prefs - let's leave the defaults
* Again, feel free to tweak as we go -> find what works best for you

--- &vcenter

<img src="assets/img/RStudioPrefernecesCode.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
* Here are a number of check boxes for various options
* Things like line numbers, auto indenting, etc. are very useful
* Again, feel free to tweak as we go -> find what works best for you

--- &vcenter

<img src="assets/img/RStudioPrefernecesAppearance.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
* Here you can change how things appear, font, size, etc.
* You can also play around with the color scheme some
* Try clicking different editor theme options to see how things change

--- &vcenter

<img src="assets/img/RStudioPrefernecesPanes.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
* Here you can set the pane layout to move things around as you like

--- &vcenter

<img src="assets/img/RStudioPrefernecesPackages.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
* Here you set preferences about how packages are installed. Don't worry about it too much


--- &vcenter

<img src="assets/img/RStudioPrefernecesSweave.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
* Sweave was the predecessor to knitr - we want to use knitr
* Set the "Weave Rnw files using" option to knitr
* May need to go to the package pane to select and install knitr 

--- &vcenter

<img src="assets/img/RStudioPrefernecesSpelling.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
* Spelling, meh.

--- &vcenter

<img src="assets/img/RStudioPrefernecesGit.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
* As we mentioned R will play nicely with git and github. We'll talk about the details of this later
* For now make sure the box is checked

---

## What is Markdown (*.md)?
* "Markdown is a text-to-HTML conversion tool for web writers. Markdown allows you to write using an easy-to-read, easy-to-write plain text format, then convert it to structurally valid XHTML (or HTML)." - [John Gruber](http://daringfireball.net/projects/markdown/)
* The advantage is that you can read it as a text document and it will make sense and you can use conversion software to generate other file formats including html, pdf, docx
* Can be rendered using:
 * A Perl script from Gruber
 * RStudio

*** =pnotes
* These slides and course materials will be written in Markdown

--- 

## What's special about R markdown (*.Rmd)?
* "R Markdown is an authoring format that enables easy creation of dynamic documents, presentations, and reports from R. It combines the core syntax of markdown (an easy-to-write plain text format) with embedded R code chunks that are run so their output can be included in the final document. R Markdown documents are fully reproducible (they can be automatically regenerated whenever underlying R code or data changes)." - [RStudio website](http://rmarkdown.rstudio.com)
* Keys...
 * Ability to format text
 * Imbed R code and output as chunks or inline

---

## Chunks
<img src="assets/fig/unnamed-chunk-1.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />

---  

## Inline

> * Let me pick a random number between 1 and 10.
> * Hmmm, I pick 5
> * 5 squared is 25
> * All of the numbers (after 1 and 10) were generated within R
> * The dynamic component is that you use R packages to allow a user to set the min and max values to bound your pick

---

## Syntax
* An R markdown "cheat sheet" is available for you to download and print from [rstudio.com](http://shiny.rstudio.com/articles/rm-cheatsheet.html)
* Other documentation, examples, tutorials are available at [rmarkdown.rstudio.com](http://rmarkdown.rstudio.com)
 * You can use existing [document templates](http://rmarkdown.rstudio.com/developer_document_templates.html)
 * You can design your own [report templates](http://rmarkdown.rstudio.com/developer_custom_formats.html)
 * Possible to insert [paper references](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
 * There's a lot more there
* We will be using R markdown tomorrow as part of the exercise

*** =pnotes
* Students are encouraged to go through the rmarkdown.rstudio.com on their own
* We will be using the basics of R markdown in this course, but if you want to make documents
more attactive you'll likely want to play with the formating styles.

--- &vcenter

<img src="assets/img/RMarkdownCheatSheetFormatting.png", style="margin:0px auto;display:block" width="550">

*** =pnotes
If you can learn this you'll be good to go...


--- &vcenter

<img src="assets/img/MarkdownCreateFile.png", style="margin:0px auto;display:block" width="1000">

--- &vcenter

<img src="assets/img/MarkdownSelectFormat.png", style="margin:0px auto;display:block" width="1000">

--- &vcenter

<img src="assets/img/MarkdownSourceCode.png", style="margin:0px auto;display:block" width="1000">

*** =pnotes
Encourage students to muck around with R Markdown syntax here

--- &vcenter

<img src="assets/img/MarkdownReferenceButton.png", style="margin:0px auto;display:block" width="1000">

--- &vcenter

<img src="assets/img/MarkdownEditOptions.png", style="margin:0px auto;display:block" width="1000">

--- &vcenter

<img src="assets/img/MarkdownKeepMDFile.png", style="margin:0px auto;display:block" width="1000">

--- &vcenter

<img src="assets/img/MarkdownKnittedToHTML.png", style="margin:0px auto;display:block" width="1000">

---

---

---

---



## For Friday
* Install appropriate software that we discussed on Tuesday
* Get books
* Sign-up for an account on [GitHub](http://github.com)
* Check out Software Carpentry [Git tutorial](http://software-carpentry.org/v5/novice/git/index.html)

--- .segue .dark

## Questions?

