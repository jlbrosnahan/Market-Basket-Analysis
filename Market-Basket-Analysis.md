---
title: "Market Basket Analysis"
author: "Jennifer Brosnahan"
date: "7/20/2020"
output:
  html_document: 
    keep_md: yes
    theme: lumen
    highlight: haddock
---

## Background
#### We have been asked by Blackwell Electronics to conduct a Market Basket Analysis on 30 days worth of transactions. Based on this market basket analysis, we will provide insights and purchasing patterns in order to provide product recommendations for cross-selling and recommender opportunities. 

## Objective
#### The purpose of this project is to conduct a Market Basket Analysis to gain insights on customer electronic transactions and find patterns or product relationships. Not only will we apply rules and gain insights, but we will also provide key business insights related to our findings. The following questions will be addressed:
* Are there any interesting patterns or item relationships within Blackwell Electronics transactions?
* Based on your market basket analysis, what product recommendations do you have for Blackwell?

## Data Description
#### The dataset contains 30 days' worth of Blackwell Electronics online transactions. Each row is a transaction, which contains only names of items purchased. There are no other variables, numeric or otherwise. 

## Analysis plan
#### We will use basket formatting and apply the apriori algorithm to determine relationships between products.

## Load packages

```r
library(tidyverse)
library(openxlsx)
library(knitr)
library(ggplot2)
library(arules)
library(arulesViz)
library(dplyr)
library(kableExtra)
```

## Import data

```r
trans <- read.transactions(file.path('C:/Users/jlbro/OneDrive/C3T4', 'ElectronidexTransactions.csv'), format = 'basket', sep=',', rm.duplicates=TRUE)
```

```
## distribution of transactions with duplicates:
## items
##   1   2 
## 191  10
```

```r
## summary statistics
summary(trans) 
```

```
## transactions as itemMatrix in sparse format with
##  9835 rows (elements/itemsets/transactions) and
##  125 columns (items) and a density of 0.03506172 
## 
## most frequent items:
##                     iMac                HP Laptop CYBERPOWER Gamer Desktop 
##                     2519                     1909                     1809 
##            Apple Earpods        Apple MacBook Air                  (Other) 
##                     1715                     1530                    33622 
## 
## element (itemset/transaction) length distribution:
## sizes
##    0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15 
##    2 2163 1647 1294 1021  856  646  540  439  353  247  171  119   77   72   56 
##   16   17   18   19   20   21   22   23   25   26   27   29   30 
##   41   26   20   10   10   10    5    3    1    1    3    1    1 
## 
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   0.000   2.000   3.000   4.383   6.000  30.000 
## 
## includes extended item information - examples:
##                             labels
## 1 1TB Portable External Hard Drive
## 2 2TB Portable External Hard Drive
## 3                   3-Button Mouse
```


```r
# view head
inspect(trans[1:5]) 
```

```
##     items                    
## [1] {Acer Aspire,            
##      Belkin Mouse Pad,       
##      Brother Printer Toner,  
##      VGA Monitor Cable}      
## [2] {Apple Wireless Keyboard,
##      Dell Desktop,           
##      Lenovo Desktop Computer}
## [3] {iMac}                   
## [4] {Acer Desktop,           
##      Intel Desktop,          
##      Lenovo Desktop Computer,
##      XIBERIA Gaming Headset} 
## [5] {ASUS Desktop,           
##      Epson Black Ink,        
##      HP Laptop,              
##      iMac}
```

## View item frequency

```r
itemFrequency(trans, type = 'absolute') 
```

```r
## Plot top 20 most frequently purchased items
itemFrequencyPlot(trans, topN=20, type = 'absolute', col = 1:20)
```

