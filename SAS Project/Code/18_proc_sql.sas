/*==============================================================================
Program: 18_proc_sql.sas
Purpose: Querying, summarizing, joining, reshaping, and managing tables/views.
==============================================================================*/

/*-----------------------------------------------------------------------------
0) Basic settings (optional)
-----------------------------------------------------------------------------*/
options mprint mlogic symbolgen;

/*-----------------------------------------------------------------------------
1) SELECT + WHERE + ORDER BY + formats
-----------------------------------------------------------------------------*/
proc sql;
  title "Cars - USA only (preview)";
  select Make,
         Model,
         Type,
         Origin,
         MSRP format=comma12.,
         Invoice format=comma12.
  from sashelp.cars
  where Origin = 'USA'
  order by MSRP desc;
quit;
title;

/*-----------------------------------------------------------------------------
2) DISTINCT + computed columns
-----------------------------------------------------------------------------*/
proc sql;
  title "Distinct Origins and Types";
  select distinct Origin, Type
  from sashelp.cars
  order by Origin, Type;
quit;
title;

/*-----------------------------------------------------------------------------
3) Aggregation + GROUP BY + ORDER BY
-----------------------------------------------------------------------------*/
proc sql;
  title "Aggregation by Type and Origin";
  select Type,
         Origin,
         count(*)                as no_of_units,
         sum(MSRP)               as total_msrp    format=comma14.,
         sum(Invoice)            as total_invoice format=comma14.,
         mean(MSRP)              as avg_msrp      format=comma12.2,
         median(MSRP)            as med_msrp      format=comma12.2
  from sashelp.cars
  group by Type, Origin
  order by Origin, Type;
quit;
title;

/*-----------------------------------------------------------------------------
4) HAVING
-----------------------------------------------------------------------------*/
proc sql;
  title "Origins with large total MSRP";
  select Origin,
         sum(MSRP) as total_msrp format=comma14.
  from sashelp.cars
  group by Origin
  having calculated total_msrp > 5000000
  order by calculated total_msrp desc;
quit;
title;

/*-----------------------------------------------------------------------------
5) CASE WHEN
-----------------------------------------------------------------------------*/
proc sql;
  title "Price band using CASE";
  select Make,
         Model,
         MSRP format=comma12.,
         case
           when MSRP < 20000 then 'LOW'
           when MSRP < 40000 then 'MID'
           else 'HIGH'
         end as price_band length=4
  from sashelp.cars;
quit;
title;

/*-----------------------------------------------------------------------------
6) Missing handling: COALESCE
-----------------------------------------------------------------------------*/
proc sql;
  title "COALESCE example";
  select Make,
         Model,
         coalesce(MSRP, Invoice, 0) as price_fallback format=comma12.
  from sashelp.cars;
quit;
title;

/*-----------------------------------------------------------------------------
7) Create table / view
-----------------------------------------------------------------------------*/
proc sql;
  create table work.cars_usa as
  select *
  from sashelp.cars
  where Origin='USA';

  create view work.v_cars_eu as
  select Make, Model, Origin, Type, MSRP, Invoice
  from sashelp.cars
  where Origin in ('Europe','Asia');
quit;

/*-----------------------------------------------------------------------------
8) Describe table / view (metadata from SQL)
-----------------------------------------------------------------------------*/
proc sql;
  describe table work.cars_usa;
  describe view  work.v_cars_eu;
quit;

/*-----------------------------------------------------------------------------
9) Set operators (combine result sets)
-----------------------------------------------------------------------------*/
proc sql;
  title "UNION vs UNION ALL";

  /* Two small subsets with same columns */
  create table work.cars_suv as
  select Make, Model, Type, Origin, MSRP
  from sashelp.cars
  where Type='SUV';

  create table work.cars_truck as
  select Make, Model, Type, Origin, MSRP
  from sashelp.cars
  where Type='Truck';

  /* DISTINCT union */
  create table work.cars_union as
  select * from work.cars_suv
  union
  select * from work.cars_truck;

  /* Keep duplicates */
  create table work.cars_union_all as
  select * from work.cars_suv
  union all
  select * from work.cars_truck;
quit;
title;

