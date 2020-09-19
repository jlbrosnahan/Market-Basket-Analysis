# The goal of this project is to do a market basket analysis on the dataset 'ElectronidexTransactions'. The dataset contains 9835 online transactions and offering 125 total products, broken down into 17 product types.

# Loading packages
library(tidyverse)
library(openxlsx)
library(knitr)
library(ggplot2)
library(arules)
library(arulesViz)

# Importing data using read.transactions() function for Market Basket analysis
trans <- read.transactions(file.path('C:/Users/jlbro/OneDrive/C3T4', 'ElectronidexTransactions.csv'), format = 'basket', sep=',', rm.duplicates=TRUE)
summary(trans) #Super helpful 

length(trans) #Number of transactions
size(trans) #Number of products in each transaction
NameNum <- data.frame(itemLabels(trans)) #Links Product # to Product Name

# exporting NameNum to excel for future reference
write.xlsx(Item_frequency,"Item Frequency.xlsx", row.names=TRUE)

LIST(trans[1:20]) #Lists the transactions by conversion?
inspect(trans[1:20]) #View transaction baskets
itemFrequency(trans, type = 'absolute') #Frequency of items purchased
Item_frequency <- data.frame(sort(itemFrequency(trans, type = 'absolute'), decreasing = FALSE)) #To visualize itemFrequency in spreadsheet and sort by ascending/descending
head(sort(Item_frequency, decreasing = TRUE), n = 20)
itemFrequencyPlot(trans, topN=20, type = 'absolute', col = 1:20)
itemFrequencyPlot(trans, topN=20, type = 'relative', col = 1:20)
itemFrequencyPlot(trans, topN=30, type = 'absolute', col = 1:30) #Does not work on 125 items
image(sample(trans, 150)) #Shows clusters of product numbers purchase, cannot see actual product numbers

# Insights/observations
### 9835 transactions
### 125 total products
### 43,151 total items were purchased
### Top 5: iMac, HP Laptop, Cyberpower Gamer Desktop, Apple Earpods, Apple MacBook Air
### Items/transaction range is 0-30
### Customers purchase 1 item the most
### The average items purchased is 4.4
### The distribution of items purchased is skewed right
### The top 7 products stand out, after that, item frequency seems to level off
### Image of sample transactions definitely shows clusters of products purchased more frequently

Rules1 <- apriori(trans, parameter = list(supp = 0.1, conf = 0.8, minlen = 3)) #Covers 10% of transactions (N=983), 80% correct
inspect(sort(Rules1, by='lift')) #No rules

Rules2 <- apriori(trans, parameter = list(supp = 0.01, conf = 0.8, minlen = 3)) #Covers 1% of transactions (N=98), 80% correct
inspect(sort(Rules2, by='lift')) #No rules

Rules3 <- apriori(trans, parameter = list(supp = 0.005, conf = 0.8, minlen = 3)) #Covers .05% transactions (N=49), 80% correct
inspect(sort(Rules3, by='lift')) #1 rule, lift = 4

Rules4 <- apriori(trans, parameter = list(supp = 0.005, conf = 0.7, minlen = 3)) #Covers .05% transactions (N=49), 70% correct
inspect(sort(Rules4, by='lift')) #3 rules, lift = 2.7-4.1

Rules5 <- apriori(trans, parameter = list(supp = 0.005, conf = 0.6, minlen = 3)) #Covers .05% transactions (N=49), 60% correct
inspect(sort(Rules5, by='lift')) #28 rules, lift = 2.3-4.8

Rules6 <- apriori(trans, parameter = list(supp = 0.006, conf = 0.6, minlen = 3)) #Covers .06% transactions (N=59), 60% correct
inspect(sort(Rules6, by='lift')) #17 rules, lift = 2.3-3.1

Rules7 <- apriori(trans, parameter = list(supp = 0.007, conf = 0.6, minlen = 3)) #Covers .07% transactions (N=68), 60% correct
inspect(sort(Rules7, by='lift')) #8 rules, lift = 2.3-3.1

