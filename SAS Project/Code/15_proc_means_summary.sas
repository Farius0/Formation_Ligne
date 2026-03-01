/*==============================================================================
Program: 15_proc_means_summary.sas
==============================================================================*/
/*Change this path to the appropriate location*/
%let ROOT = path;

/*-----------------------------------------------------------------------------
0) Load sample data
-----------------------------------------------------------------------------*/
data work.sales;
  infile "&ROOT./Csv_Files/sales_2000.csv" dlm=',' firstobs=2 truncover;
  input store year sales;
run;

proc import datafile="&ROOT./Excel_Files/Customers.xlsx"
  out=work.customer
  dbms=xlsx
  replace;
  sheet="Customers";
  getnames=yes;
run;

/* Quick preview */
proc print data=work.sales(obs=5); run;
proc print data=work.customer(obs=5); run;

/*-----------------------------------------------------------------------------
1) PROC MEANS - basic
-----------------------------------------------------------------------------*/
proc means data=work.sales n nmiss sum mean std median p75 maxdec=2;
  var sales;
run;

/*-----------------------------------------------------------------------------
2) PROC MEANS with CLASS
-----------------------------------------------------------------------------*/
proc means data=work.sales n nmiss sum mean std median p75 maxdec=2;
  class year;
  var sales;
run;

/*-----------------------------------------------------------------------------
3) Output results to a dataset 
-----------------------------------------------------------------------------*/
proc means data=work.sales n sum mean std median p75 maxdec=2 nway noprint;
  class year;
  var sales;
  output out=work.sales_stats_by_year
    n     = n_sales
    sum   = sales_sum
    mean  = sales_mean
    std   = sales_std
    median= sales_median
    p75   = sales_p75;
run;

proc print data=work.sales_stats_by_year noobs; run;

/*-----------------------------------------------------------------------------
4) PROC MEANS with multiple CLASS variables
-----------------------------------------------------------------------------*/
proc means data=work.customer n nmiss sum mean std median p75 maxdec=2;
  class country city;
  var transaction_amount;
run;

/*-----------------------------------------------------------------------------
6) Output by country
-----------------------------------------------------------------------------*/
proc means data=work.customer n sum mean std median p75 maxdec=2 nway noprint;
  class country;
  var transaction_amount;

  output out=work.trsa_mean_by_country
    n     = n_trx
    sum   = trx_sum
    mean  = trx_mean
    std   = trx_std
    median= trx_median
    p75   = trx_p75;
run;

proc sort data=work.trsa_mean_by_country out=work.trsa_mean_by_country_sorted;
  by descending trx_sum;
run;

proc print data=work.trsa_mean_by_country_sorted noobs; run;

/*-----------------------------------------------------------------------------
7) BY-group alternative (requires sorting)
-----------------------------------------------------------------------------*/
proc sort data=work.sales out=work.sales_sorted;
  by year;
run;

proc means data=work.sales_sorted n sum mean std median p75 maxdec=2 noprint;
  by year;
  var sales;
  output out=work.sales_stats_by_year_by
    n     = n_sales
    sum   = sales_sum
    mean  = sales_mean
    std   = sales_std
    median= sales_median
    p75   = sales_p75;
run;

proc print data=work.sales_stats_by_year_by noobs; run;

/*-----------------------------------------------------------------------------
8) PROC SUMMARY 
-----------------------------------------------------------------------------*/
proc summary data=work.customer nway;
  class country;
  var transaction_amount;
  output out=work.summary_by_country
    n= n_trx
    sum= trx_sum
    mean= trx_mean
    std= trx_std;
run;

proc print data=work.summary_by_country noobs; run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
