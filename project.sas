/* 
Filename: project.sas
Date: December 7th, 2019
Author: Phuong Ho
Revision: 3.0
Purpose: SAS final project
Input file: M:\sta402\data\sample_fr.tsv
			M:\sta402\data\amazon_UK_sample.txt
			M:\sta402\data\amazon_US_sample.tsv
			positive-words.txt
			negative-words.txt
			negative-words.txt
Output file:	freq_plot.rtf
				poissonTest.rtf
				rating_plot.rtf
*/

/*MACRO for data file to be used later*/
%let file = "M:\sta402\data\sample_fr.tsv";
%let uk_file = "M:\sta402\data\amazon_UK_sample.txt";
%let us_file = "M:\sta402\data\amazon_US_sample.tsv";
%let positive_file = "M:\sta402\data\positive-words.txt";
%let negative_file = "M:\sta402\data\negative-words.txt";
%let category_file = "M:\sta402\data\category.txt";

/* MACRO to load the data sets from tsv 
	and tab-seperated txt file*/
%macro load_data(infile= , outfile=);
proc import datafile=&infile
            out=&outfile
			dbms = dlm
            replace;
     delimiter='09'x;
	 getnames = yes;
run;
%mend load_data;

/*load sample_us.tsv file*/
options mprint;
%load_data(infile = &file, outfile = sample);
%load_data(infile = &uk_file, outfile = sampleUK);
%load_data(infile = &us_file, outfile = sampleUS);

/*MACRO to get frequence of variable of interest displayed in table*/
%macro get_freq(in =, ord = , variables =, out=, title=);
proc freq data= &in order = &ord; 
	tables &variables /out = &out  nocum plots=freqplot; 
	title &title;
run;
%mend;
/*show frequency between star_rating (from 1-5) and verified_purchase.*/
%get_freq(in=sampleUS,ord=freq,variables=verified_purchase, 
		out =freq_data,title = "Frequencies for star_rating");

/**/
data all;
      set sample sampleUK sampleUS;
run;
proc sort data=all;
      by descending star_rating;
run;
proc sgpanel data=all pctlevel=group;
      panelby marketplace / rows=1;
	  title "Star Rating Frequency By Verfied Purchase or Not "; 
      vbar verified_purchase / stat=percent group = star_rating 
			grouporder=reversedata groupdisplay=stack
			seglabel
			baselineattrs=(thickness=3)
			outlineattrs=(color=cx3f3f3f);
      colaxis label = "Verified Purchase (No or Yes)";
      rowaxis label = "Percentage";
run;

proc sgpanel data=all  pctlevel=group;
		panelby marketplace / rows=1;
	  	title "Star Rating Frequency By Verfied Purchase or Not"; 
      	vbar verified_purchase  / stat=percent group=marketplace
			datalabel 
			baselineattrs=(thickness=3)
			outlineattrs=(color=cx3f3f3f);
      	colaxis label = "Verified Purchase (No or Yes)";
      	rowaxis label = "Percentage";
run;

proc sgplot data=all pctlevel=group;
		title "Star Rating Frequency By Verfied Purchase or Not "; 
		vbar marketplace/ stat=percent 
			group= verified_purchase groupdisplay=stack
			seglabel
			baselineattrs=(thickness=3)
			outlineattrs=(color=cx3f3f3f);
		xaxis label = "Verified Purchase (No or Yes)";
		yaxis label = "Percentage";
run;

/*
proc sgpanel data=all pctlevel=group;
      panelby marketplace / rows=1;
      vbar verified_purchase / stat=percent group = star_rating 
			grouporder=reversedata groupdisplay=cluster
			baselineattrs=(thickness=3)
			outlineattrs=(color=cx3f3f3f);
      colaxis label = "Verified Purchase (No or Yes)";
      rowaxis label = "Percentage";
run;
*/

/* MACRO to sort data and plot vertical bar plots using
	the frequency distribution of star rating by verified payment ot not.*/
%macro plot_freq(in = , name= );
proc sort data = &in out = out;
	by  descending star_rating;
run;
proc sgplot data = out;
	title "Star Rating Frequency By Verfied Purchase or Not " &name;
	vbar verified_purchase / stat=percent 
	datalabel
    baselineattrs=(thickness=3)
    outlineattrs=(color=cx3f3f3f);
	xaxis label = "Verified Purchase (No or Yes)";
	yaxis label = "Percentage";
