/*==============================================================================
Program: 23_arrays_explore.sas
Purpose: Array patterns in SAS (IN operator, OF lists, _numeric_/_character_,
         DO loops, missing handling, counts, recoding, and derived metrics).
==============================================================================*/

options mprint mlogic symbolgen;

/*Change this path to the appropriate location*/
%let ROOT = path;

/*------------------------------------------------------------------------------
0) Import Attendance sheet
------------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Arrays.xlsx"
  out=work.attendance
  dbms=xlsx
  replace;
  sheet="Attendance";
  getnames=yes;
run;

proc contents data=work.attendance varnum; run;

/*------------------------------------------------------------------------------
1) IN operator with arrays
------------------------------------------------------------------------------*/
data work.flagging;
  set work.attendance;

  length ever_absent ever_present $3;

  array days(7) $ day1-day7;

  if 'A' in days then ever_absent  = 'YES'; else ever_absent  = 'NO';
  if 'P' in days then ever_present = 'YES'; else ever_present = 'NO';

  drop _:;
run;

proc print data=work.flagging(obs=20) noobs; run;

/*------------------------------------------------------------------------------
2) Extra flags
------------------------------------------------------------------------------*/
data work.flagging_counts;
  set work.attendance;

  length ever_absent ever_present $3;
  array days(7) $ day1-day7;

  absent_cnt  = 0;
  present_cnt = 0;

  do i = 1 to dim(days);
    if days(i) = 'A' then absent_cnt  + 1;
    if days(i) = 'P' then present_cnt + 1;
  end;

  ever_absent  = ifc(absent_cnt  > 0, 'YES', 'NO');
  ever_present = ifc(present_cnt > 0, 'YES', 'NO');

  drop i;
run;

proc print data=work.flagging_counts(obs=20) noobs; run;

/*------------------------------------------------------------------------------
0) Import Card_Sales sheet
------------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Arrays.xlsx"
  out=work.card_sales
  dbms=xlsx
  replace;
  sheet="Card_Sales";
  getnames=yes;
run;

proc contents data=work.card_sales varnum; run;

/*------------------------------------------------------------------------------
3) MIN/MAX across an array (numeric)
------------------------------------------------------------------------------*/
data work.min_max_sales;
  set work.card_sales;
  
  array sales(*) jan feb mar apr may jun jul aug sep oct nov dec;

  min_unit_sold  = min(of sales(*));
  max_unit_sold  = max(of sales(*));
  sum_unit_sold  = sum(of sales(*));
  mean_unit_sold = mean(of sales(*));
run;

proc print data=work.min_max_sales(obs=20) noobs; run;

/*------------------------------------------------------------------------------
4) Same idea using _numeric_
------------------------------------------------------------------------------*/
data work.min_max_sales_allnumeric;
  set work.card_sales;

  array nums(*) _numeric_;

  min_all = min(of nums(*));
  max_all = max(of nums(*));
  sum_all = sum(of nums(*));
run;

proc print data=work.min_max_sales_allnumeric(obs=20) noobs; run;

/*------------------------------------------------------------------------------
0) Import Missing sheet
------------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Arrays.xlsx"
  out=work.missing_data
  dbms=xlsx
  replace;
  sheet="Missing";
  getnames=yes;
run;

proc contents data=work.missing_data varnum; run;

/*------------------------------------------------------------------------------
5) Replace missing values in a list of variables (DO loop + DIM)
------------------------------------------------------------------------------*/
data work.change_missing;
  set work.missing_data;

  array x(10) a1-a10;

  do i = 1 to dim(x);
    if missing(x(i)) then x(i) = 0;
  end;

  drop i;
run;

proc print data=work.change_missing(obs=20) noobs; run;

/*------------------------------------------------------------------------------
6) Array-in / array-out
------------------------------------------------------------------------------*/
data work.standardize_row;
  set work.missing_data;

  array x(10) a1-a10;
  array z(10) z1-z10;

  row_mean = mean(of x(*));
  row_std  = std(of x(*));

  do i = 1 to dim(x);
    if row_std > 0 then z(i) = (x(i) - row_mean) / row_std;
    else z(i) = .;
  end;

  drop i;
run;

proc print data=work.standardize_row(obs=20) noobs; run;

/*------------------------------------------------------------------------------
7) Array + LEAVE: early exit when a condition is met
------------------------------------------------------------------------------*/
data work.first_missing_pos;
  set work.missing_data;

  array x(10) a1-a10;

  first_missing = .;
  do i = 1 to dim(x);
    if missing(x(i)) then do;
      first_missing = i;
      leave;
    end;
  end;

  drop i;
run;

proc print data=work.first_missing_pos(obs=20) noobs; run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
