*********************************************************************
*  Assignment:    RPTD                           
*                                                                    
*  Description:   Realistic example using PROC REPORT
*
*  Name:          Brian Phung
*
*  Date:          2019-04-02                          
*------------------------------------------------------------------- 
*  Job name:      RPTD1_bphung.sas   
*
*  Purpose:       Produce METS Table 8.1, Weight Liability by Treatment Group
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data sets OMRA, DR Lookup Table CARDS
*
*  Output:        RTF file     
*                                                                    
********************************************************************;

%LET job=RPTD1;
%LET onyen=bphung;
%LET outdir=/folders/myfolders/669/assignments/2019-04-02-rptd;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN /*ORIENTATION=LANDSCAPE*/ missing="";
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/669/data/mets" access="read";



/* get list of Meds taken at baseline visit and remove duplicates */
proc sql;
	create table omra as
	select distinct BID, scan(OMRA1,1) as WtLiabMed
		from mets.omra_669
		where OMRA5A="Y" and OMRA4="06"
	;
quit;
/* default delimiters for SCAN include space and dash */


/* input lookup table for Meds and Classification */
data lookup;
	length Med $15 Class $4;
	input Med Class;
cards;
CLOZAPINE HIGH
ZYPREXA HIGH
RISPERIDONE HIGH
SEROQUEL HIGH
INVEGA HIGH
CLOZARIL HIGH
OLANZAPINE HIGH
RISPERDAL HIGH
ZIPREXA HIGH
LARI HIGH
QUETIAPINE HIGH
RISPERDONE HIGH
RISPERIDAL HIGH
RISPERIDOL HIGH
SERAQUEL HIGH
ABILIFY LOW
GEODON LOW
ARIPIPRAZOLE LOW
HALOPERIDOL LOW
PROLIXIN LOW
ZIPRASIDONE LOW
GEODONE LOW
HALDOL LOW
PERPHENAZINE LOW
FLUPHENAZINE LOW
THIOTRIXENE LOW
TRILAFON LOW
TRILOFAN LOW
;
run;


/* applying the lookup */
proc sql;
	create table LUTA1 as
	select BID, WtLiabMed, Class
		from omra as o
		
		left join lookup as l
			on o.WtLiabMed = l.Med	
	;
quit;


/* aggregating classes to create overall_class */
proc sort data=LUTA1 out=LUTA2;
	by BID CLASS;
run;
data LUTA2;
	set LUTA2;
	length test $50 overall_class $4; 
	by BID CLASS;
	
	retain test;
	if first.BID then test="";
	test=catx("",test,class);
/* 	This concatenates all classes for each group of BIDs */

	if missing(test) then overall_class="HIGH";
	else if find(test,"HIGH") then overall_class="HIGH";
	else overall_class="LOW";
/* 	if any of the someone's med classes are HIGH then overall_class is HIGH */
/* 	otherwise to LOW */
	
	if last.BID then output;
	
	keep BID overall_class;
run;
/* proc freq data=luta2; */
/* 	tables test; */
/* run; */


/* merging dr to get TRT group */
data combine;
	merge luta2 mets.dr_669(keep=BID TRT);
	by BID;
	if missing(overall_class) then overall_class="HIGH";
run;


/* duplicate entries to get totals */
data combine2;
	set combine;
	output;
	TRT="Z";
	output;
run;


/* obtain freqencies and percentages */
proc freq data=combine2;
	tables overall_class*TRT / outpct out=for_report;
run;


/* concatenate and transpose frequencies and percentages */
data for_report2;
	set for_report(keep=overall_class TRT COUNT PCT_COL);
	cp=put(count,3.) || ' (' || strip(put(pct_col,4.1)) || ')';
	drop count pct_col;
run;
proc transpose data=for_report2 out=for_report3(drop=_name_) prefix=TRT;
	by overall_class;
	var cp;
	id TRT;
run;


/* obtain chisq p-value */
proc freq data=combine;
	table overall_class*TRT / chisq;
	output out=chisq(keep=p_pchi) pchi;
run;


/* merge p-value onto report dataset */
options mergenoby=nowarn;
data for_report4;
	merge for_report3 chisq;
/* the rare instance where you might want to merge with no BY statement */
run;
options mergenoby=warn;


/* set up class description format */
proc format;
	value $classdesc
		"HIGH"="Participants on higher weight liability antipsychotic meds"
		"LOW"="Participants on lower weight liability antipsychotic meds"
	;
run;


/* get counts into macro variables to be used for headers */
proc freq data=combine2;
	tables trt / out=headercount;
run;
data _null_;
	set headercount(drop=percent);
	
	trtmv="trt" || trt || "n";
	text="n=" || strip(put(count,3.));
	
	call symput(trtmv,text);
run;
%put &=trtan &=trtbn &=trtzn;


ODS RTF FILE="&outdir./&job._&onyen..rtf" STYLE=JOURNAL BODYTITLE;

title "Table 8.1: METS Weight Liability by Treatment Group";
footnote "*Chi-square statistic comparing metformin and placebo groups";
footnote3 "Participants taking both higher and lower weight liability meds
	are included in the higher group.";
proc report data=for_report4 nowd split="|";
	columns overall_class TRTZ TRTA TRTB P_PCHI;
	define overall_class / display format=$classdesc. "" style(column)={cellwidth=1.5in};
	define TRTZ / display "Total|N (%)|&trtzn";
	define TRTA / display "Metformin|N (%)|&trtan";
	define TRTB / display "Placebo|N (%)|&trtbn";
	define P_PCHI / display format=6.4 "P-value*";
run;

ODS RTF CLOSE;