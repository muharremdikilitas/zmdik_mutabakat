*&---------------------------------------------------------------------*
*& Include          ZMDIK_P77_I002
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl WITH FRAME TITLE text-t01.
  SELECT-OPTIONS: s_bukrs FOR zeho_t600-bukrs,
                  s_prdat for zeho_t600-prdat,
                  s_bankc FOR zeho_t600-bankc,
                  s_bankn FOR zeho_t600-bankn,
                  s_refbk for zeho_t600-refbk.

SELECTION-SCREEN END OF BLOCK bl.
