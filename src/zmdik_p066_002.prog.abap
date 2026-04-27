*&---------------------------------------------------------------------*
*& Include          ZMDIK_P066_002
*&---------------------------------------------------------------------*



SELECT-OPTIONS:   S_bukrs FOR knb1-bukrs,
                  s_kunnr for kna1-kunnr,
                  s_fdate for sy-datum.



PARAMETERS: p_debt TYPE c as CHECKBOX DEFAULT 'X'.
