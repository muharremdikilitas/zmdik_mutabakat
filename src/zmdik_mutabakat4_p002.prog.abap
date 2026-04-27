*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT4_P002
*&---------------------------------------------------------------------*


selection-screen begin of block blk1 with frame title text-005.


parameters      : p_bukrs TYPE knb1-bukrs OBLIGATORY,
                  p_date TYPE sy-datum   OBLIGATORY.


SELECT-OPTIONS  : p_kunnr FOR kna1-kunnr.

selection-screen end of block blk1.
