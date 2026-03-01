/*==============================================================================
Program: 19_proc_compare.sas
Purpose: Compare two datasets (structure + values)
==============================================================================*/

/*-----------------------------------------------------------------------------
0) Build demo datasets
-----------------------------------------------------------------------------*/
data work.base;
  length id 8 name $20;
  format amount comma12.2;
  input id name $ amount;
  datalines;
1 Alice  100.00
2 Bob    200.50
3 Carla  300.00
;
run;

/* Create a "changed" version */
data work.compare;
  set work.base;

  if id=2 then amount = amount + 0.01;
  if id=3 then name   = "CARLA";
run;

/*-----------------------------------------------------------------------------
1) Basic compare
-----------------------------------------------------------------------------*/
proc compare base=work.base compare=work.compare;
run;

/*-----------------------------------------------------------------------------
2) Compare by key (ID)
-----------------------------------------------------------------------------*/
proc compare base=work.base compare=work.compare;
  id id;
run;

/*-----------------------------------------------------------------------------
3) Numeric tolerance
-----------------------------------------------------------------------------*/
proc compare base=work.base compare=work.compare criterion=1e-3;
  id id;
run;

proc compare base=work.base compare=work.compare method=absolute criterion=0.05;
  id id;
run;

/*-----------------------------------------------------------------------------
4) Select variables to compare (VAR / WITH)
-----------------------------------------------------------------------------*/
proc compare base=work.base compare=work.compare;
  id id;
  var amount;
  with amount;
run;

/*-----------------------------------------------------------------------------
5) Quick summary only (BRIEF) + show all diffs (LISTALL)
-----------------------------------------------------------------------------*/
proc compare base=work.base compare=work.compare brief listall;
  id id;
run;

/*-----------------------------------------------------------------------------
6) Output differences to a dataset 
-----------------------------------------------------------------------------*/
proc compare base=work.base compare=work.compare
             out=work.compare_out
             outbase outcomp outdif outpct
             noprint;
  id id;
run;

proc print data=work.compare_out; run;

/*-----------------------------------------------------------------------------
7) Structure checks
-----------------------------------------------------------------------------*/
data work.compare_struct;
  length id 8 name $10;
  format amount 12.2;
  set work.base;
run;

proc compare base=work.base compare=work.compare_struct;
  id id;
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/

