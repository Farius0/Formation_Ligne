/*==============================================================================
Program: 00_import_explore.sas
Purpose: Exploration of import methods (TXT, CSV, XLSX).
==============================================================================*/

/* options mprint mlogic symbolgen; */

/*Change this path to the appropriate location*/
%let ROOT = path;

/*-----------------------------------------------------------------------------
1) Libraries
-----------------------------------------------------------------------------*/
libname stg  "&ROOT./sasdata/staging";
libname out  "&ROOT./sasdata/output";    

/*-----------------------------------------------------------------------------
2) Import TXT (TAB-delimited): state_pop.txt
-----------------------------------------------------------------------------*/
data work.state_pop;
  infile "&ROOT./Txt_Files/state_pop.txt"
    dsd
    dlm='09'x
    truncover
    firstobs=1;

  length state $32;
  input state :$32. pop :best32.;
run;

/* Quick checks */
proc contents data=work.state_pop varnum; run;
proc print data=work.state_pop(obs=5); run;

/*-----------------------------------------------------------------------------
3) Import CSV (comma-delimited): sales_2000.csv
-----------------------------------------------------------------------------*/
data work.sales_2000;
  infile "&ROOT./Csv_Files/sales_2000.csv"
    dsd
    dlm=','
    firstobs=2
    truncover;

  input store :8. year :8. sales :comma32.;
run;

proc contents data=work.sales_2000 varnum; run;
proc print data=work.sales_2000(obs=5); run;

/*-----------------------------------------------------------------------------
4) Import XLSX using PROC IMPORT: Categories.xlsx
-----------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Categories.xlsx"
  out=work.categories
  dbms=xlsx
  replace;
  sheet="Categories";
  getnames=yes;
run;

proc contents data=work.categories varnum; run;
proc print data=work.categories(obs=5); run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/