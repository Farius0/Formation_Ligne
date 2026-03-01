/*==============================================================================
Program: 01_export_explore.sas
Purpose: Explore export methods (XLSX, CSV, DLM/TXT).
==============================================================================*/
options mprint mlogic symbolgen;

/*Change this path to the appropriate location*/
%let ROOT = path;

proc import datafile="&ROOT./Excel_Files/Order_Details.xlsx"
  out=work.order_details(drop = counter)
  dbms=xlsx
  replace;
  sheet="OrderDetails";
  getnames=yes;
run;

/*-----------------------------------------------------------------------------
1) Export to Excel (XLSX)
-----------------------------------------------------------------------------*/
proc export
  data=work.order_details
  outfile="&ROOT./Excel_Files/order_exported.xlsx"
  dbms=xlsx
  replace;
  sheet="ORDERS";
run;

/*-----------------------------------------------------------------------------
2) Export to CSV
-----------------------------------------------------------------------------*/
proc export
  data=work.order_details
  outfile="&ROOT./Csv_Files/order_details_exported.csv"
  dbms=csv
  replace;
  putnames=yes;
run;

/*-----------------------------------------------------------------------------
3) Export to TXT
-----------------------------------------------------------------------------*/
proc export
  data=work.order_details
  outfile="&ROOT./Txt_Files/order_details_exported_pipe.txt"
  dbms=dlm
  replace;
  delimiter='|';
  putnames=yes;
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
