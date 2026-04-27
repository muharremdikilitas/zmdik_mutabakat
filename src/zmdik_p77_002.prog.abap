*&---------------------------------------------------------------------*
*& Include          ZMDIK_P77_I002
*&---------------------------------------------------------------------*

selection-screen begin of block bl with frame title text-t01.
  select-options: s_bukrs for zeho_t600-bukrs,
                  s_prdat for zeho_t600-prdat,
                  s_bankc for zeho_t600-bankc,
                  s_bankn for zeho_t600-bankn,
                  s_refbk for zeho_t600-refbk.

selection-screen end of block bl.
