*********************************************************************** ;
*	SET WORKING DIRECTORY -- REQUIRES USER INPUT!!!	*;
*********************************************************************** ; 

** THESE NEED TO BE MANUALLY CHANGED;
%let root   =  C:\Reproducibility_Leadership;
* Define the SAS program to be printing the syntax for (i.e., this SAS program for the comprehensive report);
%let sasprgm = C:\Reproducibility_Leadership\Code\SAS_Version\Comprehensive.sas;

*----------------------------------------------------------------------*; 
*	PROJECT TITLE:		Reproducibility and Leadership in 
							Statistics and Research
*	AUTHOR/ANALYST:		Lauren Gunn-Sandell 
*	INVESTIGATORS:		...
*	DATE CREATED: 		09DEC2023 
*	DATE LAST REVISED: 	15DEC2023 
*	VERSION DETAILS:	SAS v 9.4 on Windows 64
*	MODIFICATIONS:		10Dec2023 - Added regression analysis					
*----------------------------------------------------------------------*; run;

* REPORT TYPE:
/*  A. Comprehensive report - Keeping code/syntax, otherwise the same as collaborator report. */


* 	Project Summary:
*		We are interested in comparing weight of vehicles with their gas mileage. 
		We hypothesize that vehicles that weigh more than 3,500 lbs will have worse 
		gas mileage than the vehicles that do not.	;


*********************************************************************** ;
*	START REPORT	*;
*********************************************************************** ; 

* Create SAS libraries;
libname dataraw  	"&root/DataRaw";
libname code		"&root/Code";
libname reports		"&root/Reports";

options topmargin=1in bottommargin=1in
       leftmargin=1in rightmargin=1in;
options nodate;
ods escapechar='^';

ods pdf file="&root/Reports/SAS_Version/Comprehensive_SAS.pdf" 
		nogtitle nogfootnote
		startpage = no
		style = journal;

title1 font='Times'  bold 	height=14pt justify=L "Reproducible Comprehensive Report Toy Example";
title2 font='Times'  		height=12pt justify=L "PI: Dr. Jane Doe";
title3 font='Times'  		height=12pt justify=L "Analyst: Lauren Gunn-Sandell";
title4 font='Times'  		height=12pt justify=L "Date of report: &sysdate9";
title5 font='Times'	 		height=12pt justify=L "Updates: ";

ods text = "^{style [font_face=Times fontsize=12pt]1. Added in the regression interpretation.}";
ods text = "^{style [font_face=Times fontsize=12pt]2. Determined t test was no longer applicable to main analysis.}";
ods text = " ";
ods text = "^{style [font_face=Times fontsize=12pt]Note this (comprehensive) report will be very similar to the collaborator report, differing only by inclusion of code syntax at the end.}";

ods text = " ";
ods text = "^{style [font_face=Times fontsize=12pt]We are interested in comparing weight of vehicles with their gas mileage. We hypothesize that vehicles that weigh more than 3,500 lbs will have worse gas mileage than the vehicles that do not. }";
ods text = " ";


*********************************************************************** ;
*	READ IN DATA	*;
*********************************************************************** ; 
title "Data Management";
* we are using sashelp.cars dataset;
data work.cars;
	set sashelp.cars;
run;
title;


*********************************************************************** ;
*	DATA MANAGEMENT	*;
*********************************************************************** ; 

* Create categorical weight variable:
  * name variables appropriately and consistently such as
	using similar style (snake_case, camelCase or PascalCase);
  * this program will use snake_case;
  
title "Create a new binary variable for vehicle weight.";
data work.cars2;
	set work.cars;

	if weight > 3500 then wt_cat = "Heavier than 3500lbs";
		else if weight <= 3500 then wt_cat = "3500lbs or lighter";
	
	label wt_cat = "Weight Categories";
run;
title;


*********************************************************************** ;
*	ANALYSIS	*;
*********************************************************************** ; 
ods text = " ";
ods text = "^{style [font_face=Times fontsize=12pt]Analysis plan initially included a t test as seen below.}";
ods text = " ";


