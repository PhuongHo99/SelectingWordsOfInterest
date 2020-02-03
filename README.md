# Selecting Words of Interest from Text Data
## PROJECT FINAL REPORT
__Name: Phuong Ho__

*This project aims at generating useful data from text input for further analysis given review data sets. I adopt different approaches to access and to understand the data provided such as PROC SQL, PROC IMPORT, PROC PANEL and so on. Most of the macros implemented to read different keywords and compare them with text read from the data. The project’ purpose is also to evaluate the count of important words related to rating stars. I further build some of the other code blocks to compare the star rating distribution of verified purchases compared to those of not verified purchases. From those steps, I can study the patterns existing in reviews’ ratings across different countries, mainly between the UK and the US, and across different products..*

#### 1. Introduction: 

Throughout the project, I am able to utilize the SAS programming language to retrieve useful tags of interest from customer review data available on Amazon Web Server (AWS). In specific, I look at the review body and review header (variable names explained in part (2)) to find keywords objectives. From there, I use PROC PLOT for bar plots to see frequencies of star ratings for the count of negative and positive words I want to scan. Some of the simulating results will be discussed in more detail below. Source codes contain other macros to load, sort data, get frequencies, and other PROC SQL queries. I have written macros to sort data concerning star ratings, get the frequency between two variables, purposefully for star ratings and verification of payments. Moreover, I use PROC SGPLOT and PROC PANEL to examine the distribution of star ratings with and without verified purchases (the purchase that was made through *Amazon* website). Notably, some of the results are different between data sets from different countries.

From applying the source codes, changing word lists and analyzing the results, companies can find important aspects of their services or products which they want to inspect from customer reviews. This would be a great way for them to find other aspects of the products which were rated low or negatively. After that, they could revise more effective business models to improve their products and services. The aspects of their products found in review text data can be packaging, price, condition, usage, quality, etc...

#### 2. Description of Data:

The data used in this project is the dataset named ‘Amazon Customer Reviews Dataset’ retrieved from the AWS. This data set includes customer reviews for different categories in different countries from 1995 to 2015 described in 16 variables (explained in the table below). Accessing the index file and download data files using this link. The data set is mostly clean, already sorted by customer ID, and without any missing values. However, my main focus here is to figure out how to count the keywords of interest from review texts for further analysis to find appropriate aspects of products that need improving. 

The index website page has a total number of 2 sample data sets, 45 US reviews data sets of different categories, and 5 data sets from different countries (US, UK, JP, FR, DE). All the data is separated by tabs, ‘\t’. The first line has header names and each line has one record. Investigating the sample file from France, I notice that the languages for the review body and headline used in data sets differ based on which countries they were collected. For the convenience of this report and my source code, I decide to use mostly the US and UK’s reviews to test and compare. In specific, I can apply the same list of keywords in English that I find important when analyzing the text data from both of the countries. However, ones can still apply my source code to investigate review data in other languages by changing the lists of words that are appealing to them.

First of all, my main focus of this project is to work with text data. Thus, I need to know the differences between the review body and the review headline. While the text headline is the title, the review body is the main part expressing how customers evaluate products. However, looking at the data, the review body is not necessarily longer than the review header. The length differences might depend on customers who wrote them. To make my code more efficient, I employ a MACRO, so I can use the same process for both review headline and review body. 

The second challenge for me while working with this data is to understand what verified purchases by Amazon truly means. The verification purchases refer to all the payments of the products bought by the reviewers through the Amazon website. However, the purchases without verifications do not necessarily mean that the reviewers haven’t bought the products through Amazon. This is because they may use other customer IDs that were different from those used for the reviews to buy the products through Amazon. Likewise, not verified purchases also cannot be inferred that the customers have never bought the products since they could buy products at the stores or other online shopping websites, and then write the reviews on the Amazon website. 

One of the important terms I also have to learn is the meaning is the term helpful votes. The number of helpful votes cast by other customers. This means that every review can be evaluated by other customers through helpful votes. For example, if I bought a cooker, there was a review containing the same opinion as mine about that product. Then, I can mark the review as helpful. Later in this report, I will go over how I investigate the relationship between the number of words in reviews and helpful votes.

Due to the shortcomings of using remote desktop memory, I could not download the file .gz to load data. Thus, I resolved this problem by using part of all the records in two data sets from the US and the UK marketplace as the sampling files. I extracted the first 3000 rows into tab-separated text files and upload them to the remote disk. However, I still include the PROC HTTP at the end of source codes to unzip .gz files for your references.
The specific data sets I used in this project are the following: 

