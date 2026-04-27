FUNCTION RFCSON.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_KUNNR) TYPE  KUNNR OPTIONAL
*"  EXPORTING
*"     VALUE(ES_TABLE) TYPE  ZMDIK_MUTABAKAT4
*"     VALUE(ET_TABLE) TYPE  ZMUTABAKATSON
*"----------------------------------------------------------------------

if iv_kunnr is NOT INITIAL.
  SELECT * from zmdik_mutabakat4 into table et_table.
    else.
      SELECT SINGLE * FROM zmdik_mutabakat4 INTO CORRESPONDING FIELDS OF @es_table where kunnr eq @iv_kunnr.
ENDIF.




ENDFUNCTION.
