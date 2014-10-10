--- 
title       : Microbial Informatics
subtitle    : Lecture 14
date        : October 10, 2014
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
* Homework 3 is due today
* Have posted some guide lines to follow for Project 1
* No class on Tuesday (Fall break); Next Friday, the first hour of class will be a lecture
* Start programming discussion next Thursday!
* Read ***The Art of R Programming*** (Chapter 1: Getting Started)





---

## Review
* Type I and Type II errors
* ANOVA is a generalized form of the t-test (Parametric)
* Kruskall-Wallis is a generalized form of the Wilcox-test (Non-parametric)


---

## Learning objectives
* Regression
* Correlation

---

## Motivation  
* You have isolated an enzyme from a novel bacterium that you are convinced will solve the world's energy problems. But first you need to characterize its kinetics on a variety of substrates.
* For a variety of substrate concentrations, you run a colormetric assay and quantify the activity (amount of product formed per unit time) for each substrate concentration. Your data look like so...

---

<img src="assets/fig/unnamed-chunk-2.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

---

## Motivation  
* You recall from your undergraduate biochemistry class doing a lab on Michaelis-Menton kinetics and that there is a model that looks like this:

$$\frac{dP}{dt}=V_o=\frac{V_{max}[S]}{K_m+[S]}$$

* How do you figure out $V_{max}$ and $K_m$?

---

## Motivation  

We can make a Lineweaver-Burk plot

$$\frac{1}{V_o} = \frac{K_m + [S]}{V_{max}[S]}$$

or...

$$\frac{1}{V_o} = \frac{K_m}{V_{max}}(\frac{1}{[S]}) + \frac{1}{V_{max}}$$

---

## How do we fit this plot?
<img src="assets/fig/unnamed-chunk-3.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />

---

## How do we fit this plot?

$$\frac{1}{V_o} = \frac{K_m}{V_{max}}(\frac{1}{[S]}) + \frac{1}{V_{max}}$$

> * If we can fit a line through the data we can get our Vmax from the intercept and our Km from the slope
> * Cue... linear regression!

---

## Linear regression

$$y_i = \alpha + \beta x_i + \epsilon_{ij}$$

* We need to fit this model to estimate the values of $\alpha$ and $\beta$
* We'll come back to talking about $\epsilon$ later

---

## What we really want to do...
* Minimize the distances between the line we fit through the data and the observed values.
* This distance is the residual - minimize the squared residuals...

$$SS_{res} = \sum(y_i - (\alpha + \beta x_i) )^2$$

* Recall how to minimze a function?

---

## After some calculus and algebra...

$$\hat{\beta} = \frac{\sum(x_i-\bar x)(y_i-\bar y)}{\sum(x_i-\bar x)^2}$$
$$\hat{\alpha} = \bar y - \hat{\beta}\bar x$$

---

## Let's do some calculations...


```r
xbar <- mean(invS)
ybar <- mean(invV)

beta <- sum((invS-xbar)*(invV-ybar))/sum((invS-xbar)^2)
alpha <- ybar - beta * xbar
```

---

## Our fit


```r
plot(invS, invV, lwd = 3, col = "blue", pch = 19, xlab = "1/[Substrate] (ml/mg)", 
    ylab = "1/Vo (min)")
abline(b = beta, a = alpha, lwd = 3)
```

<img src="assets/fig/unnamed-chunk-4.png" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" style="display: block; margin: auto;" />

---

## Returning to biology

$$\frac{1}{V_o} = \frac{K_m}{V_{max}}(\frac{1}{[S]}) + \frac{1}{V_{max}}$$

$$\hat{\alpha} = \frac{1}{V_{max}} = 1.1252$$
$$\hat{\beta} = \frac{K_m}{V_{max}} = 71.2447$$

So we get a Vmax of 0.89 and a Km of 63.32

---

## How to do this with built in R function?


```r
lm(invV~invS)
```

```
## 
## Call:
## lm(formula = invV ~ invS)
## 
## Coefficients:
## (Intercept)         invS  
##        1.13        71.24
```

---

## What is the null hypothesis we're trying to test?

$$\hat{\beta} = 0$$

