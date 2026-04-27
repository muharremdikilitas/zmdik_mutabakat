FUNCTION ZMDIK_ODT_INSERT_DATA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_PERSID) TYPE  ZMDIK_PERSID_DE OPTIONAL
*"  CHANGING
*"     VALUE(ES_AIRLINE) TYPE  ZMDIK_PERS_T OPTIONAL
*"----------------------------------------------------------------------

data: gs_scarr type zmdik_pers_t. "structure tanımladık
gs_scarr-pers_id = es_airline-pers_id.
gs_scarr-pers_ad = es_airline-pers_ad.

gs_scarr-pers_soyad = es_airline-pers_soyad.
gs_scarr-pers_cins = es_airline-pers_cins .

IF gs_scarr is INITIAL.
INSERT zmdik_pers_t FROM gs_scarr.
else.
 MODIFY zmdik_pers_t FROM gs_scarr.
ENDIF.



ENDFUNCTION.
