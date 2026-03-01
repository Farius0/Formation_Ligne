/*==============================================================================
Program: 02_table_creation.sas

Table Creation (DATA step + DATALINES)
==============================================================================*/

/*-----------------------------------------------------------------------------
A) First table: employees
-----------------------------------------------------------------------------*/
data work.first_data;

  length employee $10;
  label  employee = "Employee Name"
         salary   = "Monthly Salary";

  input employee :$10.
        salary   :best12.;

  datalines;
SAMEER 1234
ROHAN 1234
MICHLE 2132
JAMES 98098
;
run;


/*-----------------------------------------------------------------------------
B) Second table: students notes
-----------------------------------------------------------------------------*/
data work.notes;

  length nom $30;

  attrib nom label="Nom des eleves"
         notes label="Score";

  input nom :$30.
        notes :best12.;

  datalines;
LEA 80
JOHN 98
ROB 67
ANNA 99
;
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
