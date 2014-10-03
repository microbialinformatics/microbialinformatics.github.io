--- 
title       : Microbial Informatics
subtitle    : Lecture 11
date        : October 3, 2014
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
* For the next two Fridays, the first hour of class will be a lecture
* Read ***Introduction to Statistics with R*** (Chapter 9: Power analysis and Chapter 7: ANOVA and Kruskal Wallis)

--- 

## Review
* Discrete distribtuions: Binomial distribution
* ChiSquared test to determine independence of two or more distributions




---

## Learning objectives
* Best practices for representing continuous data
* Understand how to test statistical hypotheses using continuous data


---

## Motivation
* Are the heights of men and women significantly different?
* Do conventional mice eat more chow than germ free mice?
* Is the abundance of bug X higher in agricultural soils than it is in forest soils?

---

## Thinking about weights...

<img src="assets/fig/weights.png" title="plot of chunk weights" alt="plot of chunk weights" style="display: block; margin: auto;" />

---

## Back to basics...

*   Mean: a measure of the central tendency of a distribution

$$\bar x=\frac{\sum x_i}{n}$$


*   Standard deviation: the amount of variation in the data

$$SD = \sqrt{\frac{\sum(x_i-\bar x)^2}{n-1}}$$

---

## Back to basics...

*   Standard error: measures the precision with which you know the mean

$$SE = \frac{SD}{\sqrt{n}}$$

*	Confidience intervals

$$\mbox{Upper 95% limit} = \bar x + (SE \times 1.96)$$
$$\mbox{Lower 95% limit} = \bar x - (SE \times 1.96)$$

---

## Data visualization

When you plot data with "error bars" you must indicate...

  * ...the number of individuals being represented
  * ...whether the bars represent the standard error or confidence interval

---

## How do we know if they differ in weight?

*	The mean weight of the PL mice (N=58) was 16.0259 and the mean weight of the PMG mice (N=60) was 17.0333. The standard deviations were 4.7113 and 4.9471, respectively.


```r
pmg.se <- sd(pmg.weights)/sqrt(length(pmg.weights))
pmg.ci <- mean(pmg.weights) + pmg.se * c(-1.95,1.95)
pmg.ci
```

```
## [1] 15.79 18.28
```

```r
pl.se <- sd(pl.weights)/sqrt(length(pl.weights))
pl.ci <-  mean(pl.weights) + pl.se * c(-1.95,1.95)
pl.ci
```

```
## [1] 14.82 17.23
```

---

## A more direct way of calculating signifcance: Two-sample *t* test

$$t=\frac{\bar x_2 - \bar x_1}{\sqrt{SE_1^2+SE_2^2}}$$

* Evaluating for our data we get *t*=-1.1331
* If the null hypothesis is true (PL and PMG come from a distribution with the same mean), then we test under a *t* distribution with n1+n2-2 degrees of freedom. In our case we use 116 degres of freedom. Using the `pt` function and a two-tailed test we get a P-value of 0.2595.

---

## Using the built-in R function


```r
t.test(pl.weights, pmg.weights)
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  pl.weights and pmg.weights
## t = -1.133, df = 116, p-value = 0.2595
## alternative hypothesis: true difference in means is not equal to 0
## 95 percent confidence interval:
##  -2.7686  0.7536
## sample estimates:
## mean of x mean of y 
##     16.03     17.03
```

No.

---

## Are the PL mice heavier than the PMG mice?


```r
t.test(pl.weights, pmg.weights, alternative="greater")
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  pl.weights and pmg.weights
## t = -1.133, df = 116, p-value = 0.8702
## alternative hypothesis: true difference in means is greater than 0
## 95 percent confidence interval:
##  -2.482    Inf
## sample estimates:
## mean of x mean of y 
##     16.03     17.03
```

No.

---

## Are the PL mice lighter than the PMG mice?


```r
t.test(pl.weights, pmg.weights, alternative="less")
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  pl.weights and pmg.weights
## t = -1.133, df = 116, p-value = 0.1298
## alternative hypothesis: true difference in means is less than 0
## 95 percent confidence interval:
##    -Inf 0.4668
## sample estimates:
## mean of x mean of y 
##     16.03     17.03
```