run;

%mend plot_freq;

ods rtf file = "M:\sta402\freq_plot.rtf";
/*try plot_freq macro */
ods html style = default; 
%plot_freq(in= sample, name = from France sample data);
%plot_freq(in= sampleUK, name = from UK sample data);
%plot_freq(in= sampleUS, name = from US sample data);
ods rtf close;

/*PROC SQL to pull out counts of the same productId or same parents*/
proc sql;
	/*create table from sample data*/
	create table sample_sql
	as 
	select * from sample;

	/*Show the number of reviews by product_id and star_rating*/
	select product_id, star_rating, count(*) as total
	from sample_sql
	group by product_id, star_rating
	order by star_rating desc;

	/*Show the number of reviews by product_parent and star_rating*/
	select product_parent,  count(*) as total
	from sample_sql
	group by product_parent;
quit;

/*MACRO to count words in the text*/
%macro countWords(data = , in = ,keepIn =, var = , dropOut= );
data &data;
	set &in (keep = &keepIn);
	delims = ' ,.!'; /* delimiters: space, comma, period, ... */
	array sentence{*} &var;
	/* for each line of text, count words */
	do j =1 to dim(sentence);
		numWords = countw(sentence{j}, delims); 	
	end;
	drop &dropOut;
run;
%mend;
/*applying the macro above for review_headline and review_body
	from US data and UK data*/
%countWords(data =countNumHead, in = sampleUK, 
		keepIn = review_headline review_id helpful_votes,
		var = review_headline, dropOut= delims j);
%countWords(data =countNumBody, in = sampleUK, 
		keepIn = review_body review_id helpful_votes,
		var = review_body, dropOut= delims j);
%countWords(data =countNum1, in = sampleUS, 
		keepIn = review_headline helpful_votes,
	var = review_headline, dropOut= delims j);
%countWords(data =countNum2, in = sampleUS, 
		keepIn = review_body helpful_votes,
	var = review_body, dropOut= delims j);

ods rtf file = "M:\sta402\poissonTest.rtf";
/*PROC GENMOD to test Poisson distribution between 
	helpful votes and the number of words */
proc genmod data = countNumHead;
  model helpful_votes= numWords / type3 dist=poisson;
run;
proc genmod data = countNumBody;
  model helpful_votes= numWords / type3 dist=poisson;
run;
proc genmod data = countNum1;
  model helpful_votes= numWords / type3 dist=poisson;
run;
proc genmod data = countNum2;
  model helpful_votes= numWords / type3 dist=poisson;
run;
ods rtf close;

/*MACRO to seperate words within one text*/
%macro seperateWords(data =, in=, keep=, var=, keepOut= );
data &data;
	set &in (keep = &keep);
	delims = ' ,.!'; /* delimiters: space, comma, period, ... */
	array sentence{*} &var;
	
	do j =1 to dim(sentence);
	/* for each line of text, count words */
		numWords = countw(sentence{j}, delims);  
		do i = 1 to numWords;          
		/* split text into words */
	  		 word = scan(sentence{j}, i, delims);
	   	output;	
		end;
	end;
	keep &keepOut;
run;
%mend;
/*seperate words review_headline*/
%seperateWords(data=parseUK, in =sampleUK , 
	keep= review_headline star_rating product_id,
	var = review_headline, keepOut= word star_rating product_id);
%seperateWords(data=parseUKbody,in =sampleUK, 
	keep= review_body star_rating product_id,
	var = review_body, keepOut= word star_rating product_id);
%seperateWords(data=parseUS, in =sampleUS , 
	keep= review_headline star_rating product_id,
	var = review_headline, keepOut= word star_rating product_id);
%seperateWords(data=parseUSbody, in =sampleUS , 
	keep= review_body star_rating product_id,
	var = review_body, keepOut= word star_rating product_id);

/*MACRO to read the extra txt files to compare with data later*/
%macro load_txt(data = , file = , first =, length =, var = );
data &data;
	infile &file
	firstobs= &first; *first obs starts at line 35;
	length &var $ &length;
	input &var;
run;
%mend load_txt;

