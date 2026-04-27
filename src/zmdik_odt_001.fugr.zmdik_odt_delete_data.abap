FUNCTION ZMDIK_ODT_DELETE_DATA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_PERSID) TYPE  ZMDIK_PERSID_DE OPTIONAL
*"  CHANGING
*"     VALUE(ES_AIRLINE) TYPE  ZMDIK_PERS_T OPTIONAL
*"----------------------------------------------------------------------

data: gs_scarr type zmdik_pers_t. "structure tanımladık


select single * from zmdik_pers_t into CORRESPONDING FIELDS OF gs_scarr where Pers_Id eq iv_persid.

IF gs_scarr is NOT INITIAL.
  delete zmdik_pers_t from gs_scarr.

ENDIF.



ENDFUNCTION.
