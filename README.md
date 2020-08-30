# Market-Basket-Analysis
This analysis is all about, "Customers who purchased this product also viewed or purchased these products...." This is an intense analysis that requires deep investigation of apriori product rules, which lead to online cross-selling and recommender systems. Ultimately, not only do I find product associations, but I also trasnlate those to actionable insights an online retailer can make.
* Please see Market Basket.md for full analysis
* Full analysis also available on R Studio's RPubs at https://rpubs.com/brosnahj/MarketBasket

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
