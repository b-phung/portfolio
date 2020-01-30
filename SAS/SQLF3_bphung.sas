*********************************************************************
*  Assignment:    SQLF                                 
*                                                                    
*  Description:   Sixth collection of SQL problems using 
*                 METS data sets
*
*  Name:          Brian Phung
*
*  Date:          2019-02-07                           
*------------------------------------------------------------------- 
*  Job name:      SQLF3_bphung.sas   
*
*  Purpose:       Practice using PROC SQL and JOIN
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data sets UVFA, CGIA, AESA, SAEA, VSFA, AUQA,
				  LABA, BSFA, SMFA
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

%LET job=SQLF3;
%LET onyen=bphung;
%LET outdir=/folders/myfolders/669/assignments/2019-02-07-sqlf;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN ORIENTATION=LANDSCAPE;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/669/data/mets" access="read";


ODS PDF FILE="&outdir./&job._&onyen..pdf" STYLE=JOURNAL;


%macro forms;
proc sql;

/* 1ST STEP: PREPARE REASONS FOR CONCATENATION */

	%let varList=UVFA1A|UVFA1B|UVFA1C|UVFA1D;
	
	create table temp as
	select BID, VISIT, UVFA0B 
	%do i=1 %to 4;
		%let var=%scan(&varList,&i,|);
		, case when &var.="1" then
		
		/* 		extracting the labels for the reasons */
		tranwrd(
			(select label
				from dictionary.columns
				where libname="METS" and memname="UVFA_669" and name="&var."),
			"Reason", ""
		)

		end as Reason&i.
	%end;
		from mets.uvfa_669
	;
	
/* 2ND STEP: CONCATENATE REASONS AND JOIN FORMS ONTO MAIN TABLE */

	%let formList=CGIA|AESA|SAEA|VSFA|AUQA|LABA|BSFA|SMFA;
	%let numForm=%sysfunc(countw(&formList,|));
	
	create table temp2 as
	select t.BID, t.VISIT, catx(", ", Reason1, Reason2, Reason3, Reason4) as Reason, t.UVFA0B
	%do i=1 %to &numform.;
		%let form=%scan(&formList,&i,|);
		, &form..FORM as FORM&i.
	%end;
		from temp as t
			%do i=1 %to &numForm.;
				%let form=%scan(&formList,&i,|);
				left join mets.&form._669 as &form. on t.BID=&form..BID and t.VISIT=&form..VISIT and t.UVFA0B=&form..&form.0B
			%end;
	;

/* 3RD STEP: CONCATENATE FORMS INTO A SINGLE COLUMN */
	title "List of Unschedule Visits and Forms Filled During Their Occurrences";
	select BID, VISIT, REASON label="Reason for Visit",
	catx(", " %do i=1 %to &numForm.; , FORM&i. %end;) as FORMS label="Forms Filled Out"
		from temp2
	;
	
quit;
%mend;
%forms;


ODS PDF CLOSE;