* How to test?

$$t=\frac{\hat{\beta}}{SE(\hat{\beta})}$$

with n-2 degrees of freedom

---

## How to do this with built in R function?


```r
summary(lm(invV~invS))
```

---

## How to do this with built in R function?


```
## 
## Call:
## lm(formula = invV ~ invS)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.3986 -0.0555  0.0255  0.0765  0.2485 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   1.1252     0.0477    23.6  5.5e-15 ***
## invS         71.2447     1.6892    42.2  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.165 on 18 degrees of freedom
## Multiple R-squared:  0.99,	Adjusted R-squared:  0.989 
## F-statistic: 1.78e+03 on 1 and 18 DF,  p-value: <2e-16
```

---

## Our fit

<img src="assets/fig/unnamed-chunk-8.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />

What do you notice about the fit?

---

## How "good" is our fit?

* The R squared value!
* Represents the percentage of the variance in the data that is reduced by going from a one parameter model ($\alpha$) to the linear, two parameter model

---

## A better fit (Chapter 16)...


```r
mm <- function(S, vmax, Km){
	Vo <- vmax * S / (Km + S)
	return(Vo)
}

nonlinear.fit <- nls(dPdt ~ mm(S, v, k), start=c(v=1, k=60))
```

---

## A better fit (Chapter 16)...


```r
summary(nonlinear.fit)
```

```
## 
## Formula: dPdt ~ mm(S, v, k)
## 
## Parameters:
##   Estimate Std. Error t value Pr(>|t|)    
## v   0.8122     0.0242    33.6  < 2e-16 ***
## k  50.7066     4.6200    11.0  2.1e-09 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.0232 on 18 degrees of freedom
## 
## Number of iterations to convergence: 3 
## Achieved convergence tolerance: 5.56e-06
```

---

## A better fit (Chapter 16)...


```r
plot(S, dPdt, lwd = 3, col = "blue", pch = 19, xlab = "1/[Substrate] (ml/mg)", 
    ylab = "1/Vo (min)")
lines(S, mm(S, vmax = lin.vmax, Km = lin.Km), col = "red", lwd = 2)
points(S, predict(nonlinear.fit), type = "l", lwd = 2)
```

<img src="assets/fig/unnamed-chunk-11.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" style="display: block; margin: auto;" />

---

## Correlation

<img src="http://imgs.xkcd.com/comics/correlation.png", style="margin:0px auto;display:block" width="900">

---

## Correlation

<img src="http://upload.wikimedia.org/wikipedia/commons/0/02/Correlation_examples.png", style="margin:0px auto;display:block" width="900">

Wikipedia

---

## Parametric: Pearson correlation

* Parametric
* Linear relationship

$$r=\frac{(x_i-\bar x)(y_i-\bar y)}{\sqrt{\sum(x_i-\bar x)^2\sum(y_i-\bar y)^2}}$$


```r
Sbar <- mean(S)
dPdtbar <- mean(dPdt)
r <- sum((S-Sbar)*(dPdt-dPdtbar))/sqrt(sum((S-Sbar)^2)*sum((dPdt-dPdtbar)^2))
r
```

```
## [1] 0.915
```

---

## Parametric: Pearson correlation



```r
cor(S, dPdt, method="pearson")
```

```
## [1] 0.915
```


```r
cor.test(S, dPdt, method="pearson")
```

```
## 
## 	Pearson's product-moment correlation
## 
## data:  S and dPdt
## t = 9.62, df = 18, p-value = 1.615e-08
## alternative hypothesis: true correlation is not equal to 0
## 95 percent confidence interval:
##  0.7939 0.9663
## sample estimates:
##   cor 
## 0.915
```

---

## Non-parametric: Spearman correlation



```r
cor(S, dPdt, method="spearman")
```

```
## [1] 0.9789
```


```r
cor.test(S, dPdt, method="spearman")
```

```
## 
## 	Spearman's rank correlation rho
## 
## data:  S and dPdt
## S = 28, p-value = 6.521e-06
## alternative hypothesis: true rho is not equal to 0
## sample estimates:
##    rho 
## 0.9789
```



--- .segue .dark

## Questions?
