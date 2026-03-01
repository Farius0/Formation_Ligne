/*==============================================================================
Program: 20_loops_explore.sas
Purpose: Exploration of DATA step loops (DO, DO WHILE, DO UNTIL, ...).
==============================================================================*/

options mprint mlogic symbolgen;

/*------------------------------------------------------------------------------
1) DO loop
------------------------------------------------------------------------------*/
data work.testing_do_basic;
  do i = 25 to 250 by 25;
    output;
  end;
run;

proc print data=work.testing_do_basic noobs; run;

/*------------------------------------------------------------------------------
2) DO block inside IF/ELSE
------------------------------------------------------------------------------*/
data work.class_enriched;
  set sashelp.class;

  length fee stay category $30;

  if age <= 12 then do;
    fee      = "15k";
    stay     = "ALLOWED";
    category = "KID";
  end;
  else do;
    fee      = "25k";
    stay     = "NOT ALLOWED";
    category = "TEENAGE";
  end;
run;

proc print data=work.class_enriched(obs=10) noobs; run;

/*------------------------------------------------------------------------------
3) DO WHILE loop
------------------------------------------------------------------------------*/
data work.testing_do_while;
  x = 1;

  do while (x <= 5);
    output;
    x + 1;
  end;
run;

proc print data=work.testing_do_while noobs; run;

/*------------------------------------------------------------------------------
4) DO UNTIL loop
------------------------------------------------------------------------------*/
data work.testing_do_until;
  x = 1;

  do until (x > 5);
    output;
    x + 1;
  end;
run;

proc print data=work.testing_do_until noobs; run;

/*------------------------------------------------------------------------------
5) Nested loops
------------------------------------------------------------------------------*/
data work.nested_loop;
  do i = 1 to 3;
    do j = 1 to 2;
      value = i * j;
      output;
    end;
  end;
run;

proc print data=work.nested_loop noobs; run;

/*------------------------------------------------------------------------------
6) Arrays + DO loop
------------------------------------------------------------------------------*/
data work.array_example;
  set sashelp.class;

  array nums {*} height weight;

  do i = 1 to dim(nums);
    nums{i} = nums{i} * 1.10;
  end;

  drop i;
run;

proc print data=work.array_example(obs=10) noobs; run;

/*------------------------------------------------------------------------------
7) Iterating over dates
------------------------------------------------------------------------------*/
data work.date_loop;
  format date date9.;

  do date = '01JAN2025'd to '31JAN2025'd by 7;
    output;
  end;
run;

proc print data=work.date_loop noobs; run;

/*------------------------------------------------------------------------------
8) Cumulative calculation (RETAIN + DO)
------------------------------------------------------------------------------*/
data work.cumulative;
  retain total 0;

  do i = 1 to 5;
    total + i;
    output;
  end;
run;

proc print data=work.cumulative noobs; run;

/*------------------------------------------------------------------------------
9) Early exit from a loop (LEAVE)
------------------------------------------------------------------------------*/
data work.leave_example;
  do i = 1 to 10;
    if i = 5 then leave;
    output;
  end;
run;

proc print data=work.leave_example noobs; run;

/*------------------------------------------------------------------------------
10) Stop the DATA step completely (STOP)
------------------------------------------------------------------------------*/
data work.stop_example;
  do i = 1 to 100;
    output;
    if i = 5 then stop;
  end;
run;

proc print data=work.stop_example noobs; run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
