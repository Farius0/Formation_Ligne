/*==============================================================================
Program: 11_proc_append.sas
==============================================================================*/
/*Change this path to the appropriate location*/
%let ROOT = path;

/* Load 2000 */
data work.sales;
  infile "&ROOT./Csv_Files/sales_2000.csv"
         dlm=',' firstobs=2;
  input store year sales;
run;

/* Load 2001 */
data work.sales_2001;
  infile "&ROOT./Csv_Files/sales_2001.csv"
         dlm=',' firstobs=2;
  input store year sales;
run;

/* Check structure */
/* proc contents data=work.sales; run; */
/* proc contents data=work.sales_2001; run; */

/* Append */
proc append
    base=work.sales
    data=work.sales_2001;
run;

/* Verify */
proc print data=work.sales(obs=20); run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
