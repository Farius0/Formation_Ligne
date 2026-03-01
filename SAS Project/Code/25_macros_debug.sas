/*==============================================================================
Program: 25_macros_debug.sas
Purpose: Macro debugging options + PROC FREQ macro.
==============================================================================*/

options mprint mlogic symbolgen mcompilenote=all;

/*-----------------------------------------------------------------------------
Macro: check_freq
-----------------------------------------------------------------------------*/
%macro check_freq(data=, var=, origin=);

  /* Basic validations (avoid confusing logs) */
  %if not %sysfunc(exist(&data)) %then %do;
    %put ERROR: Dataset &data does not exist.;
    %return;
  %end;

  /* Check that the variable exists in the dataset */
  %if %sysfunc(varnum(%sysfunc(open(&data)), &var)) = 0 %then %do;
    %put ERROR: Variable &var not found in &data..;
    %return;
  %end;

  title "Frequency of &var in ORIGIN=&origin (data=&data)";

  proc freq data=&data;
    tables &var / nopercent nocum;
    where upcase(origin) = "%upcase(&origin)";
  run;

  title;

%mend;

/*-----------------------------------------------------------------------------
Run macro
-----------------------------------------------------------------------------*/
%check_freq(data=sashelp.cars, var=type, origin=USA);
%check_freq(data=sashelp.cars, var=type, origin=Asia);

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/