https://s3.amazonaws.com/amazon-reviews-pds/tsv/index.txt
(the index page with all the data sets)

https://s3.amazonaws.com/amazon-reviews-pds/tsv/sample_fr.tsv
 (all of the rows)
 
https://s3.amazonaws.com/amazon-reviews-pds/tsv/amazon_reviews_multilingual_US_v1_00.tsv.gz
(the first 3000 rows)

https://s3.amazonaws.com/amazon-reviews-pds/tsv/amazon_reviews_multilingual_UK_v1_00.tsv.gz
(the first 3000 rows)

Table of the variables used in this report:

| Name of Variable | Meaning | 
| ----------- | ----------- |
| Customer ID  | 	Random identifier that can be used to aggregate reviews written by a single author | 
| Product ID	  |  Unique Product ID the review pertains to. In the multilingual dataset the reviews for the same product in different countries can be grouped by the same product ID | 
| Product parent	 | 		Random identifier that can be used to aggregate reviews for the same product| 
| Star rating  | The star rating of the review from 1 to 5 | 
| Helpful votes | Number of helpful votes| 
| Verified purchase | 	The review is on a verified purchase | 
| Customer ID  | The review text | 
| Review headline | 	The title of the review | 
| Review body | 	The review text | 


#### 3. Strategy Employed:

Loading original tab-separated (.tsv) files from Amazon Web Server is the first challenge I face while doing this project. At first, I attempt doing it through INFILE data steps. Then, I figure out that utilizing PROC IMPORT is highly more efficient to read the data from .tsv files or tab-separated txt files since this PROC step converts them into data sets in SAS at the same time. I define the DELIMITER as tab, ‘09’x in SAS. I set DBMS to DLM to work with both txt and tsv files. Also, the variable headers are included, so I set GETNAMES as YES. Next, I improve the coding efficiency by creating a MACRO to import data. To test the MACRO, I apply it to all sample data from France on the website, and the extracted US and UK files.  At the end of the Source Code page, I also include another way of loading data by using PROC HTTP. I first define FILENAME with URL as a source, and then use INFILE and FILE to download tsv.gz directly from the website. After downloading data, I use the MACRO for PROC IMPORT above to read data as data sets.

Afterward, I adopt the PROC FREQ method to understand the data better. I create a MACRO to output frequency tables of two variables with a defined order for reusability. Specifically, I apply this MACRO mostly to verified purchase and star ratings from two different countries’ review data. I also use the PLOT statement to visualize the distribution of the frequencies of one variable concerning the other variable. 
    
Next, I want to visualize the frequencies of star ratings in verified purchases and not verified ones. The first step I take is to stack the data sets on above each other, and then sort the data by star ratings in descending order. Then, I use VBAR statement in PROC SGPLOT to create bar plots to illustrate the frequency of two categories, verified and not verified purchases from different marketplaces. To do that, I group data by verified purchase and stack the percentage of the two categories for each of marketplace. I also call the SEGLABEL statement to show the correct percentage of each segments and set PCTLEVEL to be GROUP. I also rename axes and redefine style attributes to make the graph look clearer. Thereafter, I employ a PROC SGPANEL to show star rating frequency in verified and not verified purchase in separated the panel by marketplaces. Other statements in SGPANEL are similar to those in SGPLOT above. Since these steps are quite long, I apply a MACRO to cover the PROC functions above. I applied this MACRO to three data files loaded above. With this step, I come up with a result that might be interesting to examine more, which will be discussed later on. From there, I implement PROC SQL queries to count the star rating sorted by product ID or product parents to see which rating appears the most. This would be useful for companies to consider what products they should improve. 

The most challenging part of this project is to deal with words from text data. The first approach I tried to solve the problem is to use two separate arrays, one for keywords and one for words form reviews in a data step. However, this approach could not solve the problem. Thus, I try to divide the solution into smaller pieces of code. I first try to count the number of words in each text data. I use special characters ‘ ,.!’ as DELIMS statement in DATA step to split words in review texts from the SET statement. Then, I define an array to store texts as sentences and loop through the array. I count the number of words by COUNTW function with the sentence at each index and delimiters defined above. To use this process for both review headline and review body, I construct a MACRO with data set for input and output along with variables we want to keep. I use the MACRO for both review headline and review body in the US and UK sampling data (the first 3000 rows).

