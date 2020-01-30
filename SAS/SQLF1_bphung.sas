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
*  Job name:      SQLF1_bphung.sas   
*
*  Purpose:       Practice using PROC SQL
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data set OMRA
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

%LET job=SQLF1;
%LET onyen=bphung;
%LET outdir=/folders/myfolders/669/assignments/2019-02-07-sqlf;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/669/data/mets" access="read";


ODS PDF FILE="&outdir./&job._&onyen..pdf" STYLE=JOURNAL;


proc sql;
	title "METS Participants and Specially-Allowed Medications at Visit 2";
	select BID, OMRA1
		from mets.OMRA_669
		where OMRA5A="Y" and
			scan(OMRA1, 1) in ("AMILORIDE", "DIGOXIN", "MORPHINE",
			"PROCAINAMIDE", "QUINIDINE", "QUININE", "RANITIDINE",
			"TRIAMTERENE", "TRIMETHOPRIM", "VANCOMYCIN",
			"FUROSEMIDE", "NIFEDICAL", "CIMETIDINE")
	;
quit;


ODS PDF CLOSE;