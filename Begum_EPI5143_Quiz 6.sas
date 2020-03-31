EPI5143 Winter 2020 Quiz 6.
Due Tuesday March 31st at 11:59PM via Github (link will be provided)

Using the Nencounter table from the class data:
a) How many patients had at least 1 inpatient encounter that started in 2003?
b) How many patients had at least 1 emergency room encounter that started in 2003? 
c) How many patients had at least 1 visit of either type (inpatient or emergency room encounter) that started in 2003?
d) In patients from c) who had at least 1 visit of either type, create a variable that counts the total number encounters (of either type)
-for example, a patient with one inpatient encounter and one emergency room encounter
 would have a total encounter count of 2. Generate a frequency table of total encounter
 number for this data set, and paste the (text) table into your assignment
 - use the SAS tip from class to make the table output text-friendly
ie: 
options formchar="|----|+|---+=|-/\<>*"; 
Additional Info/hints
-you only need to use the NENCOUNTER table for this question 
-EncWID uniquely identifies encounters
-EncPatWID uniquely identifies patients
-Use EncStartDtm to identify encounters occurring in 2003
-EncVisitTypeCd identifies encounter types (EMERG/INPT)

-You will need to flatfile to end up 1 row per patient id, and decide on a strategy to count inpatient, emerg and total encounters for each patient to answer each part of the assignment. 
-There are many ways to accomplish these tasks. You could create one final dataset 
that can be used to answer all of a) through d),
 or you may wish to create different datasets/use different approaches to answer different parts.
 Choose an approach you are most comfortable with, and include lots of comments with your 
 SAS code to describe what your code is doing (makes part marks easier to award and a good practice regardless).

Please submit your solutions through Github as a plain text .sas or .txt file. 
 
 libname classdat"/folders/myfolders/class_data";
 
/*Step1: Create a dataset from the nencounter dataset and keeping cases where their admission 
start date occured in 2003*/
DATA encounter;
	SET classdat.nencounter;
	if 2003= year(datepart(encStartDtm)) then output;
	run;
	/*total of 3327 rows*/

/*just a double check that there is one row per encounter ID in the spine dataset while 
sorting by encwid*/
proc sort data=encounter nodupkey;
	by EncWID;
	run;

/*sort encounter dataset in order by the linking identifier*/
proc sort data=encounter;
	by EncPatWID;
	run;

/*1a) How many patients had at least 1 inpatient encounter that started in 2003?*/

/*Create a seperate column with a numerical value for INPT visits*/
DATA inpatient;
	SET encounter;
	if EncVisitTypeCd= "INPT" then EncVisitTypeCd_INPT=1;
	else EncVisitTypeCd_INPT=0;
	/*keep in mind, characters are in brackets*/
	run;
	
Proc means data=inpatient noprint;
	class EncPatWID;
	types EncPatWID;
	var EncVisitTypeCd_INPT;
	Output out=inpatient2counts max(EncVisitTypeCd_INPT)=EncVisitTypeCd_INPT n(EncVisitTypeCd_INPT)=count1 
	sum(EncVisitTypeCd_INPT)=EncVisitTypeCd_INPT_count1;
	run;

/*Step2: Find the frequency of 1 inpatient visits*/
proc freq data=inpatient2counts order=freq; 
	table EncVisitTypeCd_INPT; 
	run; 
/*1074 patients retrieved

*1074 patients had at least 1 inpatient encounter that started in 2003.

1b) How many patients had at least 1 emergency room encounter that started in 2003?*/

/*Create a seperate column with a numerical value for EMERG visits*/ 
DATA EmergencyRm;
	SET encounter;
	if EncVisitTypeCd= "EMERG" then EncVisitTypeCd_EMERG=1; 
	else EncVisitTypeCd_EMERG=0;
	/*keep in mind, characters are in brackets*/
	run;

Proc means data=EmergencyRm noprint;
	class EncPatWID;
	types EncPatWID;
	var EncVisitTypeCd_EMERG;
	Output out=emerg2counts max(EncVisitTypeCd_EMERG)=EncVisitTypeCd_EMERG n(EncVisitTypeCd_EMERG)=count2 
	sum(EncVisitTypeCd_EMERG)=EncVisitTypeCd_EMERG_count2;
	run;

/*Step2: Find the frequency of 1 emergency visits*/
proc freq data=emerg2counts order=freq; 
	table EncVisitTypeCd_EMERG; 
	run; 

/*1978 patients had at least 1 emergency room encounter that started in 2003.

c) How many patients had at least 1 visit of either type 
(inpatient or emergency room encounter) that started in 2003?*/

DATA final;
	Merge inpatient2counts: (IN=a) emerg2counts: (IN=b);
	by EncPatWID;
	run;
	
proc freq data=final order=freq; 
	table EncVisitTypeCd_INPT*EncVisitTypeCd_EMERG; 
	run; 

/*2891 patients had either INPT or EMERG visits

d) In patients from c) who had at least 1 visit of either type, create a variable
 that counts the total number encounters (of either type)*/

DATA final2; 
	set final; 
	totcount=EncVisitTypeCd_INPT_count1+EncVisitTypeCd_EMERG_count2; 
	run; 
	options formchar="|----|+|---+=|-/\<>*";
proc freq data=final2 order=freq; 
	table totcount; 
	run; 
 
 *							The FREQ Procedure

totcount	Frequency	Percent	Cumulative FrequencyCumulative Percent
	1		2556		88.41			2556				88.41
	2		270			9.34			2826				97.75
	3		45			1.56			2871				99.31
	4		14			0.48			2885				99.79
	5		3			0.10			2888				99.90
	6		1			0.03			2889				99.93
	7		1			0.03			2890				99.97
	12		1			0.03			2891				100.00
 