/*==============================================================================
Program: 04_filtering.sas

Filtering
==============================================================================*/

/*Change this path to the appropriate location*/
%let ROOT = path;

/*-----------------------------------------------------------------------------
Load sample data (Excel -> WORK)
-----------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Customers.xlsx"
  out=work.customer
  dbms=xlsx
  replace;
  sheet="Customers";
  getnames=yes;
run;

data testing_filtered;
  set work.customer
      (where=(
          country = 'USA'
          and transaction_amount > 600
          and not missing(transaction_amount)
      ));
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