Thereafter, I hope to assess the relationship between the number of words in review text data with helpful votes. At first, I try the Simple Linear Regression modeling with PROC GLM, but the graphs suggest that the linear regression model is not an appropriate distribution. Thus, I decide to use a Poisson distribution which is better for COUNT data. I utilize PROC GENMOD and define DIST as POISSON. I also call TYPE3 for analysis of Chi-squared statistics with the p-value. I apply this process for four data sets generated by the step above. 

Coming back to the main challenge to count keywords of interest, I employ the SCAN function to generate new data sets. In specific, I count the number of words in a sentence like above and define another loop through each word in the sentence, from 0 to the number of words in that sentence. Then I use the SCAN function for output. For the SCAN function, I use sentences at each index, the index, and delimiters like when I use for counting words. I also build a MACRO for reusing this step for both review headline and review body in the US and UK sampling data (the first 3000 rows). 

From then on, I form data sets for words of interest by using INFILE text files with defined FIRSTOBS and LENGTH options to read the input. To use this step later to load keywords in other languages, I build a MACRO for it. I choose positive, negative, and categorical keywords for this step. I then utilize PROC SQL and queries to generate new data from evaluating matched important keywords with the words separated by the SCAN function above. I also create a table in PROC SQL for the star rating system, so later I can merge the number of positive and negative words. I implement the PROC SQL SELECT query to count the number of words from the three wordlists of my interest. I build a MACRO for this step with the input data set from review data, two output file names (one is the output data including star rating, number of positive words, number of negative words; one is the output for categorical keywords). I applied this MACRO for the four word-separated data sets generated above. Finally, to understand how the positive and negative words in related to star ratings, I build another MACRO. I run PROC SGPLOT to create bar plots showing the percentage of each star rating in the total number of positive or negative words. I test this MACRO using the data sets from the MACRO in the step right before plotting.

#### 4. Results:

First of all, from the three stacked bar plots in Display 1, we can see the percentage distribution for the two categories, verified and not verified the purchase, in the total number of customer reviews from the US, UK, and FR marketplaces. In this plot, we can also tell that there is a huge difference between the column from US sampling data and those of the two other countries. In the US sampling plot, the percentage of purchases without verifications (97.8%) is much bigger than that with verifications (2.2%). The other two plots show the opposite result. The UK column shows that the verified purchases covered about 89.4% of the number of reviews. Similarly, France data set’s column shows 93.9% of reviews come from verified payment through Amazon. 

