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
*  Job name:      SQLF2_bphung.sas   
*
*  Purpose:       Practice using PROC SQL
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         METS data sets DR, IECA, RDMA
*
*  Output:        PDF file     
*                                                                    
********************************************************************;

%LET job=SQLF2;
%LET onyen=bphung;
%LET outdir=/folders/myfolders/669/assignments/2019-02-07-sqlf;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";
LIBNAME mets "/folders/myfolders/669/data/mets" access="read";


ODS PDF FILE="&outdir./&job._&onyen..pdf" STYLE=JOURNAL;


proc sql;
	title "METS Participants with Non-Standard Observation Period";
	title2 "Sort by site, interval of interest";
	select d.BID, d.PSITE, i.IECA0B label="Screening Date", r.RDMA0B label="Randomization Date",
	r.RDMA0B - i.IECA0B as DUR label="Difference (days)"
		from mets.dr_669 as d, mets.ieca_669 as i, mets.rdma_669 as r
		where d.BID=i.BID=r.BID and not (3 <= calculated DUR <= 14)
		having not (3 <= calculated DUR <= 14)
		order by PSITE, DUR
	;
quit;


ODS PDF CLOSE;