Rules8 <- apriori(trans, parameter = list(supp = 0.008, conf = 0.6, minlen = 3)) #Covers .08% transactions (N=78), 60% correct
inspect(sort(Rules8, by='lift')) #6 rules, lift = 2.3-3.1

Rules9 <- apriori(trans, parameter = list(supp = 0.009, conf = 0.6, minlen = 3)) #Covers .09% transactions (N=88), 60% correct
inspect(sort(Rules9, by='lift')) #6 rules, lift = 1.5-2.2

Rules10 <- apriori(trans, parameter = list(supp = 0.01, conf = 0.6, minlen = 3)) #Covers 1% transactions (N=98), 60% correct
inspect(sort(Rules10, by='lift')) #1 rule, lift = 3.1

###Seems best to me
Rules11 <- apriori(trans, parameter = list(supp = 0.01, conf = 0.5, minlen = 3)) ###Covers 1% transactions (N=98), 50% correct
inspect(sort(Rules11[1:10], by='lift')) #19 rules, lift = 1.9-3.1 
support11 <- data.frame(inspect(sort(Rules11, by = 'support', decreasing = TRUE))) #Dell desktop and ViewSonic Monitor (#2) had greatest support at 1.5% (n=150 count)
confidence11 <- data.frame(inspect(sort(Rules11, by = 'confidence', decreasing = TRUE))) #Acer Aspire and ViewSonic Monitor (#1) had greatest confidence at 60% (although 2nd rule 57%)
lift11 <- data.frame(inspect(sort(Rules11, by = 'lift', decreasing = TRUE)))

# exporting to excel for inspection
write.xlsx(support11,"Support_Rules11.xlsx", row.names=TRUE)
write.xlsx(confidence11,"Conf_Rules11.xlsx", row.names=TRUE)
write.xlsx(lift11,"Lift_Rules11.xlsx", row.names=TRUE)

head(quality(Rules11))
inspect(Rules11[is.redundant(Rules11)]) #No redundant rules
inspect(Rules11[!is.redundant(Rules11)]) #No redundant rules
plot(Rules11)
plot(Rules11, method = 'graph')
plot(Rules11, method = 'grouped')
plot(Rules11, measure = c('support','confidence'), shading = 'lift') #the SAME as plot(Rules8)
plot(Rules11, shading = 'order', control=list(main = 'Scatter plot for 19 rules'))
summary(Rules11)

Rules12 <- apriori(trans, parameter = list(supp = 0.01, conf = 0.45, minlen = 3)) ###Covers 1% transactions (N=98), 45% correct
inspect(sort(Rules12, by='lift')) #37 rules, lift = 1.7-3.1

Rules13 <- apriori(trans, parameter = list(supp = 0.003, conf = 0.7, minlen = 3)) #Covers .03% transactions (N=29), 70% correct
inspect(sort(Rules13, by='lift')) #23 rules, lift = 2.7-4.6

Rules14 <- apriori(trans, parameter = list(supp = 0.01, conf = 0.55, minlen = 3)) #Covers 1% transactions (N=29), 55% correct
inspect(sort(Rules14, by='lift')) #9 rules, lift = 2.1-3.1
head(quality(Rules14))
inspect(Rules14[is.redundant(Rules14)]) #No redundant rules
inspect(Rules14[!is.redundant(Rules14)]) #No redundant rules
plot(Rules14)
plot(Rules14, method = 'graph')
plot(Rules14, method = 'grouped')
plot(Rules14, measure = c('support','confidence'), shading = 'lift') #the SAME as plot(Rules8)
plot(Rules14, shading = 'order', control=list(main = 'Scatter plot for 9 rules'))
summary(Rules14)


# Rules #11 (supp=.01, conf=.5) and 14 (supp=.01, conf=.55) seem best.

