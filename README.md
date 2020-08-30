# Market-Basket-Analysis
## "Customers who purchased this product also viewed or purchased these products...." 
Sound earily familiar? This type of data science is called Market Basket Analysis, which requires a deep investigation of apriori product rules that can help lead to online cross-selling and recommender systems. Not only do I find product associations in this analysis, but I also translate findings to actionable insights for an online retailer, applicability of which is often lacking in other published market basket analyses and tutorials.
* Please see Market-Basket-Analysis.md for full analysis, scroll down for full business insights
* Also available on R Studio's RPubs at https://rpubs.com/brosnahj/MarketBasket
* See 'Market Basket Report.pdf' for business insight report provided to company

## Background
We have been asked by Blackwell Electronics to conduct a Market Basket Analysis on 30 days worth of transactions. Based on this market basket analysis, we will provide insights and purchasing patterns in order to provide product recommendations for cross-selling and recommender opportunities.

## Objective
The purpose of this project is to conduct a Market Basket Analysis to gain insights on customer electronic transactions and find patterns or product relationships. Not only will we apply rules and gain insights, but we will also provide key business insights related to our findings. The following questions will be addressed:
* Are there any interesting patterns or item relationships within Blackwell Electronics transactions?
* Based on your market basket analysis, what product recommendations do you have for Blackwell?

## Data Description
The dataset contains 30 days’ worth of Blackwell Electronics online transactions. Each row is a transaction, which contains only names of items purchased. There are no other variables, numeric or otherwise.

## Analysis plan
We will use basket formatting and apply the apriori algorithm to determine relationships between products.
