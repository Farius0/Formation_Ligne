/*==============================================================================
Program: 08_num_utilities.sas
Purpose: Common numeric functions for transformation, validation,
         statistics, financial and mathematical operations.
==============================================================================*/

/*-----------------------------------------------------------------------------
A) Rounding Functions: ROUND / CEIL / FLOOR / INT
-----------------------------------------------------------------------------*/
data num_01_rounding;
  value = 123.4567;

  round_1    = round(value, 0.1);
  round_01   = round(value, 0.01);
  ceil_val   = ceil(value);
  floor_val  = floor(value);
  int_val    = int(value);
run;


/*-----------------------------------------------------------------------------
B) Absolute value and sign
-----------------------------------------------------------------------------*/
data num_02_abs;
  x = -25;

  abs_val  = abs(x);
  sign_val = sign(x);
run;


/*-----------------------------------------------------------------------------
C) Power / Square / Square Root
-----------------------------------------------------------------------------*/
data num_03_power;
  x = 5;

  squared   = x**2;
  cubed     = x**3;
  sqrt_val  = sqrt(25);
  exp_val   = exp(1);
  log_val   = log(100);
  log10_val = log10(100);
run;


/*-----------------------------------------------------------------------------
D) Modulo (remainder)
-----------------------------------------------------------------------------*/
data num_04_mod;
  x = 17;
  mod_val = mod(x, 5);
run;


/*-----------------------------------------------------------------------------
E) Row-level statistics: SUM / MEAN / MIN / MAX
-----------------------------------------------------------------------------*/
data num_05_row_stats;
  a = 10;
  b = .;       /* missing */
  c = 30;

  sum_val  = sum(a, b, c);     /* ignores missing */
  mean_val = mean(a, b, c);
  min_val  = min(a, b, c);
  max_val  = max(a, b, c);
run;


/*-----------------------------------------------------------------------------
F) Safe Division
-----------------------------------------------------------------------------*/
data num_06_safe_div;
  numerator   = 100;
  denominator = 0;

  if denominator ne 0 then ratio = numerator / denominator;
  else ratio = .;
run;


/*-----------------------------------------------------------------------------
G) Missing handling: COALESCE / NMISS
-----------------------------------------------------------------------------*/
data num_07_missing;
  x = .;
  y = 10;

  coalesced = coalesce(x, y, 0);  /* first non-missing */
  nmiss_val = nmiss(x, y);        /* number of missing values */
run;


/*-----------------------------------------------------------------------------
H) Random numbers
-----------------------------------------------------------------------------*/
data num_08_random;
  call streaminit(123);           /* seed for reproducibility */

  uniform_val = rand("uniform");
  normal_val  = rand("normal", 0, 1);
run;


/*-----------------------------------------------------------------------------
I) Ranking manually
-----------------------------------------------------------------------------*/
proc sort data=sashelp.class out=num_09_rank;
  by weight;
run;

data num_09_rank;
  set num_09_rank;
  rank = _n_;
run;


/*-----------------------------------------------------------------------------
J) Standardization
-----------------------------------------------------------------------------*/
proc means data=sashelp.class noprint;
  var weight;
  output out=stats mean=mean_w std=std_w;
run;

data num_10_standardize;
  if _n_=1 then set stats;
  set sashelp.class;

  z_score = (weight - mean_w) / std_w;
run;


/*-----------------------------------------------------------------------------
K) Financial utilities
-----------------------------------------------------------------------------*/
data num_11_financial;
  rate = 0.05;
  nper = 10;
  pv   = 1000;

  fv_val = pv * (1 + rate)**nper;
run;


/*-----------------------------------------------------------------------------
L) Trigonometric functions
-----------------------------------------------------------------------------*/
data num_12_trig;
  angle = constant('pi') / 4;

  sin_val = sin(angle);
  cos_val = cos(angle);
  tan_val = tan(angle);
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
