/*==============================================================================
Program: 10_proc_print.sas
Purpose: Practical reporting patterns (filtering, grouping, formatting).
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

/*-----------------------------------------------------------------------------
0) Basic print
-----------------------------------------------------------------------------*/
proc print data=work.customer;
run;

/*-----------------------------------------------------------------------------
1) Limit observations
-----------------------------------------------------------------------------*/
proc print data=work.customer(obs=20);
run;

/*-----------------------------------------------------------------------------
2) Select variables (VAR)
-----------------------------------------------------------------------------*/
proc print data=work.customer(obs=20);
  var ContactName Country Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
3) Remove Obs column + show labels
-----------------------------------------------------------------------------*/
proc print data=work.customer(obs=15) noobs label;
  var ContactName Country Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
4) Use an ID variable instead of Obs
-----------------------------------------------------------------------------*/
proc print data=work.customer(obs=15) noobs;
  id ContactName;
  var Country Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
5) Apply formats (display control)
-----------------------------------------------------------------------------*/
proc print data=work.customer(obs=15) noobs;
  var ContactName Country Transaction_Amount;
  format Transaction_Amount comma12.2;
run;

/*-----------------------------------------------------------------------------
6) Titles / Footnotes
-----------------------------------------------------------------------------*/
title  "CUSTOMERS TABLE (Preview)";
footnote "Generated via PROC PRINT";

proc print data=work.customer(obs=10) noobs;
  var ContactName Country Transaction_Amount;
run;

title;
footnote;

/*-----------------------------------------------------------------------------
7) Sorting + BY-group printing
-----------------------------------------------------------------------------*/
proc sort data=work.customer out=customer_sorted;
  by Country;
run;

title "CUSTOMERS BY COUNTRY";

proc print data=customer_sorted noobs;
  by Country;
  var ContactName Transaction_Amount;
run;

title;

/*-----------------------------------------------------------------------------
8) Group totals (SUM) within BY groups
-----------------------------------------------------------------------------*/
proc print data=customer_sorted noobs;
  by Country;
  var ContactName Transaction_Amount;
  sum Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
9) Filter with WHERE
-----------------------------------------------------------------------------*/
/* A) WHERE statement */
proc print data=work.customer noobs;
  where Country = 'USA' and Transaction_Amount > 600;
  var ContactName Country Transaction_Amount;
run;

/* B) Dataset option WHERE= */
proc print data=work.customer(where=(Country='USA' and Transaction_Amount > 600)) noobs;
  var ContactName Country Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
10) Page by group
-----------------------------------------------------------------------------*/
title "CUSTOMERS - One Page per Country";

proc print data=customer_sorted noobs;
  by Country;
  pageby Country;
  var ContactName Transaction_Amount;
run;

title;

/*-----------------------------------------------------------------------------
11) SPLIT for multi-line column headers using LABEL
-----------------------------------------------------------------------------*/
proc print data=work.customer(obs=10) noobs split='*' label;
  var ContactName Transaction_Amount;
  label Transaction_Amount = "Transaction*Amount";
run;

/*-----------------------------------------------------------------------------
12) N option + UNIFORM
-----------------------------------------------------------------------------*/
proc print data=work.customer(obs=20) noobs n uniform;
  var ContactName Country Transaction_Amount;
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