* Perform t-test;
ods proclabel = 'T-Test Analysis';
title "T-test Analysis";
ods output  TTests = ttest_variance
			statistics = ttest_results
			Equality = test_results2;
proc ttest data = cars2;
	class wt_cat;
	var MPG_City;
run;

*	Assign macro values for t-test statistic and p-value for report;
data _null_;
	set test_results2;
	call symputx ("test_stat", put(Fvalue, 5.2));
	call symputx ("pval", put(ProbF, pvalue6.3));
run;





*	T-test Results Interpretation;
ods text = " ";
ods text = "^{style [font_face=Times fontsize=12pt]The t test comparing mean city gas mileage between cars that weigh over 3500lbs and those that are equal to and less than 3500 have a significant difference (&test_stat, p&pval).}";
ods text = " ";

data mean_diff;
	set ttest_results(where = (method = " "));
	keep variable class n mean LowerCLMean UpperCLMean;
run;

ods proclabel = "Mean MPG by Weight Class";
title  "Mean MPG by Weight Class";
proc print data = mean_diff noobs;
	format mean LowerCLMean UpperCLMean 5.2;
run;
title;


ods pdf startpage=now; *insert page break for the new regression output;


ods proclabel = 'Regression Analysis';
title "Regression Analysis"; 
ods output 	ParameterEstimates =  ParameterEstimates;
proc reg data = cars2; label;
	model MPG_City = weight;
	label 	weight = "Weight"
			MPG_City = "MPG (City)";
quit;

*	Convert estimate to reflect a 1000 pound increase rather than 1 pound;
*	Assign macro values for parameter estimate and p-value for reporting;
data _null_;
	set ParameterEstimates;
	where variable = "Weight";
	estimate_1000 = estimate*1000;
	call symputx ("estimate", put(estimate_1000, 5.2));
	call symputx ("pvalreg", put(ProbT, pvalue6.3));
run;

*	Regression Results Interpretation;
*	Regression Results Interpretation;
ods text = " ";
ods text = "^{style [font_face=Times fontsize=14pt]Interpretation:}";
ods text = "^{style [font_face=Times fontsize=12pt]The linear regression assessing mean city gas mileage shows a significant relationship with car weight. For every one-thousand pound increase in weight, the expected MPG (city) changes by &estimate (p&pvalreg).}";
ods text = " ";

*	Session Info;
ods text = "^{style [font_face=Times fontsize=10pt]Session Information}";
ods text = "^{style [font_face=Times fontsize=10pt]Date: &SYSDATE9}";
ods text = "^{style [font_face=Times fontsize=10pt]Operating System: &SYSSCP, &SYSSCPL}";
ods text = "^{style [font_face=Times fontsize=10pt]SAS Version: &SYSVER}";

ods text = " ";



*********************************************************************** ;
*	CODE TO INCLUDE SYNTAX OF THIS PROGRAM AT END OF REPORT			*;
*********************************************************************** ; 

data thepgm;
	length linenum 8 pgmline $250;
	infile "&sasprgm." length=linelen lrecl=256 missover;
	input @;
	linenum = _n_;
	if linelen = . then do;
	** have a blank line and want to keep it in the output;
		linelen=0;
		pgmline = ' ';
	end;
	if linelen gt 0 then do;
	** have a program line and want to read it;
	input @1 pgmline $varying. linelen;
	end;
	keep linenum pgmline linelen;
run;

title j=c "Program: &sasprgm";
ods proclabel = "Code used to generate results.";
proc report data=thepgm nowd noheader missing
	style(report) ={font_face='Courier New' font_size=10pt rules=none frame=void
	cellspacing=0 cellpadding=2 asis=on outputwidth=100%}
	style(column) ={font_face='Courier New' font_size=10pt asis=on just=l} ;
	column linenum pgmline;
	define linenum / order noprint;
	define pgmline / display;
run;


ods text = "^{style [font_face=Times fontsize=14pt]End of report.}";

title;
ods pdf close;







* End of program;
quit;
;	*';	*";	*/;


