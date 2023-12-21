*********************************************************************** ;
*	SET WORKING DIRECTORY -- REQUIRES USER INPUT!!!	*;
*********************************************************************** ; 

** THIS NEEDS TO BE MANUALLY CHANGED;
%let root   =  C:\Reproducibility_Leadership;

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
/*  C. Circulation report - will only contain what is pertinent to the manuscript. */


* 	Project Summary:
*		We are interested in comparing weight of vehicles with their gas mileage. 
		We hypothesize that vehicles that weigh more will have worse 
		gas mileage than the vehicles that are lighter.	;


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

ods pdf file="&root/Reports/SAS_Version/Circulation_SAS.pdf" 
		nogtitle nogfootnote
		startpage = no
		style = journal;

title1 font='Times'  bold 	height=14pt justify=L "Reproducible Circulation Report Toy Example";
title2 font='Times'  		height=12pt justify=L "PI: Dr. Jane Doe";
title3 font='Times'  		height=12pt justify=L "Analyst: Lauren Gunn-Sandell";
title4 font='Times'  		height=12pt justify=L "Date of report: &sysdate9";

ods text = "^{style [font_face=Times fontsize=12pt]Note this (circulation) report will only contain what is pertinent to the manuscript.}";
ods text = " ";
ods text = "^{style [font_face=Times fontsize=12pt]We are interested in comparing weight of vehicles with their gas mileage. We hypothesize that vehicles that weigh more will have worse gas mileage than the vehicles that are lighter. }";
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
*	ANALYSIS	*;
*********************************************************************** ; 

ods proclabel = 'Regression Analysis';
title "Regression Analysis"; 
ods output 	ParameterEstimates =  ParameterEstimates;
proc reg data = cars; label;
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



ods text = "^{style [font_face=Times fontsize=14pt]End of report.}";

title;
ods pdf close;


* End of program;
quit;
;	*';	*";	*/;


