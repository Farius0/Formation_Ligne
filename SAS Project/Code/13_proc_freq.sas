/*==============================================================================
Program: 13_proc_freq.sas
Purpose: Frequency tables, cross-tabs, filters, outputs, and tests.
==============================================================================*/
/*Change this path to the appropriate location*/
%let ROOT = path;

/*-----------------------------------------------------------------------------
0) Load sample data (Excel -> WORK)
-----------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Customers.xlsx"
  out=work.customer
  dbms=xlsx
  replace;
  sheet="Customers";
  getnames=yes;
run;

/*-----------------------------------------------------------------------------
1) One-way frequency (basic)
-----------------------------------------------------------------------------*/
proc freq data=work.customer;
  tables City;
run;

/*-----------------------------------------------------------------------------
2) Control percentages / cumulative
-----------------------------------------------------------------------------*/
proc freq data=work.customer;
  tables City / nopercent nocum;
run;

/*-----------------------------------------------------------------------------
3) Include missing as a category
-----------------------------------------------------------------------------*/
proc freq data=work.customer;
  tables City / missing;
run;

/*-----------------------------------------------------------------------------
4) Order of levels
-----------------------------------------------------------------------------*/
proc freq data=work.customer order=freq;
  tables City;
run;

/*-----------------------------------------------------------------------------
5) Two-way table (cross-tab)
-----------------------------------------------------------------------------*/
proc freq data=work.customer;
  tables City * Country / nopercent norow nocol;
run;

/*-----------------------------------------------------------------------------
6) Chi-square test for association (cross-tab inference)
-----------------------------------------------------------------------------*/
proc freq data=work.customer;
  tables City * Country / chisq;
run;

/*-----------------------------------------------------------------------------
7) Filter with WHERE
-----------------------------------------------------------------------------*/
proc freq data=work.customer(where=(Transaction_Amount <= 200));
  tables City * Country / nopercent norow nocol;
run;

/*-----------------------------------------------------------------------------
8) LIST format
-----------------------------------------------------------------------------*/
proc freq data=work.customer;
  tables City * Country / list;
run;

/*-----------------------------------------------------------------------------
9) Output results to a dataset (counts + percentages)
-----------------------------------------------------------------------------*/
proc freq data=work.customer noprint;
  tables City * Country / out=work.freq_city outpct;
run;

proc print data=work.freq_city(obs=20) noobs; run;

/*-----------------------------------------------------------------------------
10) Multiple tables in one PROC FREQ call
-----------------------------------------------------------------------------*/
proc freq data=work.customer;
  tables City Country;
run;

/*-----------------------------------------------------------------------------
11) Format categories before PROC FREQ (grouping levels)
-----------------------------------------------------------------------------*/
proc format;
  value amt_band
    low - <200 = "<200"
    200 - <500 = "200-499"
    500 - <1000 = "500-999"
    1000 - high = "1000+";
run;

data work.customer_bands;
  set work.customer;
  format Transaction_Amount amt_band.;
run;

proc freq data=work.customer_bands;
  tables Transaction_Amount;
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