/*import negative and poisitive words*/
%load_txt(data = GoodList, file =&positive_file, 
		first = 35, length=20, var = goodWords);
%load_txt(data = BadList, file =&negative_file, 
		first = 35, length=30, var = badWords);
/*import category list*/
%load_txt(data = CategoryList, file =&category_file, 
		first =	1, length=30, var = aspect);


/*MACRO to create tables after counting
		positive, negative and category words
		from review texts*/
%macro count_words_interest(infile = , outfile= , outcategory = );
/*PROC SQL to counts positive and negative words*/
proc sql;
	/*create table of words generated by above MACRO*/
	create table words
	as
	select * from &infile;

	/*create table of words */
	create table rating(star_rating int );
	insert into rating (star_rating) values (1);
	insert into rating (star_rating) values (2);
	insert into rating (star_rating) values (3);
	insert into rating (star_rating) values (4);
	insert into rating (star_rating) values (5);

	/*create table of positive words*/
	create table good 
	as
	select * from GoodList;

	/*create table of negative word*/
	create table bad 
	as 
	select * from BadList;

	/*create table form category data*/
	create table category
	as
	select * from CategoryList;

	/*count positive words form review_header*/
	create table positive_feedback 
	as
	select star_rating, count(*) as Num_Positive
	from words
	where lower(word) in (select goodWords from good)
	group by star_rating
	order by star_rating;

	/*count negative words form review_header*/
	create table negative_feedback 
	as
	select  star_rating,count(*) as Num_Negative
	from words
	where lower(word) in (select badWords from bad)
	group by star_rating
	order by star_rating;



	/*create the table of all the count negative and positive words*/
	create table &outfile 
	as 
	select r.star_rating,  
			sum(Num_Positive, 0) as Num_Positive ,  
			sum(Num_Negative, 0) as Num_Negative
	from  positive_feedback p
		join negative_feedback n on n.star_rating = p.star_rating
		full join rating r on r.star_rating = p.star_rating;

	/*count categorical words form review_header*/
	create table &outcategory as
	select product_id, aspect, star_rating, count(*) as total
	from words, category
	where  lower(word) in (select aspect from category)
	group by product_id, aspect, star_rating
	order by  product_id, star_rating;	
quit;
%mend;
%count_words_interest(infile = parseUK, 
	outfile= feedbackUK, outcategory=cateUKreview);
%count_words_interest(infile = parseUS, outfile= feedbackUS, 
	outcategory= cateUSreview);
%count_words_interest(infile=parseUKbody,outfile=feedbackUKbody,  
	outcategory= cateUKbody);
%count_words_interest(infile = parseUSbody, outfile= feedbackUSbody,
	outcategory= cateUSbody);

%macro rating_percent(infile = , response = , name=);
proc sgplot data = &infile;
	title1 "Percentage of Words of Interest by Star Rating " &name;
	vbar star_rating / response= &response stat=percent
	 seglabel 
    baselineattrs=(thickness=3)
    outlineattrs=(color=cx3f3f3f);
	xaxis label = "Star Rating (1-5)";
run;
%mend;

ods rtf file="M:\sta402\rating_plot.rtf";
%rating_percent(infile =feedbackUSbody,response= Num_Negative,  name = US Review Body);
%rating_percent(infile =feedbackUKbody,response= Num_Negative, name = UK Review Body);
ods rtf close;
%rating_percent(infile =feedbackUS,response= Num_Positive);
%rating_percent(infile =feedbackUK,response= Num_Positive);

proc print data = cateUKreview;
run;

/* code for downloading a gz file from a website 
filename webfile url 'https://s3.amazonaws.com/amazon-reviews-pds/tsv/amazon_reviews_us_Wireless_v1_00.tsv.gz';
filename newgz 'M:\sta402\wireless.tsv.gz';
data _null_;
  infile webfile recfm=s nbyte=n length=len; * use the website as the source;
  file  newgz  recfm=n; * use a local gz file as the target;
  input record $varying32767. len; * read something from the website;
  put record; * put it into the local gz file;
run;

*code for unzipping the gz file; 
filename newtsv zip 'M:\sta402\wireless.tsv.gz' gzip;

*now use PROC IMPORT with DATAFILE=newtsv;
%load_data(infile = newtsv, outfile = sample02);
*/
