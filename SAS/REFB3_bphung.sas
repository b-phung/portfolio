*********************************************************************
*  Assignment:    REFB                                         
*                                                                    
*  Description:   Second collection of SAS refresher problems using 
*                 METS study data
*
*  Name:          Brian Phung
*
*  Date:          2019-01-17                                      
*------------------------------------------------------------------- 
*  Job name:      REFB3_bphung.sas   
*
*  Purpose:       Produce a list of METS study participants who had
*				  unscheduled visits, their reasons for doing so,
*				  and forms they filled out during.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data sets UVFA, CGIA, AESA, SAEA, VSFA, AUQA,
				  LABA, BSFA, SMFA
*
*  Output:        PDF file    
*                                                                    
********************************************************************;

%LET job=REFB3;
%LET onyen=bphung;
%LET outdir=/folders/myfolders/669/assignments/2019-01-17-refb;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/669/data/mets" access="read";


ODS PDF FILE="&outdir/&job._&onyen..pdf" STYLE=JOURNAL;

%macro mergeform(formList);
%let numForm=%sysfunc(countw(&formList,|));
data work.main;
	merge mets.uvfa_669(in=inmain keep=BID VISIT UVFA:)
		%do i=1 %to &numForm;
			%let form=%scan(&formList,&i,|);
			mets.&form._669(keep=BID VISIT &form.0B FORM 	rename=(&form.0B=UVFA0B FORM=&form.))
		%end;
	;
	by BID VISIT UVFA0B;
	if inmain;
	FORMS = catx(", ", %sysfunc(tranwrd(%quote(&formList.),|,%str(,))));
	label FORMS="Forms filled out";
	drop %sysfunc(tranwrd(%quote(&formList.),|,%str( )));
run;
%mend;

%mergeform(CGIA|AESA|SAEA|VSFA|AUQA|LABA|BSFA|SMFA);

title "List of Unschedule Visits and Form Filled During Their Occurrences";
proc print data=work.main label noobs;
	var BID VISIT UVFA0B UVFA1: FORMS;
run;
title;

ODS PDF CLOSE;