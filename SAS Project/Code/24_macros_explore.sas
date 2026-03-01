/*==============================================================================
Program: 24_macros_explore.sas
Purpose: Macro language exploration (quoting, arithmetic, SYSFUNC, macro defs,
         PROC SQL INTO :, CALL SYMPUTX, macro IF/ELSE, and reusable QC macro).
==============================================================================*/

options mprint mlogic symbolgen;

/*------------------------------------------------------------------------------
1) Macro quoting: %STR / %NRSTR
------------------------------------------------------------------------------*/
%let x = %str(J%'aime coder);
%put NOTE: x=&x.;

%let y = %nrstr(%put This will NOT execute at compile time;);
%put NOTE: y=&y.;

/*------------------------------------------------------------------------------
2) Macro arithmetic: %EVAL (integer) / %SYSEVALF (decimal)
------------------------------------------------------------------------------*/
%let a = 10;
%let b = 4;
%let ab = %eval(&a * &b);
%put NOTE: ab=&ab.;

%let c = 10.5;
%let d = 4;
%let cd = %sysevalf(&c * &d);
%put NOTE: cd=&cd.;

/*------------------------------------------------------------------------------
3) %SYSFUNC: call DATA step functions from macro layer
------------------------------------------------------------------------------*/
%let name = %str(John Carter);
%let first_name = %sysfunc(substr(&name, 1, 4));
%put NOTE: first_name=&first_name.;

/*------------------------------------------------------------------------------
4) Reusable QC macro (Quality Check helper)
------------------------------------------------------------------------------*/
%macro qc(ds=, obs=5);

  %if %sysfunc(exist(&ds)) %then %do;

    title "QC: &ds";

    proc contents data=&ds varnum; run;
    proc print data=&ds(obs=&obs) noobs; run;

    proc sql noprint;
      select count(*) into :_qc_n trimmed from &ds;
    quit;

    %put NOTE: QC row_count for &ds = &_qc_n.;

    title;

  %end;
  %else %do;
    %put ERROR: Dataset &ds does not exist.;
  %end;

%mend;

/*------------------------------------------------------------------------------
5) Macro to build a TYPE summary table from SASHELP.CARS
------------------------------------------------------------------------------*/
%macro type_summary(car_type);

  %local type_u dsname;
  %let type_u = %upcase(%superq(car_type));
  %let dsname = %sysfunc(compress(&type_u, , 'kas'))_summary;

  proc sql;
    create table work.&dsname as
    select Type,
           Origin,
           count(*)      as no_of_units,
           sum(MSRP)     as total_msrp     format=comma14.,
           sum(Invoice)  as total_invoice  format=comma14.
    from sashelp.cars
    where upcase(Type) = "&type_u"
    group by Type, Origin;
  quit;

  %qc(ds=work.&dsname, obs=10);

%mend;

/* Run macro */
%type_summary(SUV);

/*------------------------------------------------------------------------------
6) Global vs local macro variables
------------------------------------------------------------------------------*/
%let g_a = 777;
%let g_b = 266;

%macro sum_global;
  data work.testing_global;
    sum = &g_a + &g_b;
  run;
  %qc(ds=work.testing_global, obs=5);
%mend;

%sum_global;

%macro sum_local;
  %local a b;
  %let a = 777;
  %let b = 266;

  data work.testing_local;
    sum = &a + &b;
  run;
  %qc(ds=work.testing_local, obs=5);
%mend;

%sum_local;

/*------------------------------------------------------------------------------
7) PROC SQL INTO : macro variables
------------------------------------------------------------------------------*/
proc sql;
  create table work.car_summary as
  select Type,
         Origin,
         count(*)      as no_of_units,
         sum(MSRP)     as total_msrp     format=comma14.,
         sum(Invoice)  as total_invoice  format=comma14.
  from sashelp.cars
  group by Type, Origin;
quit;

%qc(ds=work.car_summary, obs=10);

proc sql noprint;
  select distinct no_of_units
    into :units_list separated by ','
  from work.car_summary
  where no_of_units > 50;
quit;

%put NOTE: units_list=&units_list.;

data work.testing_units_filter;
  set work.car_summary;
  where no_of_units in (&units_list);
run;

%qc(ds=work.testing_units_filter, obs=10);

/*------------------------------------------------------------------------------
8) CALL SYMPUTX (DATA step -> macro variable)
------------------------------------------------------------------------------*/
data _null_;
  call symputx('units_single', 94, 'G'); /* global */
run;

%put NOTE: units_single=&units_single.;

data work.testing_units_single;
  set work.car_summary;
  where no_of_units = &units_single;
run;

%qc(ds=work.testing_units_single, obs=10);

/*------------------------------------------------------------------------------
9) Macro IF/ELSE
------------------------------------------------------------------------------*/
%macro report(car_type);

  %local type_u;
  %let type_u = %upcase(%superq(car_type));

  %if &type_u = HYBRID %then %do;

    proc sql;
      create table work.hybrid_category as
      select Type,
             Origin,
             count(*)       as no_of_units,
             mean(Cylinders) as avg_no_of_cylinders format=8.2
      from sashelp.cars
      where upcase(Type) = "&type_u"
      group by Type, Origin;
    quit;

/*     %qc(ds=work.hybrid_category, obs=10); */

  %end;
  %else %do;

    proc sql;
      create table work.normal_category as
      select Type,
             Origin,
             count(*)        as no_of_units,
             mean(Horsepower) as avg_horsepower format=8.2
      from sashelp.cars
      where upcase(Type) ne "&type_u"
      group by Type, Origin;
    quit;

/*     %qc(ds=work.normal_category, obs=10); */

  %end;

%mend;

/* Run macro */
%report(SUV);
%report(HYBRID);

/*------------------------------------------------------------------------------
10) Macro Loop
------------------------------------------------------------------------------*/
%macro loop_types(type_list);
  %local i one;
  %let i = 1;
  %let one = %scan(&type_list, &i, |);

  %do %while(%length(&one) > 0);
    %type_summary(&one);
    %let i = %eval(&i + 1);
    %let one = %scan(&type_list, &i, |);
  %end;
%mend;

%loop_types(SUV|Truck|Sedan);

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
