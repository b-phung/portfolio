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
*  Job name:      SQLF4_bphung.sas   
*
*  Purpose:       Practice using PROC SQL and fuzzy matching
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data sets UVFA, CGIA, AESA, SAEA, VSFA, AUQA,
				  LABA, BSFA, SMFA
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

%LET job=SQLF4;
%LET onyen=bphung;
%LET outdir=/folders/myfolders/669/assignments/2019-02-07-sqlf;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN ORIENTATION=LANDSCAPE;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/669/data/mets" access="read";


ODS PDF FILE="&outdir./&job._&onyen..pdf" STYLE=JOURNAL;


%macro fuzzyForms;
%let formList=CGIA|AESA|SAEA|VSFA|AUQA|LABA|BSFA|SMFA;
%let numForm=%sysfunc(countw(&formList,|));

proc sql;
	title "List of Unschedule Visits and Forms Filled During Their Occurrences (with +/-1 day margin of error";
	select u.BID, u.VISIT, u.UVFA0B label="UVFA date"
	%do i=1 %to &numform.;
		%let form=%scan(&formList,&i,|);
		, &form.0B label="&form. date"
	%end;
		from mets.uvfa_669 as u
		%do i=1 %to &numform.;
			%let form=%scan(&formList,&i,|);
			left join mets.&form._669 as &form. on u.BID=&form..BID and u.VISIT=&form..VISIT and u.UVFA0B-1<=&form..&form.0B<=u.UVFA0B+1
		%end;
	;
quit;
%mend;
%fuzzyForms;


ODS PDF CLOSE;