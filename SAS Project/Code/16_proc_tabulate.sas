/*==============================================================================
Program: 16_proc_tabulate.sas
Purpose: Multi-dimensional summary tables
==============================================================================*/
/*Change this path to the appropriate location*/
%let ROOT = path;

/*-----------------------------------------------------------------------------
0) Load sample data
-----------------------------------------------------------------------------*/
proc import datafile="&ROOT./Excel_Files/Customers.xlsx"
  out=work.customer
  dbms=xlsx
  replace;
  sheet="Customers";
  getnames=yes;
run;

/*-----------------------------------------------------------------------------
1) Clean / prepare 
-----------------------------------------------------------------------------*/
data work.customer_clean;
  set work.customer;

  length Country_C City_C ContactName_C $100;

  Country_C     = upcase(strip(Country));
  City_C        = propcase(strip(City));
  ContactName_C = strip(ContactName);

  Amount = Transaction_Amount;
run;

/*-----------------------------------------------------------------------------
2) Formats (banding + stable ordering)
-----------------------------------------------------------------------------*/
proc format;
  value amt_band
    low - <200    = "<200"
    200 - <500    = "200-499"
    500 - <1000   = "500-999"
    1000 - high   = "1000+";
run;

data work.customer_band;
  set work.customer_clean;
  format Amount amt_band.;
run;

/*==============================================================================
A) Core TABULATE patterns
==============================================================================*/

/*-----------------------------------------------------------------------------
A1)1D table*
-----------------------------------------------------------------------------*/
proc tabulate data=work.customer_clean format=comma12.2;
  class Country_C;
  var Amount;

  table Country_C all,
        Amount*(n sum mean median p75);
run;

/*-----------------------------------------------------------------------------
A2) 2D table (rows=Country, cols=City)
-----------------------------------------------------------------------------*/
proc tabulate data=work.customer_clean format=comma12.2;
  class Country_C City_C;
  var Amount;

  keylabel n='Count' sum='Total' mean='Avg' median='Median' p75='P75';

  table Country_C all,
        City_C all * Amount*(n sum mean) 
        / box = "CUSTOMERS - Amount Summary (Country x City)"; 
run;

/*-----------------------------------------------------------------------------
A3) Missing handling
-----------------------------------------------------------------------------*/
proc tabulate data=work.customer_clean format=comma12.2 missing;
  class Country_C City_C;
  var Amount;

  table Country_C,
        City_C * Amount*(n sum)
   		/ misstext = "0" box = "CUSTOMERS - Missing Handling Demo";
run;

/*-----------------------------------------------------------------------------
A4) Filtered tabulate (WHERE= dataset option)
-----------------------------------------------------------------------------*/
proc tabulate data=work.customer_clean(where=(Country_C='USA')) format=comma12.2;
  class City_C;
  var Amount;

  table City_C all,
        Amount*(n sum mean)
        / box = "USA ONLY - Amount Summary by City";
run;

/*==============================================================================
B) Category control: ORDER=FORMATTED / show all levels
==============================================================================*/

/*-----------------------------------------------------------------------------
B1) Band distribution
-----------------------------------------------------------------------------*/
proc tabulate data=work.customer_band format=comma12.2 order=formatted;
  class Country_C Amount;
  table Country_C all,
        Amount all * (n)
        / box = "CUSTOMERS - Amount Bands (PRELOADFMT + ORDER=FORMATTED)";
run;

proc tabulate data=work.customer_band format=comma12.2 order=formatted missing;
  class Amount;
  table Amount, n
  / box = "Amount Bands - Includes Missing";
run;

/*==============================================================================
C) Percentages
==============================================================================*/

/*-----------------------------------------------------------------------------
C1) Percent of counts by Country
-----------------------------------------------------------------------------*/
proc tabulate data=work.customer_clean;
  class Country_C;
  table Country_C all,
        n pctn
        / box = "COUNTRY DISTRIBUTION (Count + % of Total)";
run;

/*-----------------------------------------------------------------------------
C2) Row and column percentages in a cross-tab
-----------------------------------------------------------------------------*/
proc tabulate data=work.customer_clean;
  class Country_C City_C;
  table Country_C,
        City_C * (n rowpctn colpctn)
        / box = "COUNTRY x CITY (N + Row% + Col%)";
run;

/*==============================================================================
D) Multi-dimensional (3D)
==============================================================================*/

data work.customer_3d;
  set work.customer_clean;
  length Segment $10;
  if Amount < 200 then Segment="LOW";
  else if Amount < 500 then Segment="MID";
  else Segment="HIGH";
run;

proc tabulate data=work.customer_3d format=comma12.2;
  class Country_C City_C Segment;
  var Amount;

  table Country_C,
        City_C,
        Segment * Amount*(n sum mean)
        / box = "3D TABLE (Country / City / Segment)";
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
