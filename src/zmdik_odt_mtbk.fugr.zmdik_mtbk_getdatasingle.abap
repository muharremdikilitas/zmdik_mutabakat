FUNCTION ZMDIK_MTBK_GETDATASINGLE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_KUNNR) TYPE  KUNNR OPTIONAL
*"  EXPORTING
*"     VALUE(ES_TABLE) TYPE  ZMDIK_MUTAKABAT
*"----------------------------------------------------------------------

IF P_KUNNR IS NOT INITIAL.

    SELECT SINGLE * FROM zmdik_mutakabat INTO CORRESPONDING FIELDS OF @ES_table WHERE kunnr EQ @P_KUNNR.
  ENDIF.



ENDFUNCTION.