# For Rule 11, what influenced the purchase of HP Laptops using 'appearance' function?
### Dell Desktop, ViewSonic Monitor, CYBERPOWER Gamer Desktop, Acer Aspire
# For Rule 11, what purchases did HP Laptops influence?
### None
Rule11HP <- apriori(trans, parameter = list(supp = 0.01, conf = 0.5, minlen = 3),
                  appearance = list(default = 'lhs', rhs = 'HP Laptop'))
inspect(sort(Rule11HP, by = 'support', decreasing = TRUE)) #Dell desktop and ViewSonic Monitor (#2) had greatest support at 1.5% (n=150 count)
inspect(sort(Rule11HP, by = 'confidence', decreasing = TRUE)) #Acer Aspire and ViewSonic Monitor (#1) had greatest confidence at 60% (although 2nd rule 57%)
inspect(sort(Rule11HP, by = 'lift', decreasing = TRUE)) #Acer Aspire and ViewSonic Monitor (#1) had greatest lift at 3.1


# For Rule 11, what influenced the purchase of iMacs using 'appearance' function?
### HP Laptop, Lenovo Desktop Computer, Dell Desktop, Acer Desktop, ViewSonic Monitor, Apple Magic Keyboard, Microsoft Office Home & Student 2016, Cyberpower Gamer Desktop, ASUS Monitor, 
# For Rule 11, what purchases did iMacs influence? 
### None
Rule11iMac <- apriori(trans, parameter = list(supp = 0.01, conf = 0.5, minlen = 3),
                    appearance = list(default = 'lhs', rhs = 'iMac'))
inspect(sort(Rule11iMac, by = 'support', decreasing = TRUE)) #HP Laptop and Lenovo Desktop Computer had greatest support at 2.3% (n=227 count)
inspect(sort(Rule11iMac, by = 'confidence', decreasing = TRUE)) #ASUS 2 Monitor and Lenovo Desktop had greatest confidence at 59%
inspect(sort(Rule11iMac, by = 'lift', decreasing = TRUE)) #ASUS 2 Monitor and Lenovo Desktop had greatest lift at 2.3


# For Rule 14, what influenced the purchase of HP Laptops using 'appearance' function?
### Acer Aspire, ViewSonic Monitor, Dell Desktop
# For Rule 14, what purchases did HP Laptops influence? 
### None
Rule14HP <- apriori(trans, parameter = list(supp = 0.01, conf = 0.55, minlen = 3),
                    appearance = list(default = 'lhs', rhs = 'HP Laptop'))
inspect(sort(Rule14HP, by = 'support', decreasing = TRUE)) #Dell desktop and ViewSonic Monitor had greatest support at 1.5% (n=150 count)
inspect(sort(Rule14HP, by = 'confidence', decreasing = TRUE)) #Acer Aspire and ViewSonic Monitor had greatest confidence at 60% (although 2nd rule 57%)
inspect(sort(Rule14HP, by = 'lift', decreasing = TRUE)) #Acer Aspire and ViewSonic Monitor had greatest lift at 3.1


# For Rule 14, what influenced the purchase of iMacs using 'appearance' function?
### Asus 2 Monitor, Lenovo Desktop Computer, Apple Magic Keyboard, Dell Desktop, Asus Monitor, HP Laptop, ViewSonic Monitor, Microsoft Office Home & Student 2016
# For Rule 14, what purchases did iMacs influence? 
### None
Rule14iMac <- apriori(trans, parameter = list(supp = 0.01, conf = 0.5, minlen = 3),
                      appearance = list(default = 'lhs', rhs = 'iMac'))
inspect(sort(Rule14iMac, by = 'support', decreasing = TRUE)) #HP Laptop and Lenovo Desktop Computer had greatest support at 2.3% (n=227 count)
inspect(sort(Rule14iMac, by = 'confidence', decreasing = TRUE)) #ASUS 2 Monitor and Lenovo Desktop had greatest confidence at 59% (n=107)
inspect(sort(Rule14iMac, by = 'lift', decreasing = TRUE)) #ASUS 2 Monitor and Lenovo Desktop had greatest lift at 2.3 (n=107)


















