FUNCTION ZMDIK_MTBK_GETDATA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_KUNNR) TYPE  KUNNR OPTIONAL
*"  CHANGING
*"     VALUE(ES_TABLE) TYPE  ZMDIK_MUTAKABAT OPTIONAL
*"     VALUE(ET_TABLE) TYPE  ZMDIK_MTBK_DE OPTIONAL
*"----------------------------------------------------------------------
if p_kunnr is INITIAL.
  select * from zmdik_mutakabat into TABLE et_table.
else.
    select SINGLE * from zmdik_mutakabat INTO CORRESPONDING FIELDS OF es_table where bukrs eq p_kunnr .
ENDIF.




ENDFUNCTION.
