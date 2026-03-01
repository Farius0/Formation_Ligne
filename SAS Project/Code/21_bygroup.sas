/*==============================================================================
Program: 21_bygroup.sas
Purpose: BY-group processing (FIRST./LAST.) for counters and cumulative sums
==============================================================================*/

options mprint mlogic symbolgen;

/*Change this path to the appropriate location*/
%let ROOT = path;

/*------------------------------------------------------------------------------
0) Load sample data (Excel -> WORK)
------------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Order_Details.xlsx"
  out=work.order_details_raw(drop=counter)
  dbms=xlsx
  replace;
  sheet="OrderDetails";
  getnames=yes;
run;

/* proc contents data=work.order_details_raw varnum; run; */
/* proc print data=work.order_details_raw(obs=10) noobs; run; */

/*==============================================================================
BY-group processing (FIRST./LAST.)
==============================================================================*/

/*------------------------------------------------------------------------------
1) Sort by OrderID 
------------------------------------------------------------------------------*/
proc sort data=work.order_details_raw out=work.order_details_s;
  by OrderID;
run;

/*------------------------------------------------------------------------------
2) Row counter within each OrderID
------------------------------------------------------------------------------*/
data work.orders_rows;
  set work.order_details_s(keep=OrderID Quantity);
  by OrderID;

  if first.OrderID then counter = 0;
  counter + 1;
run;

proc print data=work.orders_rows(obs=20) noobs; run;

/*------------------------------------------------------------------------------
3) Running cumulative sum of Quantity within each OrderID
------------------------------------------------------------------------------*/
data work.orders_cumsum_rows;
  set work.order_details_s(keep=OrderID Quantity);
  by OrderID;

  if first.OrderID then quantity_cum = 0;
  quantity_cum + Quantity;
run;

proc print data=work.orders_cumsum_rows(obs=20) noobs; run;

/*------------------------------------------------------------------------------
4) One row per OrderID
------------------------------------------------------------------------------*/
data work.orders_final_by;
  set work.order_details_s(keep=OrderID Quantity);
  by OrderID;

  if first.OrderID then do;
    line_count = 0;
    qty_total  = 0;
    qty_missing= 0;
    qty_neg    = 0;
  end;

  line_count + 1;

  if missing(Quantity) then qty_missing + 1;
  else do;
    qty_total + Quantity;
    if Quantity < 0 then qty_neg + 1;
  end;

  if last.OrderID then output;

  keep OrderID line_count qty_total qty_missing qty_neg;
run;

proc print data=work.orders_final_by(obs=20) noobs; run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
