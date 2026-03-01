/*==============================================================================
Program: 17_proc_transpose.sas
Purpose: Wide <-> Long reshaping after aggregation.
==============================================================================*/
/*Change this path to the appropriate location*/
%let ROOT = path;

/*-----------------------------------------------------------------------------
0) Load sample data
-----------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Customers.xlsx"
  out=work.customer
  dbms=xlsx
  replace;
  sheet="Customers";
  getnames=yes;
run;

/*-----------------------------------------------------------------------------
1) Summarize first
-----------------------------------------------------------------------------*/
proc summary data=work.customer nway;
  class City Country;
  var Transaction_Amount;
  output out=work.customer_t1(drop=_type_ _freq_)
         sum=Transaction_Amount;
run;

proc sort data=work.customer_t1;
  by City;
run;

/*-----------------------------------------------------------------------------
2) TRANSPOSE
-----------------------------------------------------------------------------*/
proc transpose data=work.customer_t1 out=work.customer_t2(drop=_name_ _label_);
  by City;
  id Country;
  var Transaction_Amount;
run;

proc contents data=work.customer_t2 varnum; run;
proc print data=work.customer_t2(obs=10); run;


/*-----------------------------------------------------------------------------
3) By ContactName x City x Country
-----------------------------------------------------------------------------*/
proc summary data=work.customer nway;
  class ContactName City Country;
  var Transaction_Amount;
  output out=work.customer_tt(drop=_type_ _freq_)
         sum=Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
4) BY ContactName Country, ID City
-----------------------------------------------------------------------------*/
proc sort data=work.customer_tt;
  by ContactName Country;
run;

proc transpose data=work.customer_tt out=work.customer_tt3(drop=_name_ _label_) prefix=CITY_;
  by ContactName Country;
  id City;
  var Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
5) NAME
-----------------------------------------------------------------------------*/
proc sort data=work.customer_t1;
  by City;
run;

proc transpose data=work.customer_t1 out=work.customer_t2_name(drop=_label_) name=measure;
  by City;
  id Country;
  var Transaction_Amount;
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
