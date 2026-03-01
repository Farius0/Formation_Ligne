/*==============================================================================
Program: 07_char_utilities.sas
Purpose: Common SAS character functions used for cleaning, parsing, validation,
         masking, and pattern matching.
==============================================================================*/

/*-----------------------------------------------------------------------------
A) Whitespace normalization: COMPRESS / COMPBL / STRIP / TRIM / TRIMN
-----------------------------------------------------------------------------*/
data ch_01_whitespace;
  length text $80;
  text = "  I  WANT    YOU   ";

  len_original = length(text);

  t_strip   = strip(text);              
  t_trim    = trim(text);             
  t_trimn   = trimn(text);
  t_compbl  = compbl(text);
  t_cmp_all = compress(text);

  len_strip  = length(t_strip);
  len_compbl = length(t_compbl);
  len_cmpall = length(t_cmp_all);
run;

/*-----------------------------------------------------------------------------
B) Case tools: UPCASE / LOWCASE / PROPCASE
-----------------------------------------------------------------------------*/
data ch_02_case;
  length name $30;
  input name $1-30;
  datalines;
john
Matthews
Juan
LEA
APriL
raOUl
;
run;

data ch_02_case_out;
  set ch_02_case;
  up  = upcase(name);
  low = lowcase(name);
  pro = propcase(name);
run;

/*-----------------------------------------------------------------------------
C) Concatenation: || vs CAT/CATS/CATX
-----------------------------------------------------------------------------*/
data ch_03_concat;
  length first last $20 full1 full2 full3 full4 $60;

  first = "  JOHN";
  last  = "REAGAN  ";

  full1 = first || " " || last;
  full2 = cat(first, " ", last);
  full3 = cats(first, last);                 
  full4 = catx(" ", first, last);           
run;

/*-----------------------------------------------------------------------------
D) Substrings: SUBSTR / SUBSTRN
-----------------------------------------------------------------------------*/
data ch_04_cards;
  length card_number $50;
  input card_number $1-50;
  datalines;
4467464474464748
3489279827484398
3826932684246236
3289237932798323
1291982982383749
1913903857309310
;
run;

data ch_04_mask;
  set ch_04_cards;

  last4  = substr(card_number, 13, 4);

  masked = card_number;
  substr(masked, 5, 8) = "XXXXXXXX";
run;

/*-----------------------------------------------------------------------------
E) Replace: TRANWRD (substring replace) vs TRANSLATE (char mapping)
-----------------------------------------------------------------------------*/
data ch_05_replace;
  length text $80;
  text = "I WANT YOU AND ONLY YOU";

  rep_word = tranwrd(text, "YOU", "ME");
run;

data ch_05_translate;
  length text $80;
  text = "Leonard";
  rep_char = translate(text, "Br", "Lo");
run;

/*-----------------------------------------------------------------------------
F) Search: INDEX / FIND / INDEXC / FINDC
-----------------------------------------------------------------------------*/
data ch_06_transaction;
  length remarks $80;
  input remarks $1-80;
  datalines;
john.com
louise and amando
gg.com
878.com
Devoted Mother 98907888
5 Ducklings and 1 Fox
Tricking.com
Always love you
Delighted.fr
Are you afraid ??
dev.COM
;
run;

data ch_06_search;
  set ch_06_transaction;

  pos_index  = index(remarks, '.com');        /* case-sensitive */
  pos_find_i = find(remarks, '.com', 'i');    /* ignore case */

  pos_digit  = indexc(remarks, '0123456789'); /* first digit position */
  pos_vowel  = findc(remarks, 'aeiou', 'i');  /* first vowel, ignore case */
run;

/*-----------------------------------------------------------------------------
G) Tokenizing: SCAN / COUNTW
-----------------------------------------------------------------------------*/
data ch_07_tokens;
  length sentence $120;
  sentence = "5 Ducklings and 1 Fox";

  word1 = scan(sentence, 1, ' ');
  word2 = scan(sentence, 2, ' ');
  lastw = scan(sentence, -1, ' ');
  nwords = countw(sentence, ' ');
run;

/*-----------------------------------------------------------------------------
H) Validation helpers: VERIFY / ANYDIGIT / NOTDIGIT / ANYALPHA / ANYSPACE
-----------------------------------------------------------------------------*/
data ch_08_validate;
  length s $50;
  s = "12345A";

  pos_not_allowed = verify(s, '0123456789');
  pos_not_digit   = notdigit(s);
  pos_digit       = anydigit(s);
  pos_alpha       = anyalpha(s);
  pos_space       = anyspace("A B");
run;

/*-----------------------------------------------------------------------------
I) KEEP ONLY certain character classes using COMPRESS modifiers
-----------------------------------------------------------------------------*/
data ch_09_compress_classes;
  length mixed $80;
  mixed = "Order# A-19, amount=1,234.50 EUR";

  digits_only  = compress(mixed, , 'kd');     /* keep digits */
  alpha_only   = compress(mixed, , 'ka');     /* keep letters */
  no_digits    = compress(mixed, , 'd');      /* remove digits */
  no_punct     = compress(mixed, , 'p');      /* remove punctuation */
run;

/*-----------------------------------------------------------------------------
J) Regex: PRXMATCH (detect) + PRXCHANGE (replace)
-----------------------------------------------------------------------------*/
data ch_10_regex;
  set ch_06_transaction;

  pos_8digits = prxmatch('/\d{8}/', remarks);
  if pos_8digits > 0 then mobile = substr(remarks, pos_8digits, 8);

  /* Normalize repeated blanks using regex replace */
  norm_spaces = prxchange('s/\\s+/ /', -1, strip(remarks));
run;

/*-----------------------------------------------------------------------------
K) PUT/INPUT: NUM <-> CHAR conversion
-----------------------------------------------------------------------------*/
data ch_11_convert;
  length num_char $20;
  num = 12345.67;

  num_char = put(num, best12.);
  num_back = input(num_char, best12.);
run;

/*-----------------------------------------------------------------------------
L) Zeros and IDs: preserve leading zeros
-----------------------------------------------------------------------------*/
data ch_12_leading_zeros;
  length id_char $6;
  id_num  = 123;
  id_char = put(id_num, z6.);
run;

/*-----------------------------------------------------------------------------
M) REVERSE
-----------------------------------------------------------------------------*/
data ch_13_reverse;
  length reversed_id $50;

  customerid_num = 987654;
  reversed_id = reverse(strip(put(customerid_num, best12.)));
run;

/*-----------------------------------------------------------------------------
N) CLEANING patterns
-----------------------------------------------------------------------------*/
data ch_14_cleaning_patterns;
  length raw $120 clean $120 email $120;

  raw   = "  john.doe@Example.COM   ";
  clean = upcase(strip(raw));                 /* trim + normalize case */

  /* remove all blanks */
  no_blanks = compress(raw);

  /* keep only letters and digits */
  alnum_only = compress(raw, , 'kas');

  /* email normalization (common) */
  email = lowcase(strip(raw));
run;

/*------------------------------------------------------------------------------
End of program
------------------------------------------------------------------------------*/
