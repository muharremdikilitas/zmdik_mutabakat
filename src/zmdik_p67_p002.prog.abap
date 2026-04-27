*&---------------------------------------------------------------------*
*& Include          ZMDIK_P67_P002
*&---------------------------------------------------------------------*


selection-screen begin of block b1 with frame title title1.
  parameters: p_carrid type char20 default 'AA'.
selection-screen end of block b1.

selection-screen begin of block b2 with frame title title2.
  select-options: so_date for sy-datum default '' to sy-datum.
selection-screen end of block b2.
