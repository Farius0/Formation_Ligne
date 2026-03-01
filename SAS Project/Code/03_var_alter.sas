/*==============================================================================
Program: 03_var_alter.sas

Variable Alteration (Rename, Drop, Create)
==============================================================================*/

/*Change this path to the appropriate location*/
%let ROOT = path;

proc import datafile="&ROOT./Excel_Files/Order_Details.xlsx"
  out=work.order_details(drop = counter)
  dbms=xlsx
  replace;
  sheet="OrderDetails";
  getnames=yes;
run;

data testing_clean;
  set work.order_details
      (rename=(quantity=qty)
       drop=OrderDetailID);

  price = qty * 5;

  label price = "Calculated Price";
  format price comma12.2;
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