/*-----------------------------------------------------------------------------
10) Joins (INNER / LEFT / RIGHT / FULL / CROSS)
-----------------------------------------------------------------------------*/
proc sql;
  title "Join example: attach origin totals to each row";

  /* Build a summary table to join */
  create table work.origin_totals as
  select Origin,
         count(*)  as n,
         sum(MSRP) as total_msrp format=comma14.
  from sashelp.cars
  group by Origin;

  /* LEFT JOIN */
  create table work.cars_with_origin_totals as
  select a.Make,
         a.Model,
         a.Origin,
         a.MSRP format=comma12.,
         b.n,
         b.total_msrp
  from sashelp.cars as a
  left join work.origin_totals as b
    on a.Origin = b.Origin
  order by a.Origin, a.MSRP desc;
quit;
title;

/* CROSS JOIN */
proc sql;
  title "Cross join (demo with tiny tables)";
  create table work.t1 as select distinct Origin from sashelp.cars;
  create table work.t2 as select distinct Type   from sashelp.cars;

  create table work.cross_demo as
  select a.Origin, b.Type
  from work.t1(obs=3) as a
  cross join work.t2(obs=3) as b;
quit;
title;

/*-----------------------------------------------------------------------------
11) Subqueries
-----------------------------------------------------------------------------*/
proc sql;
  title "Cars above overall average MSRP (scalar subquery)";
  select Make, Model, MSRP format=comma12.
  from sashelp.cars
  where MSRP > (select mean(MSRP) from sashelp.cars)
  order by MSRP desc;
quit;
title;

proc sql;
  title "Origins having more than 100 cars (IN subquery)";
  select *
  from sashelp.cars
  where Origin in (
    select Origin
    from sashelp.cars
    group by Origin
    having count(*) > 100
  );
quit;
title;

/*-----------------------------------------------------------------------------
12) Correlated subquery (row-dependent subquery)
-----------------------------------------------------------------------------*/
proc sql;
  title "Above average MSRP within each Type (correlated subquery)";
  select a.Make, a.Model, a.Type, a.MSRP format=comma12.
  from sashelp.cars as a
  where a.MSRP > (
    select mean(b.MSRP)
    from sashelp.cars as b
    where b.Type = a.Type
  );
quit;
title;

/*-----------------------------------------------------------------------------
13) Data management: INSERT / UPDATE / DELETE
-----------------------------------------------------------------------------*/
proc sql;
  create table work.demo_dml as
  select Make, Model, Type, Origin, MSRP
  from sashelp.cars(obs=5);

  /* INSERT */
  insert into work.demo_dml
    set Make='TEST', Model='MODEL_X', Type='Sedan', Origin='USA', MSRP=99999;

  /* UPDATE */
  update work.demo_dml
    set MSRP = MSRP * 1.05
    where Make='TEST';

  /* DELETE */
  delete from work.demo_dml
    where Make='TEST';

quit;

/*-----------------------------------------------------------------------------
14) CREATE INDEX (performance)
-----------------------------------------------------------------------------*/
proc sql;
  create index Origin on work.cars_usa(Origin);
quit;

/*-----------------------------------------------------------------------------
15) Macro variables from SQL (INTO :)
-----------------------------------------------------------------------------*/
proc sql noprint;
  select count(*) into :n_usa trimmed
  from sashelp.cars
  where Origin='USA';
quit;

%put NOTE: Number of USA cars = &n_usa.;

/*-----------------------------------------------------------------------------
16) Dictionary tables
-----------------------------------------------------------------------------*/
proc sql;
  title "List WORK tables";
  select memname, nobs
  from dictionary.tables
  where libname='WORK'
  order by memname;
quit;
title;

proc sql;
  title "Columns of SASHELP.CARS";
  select name, type, length, format, label
  from dictionary.columns
  where libname='SASHELP' and memname='CARS'
  order by varnum;
quit;
title;

/*-----------------------------------------------------------------------------
17) Reshaping (pivot-like) using PROC SQL
-----------------------------------------------------------------------------*/
proc sql;
  title "SQL pivot (manual): Origin x Type";
  select Origin,
         sum(case when Type='SUV'   then MSRP else 0 end) as suv_msrp   format=comma14.,
         sum(case when Type='Sedan' then MSRP else 0 end) as sedan_msrp format=comma14.,
         sum(case when Type='Truck' then MSRP else 0 end) as truck_msrp format=comma14.
  from sashelp.cars
  group by Origin;
quit;
title;

/*-----------------------------------------------------------------------------
18) OUTOBS / INOBS
-----------------------------------------------------------------------------*/
proc sql outobs=10;
  title "First 10 rows (SQL sampling)";
  select * from sashelp.cars;
quit;
title;

/*-----------------------------------------------------------------------------
19) Clean up titles
-----------------------------------------------------------------------------*/
title;
footnote;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
