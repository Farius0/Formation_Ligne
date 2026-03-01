/*==============================================================================
Program: 22_combine_merge_explore.sas
Purpose: Combine datasets (stack rows) and merge datasets (join columns) using
         DATA step SET/MERGE and dataset lists.
==============================================================================*/

options mprint mlogic symbolgen;

/*Change this path to the appropriate location*/
%let ROOT = path;

/*------------------------------------------------------------------------------
0) Load sample data (Excel -> WORK)
------------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Customers.xlsx"
  out=work.customer
  dbms=xlsx
  replace;
  sheet="Customers";
  getnames=yes;
run;

proc contents data=work.customer varnum; run;

/*------------------------------------------------------------------------------
1) Combine rows (vertical stack) with SET (UNION ALL)
------------------------------------------------------------------------------*/
data work.customer_part1;
  set work.customer(obs=20);
run;

data work.customer_part2;
  set work.customer(firstobs=21 obs=40);
run;

data work.combined_rows;
  set work.customer_part1 work.customer_part2;
run;

proc print data=work.combined_rows noobs; run;

/*------------------------------------------------------------------------------
2) Combine columns by row position
------------------------------------------------------------------------------*/

data work.customer_cols_a;
  set work.customer(obs=20);
  row_id = _n_;
  keep row_id customerid customername contactname address;
run;

data work.customer_cols_b;
  set work.customer(obs=20);
  row_id = _n_;
  keep row_id transaction_amount city postalcode country;
run;

/* proc sort data=work.customer_cols_a; by row_id; run; */
/* proc sort data=work.customer_cols_b; by row_id; run; */

data work.combined_cols_row_aligned;
  merge work.customer_cols_a(in=a) work.customer_cols_b(in=b);
  by row_id;
  if a and b;
  drop row_id;
run;

proc print data=work.combined_cols_row_aligned(obs=10) noobs; run;

/*------------------------------------------------------------------------------
3) MERGE by a key (join) - FULL / LEFT / RIGHT / INNER
------------------------------------------------------------------------------*/
data work.left_ds;
  set work.customer(firstobs=1 obs=20);
  keep customerid customername contactname address;
run;

data work.right_ds;
  set work.customer(firstobs=10 obs=30);
  keep customerid transaction_amount city postalcode country;
run;

proc sort data=work.left_ds;  by customerid; run;
proc sort data=work.right_ds; by customerid; run;

/* 3.1 FULL JOIN */
data work.merge_full;
  merge work.left_ds(in=a) work.right_ds(in=b);
  by customerid;
  in_left  = a;
  in_right = b;
run;

proc print data=work.merge_full(obs=15) noobs; run;

/* 3.2 LEFT JOIN */
data work.merge_left;
  merge work.left_ds(in=a) work.right_ds(in=b);
  by customerid;
  if a;
run;

proc print data=work.merge_left(obs=15) noobs; run;

/* 3.3 RIGHT JOIN */
data work.merge_right;
  merge work.left_ds(in=a) work.right_ds(in=b);
  by customerid;
  if b;
run;

proc print data=work.merge_right(obs=15) noobs; run;

/* 3.4 INNER JOIN */
data work.merge_inner;
  merge work.left_ds(in=a) work.right_ds(in=b);
  by customerid;
  if a and b;
run;

proc print data=work.merge_inner(obs=15) noobs; run;

/*------------------------------------------------------------------------------
4) Combine multiple datasets using a name prefix list
------------------------------------------------------------------------------*/

data work.cust_a; set work.customer(obs=5); run;
data work.cust_b; set work.customer(firstobs=6 obs=10); run;

data work.combined_all_prefix;
  set work.cust:;
run;

proc print data=work.combined_all_prefix(obs=10) noobs; run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