![alt text](https://github.com/PhuongHo99/SelectingWordsOfInterest.Picture1png "Display1")
 
*Display 1. Three bar plots of star ratings’ percentage in verified purchases and not verified purchases from the US and UK extracted data and France sample data.*

Display 2 presents the panel of frequency of star ratings in verified and not verified purchase for different marketplaces. While the plots from France and the UK sampling data suggests the frequency of star ratings in non-verified purchases does not vary as much as that on verified purchases, the plots from US sampling data show a reverse result. The contradictory between the three plots might happen as a result of the date range I select when extracting data. The first 3000 rows of the UK data and 50 rows of France sample data are retrieved between the year 2014 and 2015 while the first 3000 rows of the US data are from 1995 to 1998. However, this possibility of cause needs more investigations to justify. 

![alt text](https://github.com/PhuongHo99/SelectingWordsOfInterest.Picture2png "Display2")
 
*Display 2. The Panel for bar plots showing star ratings’ frequencies in verified purchases and not verified purchases from the US and UK extracted data and France sample data.*

From the results of PROC GENMOD, I select three specific tables: Model Information, Analysis Of Maximum Likelihood Parameter Estimates, and LR Statistics For Type 3 Analysis in Display 3. The tables are generated from the review headline of US sampling data. The Model Information tells us the data set we use, the response variable and model with LINK function. The next table provides the coefficients (labeled Estimate), their standard errors (error), the Wald Chi-Square statistic, and associated p-values. The coefficients for the number of words in text data are statistically significant (<.0001).   The coefficient for the number of words is 0.0543. This means that the expected increase in log count of helpful votes for a one-unit increase in the number of words is 0.0543. In the last section of Display 3, the likelihood ratio chi-square of 172.87 with a p-value of 0.0001 tells us that our model as a whole fits significantly better than an empty model. In other words, this table indicates that the model between the number of words and helpful votes is statistically significant. There is a thought-provoking finding that the Chi-Square in LS Statistics of PROC GENMOD using the review body in Display 4 (3146.50) is much higher than the Chi-Square statistics of the model above. This may demonstrate using the number of words in the review headline is better for the Poisson model with the number of helpful votes. I also applied PROC GENMOD for UK sampling data and got the same results.

Model Information
Data Set	WORK.COUNTNUM1
Distribution	Poisson
Link Function	Log
Dependent Variable	helpful_votes

Analysis Of Maximum Likelihood Parameter Estimates
Parameter	DF	Estimate	Standard
Error	Wald 95% Confidence Limits	Wald Chi-Square	Pr > ChiSq
Intercept	1	0.5520	0.0289	0.4953	0.6087	364.26	<.0001
numWords	1	0.0543	0.0041	0.0462	0.0623	173.13	<.0001
Scale	0	1.0000	0.0000	1.0000	1.0000		

LR Statistics For Type 3 Analysis
Source	DF	Chi-Square	Pr > ChiSq
numWords	1	172.87	<.0001

*Display 3. The selected table as a result of PROC GENMOD to model Poisson distribution between helpful votes and number of words in review headline from US sampling data*


LR Statistics For Type 3 Analysis
Source	DF	Chi-Square	Pr > ChiSq
numWords	1	3146.50	<.0001

*Display 4. The LR Statistics For Type 3 Analysis of Poisson distribution between helpful votes and number of words in review body from US sampling data*

In Display 5 and Display 6, the distribution of star ratings having negative words in the review body from the US and UK sampling data is shown. This is fairly interesting since the highest rating (5 stars) has the most percentage in the total number of negative words in both countries the US and UK (respectively 62.2% and 55.4%). This might be because the percentage of 5-star rating reviews is the largest from the US and UK data presented in Display 1, but further justifications and tests will be needed. I also try to use the same MACRO for plotting positive words with both of the sampling data above. The percentage of positive words increases as the star rating increases, which is explainable. As people love the products, they will use a lot of good words to describe it.

 ![alt text](https://github.com/PhuongHo99/SelectingWordsOfInterest.Picture5png "Display5")
*Display 5. The bar plot of star rating percentage in the number of negative words in review body from US sampling data*

 ![alt text](https://github.com/PhuongHo99/SelectingWordsOfInterest.Picture6png "Display6")
*Display 6. The bar plot of star rating percentage in the number of negative words in review body from UK sampling data*

#### 5. Discussion:

There are a lot of further research questions raised from the result section above. First of all, we can study the changes in the distribution of verified purchases in the total number of reviews through years or geography suggested in Display 1. Likewise, it is a compelling question to learn the variance of star rating distribution in verified and not verified purchases as presented in Display 2. Looking at Display 3 and Display 4, we might want to find an answer to whether the number of words of text data is stronger than the contents in reviews related to the number of helpful votes. We can also study the prediction of the number of helpful votes based on the number of words in the review headline and review body and compare the models. One can also change parameters in some of the MACROs to plot the frequency plots from the data other countries like CA and JP to see the patterns. Another promising research question is to understand why customers still use negative words in high star ratings presented in Display 5 and Display 6.  

The code and results are also useful for companies’ perspective to find strategies to increase their revenue. Manufacturers can change the important words’ lists to the lists of their own words of interest or in different languages. Additionally, the manufacturers can see positive words compared to negative words that customers wrote in the feedbacks. From that, the company can also want to improve the products so they can receive more positive feedbacks. For example, we can look at Display 7. As a manager, I will focus on improving the battery, air, color, and creative performance for product ID B0002K0ZUI. Apart from those improvements, I look for other improvements that will help my company get better reviews and increase revenue. In contrast, as a manufacturer of product ID 1409155846, I hope to maintain the color of the product since I got a 5-star rating on it.

| Obs | product_id | aspect | star_rating | total |
| ----------- | ----------- |----------- |----------- |----------- |
| 1   | 1409155846 | air | 5 | 1 |
| 2   | 1409155846 | battery | 5 | 1 |
| ... | ... |...| ... | ... |
| 193 | B0002K0ZUI | color | 3 | 1 |
| 194 | B0002K0ZUI | creativity | 3 | 1 |

*Display 7. The table of product ID group by categorical words and star rating in review from US sample data*


