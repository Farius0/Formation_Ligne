/*==============================================================================
Program: 09_date_utilities.sas
Purpose: Create, parse, format, and manipulate SAS dates.
==============================================================================*/

/*-----------------------------------------------------------------------------
1) Create dates + extract components
-----------------------------------------------------------------------------*/
data dt_01_basics;
  format current_date make_date date9.;

  current_date = today();

  day_num     = day(current_date);
  weekday_num = weekday(current_date);
  month_num   = month(current_date);
  quarter_num = qtr(current_date);
  year_num    = year(current_date);

  make_date = mdy(5, 30, 2027);
run;

proc print data=dt_01_basics; run;

/*-----------------------------------------------------------------------------
2) Parse dates from text (INFORMAT) + display (FORMAT)
-----------------------------------------------------------------------------*/
data dt_02_parse_ddmmyy;
  input date_char $10.;
  date = input(date_char, ddmmyy10.);
  format date ddmmyy10.;
  datalines;
01/01/1961
30/12/2025
;
run;

proc print data=dt_02_parse_ddmmyy; run;

/* Alternative */
data dt_02_parse_direct;
  input date ddmmyy10.;
  format date ddmmyy10.;
  datalines;
01/01/1961
;
run;

proc print data=dt_02_parse_direct; run;

/*-----------------------------------------------------------------------------
3) Date literals
-----------------------------------------------------------------------------*/
data dt_03_literals;
  format admission_date discharge_date date9.;
  admission_date  = "10JAN2025"d;
  discharge_date  = "30JAN2025"d;
  length_of_stay  = discharge_date - admission_date;
run;

proc print data=dt_03_literals; run;

/*-----------------------------------------------------------------------------
4) INTCK: count boundaries crossed (discrete vs continuous)
-----------------------------------------------------------------------------*/
data dt_04_intck;
  format start_date end_date date9.;
  start_date = "31DEC2025"d;
  end_date   = "01JAN2026"d;

  diff_day  = intck('day', start_date, end_date);
  diff_m_d  = intck('month', start_date, end_date);        /* discrete */
  diff_m_c  = intck('month', start_date, end_date, 'c');   /* continuous */
run;

proc print data=dt_04_intck; run;

/*-----------------------------------------------------------------------------
5) INTNX: move to a future/past date (with alignment)
Alignment:
  - 'S' Same day (default)
  - 'B' Beginning of interval
  - 'M' Middle of interval
  - 'E' End of interval
-----------------------------------------------------------------------------*/
data dt_05_intnx_days;
  format first_visit second_visit third_visit fourth_visit date9.;
  first_visit  = "10JUL2025"d;
  second_visit = intnx('day', first_visit, 20, 's');
  third_visit  = intnx('day', second_visit, 20, 's');
  fourth_visit = intnx('day', third_visit, 20, 's');
run;

proc print data=dt_05_intnx_days; run;

data dt_06_intnx_month_align;
  format start_date end_same end_beg end_mid end_end date9.;
  start_date = "10JUL2025"d;

  end_same = intnx('month', start_date, 3, 's');
  end_beg  = intnx('month', start_date, 3, 'b');
  end_mid  = intnx('month', start_date, 3, 'm');
  end_end  = intnx('month', start_date, 3, 'e');
run;

proc print data=dt_06_intnx_month_align; run;

/*-----------------------------------------------------------------------------
6) Common derived dates (start/end of month, next/previous)
-----------------------------------------------------------------------------*/
data dt_07_month_helpers;
  format d month_beg month_end next_month_beg prev_month_end date9.;

  d = today();

  month_beg      = intnx('month', d, 0, 'b');
  month_end      = intnx('month', d, 0, 'e');
  next_month_beg = intnx('month', d, 1, 'b');
  prev_month_end = intnx('month', d, -1, 'e');
run;

proc print data=dt_07_month_helpers; run;

/*-----------------------------------------------------------------------------
7) Day name / month name (formats)
-----------------------------------------------------------------------------*/
data dt_08_names;
  format d date9.;
  d = today();

  weekday_name = put(d, downame.);
  month_name   = put(d, monname.);
run;

proc print data=dt_08_names; run;

/*-----------------------------------------------------------------------------
8) YRDIF: year fraction between two dates
Day count conventions include: 'ACT/ACT', '30/360', etc.
-----------------------------------------------------------------------------*/
data dt_09_yrdif;
  format birthdate refdate date9.;
  birthdate = "01JAN1990"d;
  refdate   = today();

  age_years = yrdif(birthdate, refdate, 'ACT/ACT');
run;

proc print data=dt_09_yrdif; run;

/*-----------------------------------------------------------------------------
9) Datetime (seconds since 01JAN1960:00:00:00)
  - DATEPART extracts date from datetime
  - TIMEPART extracts time from datetime
-----------------------------------------------------------------------------*/
data dt_10_datetime;
  format dt datetime19. d date9. t time8.;

  dt = datetime();
  d  = datepart(dt);
  t  = timepart(dt);
run;

proc print data=dt_10_datetime; run;

/*-----------------------------------------------------------------------------
10) LAG()
-----------------------------------------------------------------------------*/
data dt_11_lag_example;
  format d prev_d date9.;
  input d date9.;
  prev_d = lag(d);
  if not missing(prev_d) then diff_days = d - prev_d;
  datalines;
01JAN2025
05JAN2025
20JAN2025
;
run;

proc print data=dt_11_lag_example; run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
