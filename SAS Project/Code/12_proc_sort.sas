/*==============================================================================
Program: 12_proc_sort.sas
Purpose: Sorting, ordering, and duplicate handling (NODUPKEY/NODUP/DUPOUT).
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
1) Basic sort (single key)
-----------------------------------------------------------------------------*/
proc sort data=work.customer out=work.customer_s_country;
  by Country;
run;

/*-----------------------------------------------------------------------------
2) Multi-key sort
-----------------------------------------------------------------------------*/
proc sort data=work.customer out=work.customer_s_country_amt;
  by Country Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
3) Descending sort
-----------------------------------------------------------------------------*/
proc sort data=work.customer out=work.customer_s_desc;
  by descending Country descending Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
4) Sort with OUT
-----------------------------------------------------------------------------*/
proc sort data=work.customer out=work.customer_sorted;
  by Country;
run;

/*-----------------------------------------------------------------------------
5) Remove duplicates by KEY (NODUPKEY)
-----------------------------------------------------------------------------*/
proc sort data=work.customer out=work.customer_nodupkey nodupkey
          dupout=work.customer_dupkey;
  by CustomerID;
run;

/*-----------------------------------------------------------------------------
6) Remove exact duplicate ROWS (NODUP)
-----------------------------------------------------------------------------*/
proc sort data=work.customer out=work.customer_noduprow nodup
          dupout=work.customer_duprow;
  by _all_;
run;

/*-----------------------------------------------------------------------------
7) KEEP/DROP/RENAME
-----------------------------------------------------------------------------*/
proc sort data=work.customer(keep=ContactName Country Transaction_Amount)
          out=work.customer_small_sorted;
  by Country Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
8) Validate results: counts + inspect duplicates
-----------------------------------------------------------------------------*/
proc sql;
  title "Row counts (source vs outputs)";
  create table work.row_counts as
  select 'customer'        as dataset length=20, count(*) as n from work.customer
  union all
  select 'customer_sorted' as dataset length=20, count(*) as n from work.customer_sorted
  union all
  select 'nodupkey'        as dataset length=20, count(*) as n from work.customer_nodupkey
  union all
  select 'dupkey'          as dataset length=20, count(*) as n from work.customer_dupkey
  union all
  select 'noduprow'        as dataset length=20, count(*) as n from work.customer_noduprow
  union all
  select 'duprow'          as dataset length=20, count(*) as n from work.customer_duprow
  ;
quit;
proc print data=work.row_counts noobs; run;
title;

/* Quick look at duplicates captured */
proc print data=work.customer_dupkey(obs=20); title "Duplicates by key (Country)"; run;
title;

proc print data=work.customer_duprow(obs=20); title "Exact duplicate rows"; run;
title;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
