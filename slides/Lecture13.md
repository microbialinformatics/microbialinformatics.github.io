--- 
title       : Microbial Informatics
subtitle    : Lecture 13
date        : October 9, 2014
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
* Homework 3 is out
* Have posted some guide lines to follow for Project 1
* For this Friday, the first hour of class will be a lecture
* Read ***Introduction to Statistics with R*** (Chapter 6: Regression and correlation)
* Start programming discussion next Thursday!



---

## Review
* **Type I Error ($\alpha$):** Pr(detecting difference between groups) when they are drawn from the same distribution
* **Type II Error ($\beta$):** Pr(not detecting difference between groups) when they are drawn from different distributions
* Power ($1-\beta$) is dependent on:
  * Effect size
  * Number of individuals
  * Variation in data
  * $\alpha$
  * Statistical test

---

## Learning objectives
* How to compare more than two levels of a treatment
* How to comapre two treatments, each with multiple levels
* How about when the data are not normally distrubted?

---

## Motivation  
> * Does the relative abundance of *F. nucleatum* vary between healthy people and those with adenomas or carcinoms?
> * Is there a difference in the weights of male and female mice when we account for their species?

---

## Motivation  
> * Does the relative abundance of *F. nucleatum* vary between healthy people and those with adenomas or carcinoms?
>   * **One-way ANOVA:**	You have multiple groups or levels of a treatment and you want to know whether one of them is different
> * Is there a difference in the weights of male and female mice when we account for their species?
>   * **Mutliple-way ANOVA:**	You have multiple treatments with multiple groups / levels and you want to know whether one of them is different
> * These are really a type of regression, a topic we'll be covering over the course of the next few weeks

---

## Let's do an experiment...

* Imagine we go out and count the number of L. acidophilus CFUs/gram of feces from three groups of people (N=20) where each group is eating a different commercial yogurt

<img src="assets/fig/obs.data.png" title="plot of chunk obs.data" alt="plot of chunk obs.data" style="display: block; margin: auto;" />

---

## Let's assume they all come from the same population

<img src="assets/fig/unnamed-chunk-2.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

---

## Do they follow a normal distribution?

* Mean ($\mu$): 6.7752
* Standard deviation ($\sigma$): 1.3103

<img src="assets/fig/unnamed-chunk-3.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />

---

## Lets generate a model to explain the variation we see

* We can create a model to explain the observed data:

$$x_{ij}=\mu + \alpha_{i}+ \epsilon_{ij}$$  

> * $x_{ij}$ is the *jth* observed value in group *i*
> * $\mu$ is the mean of all observed values (6.7752)
> * $\alpha_{i}$ is the effect size for group *i*
> * $\epsilon_{ij}$ is the error associated with the observed value
> * What do you think the null hypothesis is?

---

## Lets generate a model to explain the variation we see

* The null hypothesis is that the effect sizes are all zero:

$$\alpha_{i} = 0$$

$$\alpha_{A} = \alpha_{B} = \alpha_{C} = 0$$

* If any of the $\alpha$ values are not zero, then the null hypothesis should be rejected

---

## How do we fit the model?

* We want to partition the variation we see in the data...

$$x_{ij} = \bar{\bar x} + (\bar x_i - \bar{\bar x}) + (x_{ij} - \bar x_i)$$

* This says that the value we observed in treatment *i* is the sum of the overall mean across all data plus the ***variation*** due to the treatment plus the ***variation*** due to random noise.

---

## How do we fit the model?

* The total variation in the data, the Sum Squared Difference is:

$$SSD_{total} = \sum(x_{ij} - \bar x)^2$$

* The question posed by the model then is can we parition this total variation into factors we can explain, such as the three treatment groups
  *	Variation between treatments
  *	Unexplained variation / variation within treatments
*	Which source of variation is bigger? (what does that mean?)

---

## How do we fit the model?

$$x_{ij} = \bar{\bar x} + (\bar x_i - \bar{\bar x}) + (x_{ij} - \bar x_i)$$

* The terms in parentheses can be collapsed into sums of variation:

$$SSD_{between} = \sum n_i (\bar x_i - \bar{\bar x})^2$$
$$SSD_{within} = \sum \sum (x_{ij} - \bar x_i)^2$$
$$SSD_{total} = \sum \sum (x_ij - \bar{\bar x})^2$$


---

## Mean squared error

* The $SSD_{between}$ and $SSD_{within}$ will both explain some fraction of the total variance, but we need to normalize that variance for the degrees of freedom
  * $df_{total}$: N-1
  * $df_{between}$: K-1
  * $df_{within}$: N-K
* This gives us the following mean square error terms:
$$MS_{between} = SSD_{between} / (K-1)$$
$$MS_{within} = SSD_{within} / (N-K)$$

---

## How to test the significance of the differences in MS values:

$$F=MS_{between}/MS_{within}$$

* *F* > 1 indicate there is more variation between groups than within groups
* *F* <= 1 indicate there is as much variation or more within groups than between groups
* Can test significance of *F* using the F distribution (i.e. `pf`) with $df_{between}$ and $df_{within}$ degrees of freedom looking for values above the 95th percentile for significance

---

## Let's run the numbers


