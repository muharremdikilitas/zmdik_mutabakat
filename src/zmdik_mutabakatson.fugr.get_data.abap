FUNCTION GET_DATA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_KUNNR) TYPE  KUNNR OPTIONAL
*"  EXPORTING
*"     VALUE(ES_TABLE) TYPE  ZMDIK_T006
*"     VALUE(ET_TABLE) TYPE  ZMDIK_T006S
*"----------------------------------------------------------------------

  IF IV_KUNNR IS INITIAL.
    SELECT * FROM zmdik_t006 INTO TABLE @et_table.
  ELSE.
    SELECT SINGLE * FROM zmdik_t006 INTO CORRESPONDING FIELDS OF @es_table WHERE kunnr EQ @IV_KUNNR.
  ENDIF.





ENDFUNCTION.
