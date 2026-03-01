/*==============================================================================
Program: 05_cond_if_then_else.sas

Conditional Categorization (IF-THEN-ELSE)
==============================================================================*/

data testing;
  set work.customer;

  length category $20;

  if missing(transaction_amount) then category = "Missing";

  else if transaction_amount < 500 then
      category = "Below Average";

  else if 500 <= transaction_amount < 699 then
      category = "Premium";

  else
      category = "Above Average";

run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