```r
x.doublebar <- mean(c(a, b, c))
x.bar <- apply(cbind(a,b,c), 2, mean)
n.i <- apply(cbind(a,b,c), 2, length)

ssd.between <- sum(n.i*(x.bar-x.doublebar)^2)
ssd.within <- sum((rbind(a,b,c)-x.bar)^2)
ssd.total <- sum((c(a,b,c)-x.doublebar)^2)
df.between <- 3-1
df.within <- length(c(a,b,c))-3
ms.between <- ssd.between / df.between
ms.within <- ssd.within / df.within
F <- ms.between / ms.within
P <- 1-pf(F, df.between, df.within)
```

We get an F statistic of 51.6547 with 2 and 87 degrees of freedom and a P-value of 1.5543 &times; 10<sup>-15</sup>.

---

## An easier way?

* R has many many options for performing model fits with all sorts of complexities. We first need to get our data into a single vector with another vector to annotate which group each datum belongs to:


```r
groups <- c(rep("A", length(a)), rep("B", length(b)), rep("C", length(c)))
data <- c(a, b, c)
```

---

## An easier way?

* We can then model the data using the `lm` command (think: linear model):


```r
anova(lm(data~groups))
```

```
## Analysis of Variance Table
## 
## Response: data
##           Df Sum Sq Mean Sq F value  Pr(>F)    
## groups     2   83.0    41.5    51.6 1.6e-15 ***
## Residuals 87   69.9     0.8                    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

* Earlier we had an F statistic of 51.6547 with 2 and 87 degrees of freedom and a P-value of 1.5543 &times; 10<sup>-15</sup>.

---

## Recall our null hypothesis?

$$\alpha_{A} = \alpha_{B} = \alpha_{C} = 0$$

---

#	So you get back a small p-value, what does that mean?

*	Tests of comparisons
  * Planned comparisons <- orthoganal comparisons, a priori hypotheses
  * Unplanned comparisons <- tukey's hsd, post hoc analyses
  * All possible comparisons <- what's wrong with this approach?
* Strategy:
  * Do all possible T-tests between levels of your treatment
  * Correct alpha for multiple comparisons (e.g. Bonferroni)

---

##  So which $\alpha$ is significantly different?


```r
pairwise.t.test(data, groups)
```

```
## 
## 	Pairwise comparisons using t tests with pooled SD 
## 
## data:  data and groups 
## 
##   A       B      
## B 2.6e-13 -      
## C 0.9     3.0e-13
## 
## P value adjustment method: holm
```

* A and B are significantly different from C, but not each other.

---

<img src="assets/fig/unnamed-chunk-8.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />

---

## Non-parametric test: Kruskal-Wallis Rank Sum Test


```r
kruskal.test(x=data, g=factor(groups))
```

```
## 
## 	Kruskal-Wallis rank sum test
## 
## data:  data and factor(groups)
## Kruskal-Wallis chi-squared = 50.23, df = 2, p-value = 1.236e-11
```

---

## Two-way ANOVA

* Model with replication allows you to look at interactions

$$x_{ijk} = \mu + \alpha_i + \beta_j + \alpha\beta_{ij} + \epsilon_{ijk}$$

* Model without replication prevents you from looking at interactions

$$x_{ijk} = \mu + \alpha_i + \beta_j + \epsilon_{ij}$$

* Calculations get tricky if you have an unbalanced design
* Results get tricky if interaction term is significant

---

## An example: Without the interaction term


```r
metadata <- read.table(file="wild.metadata.txt", header=T, row.names=1)
anova(lm(metadata$Weight~metadata$SP+metadata$Sex))
```

```
## Analysis of Variance Table
## 
## Response: metadata$Weight
##               Df Sum Sq Mean Sq F value Pr(>F)
## metadata$SP    1     18    17.9    0.99   0.32
## metadata$Sex   1     39    38.7    2.13   0.15
## Residuals    108   1964    18.2
```

---

## An example: With the interaction term


```r
anova(lm(metadata$Weight~metadata$SP*metadata$Sex))
```

```
## Analysis of Variance Table
## 
## Response: metadata$Weight
##                           Df Sum Sq Mean Sq F value Pr(>F)
## metadata$SP                1     18    17.9    0.98   0.33
## metadata$Sex               1     39    38.7    2.11   0.15
## metadata$SP:metadata$Sex   1      0     0.2    0.01   0.92
## Residuals                107   1964    18.4
```

---

## Power


```r
between <- var(c(a.mean, b.mean, c.mean))
within <- mean(c(var(a), var(b), var(c)))
power.anova.test(groups = 3, n = 30, between.var = between, within.var = within, 
    sig.level = 0.05)
```

```
## 
##      Balanced one-way analysis of variance power calculation 
## 
##          groups = 3
##               n = 30
##     between.var = 1.383
##      within.var = 0.8029
##       sig.level = 0.05
##           power = 1
## 
## NOTE: n is number in each group
```

---

## Power


```r
between <- var(c(6, 6, 6.5))
power.anova.test(groups = 3, n = NULL, between.var = between, within.var = within, 
    power = 0.8, sig.level = 0.05)
```

```
## 
##      Balanced one-way analysis of variance power calculation 
## 
##          groups = 3
##               n = 47.43
##     between.var = 0.08333
##      within.var = 0.8029
##       sig.level = 0.05
##           power = 0.8
## 
## NOTE: n is number in each group
```

--- .segue .dark

## Questions?