No.

---

## Prior knowledge

* We've read that a study of PL mice in Ohio showed they had an average weight of 15 g. Assume that they have the same standard deviation, could our our observed weights have been drawn from the same distribution?

$$t=\frac{\bar x - x_o}{SE}$$

* We can test against a *t* distribution with n-1 degrees of freedom



* For this example, we get a *t* of 1.6583 and a P-value of 0.1027 

---

## Using the built-in R function


```r
t.test(pl.weights, mu=15)
```

```
## 
## 	One Sample t-test
## 
## data:  pl.weights
## t = 1.658, df = 57, p-value = 0.1028
## alternative hypothesis: true mean is not equal to 15
## 95 percent confidence interval:
##  14.79 17.26
## sample estimates:
## mean of x 
##     16.03
```

---

## Paired observations

> * Suppose we sampled the pH of lakes in the spring and fall and wanted to know if there was a signficant change in the pH of the lakes
> * We could do it by treating the spring pH values as one variable and the fall pH values as another variable
> * However the problem with this approach is that the observations are not independent of each other - we were interested in the ***change*** in pH
> * Method: calculate the difference in pH for each lake and see whether that distrubion has a mean of zero
> * This is the "paired t-test"

---

## Example


```r
first <- pl.weights[1:40]
second <- pmg.weights[1:40]
diff <- first-second
hist(diff, main="")
```

<img src="assets/fig/unnamed-chunk-8.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />

---

## The test:

$$t=\frac{\bar x}{SE}$$


```r
diff.mean <- mean(diff)
diff.se <- sd(diff)/sqrt(length(diff))
t <- diff.mean / diff.se
df <- length(diff) - 1
p <- 2 * pt(t, df)
```

We get a P-value of 0.0384, which indicates the mice had a significant change in weight over the two time points

---

## R style...


```r
t.test(first, second, paired=TRUE)
```

```
## 
## 	Paired t-test
## 
## data:  first and second
## t = -2.143, df = 39, p-value = 0.03837
## alternative hypothesis: true difference in means is not equal to 0
## 95 percent confidence interval:
##  -4.1789 -0.1211
## sample estimates:
## mean of the differences 
##                   -2.15
```

---

## Assumptions required to perform a *t*-test
1. Data follow a normal distribution
2. Observations are independent

---

## Are our data normally distributed?

<img src="assets/fig/unnamed-chunk-11.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" style="display: block; margin: auto;" />

* Meh, not really

---

## Parametric vs. non-parametric
* Parametric tests (e.g. *t*-test) assume that the data are well behaved and follow nice distributions
* If they meet this assumption, it becomes easy to calculate test statistics and P-values
* If they don't and you use the test anyway, you can get bad results.
* The alternative is to use non-parametric tests, which don't assume a distribution


---

## The non-parametric *t*-test: Wilcox test

* Rank based: Order your observations from two treatment groups and count number of switches between groups.
* If the number of switches is greater than you'd expect by chance, it is significant
* Syntax for `wilcox.test` is virutally identical to that of `t.test`
* In figures and text, present the median and interquartile range (25-75%tile)

---

## Two sample test


```r
wilcox.test(pl.weights, pmg.weights)
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  pl.weights and pmg.weights
## W = 1525, p-value = 0.2474
## alternative hypothesis: true location shift is not equal to 0
```

---

## Single-sample test


```r
wilcox.test(pl.weights, mu=15)
```

```
## 
## 	Wilcoxon signed rank test with continuity correction
## 
## data:  pl.weights
## V = 867, p-value = 0.1804
## alternative hypothesis: true location is not equal to 15
```

---

## Paired test


```r
wilcox.test(first, second, paired=TRUE)
```

```
## Warning: cannot compute exact p-value with ties
## Warning: cannot compute exact p-value with zeroes
```

```
## 
## 	Wilcoxon signed rank test with continuity correction
## 
## data:  first and second
## V = 180.5, p-value = 0.01685
## alternative hypothesis: true location shift is not equal to 0
```


--- .segue .dark

## Questions?