![](Market-Basket-Analysis_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

## View image of a sample of purchases

```r
image(sample(trans, 150))
```

![](Market-Basket-Analysis_files/figure-html/unnamed-chunk-7-1.png)<!-- -->

### Observation:
Graph reveals clusters of products purchased, however, it is hard to view product numbers

## View 10 least frequent items sold for possible liquidation purposes
<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Logitech.Wireless.Keyboard </th>
   <th style="text-align:right;"> 22 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> VGA Monitor Cable </td>
   <td style="text-align:right;"> 22 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Panasonic On-Ear Stereo Headphones </td>
   <td style="text-align:right;"> 23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1TB Portable External Hard Drive </td>
   <td style="text-align:right;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canon Ink </td>
   <td style="text-align:right;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Logitech Stereo Headset </td>
   <td style="text-align:right;"> 30 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ethernet Cable </td>
   <td style="text-align:right;"> 32 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canon Office Printer </td>
   <td style="text-align:right;"> 35 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gaming Mouse Professional </td>
   <td style="text-align:right;"> 35 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Audio Cable </td>
   <td style="text-align:right;"> 36 </td>
  </tr>
</tbody>
</table>

#### Note, bottom frequency items can be highly discounted for liquidation purposes

### Initial observations

* 9835 transactions
* 125 total products
* 43,151 total items were purchased
* Top 5: iMac, HP Laptop, Cyberpower Gamer Desktop, Apple Earpods, Apple MacBook Air
* Items/transaction range is 0-30
* Customers purchase 1 item the most, however, 2163 transactions only included 1 item, indicating potential for cross-selling opportunities
* The average items purchased is 4.4
* The top 7 products stand out, after that, item frequency seems to level off

## Apply apriori rules
### The apriori algorithm is used to uncover insights pertaining to transactional datasets based on item frequency. It assesses rules using two types of measurements: 1) Support, which measures itemsets of rules frequency, and 2) Confidence, which measures accuracy of the rules. A rule that measure high in both support and confidence are considered strong.

### The aim is to apply apriori rules until we find the 'sweet spot' of a useful amount of support, confidence, and lifts, generally greater than 1 for stronger rules.

```r
## Apriori #1
Rules1 <- apriori(trans, parameter = list(supp = 0.1, conf = 0.8, minlen = 3)) #Covers 10% of transactions (N=983), 80% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.8    0.1    1 none FALSE            TRUE       5     0.1      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 983 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [10 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 done [0.00s].
## writing ... [0 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules1, by='lift')) 
```

#### Apriori 1 generated no rules



```r
## Apriori #2
Rules2 <- apriori(trans, parameter = list(supp = 0.01, conf = 0.8, minlen = 3)) #Covers 1% of transactions (N=98), 80% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.8    0.1    1 none FALSE            TRUE       5    0.01      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 98 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [82 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 done [0.00s].
## writing ... [0 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules2, by='lift')) 
```

#### Apriori 2 generated no rules, keep going.



```r
## Apriori #3
Rules3 <- apriori(trans, parameter = list(supp = 0.005, conf = 0.8, minlen = 3)) #Covers .05% transactions (N=49), 80% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.8    0.1    1 none FALSE            TRUE       5   0.005      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 49 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [109 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 5 done [0.00s].
## writing ... [1 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules3, by='lift')) 
```

```
##     lhs                    rhs             support confidence    coverage     lift count
## [1] {Acer Aspire,                                                                       
##      Dell Desktop,                                                                      
##      ViewSonic Monitor} => {HP Laptop} 0.005287239     0.8125 0.006507372 4.185928    52
```

#### Apriori 3 generated 1 rule with a lift = 4



```r
## Apriori #4
Rules4 <- apriori(trans, parameter = list(supp = 0.005, conf = 0.7, minlen = 3)) #Covers .05% transactions (N=49), 70% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.7    0.1    1 none FALSE            TRUE       5   0.005      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 49 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.01s].
## sorting and recoding items ... [109 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 5 done [0.00s].
## writing ... [3 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules4, by='lift')) 
```

```
##     lhs                          rhs             support confidence    coverage     lift count
## [1] {Acer Aspire,                                                                             
##      Dell Desktop,                                                                            
##      ViewSonic Monitor}       => {HP Laptop} 0.005287239  0.8125000 0.006507372 4.185928    52
## [2] {ASUS 2 Monitor,                                                                          
##      Dell Desktop,                                                                            
##      Lenovo Desktop Computer} => {iMac}      0.005185562  0.7391304 0.007015760 2.885807    51
## [3] {ASUS 2 Monitor,                                                                          
##      ASUS Monitor}            => {iMac}      0.005083884  0.7142857 0.007117438 2.788805    50
```

#### Apriori 4 generated 3 rules, lift = 2.7-4.1



```r
## Apriori #5
Rules5 <- apriori(trans, parameter = list(supp = 0.005, conf = 0.6, minlen = 3)) #Covers .05% transactions (N=49), 60% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.6    0.1    1 none FALSE            TRUE       5   0.005      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 49 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [109 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 5 done [0.00s].
## writing ... [28 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules5, by='lift')) 
```

```
##      lhs                                         rhs             support confidence    coverage     lift count
## [1]  {Acer Aspire,                                                                                            
##       Dell Desktop,                                                                                           
##       ViewSonic Monitor}                      => {HP Laptop} 0.005287239  0.8125000 0.006507372 4.185928    52
## [2]  {Acer Aspire,                                                                                            
##       iMac,                                                                                                   
##       ViewSonic Monitor}                      => {HP Laptop} 0.006202339  0.6630435 0.009354347 3.415942    61
## [3]  {Acer Desktop,                                                                                           
##       iMac,                                                                                                   
##       ViewSonic Monitor}                      => {HP Laptop} 0.006405694  0.6363636 0.010066090 3.278489    63
## [4]  {Dell Desktop,                                                                                           
##       Lenovo Desktop Computer,                                                                                
##       ViewSonic Monitor}                      => {HP Laptop} 0.006202339  0.6224490 0.009964413 3.206802    61
## [5]  {Computer Game,                                                                                          
##       ViewSonic Monitor}                      => {HP Laptop} 0.007422471  0.6186441 0.011997966 3.187200    73
## [6]  {Computer Game,                                                                                          
##       Dell Desktop}                           => {HP Laptop} 0.005693950  0.6086957 0.009354347 3.135946    56
## [7]  {Acer Aspire,                                                                                            
##       ViewSonic Monitor}                      => {HP Laptop} 0.010777834  0.6022727 0.017895272 3.102856   106
## [8]  {ASUS 2 Monitor,                                                                                         
##       Dell Desktop,                                                                                           
##       Lenovo Desktop Computer}                => {iMac}      0.005185562  0.7391304 0.007015760 2.885807    51
## [9]  {ASUS 2 Monitor,                                                                                         
##       ASUS Monitor}                           => {iMac}      0.005083884  0.7142857 0.007117438 2.788805    50
## [10] {ASUS 2 Monitor,                                                                                         
##       Microsoft Office Home and Student 2016} => {iMac}      0.005185562  0.6986301 0.007422471 2.727681    51
## [11] {Dell Desktop,                                                                                           
##       Lenovo Desktop Computer,                                                                                
##       ViewSonic Monitor}                      => {iMac}      0.006914082  0.6938776 0.009964413 2.709125    68
## [12] {Apple Magic Keyboard,                                                                                   
##       Dell Desktop,                                                                                           
##       Lenovo Desktop Computer}                => {iMac}      0.005287239  0.6842105 0.007727504 2.671382    52
## [13] {Apple Magic Keyboard,                                                                                   
##       ASUS Monitor}                           => {iMac}      0.006812405  0.6700000 0.010167768 2.615899    67
## [14] {Acer Desktop,                                                                                           
##       HP Laptop,                                                                                              
##       ViewSonic Monitor}                      => {iMac}      0.006405694  0.6562500 0.009761057 2.562215    63
## [15] {Acer Desktop,                                                                                           
##       ASUS 2 Monitor}                         => {iMac}      0.006405694  0.6428571 0.009964413 2.509925    63
## [16] {ASUS Monitor,                                                                                           
##       ViewSonic Monitor}                      => {iMac}      0.008235892  0.6377953 0.012913066 2.490161    81
## [17] {ASUS Monitor,                                                                                           
##       Dell Desktop}                           => {iMac}      0.007930859  0.6341463 0.012506355 2.475915    78
## [18] {Acer Desktop,                                                                                           
##       HP Laptop,                                                                                              
##       Lenovo Desktop Computer}                => {iMac}      0.006304016  0.6326531 0.009964413 2.470085    62
## [19] {ASUS Monitor,                                                                                           
##       Lenovo Desktop Computer}                => {iMac}      0.009761057  0.6315789 0.015455008 2.465891    96
## [20] {ASUS 2 Monitor,                                                                                         
##       Dell Desktop}                           => {iMac}      0.009049314  0.6312057 0.014336553 2.464433    89
## [21] {Acer Desktop,                                                                                           
##       Apple Magic Keyboard}                   => {iMac}      0.006710727  0.6226415 0.010777834 2.430996    66
## [22] {ASUS Monitor,                                                                                           
##       Microsoft Office Home and Student 2016} => {iMac}      0.005998983  0.6145833 0.009761057 2.399534    59
## [23] {Belkin Mouse Pad,                                                                                       
##       Microsoft Office Home and Student 2016} => {iMac}      0.005490595  0.6136364 0.008947636 2.395837    54
## [24] {Apple MacBook Pro,                                                                                      
##       ASUS Monitor}                           => {iMac}      0.005388917  0.6022727 0.008947636 2.351470    53
## [25] {HP Laptop,                                                                                              
##       HP Monitor,                                                                                             
##       Lenovo Desktop Computer}                => {iMac}      0.005388917  0.6022727 0.008947636 2.351470    53
## [26] {HP Laptop,                                                                                              
##       Lenovo Desktop Computer,                                                                                
##       ViewSonic Monitor}                      => {iMac}      0.008439248  0.6014493 0.014031520 2.348255    83
## [27] {Acer Desktop,                                                                                           
##       ASUS Monitor}                           => {iMac}      0.005795628  0.6000000 0.009659380 2.342596    57
## [28] {Dell Desktop,                                                                                           
##       Microsoft Office Home and Student 2016} => {iMac}      0.009456024  0.6000000 0.015760041 2.342596    93
```

#### Apriori 5 generated 28 rules, lift = 2.3-4.8



```r
## Apriori #6
Rules6 <- apriori(trans, parameter = list(supp = 0.006, conf = 0.6, minlen = 3)) #Covers .06% transactions (N=59), 60% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.6    0.1    1 none FALSE            TRUE       5   0.006      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 59 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [102 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 5 done [0.00s].
## writing ... [17 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules6, by='lift')) 
```

```
##      lhs                                         rhs             support confidence    coverage     lift count
## [1]  {Acer Aspire,                                                                                            
##       iMac,                                                                                                   
##       ViewSonic Monitor}                      => {HP Laptop} 0.006202339  0.6630435 0.009354347 3.415942    61
## [2]  {Acer Desktop,                                                                                           
##       iMac,                                                                                                   
##       ViewSonic Monitor}                      => {HP Laptop} 0.006405694  0.6363636 0.010066090 3.278489    63
## [3]  {Dell Desktop,                                                                                           
##       Lenovo Desktop Computer,                                                                                
##       ViewSonic Monitor}                      => {HP Laptop} 0.006202339  0.6224490 0.009964413 3.206802    61
## [4]  {Computer Game,                                                                                          
##       ViewSonic Monitor}                      => {HP Laptop} 0.007422471  0.6186441 0.011997966 3.187200    73
## [5]  {Acer Aspire,                                                                                            
##       ViewSonic Monitor}                      => {HP Laptop} 0.010777834  0.6022727 0.017895272 3.102856   106
## [6]  {Dell Desktop,                                                                                           
##       Lenovo Desktop Computer,                                                                                
##       ViewSonic Monitor}                      => {iMac}      0.006914082  0.6938776 0.009964413 2.709125    68
## [7]  {Apple Magic Keyboard,                                                                                   
##       ASUS Monitor}                           => {iMac}      0.006812405  0.6700000 0.010167768 2.615899    67
## [8]  {Acer Desktop,                                                                                           
##       HP Laptop,                                                                                              
##       ViewSonic Monitor}                      => {iMac}      0.006405694  0.6562500 0.009761057 2.562215    63
## [9]  {Acer Desktop,                                                                                           
##       ASUS 2 Monitor}                         => {iMac}      0.006405694  0.6428571 0.009964413 2.509925    63
## [10] {ASUS Monitor,                                                                                           
##       ViewSonic Monitor}                      => {iMac}      0.008235892  0.6377953 0.012913066 2.490161    81
## [11] {ASUS Monitor,                                                                                           
##       Dell Desktop}                           => {iMac}      0.007930859  0.6341463 0.012506355 2.475915    78
## [12] {Acer Desktop,                                                                                           
##       HP Laptop,                                                                                              
##       Lenovo Desktop Computer}                => {iMac}      0.006304016  0.6326531 0.009964413 2.470085    62
## [13] {ASUS Monitor,                                                                                           
##       Lenovo Desktop Computer}                => {iMac}      0.009761057  0.6315789 0.015455008 2.465891    96
## [14] {ASUS 2 Monitor,                                                                                         
##       Dell Desktop}                           => {iMac}      0.009049314  0.6312057 0.014336553 2.464433    89
## [15] {Acer Desktop,                                                                                           
##       Apple Magic Keyboard}                   => {iMac}      0.006710727  0.6226415 0.010777834 2.430996    66
## [16] {HP Laptop,                                                                                              
##       Lenovo Desktop Computer,                                                                                
##       ViewSonic Monitor}                      => {iMac}      0.008439248  0.6014493 0.014031520 2.348255    83
## [17] {Dell Desktop,                                                                                           
##       Microsoft Office Home and Student 2016} => {iMac}      0.009456024  0.6000000 0.015760041 2.342596    93
```

#### Apriori 6 generated 17 rules, lift = 2.3-3.1



```r
## Apriori #7
Rules7 <- apriori(trans, parameter = list(supp = 0.007, conf = 0.6, minlen = 3)) #Covers .07% transactions (N=68), 60% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.6    0.1    1 none FALSE            TRUE       5   0.007      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 68 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [97 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 done [0.00s].
## writing ... [8 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules7, by='lift')) 
```

```
##     lhs                                         rhs             support confidence   coverage     lift count
## [1] {Computer Game,                                                                                         
##      ViewSonic Monitor}                      => {HP Laptop} 0.007422471  0.6186441 0.01199797 3.187200    73
## [2] {Acer Aspire,                                                                                           
##      ViewSonic Monitor}                      => {HP Laptop} 0.010777834  0.6022727 0.01789527 3.102856   106
## [3] {ASUS Monitor,                                                                                          
##      ViewSonic Monitor}                      => {iMac}      0.008235892  0.6377953 0.01291307 2.490161    81
## [4] {ASUS Monitor,                                                                                          
##      Dell Desktop}                           => {iMac}      0.007930859  0.6341463 0.01250635 2.475915    78
## [5] {ASUS Monitor,                                                                                          
##      Lenovo Desktop Computer}                => {iMac}      0.009761057  0.6315789 0.01545501 2.465891    96
## [6] {ASUS 2 Monitor,                                                                                        
##      Dell Desktop}                           => {iMac}      0.009049314  0.6312057 0.01433655 2.464433    89
## [7] {HP Laptop,                                                                                             
##      Lenovo Desktop Computer,                                                                               
##      ViewSonic Monitor}                      => {iMac}      0.008439248  0.6014493 0.01403152 2.348255    83
## [8] {Dell Desktop,                                                                                          
##      Microsoft Office Home and Student 2016} => {iMac}      0.009456024  0.6000000 0.01576004 2.342596    93
```

#### Apriori 7 generated 8 rules, lift = 2.3-3.1



```r
## Apriori #8
Rules8 <- apriori(trans, parameter = list(supp = 0.008, conf = 0.6, minlen = 3)) #Covers .08% transactions (N=78), 60% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.6    0.1    1 none FALSE            TRUE       5   0.008      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 78 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [93 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 done [0.00s].
## writing ... [6 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules8, by='lift')) 
```

```
##     lhs                                         rhs             support confidence   coverage     lift count
## [1] {Acer Aspire,                                                                                           
##      ViewSonic Monitor}                      => {HP Laptop} 0.010777834  0.6022727 0.01789527 3.102856   106
## [2] {ASUS Monitor,                                                                                          
##      ViewSonic Monitor}                      => {iMac}      0.008235892  0.6377953 0.01291307 2.490161    81
## [3] {ASUS Monitor,                                                                                          
##      Lenovo Desktop Computer}                => {iMac}      0.009761057  0.6315789 0.01545501 2.465891    96
## [4] {ASUS 2 Monitor,                                                                                        
##      Dell Desktop}                           => {iMac}      0.009049314  0.6312057 0.01433655 2.464433    89
## [5] {HP Laptop,                                                                                             
##      Lenovo Desktop Computer,                                                                               
##      ViewSonic Monitor}                      => {iMac}      0.008439248  0.6014493 0.01403152 2.348255    83
## [6] {Dell Desktop,                                                                                          
##      Microsoft Office Home and Student 2016} => {iMac}      0.009456024  0.6000000 0.01576004 2.342596    93
```

#### Apriori 8 generated 6 rules, lift = 2.3-3.1



```r
## Apriori #9
Rules9 <- apriori(trans, parameter = list(supp = 0.009, conf = 0.6, minlen = 3)) #Covers .09% transactions (N=88), 60% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.6    0.1    1 none FALSE            TRUE       5   0.009      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 88 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [87 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 done [0.00s].
## writing ... [4 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules9, by='lift')) 
```

```
##     lhs                                         rhs             support confidence   coverage     lift count
## [1] {Acer Aspire,                                                                                           
##      ViewSonic Monitor}                      => {HP Laptop} 0.010777834  0.6022727 0.01789527 3.102856   106
## [2] {ASUS Monitor,                                                                                          
##      Lenovo Desktop Computer}                => {iMac}      0.009761057  0.6315789 0.01545501 2.465891    96
## [3] {ASUS 2 Monitor,                                                                                        
##      Dell Desktop}                           => {iMac}      0.009049314  0.6312057 0.01433655 2.464433    89
## [4] {Dell Desktop,                                                                                          
##      Microsoft Office Home and Student 2016} => {iMac}      0.009456024  0.6000000 0.01576004 2.342596    93
```

#### Apriori 9 generated 6 rules with lift = 1.5-2.2



```r
## Apriori #10
Rules10 <- apriori(trans, parameter = list(supp = 0.01, conf = 0.6, minlen = 3)) #Covers 1% transactions (N=98), 60% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.6    0.1    1 none FALSE            TRUE       5    0.01      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 98 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [82 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 done [0.00s].
## writing ... [1 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules10, by='lift')) 
```

```
##     lhs                                rhs         support    confidence
## [1] {Acer Aspire,ViewSonic Monitor} => {HP Laptop} 0.01077783 0.6022727 
##     coverage   lift     count
## [1] 0.01789527 3.102856 106
```

#### Apriori 10 generated 1 rule, lift = 3.1



```r
## Apriori #11
Rules11 <- apriori(trans, parameter = list(supp = 0.01, conf = 0.5, minlen = 3)) ###Covers 1% transactions (N=98), 50% correct
```

```
## Apriori
## 
## Parameter specification:
##  confidence minval smax arem  aval originalSupport maxtime support minlen
##         0.5    0.1    1 none FALSE            TRUE       5    0.01      3
##  maxlen target  ext
##      10  rules TRUE
## 
## Algorithmic control:
##  filter tree heap memopt load sort verbose
##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
## 
## Absolute minimum support count: 98 
## 
## set item appearances ...[0 item(s)] done [0.00s].
## set transactions ...[125 item(s), 9835 transaction(s)] done [0.00s].
## sorting and recoding items ... [82 item(s)] done [0.00s].
## creating transaction tree ... done [0.00s].
## checking subsets of size 1 2 3 4 done [0.00s].
## writing ... [19 rule(s)] done [0.00s].
## creating S4 object  ... done [0.00s].
```

```r
inspect(sort(Rules11[1:10], by='lift')) 
```

```
##      lhs                                         rhs            support confidence   coverage     lift count
## [1]  {Acer Aspire,                                                                                          
##       ViewSonic Monitor}                      => {HP Laptop} 0.01077783  0.6022727 0.01789527 3.102856   106
## [2]  {ASUS 2 Monitor,                                                                                       
##       Lenovo Desktop Computer}                => {iMac}      0.01087951  0.5911602 0.01840366 2.308083   107
## [3]  {Apple Magic Keyboard,                                                                                 
##       Dell Desktop}                           => {iMac}      0.01016777  0.5847953 0.01738688 2.283232   100
## [4]  {ASUS Monitor,                                                                                         
##       HP Laptop}                              => {iMac}      0.01179461  0.5829146 0.02023386 2.275889   116
## [5]  {ASUS 2 Monitor,                                                                                       
##       HP Laptop}                              => {iMac}      0.01108287  0.5828877 0.01901373 2.275784   109
## [6]  {HP Laptop,                                                                                            
##       Microsoft Office Home and Student 2016} => {iMac}      0.01291307  0.5521739 0.02338587 2.155868   127
## [7]  {Acer Desktop,                                                                                         
##       ViewSonic Monitor}                      => {iMac}      0.01006609  0.5439560 0.01850534 2.123782    99
## [8]  {Apple Magic Keyboard,                                                                                 
##       Lenovo Desktop Computer}                => {iMac}      0.01138790  0.5161290 0.02206406 2.015137   112
## [9]  {Apple Magic Keyboard,                                                                                 
##       HP Laptop}                              => {iMac}      0.01474326  0.5105634 0.02887646 1.993406   145
## [10] {HP Laptop,                                                                                            
##       HP Monitor}                             => {iMac}      0.01057448  0.5024155 0.02104728 1.961594   104
```

#### Apriori 11 generated 19 total association rules, lift = 1.9-3.1. This appears to be our best rule, because it generated 19 total rules, has a good amount of support (1% frequency), confidence (50% accuracy), and lift of 1.5-3.1 (>1 indicates effectiveness). We will further inspect support, confidence, and lift to confirm.



```r
# inspect support
support11 <- data.frame(inspect(sort(Rules11, by = 'support', decreasing = TRUE))) #Dell desktop and ViewSonic Monitor (#2) had greatest support at 1.5% (n=150 count)
```

```
##      lhs                                         rhs            support confidence   coverage     lift count
## [1]  {HP Laptop,                                                                                            
##       Lenovo Desktop Computer}                => {iMac}      0.02308083  0.5000000 0.04616167 1.952164   227
## [2]  {Dell Desktop,                                                                                         
##       Lenovo Desktop Computer}                => {iMac}      0.01860702  0.5069252 0.03670564 1.979202   183
## [3]  {Acer Desktop,                                                                                         
##       HP Laptop}                              => {iMac}      0.01596340  0.5114007 0.03121505 1.996675   157
## [4]  {Lenovo Desktop Computer,                                                                              
##       ViewSonic Monitor}                      => {iMac}      0.01576004  0.5555556 0.02836807 2.169071   155
## [5]  {Dell Desktop,                                                                                         
##       ViewSonic Monitor}                      => {HP Laptop} 0.01525165  0.5747126 0.02653787 2.960869   150
## [6]  {Apple Magic Keyboard,                                                                                 
##       HP Laptop}                              => {iMac}      0.01474326  0.5105634 0.02887646 1.993406   145
## [7]  {Dell Desktop,                                                                                         
##       ViewSonic Monitor}                      => {iMac}      0.01474326  0.5555556 0.02653787 2.169071   145
## [8]  {HP Laptop,                                                                                            
##       Microsoft Office Home and Student 2016} => {iMac}      0.01291307  0.5521739 0.02338587 2.155868   127
## [9]  {CYBERPOWER Gamer Desktop,                                                                             
##       ViewSonic Monitor}                      => {iMac}      0.01281139  0.5271967 0.02430097 2.058348   126
## [10] {Acer Desktop,                                                                                         
##       Lenovo Desktop Computer}                => {iMac}      0.01230300  0.5307018 0.02318251 2.072033   121
## [11] {CYBERPOWER Gamer Desktop,                                                                             
##       ViewSonic Monitor}                      => {HP Laptop} 0.01220132  0.5020921 0.02430097 2.586734   120
## [12] {ASUS Monitor,                                                                                         
##       HP Laptop}                              => {iMac}      0.01179461  0.5829146 0.02023386 2.275889   116
## [13] {Apple Magic Keyboard,                                                                                 
##       Lenovo Desktop Computer}                => {iMac}      0.01138790  0.5161290 0.02206406 2.015137   112
## [14] {ASUS 2 Monitor,                                                                                       
##       HP Laptop}                              => {iMac}      0.01108287  0.5828877 0.01901373 2.275784   109
## [15] {ASUS 2 Monitor,                                                                                       
##       Lenovo Desktop Computer}                => {iMac}      0.01087951  0.5911602 0.01840366 2.308083   107
## [16] {Acer Aspire,                                                                                          
##       ViewSonic Monitor}                      => {HP Laptop} 0.01077783  0.6022727 0.01789527 3.102856   106
## [17] {HP Laptop,                                                                                            
##       HP Monitor}                             => {iMac}      0.01057448  0.5024155 0.02104728 1.961594   104
## [18] {Apple Magic Keyboard,                                                                                 
##       Dell Desktop}                           => {iMac}      0.01016777  0.5847953 0.01738688 2.283232   100
## [19] {Acer Desktop,                                                                                         
##       ViewSonic Monitor}                      => {iMac}      0.01006609  0.5439560 0.01850534 2.123782    99
```

```r
support11
```

```
## data frame with 0 columns and 0 rows
```


```r
# inspect confidence
confidence11 <- data.frame(inspect(sort(Rules11, by = 'confidence', decreasing = TRUE))) #Acer Aspire and ViewSonic Monitor (#1) had greatest confidence at 60% (although 2nd rule 57%)
```

```
##      lhs                                         rhs            support confidence   coverage     lift count
## [1]  {Acer Aspire,                                                                                          
##       ViewSonic Monitor}                      => {HP Laptop} 0.01077783  0.6022727 0.01789527 3.102856   106
## [2]  {ASUS 2 Monitor,                                                                                       
##       Lenovo Desktop Computer}                => {iMac}      0.01087951  0.5911602 0.01840366 2.308083   107
## [3]  {Apple Magic Keyboard,                                                                                 
##       Dell Desktop}                           => {iMac}      0.01016777  0.5847953 0.01738688 2.283232   100
## [4]  {ASUS Monitor,                                                                                         
##       HP Laptop}                              => {iMac}      0.01179461  0.5829146 0.02023386 2.275889   116
## [5]  {ASUS 2 Monitor,                                                                                       
##       HP Laptop}                              => {iMac}      0.01108287  0.5828877 0.01901373 2.275784   109
## [6]  {Dell Desktop,                                                                                         
##       ViewSonic Monitor}                      => {HP Laptop} 0.01525165  0.5747126 0.02653787 2.960869   150
## [7]  {Dell Desktop,                                                                                         
##       ViewSonic Monitor}                      => {iMac}      0.01474326  0.5555556 0.02653787 2.169071   145
## [8]  {Lenovo Desktop Computer,                                                                              
##       ViewSonic Monitor}                      => {iMac}      0.01576004  0.5555556 0.02836807 2.169071   155
## [9]  {HP Laptop,                                                                                            
##       Microsoft Office Home and Student 2016} => {iMac}      0.01291307  0.5521739 0.02338587 2.155868   127
## [10] {Acer Desktop,                                                                                         
##       ViewSonic Monitor}                      => {iMac}      0.01006609  0.5439560 0.01850534 2.123782    99
## [11] {Acer Desktop,                                                                                         
##       Lenovo Desktop Computer}                => {iMac}      0.01230300  0.5307018 0.02318251 2.072033   121
## [12] {CYBERPOWER Gamer Desktop,                                                                             
##       ViewSonic Monitor}                      => {iMac}      0.01281139  0.5271967 0.02430097 2.058348   126
## [13] {Apple Magic Keyboard,                                                                                 
##       Lenovo Desktop Computer}                => {iMac}      0.01138790  0.5161290 0.02206406 2.015137   112
## [14] {Acer Desktop,                                                                                         
##       HP Laptop}                              => {iMac}      0.01596340  0.5114007 0.03121505 1.996675   157
## [15] {Apple Magic Keyboard,                                                                                 
##       HP Laptop}                              => {iMac}      0.01474326  0.5105634 0.02887646 1.993406   145
## [16] {Dell Desktop,                                                                                         
##       Lenovo Desktop Computer}                => {iMac}      0.01860702  0.5069252 0.03670564 1.979202   183
## [17] {HP Laptop,                                                                                            
##       HP Monitor}                             => {iMac}      0.01057448  0.5024155 0.02104728 1.961594   104
## [18] {CYBERPOWER Gamer Desktop,                                                                             
##       ViewSonic Monitor}                      => {HP Laptop} 0.01220132  0.5020921 0.02430097 2.586734   120
## [19] {HP Laptop,                                                                                            
##       Lenovo Desktop Computer}                => {iMac}      0.02308083  0.5000000 0.04616167 1.952164   227
```

```r
confidence11
```

```
## data frame with 0 columns and 0 rows
```


```r
# inspect lift
lift11 <- data.frame(inspect(sort(Rules11, by = 'lift', decreasing = TRUE)))
```

```
##      lhs                                         rhs            support confidence   coverage     lift count
## [1]  {Acer Aspire,                                                                                          
##       ViewSonic Monitor}                      => {HP Laptop} 0.01077783  0.6022727 0.01789527 3.102856   106
## [2]  {Dell Desktop,                                                                                         
##       ViewSonic Monitor}                      => {HP Laptop} 0.01525165  0.5747126 0.02653787 2.960869   150
## [3]  {CYBERPOWER Gamer Desktop,                                                                             
##       ViewSonic Monitor}                      => {HP Laptop} 0.01220132  0.5020921 0.02430097 2.586734   120
## [4]  {ASUS 2 Monitor,                                                                                       
##       Lenovo Desktop Computer}                => {iMac}      0.01087951  0.5911602 0.01840366 2.308083   107
## [5]  {Apple Magic Keyboard,                                                                                 
##       Dell Desktop}                           => {iMac}      0.01016777  0.5847953 0.01738688 2.283232   100
## [6]  {ASUS Monitor,                                                                                         
##       HP Laptop}                              => {iMac}      0.01179461  0.5829146 0.02023386 2.275889   116
## [7]  {ASUS 2 Monitor,                                                                                       
##       HP Laptop}                              => {iMac}      0.01108287  0.5828877 0.01901373 2.275784   109
## [8]  {Dell Desktop,                                                                                         
##       ViewSonic Monitor}                      => {iMac}      0.01474326  0.5555556 0.02653787 2.169071   145
## [9]  {Lenovo Desktop Computer,                                                                              
##       ViewSonic Monitor}                      => {iMac}      0.01576004  0.5555556 0.02836807 2.169071   155
## [10] {HP Laptop,                                                                                            
##       Microsoft Office Home and Student 2016} => {iMac}      0.01291307  0.5521739 0.02338587 2.155868   127
## [11] {Acer Desktop,                                                                                         
##       ViewSonic Monitor}                      => {iMac}      0.01006609  0.5439560 0.01850534 2.123782    99
## [12] {Acer Desktop,                                                                                         
##       Lenovo Desktop Computer}                => {iMac}      0.01230300  0.5307018 0.02318251 2.072033   121
## [13] {CYBERPOWER Gamer Desktop,                                                                             
##       ViewSonic Monitor}                      => {iMac}      0.01281139  0.5271967 0.02430097 2.058348   126
## [14] {Apple Magic Keyboard,                                                                                 
##       Lenovo Desktop Computer}                => {iMac}      0.01138790  0.5161290 0.02206406 2.015137   112
## [15] {Acer Desktop,                                                                                         
##       HP Laptop}                              => {iMac}      0.01596340  0.5114007 0.03121505 1.996675   157
## [16] {Apple Magic Keyboard,                                                                                 
##       HP Laptop}                              => {iMac}      0.01474326  0.5105634 0.02887646 1.993406   145
## [17] {Dell Desktop,                                                                                         
##       Lenovo Desktop Computer}                => {iMac}      0.01860702  0.5069252 0.03670564 1.979202   183
## [18] {HP Laptop,                                                                                            
##       HP Monitor}                             => {iMac}      0.01057448  0.5024155 0.02104728 1.961594   104
## [19] {HP Laptop,                                                                                            
##       Lenovo Desktop Computer}                => {iMac}      0.02308083  0.5000000 0.04616167 1.952164   227
```

```r
lift11
```

```
## data frame with 0 columns and 0 rows
```


```r
# check quality for rules 11
head(quality(Rules11))
```

```
##      support confidence   coverage     lift count
## 1 0.01087951  0.5911602 0.01840366 2.308083   107
## 2 0.01108287  0.5828877 0.01901373 2.275784   109
## 3 0.01179461  0.5829146 0.02023386 2.275889   116
## 4 0.01291307  0.5521739 0.02338587 2.155868   127
## 5 0.01057448  0.5024155 0.02104728 1.961594   104
## 6 0.01016777  0.5847953 0.01738688 2.283232   100
```


```r
# check for redundancy
inspect(Rules11[is.redundant(Rules11)]) #No redundant rules
```

## plot best set of rules (11)

```r
plot(Rules11)
```

![](Market-Basket-Analysis_files/figure-html/unnamed-chunk-25-1.png)<!-- -->


```r
plot(Rules11, method = 'graph')
```

![](Market-Basket-Analysis_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

## Summarize best set of rules (11)

```r
summary(Rules11)
```

```
## set of 19 rules
## 
## rule length distribution (lhs + rhs):sizes
##  3 
## 19 
## 
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##       3       3       3       3       3       3 
## 
## summary of quality measures:
##     support          confidence        coverage            lift      
##  Min.   :0.01007   Min.   :0.5000   Min.   :0.01739   Min.   :1.952  
##  1st Qu.:0.01098   1st Qu.:0.5110   1st Qu.:0.01962   1st Qu.:2.006  
##  Median :0.01230   Median :0.5440   Median :0.02339   Median :2.156  
##  Mean   :0.01343   Mean   :0.5439   Mean   :0.02495   Mean   :2.234  
##  3rd Qu.:0.01500   3rd Qu.:0.5788   3rd Qu.:0.02745   3rd Qu.:2.280  
##  Max.   :0.02308   Max.   :0.6023   Max.   :0.04616   Max.   :3.103  
##      count      
##  Min.   : 99.0  
##  1st Qu.:108.0  
##  Median :121.0  
##  Mean   :132.1  
##  3rd Qu.:147.5  
##  Max.   :227.0  
## 
## mining info:
##   data ntransactions support confidence
##  trans          9835    0.01        0.5
```

## View top product associations and rules
<table class="table table-striped table-hover" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Rule.# </th>
   <th style="text-align:left;"> Items.purchased.together </th>
   <th style="text-align:left;"> X3 </th>
   <th style="text-align:left;"> Likely.to.be.purchased </th>
   <th style="text-align:right;"> Support </th>
   <th style="text-align:right;"> Confidence </th>
   <th style="text-align:right;"> Coverage </th>
   <th style="text-align:right;"> Lift </th>
   <th style="text-align:right;"> Count </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> [1] </td>
   <td style="text-align:left;"> {Acer Aspire,ViewSonic Monitor} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {HP Laptop} </td>
   <td style="text-align:right;"> 0.0107778 </td>
   <td style="text-align:right;"> 0.6022727 </td>
   <td style="text-align:right;"> 0.0178953 </td>
   <td style="text-align:right;"> 3.102856 </td>
   <td style="text-align:right;"> 106 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [2] </td>
   <td style="text-align:left;"> {Dell Desktop,ViewSonic Monitor} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {HP Laptop} </td>
   <td style="text-align:right;"> 0.0152517 </td>
   <td style="text-align:right;"> 0.5747126 </td>
   <td style="text-align:right;"> 0.0265379 </td>
   <td style="text-align:right;"> 2.960869 </td>
   <td style="text-align:right;"> 150 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [3] </td>
   <td style="text-align:left;"> {CYBERPOWER Gamer Desktop,ViewSonic Monitor} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {HP Laptop} </td>
   <td style="text-align:right;"> 0.0122013 </td>
   <td style="text-align:right;"> 0.5020921 </td>
   <td style="text-align:right;"> 0.0243010 </td>
   <td style="text-align:right;"> 2.586734 </td>
   <td style="text-align:right;"> 120 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [4] </td>
   <td style="text-align:left;"> {ASUS 2 Monitor,Lenovo Desktop Computer} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0108795 </td>
   <td style="text-align:right;"> 0.5911602 </td>
   <td style="text-align:right;"> 0.0184037 </td>
   <td style="text-align:right;"> 2.308083 </td>
   <td style="text-align:right;"> 107 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [5] </td>
   <td style="text-align:left;"> {Apple Magic Keyboard,Dell Desktop} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0101678 </td>
   <td style="text-align:right;"> 0.5847953 </td>
   <td style="text-align:right;"> 0.0173869 </td>
   <td style="text-align:right;"> 2.283232 </td>
   <td style="text-align:right;"> 100 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [6] </td>
   <td style="text-align:left;"> {ASUS Monitor,HP Laptop} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0117946 </td>
   <td style="text-align:right;"> 0.5829146 </td>
   <td style="text-align:right;"> 0.0202339 </td>
   <td style="text-align:right;"> 2.275889 </td>
   <td style="text-align:right;"> 116 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [7] </td>
   <td style="text-align:left;"> {ASUS 2 Monitor,HP Laptop} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0110829 </td>
   <td style="text-align:right;"> 0.5828877 </td>
   <td style="text-align:right;"> 0.0190137 </td>
   <td style="text-align:right;"> 2.275784 </td>
   <td style="text-align:right;"> 109 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [8] </td>
   <td style="text-align:left;"> {Dell Desktop,ViewSonic Monitor} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0147433 </td>
   <td style="text-align:right;"> 0.5555556 </td>
   <td style="text-align:right;"> 0.0265379 </td>
   <td style="text-align:right;"> 2.169071 </td>
   <td style="text-align:right;"> 145 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [9] </td>
   <td style="text-align:left;"> {Lenovo Desktop Computer,ViewSonic Monitor} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0157600 </td>
   <td style="text-align:right;"> 0.5555556 </td>
   <td style="text-align:right;"> 0.0283681 </td>
   <td style="text-align:right;"> 2.169071 </td>
   <td style="text-align:right;"> 155 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [10] </td>
   <td style="text-align:left;"> {HP Laptop,Microsoft Office Home and Student 2016} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0129131 </td>
   <td style="text-align:right;"> 0.5521739 </td>
   <td style="text-align:right;"> 0.0233859 </td>
   <td style="text-align:right;"> 2.155868 </td>
   <td style="text-align:right;"> 127 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [11] </td>
   <td style="text-align:left;"> {Acer Desktop,ViewSonic Monitor} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0100661 </td>
   <td style="text-align:right;"> 0.5439560 </td>
   <td style="text-align:right;"> 0.0185053 </td>
   <td style="text-align:right;"> 2.123782 </td>
   <td style="text-align:right;"> 99 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [12] </td>
   <td style="text-align:left;"> {Acer Desktop,Lenovo Desktop Computer} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0123030 </td>
   <td style="text-align:right;"> 0.5307018 </td>
   <td style="text-align:right;"> 0.0231825 </td>
   <td style="text-align:right;"> 2.072033 </td>
   <td style="text-align:right;"> 121 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [13] </td>
   <td style="text-align:left;"> {CYBERPOWER Gamer Desktop,ViewSonic Monitor} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0128114 </td>
   <td style="text-align:right;"> 0.5271967 </td>
   <td style="text-align:right;"> 0.0243010 </td>
   <td style="text-align:right;"> 2.058348 </td>
   <td style="text-align:right;"> 126 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [14] </td>
   <td style="text-align:left;"> {Apple Magic Keyboard,Lenovo Desktop Computer} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0113879 </td>
   <td style="text-align:right;"> 0.5161290 </td>
   <td style="text-align:right;"> 0.0220641 </td>
   <td style="text-align:right;"> 2.015137 </td>
   <td style="text-align:right;"> 112 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [15] </td>
   <td style="text-align:left;"> {Acer Desktop,HP Laptop} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0159634 </td>
   <td style="text-align:right;"> 0.5114007 </td>
   <td style="text-align:right;"> 0.0312150 </td>
   <td style="text-align:right;"> 1.996675 </td>
   <td style="text-align:right;"> 157 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [16] </td>
   <td style="text-align:left;"> {Apple Magic Keyboard,HP Laptop} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0147433 </td>
   <td style="text-align:right;"> 0.5105634 </td>
   <td style="text-align:right;"> 0.0288765 </td>
   <td style="text-align:right;"> 1.993406 </td>
   <td style="text-align:right;"> 145 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [17] </td>
   <td style="text-align:left;"> {Dell Desktop,Lenovo Desktop Computer} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0186070 </td>
   <td style="text-align:right;"> 0.5069252 </td>
   <td style="text-align:right;"> 0.0367056 </td>
   <td style="text-align:right;"> 1.979202 </td>
   <td style="text-align:right;"> 183 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [18] </td>
   <td style="text-align:left;"> {HP Laptop,HP Monitor} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0105745 </td>
   <td style="text-align:right;"> 0.5024155 </td>
   <td style="text-align:right;"> 0.0210473 </td>
   <td style="text-align:right;"> 1.961594 </td>
   <td style="text-align:right;"> 104 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [19] </td>
   <td style="text-align:left;"> {HP Laptop,Lenovo Desktop Computer} </td>
   <td style="text-align:left;"> =&gt; </td>
   <td style="text-align:left;"> {iMac} </td>
   <td style="text-align:right;"> 0.0230808 </td>
   <td style="text-align:right;"> 0.5000000 </td>
   <td style="text-align:right;"> 0.0461617 </td>
   <td style="text-align:right;"> 1.952164 </td>
   <td style="text-align:right;"> 227 </td>
  </tr>
</tbody>
</table>

## Top Discoveries
#### The following business insights are obtained from the top association rules:

#### 1. Customers who purchase a ViewSonic Monitor with either an Acer Aspire laptop, Dell Desktop, or a CYBERPOWER Gamer Desktop also purchase an HP Laptop. 
* These itemset combinations would serve as an excellent recommendation of items frequently bought together to further boost sales of higher cost items. 

#### 2. Monitors (ViewSonic, ASUS 2, ASUS, HP Monitor) are a popular product purchased alongside desktop computers, as seen in 10 of 19 rules. 
* ViewSonic and ASUS 2 are top and would be excellent recommendation items with any desktop computer brand.

#### 3. iMac Desktops are often purchased with 1 or more other desktop computer brands (Lenovo, Dell, Acer), as seen in 1406 total transactions. 
* It is unclear if customers are buying different brands and keeping all, or buying to test out different brands, only to eventually return less desired desktops. 
* In this situation, it would be prudent to first investigate returns of desktops purchased alongside other desktop computer brands listed above. If customers are more often keeping all desktops, then these higher sale transactions could serve as excellent recommendation opportunities of associated products frequently bought together.


## Actionable insights for Blackwell:
#### 1. Initiate recommender systems for the following products listed within these item sets frequently bought together:
* Acer Aspire, ViewSonic Monitor, HP Laptop
* Dell Desktop, ViewSonic Monitor, HP Laptop
* CYBERPOWER Gamer Desktop, ViewSonic Monitor, HP Laptop
* ASUS Monitor, HP Laptop, iMac
* ASUS 2 Monitor, HP Laptop, iMac
* HP Laptop, Microsoft Office Home and Student 2016, iMac
* CYBERPOWER Gamer Desktop, ViewSonic Monitor, iMac
* HP Laptop, HP Monitor, iMac

#### 2. Send promotional emails to customers who buy specific products within any of the above item sets bulleted above, informing them of products likely to be interesting to them.

#### 3. Recommend ViewSonic and ASUS 2 Monitors as items customers also view each time a desktop computer is viewed or added to cart.

#### 4. Investigate returns of desktops purchased alongside other desktop brands. If customers are more often keeping all desktops, then initiate recommender systems and email promotions as items customers frequently purchase together.

#### 5. Discount the 20 lowest selling electronic products alongside other items recommended to customers in an effort to liquidate products not selling.






