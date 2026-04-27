FUNCTION ZMDIK_ODT_GET_DATA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_PERSID) TYPE  ZMDIK_PERSID_DE OPTIONAL
*"  EXPORTING
*"     VALUE(ET_AIRLINE) TYPE  ZMDIK_PERS_TT
*"     VALUE(ES_AIRLINE) TYPE  ZMDIK_PERS_T
*"----------------------------------------------------------------------
IF iv_persid is INITIAL.
  select * from zmdik_pers_t into table @et_airline.
    else.
      SELECT SINGLE * FROM zmdik_pers_t INTO CORRESPONDING FIELDS OF @es_airline where pers_id eq @iv_persid.


ENDIF.




ENDFUNCTION.
