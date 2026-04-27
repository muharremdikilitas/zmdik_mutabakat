*&---------------------------------------------------------------------*
*& Include          ZMDIK_P96_002
*&---------------------------------------------------------------------*

selection-screen begin of block b1 with frame title text-t01.

  parameters: p_bukrs type bukrs.

  selection-screen begin of line.
    selection-screen comment 1(28) text-b07 for field p_koart.
    select-options p_koart for /mdpes/erec_t010-koart no intervals.
  selection-screen end of line.


  selection-screen begin of line.
    selection-screen comment 1(28) text-b06 for field p_acno.
    select-options p_acno for /mdpes/erec_t010-accno no intervals.
  selection-screen end of line.

selection-screen end of block b1.

selection-screen begin of block b2 with frame title text-t02.
  select-options p_remark for adrt-remark  no intervals .
  selection-screen skip.

  selection-screen begin of line.
    parameters p_only  radiobutton group r1 default 'X' user-command rdo.
    selection-screen comment 5(60) text-m02.
  selection-screen end of line.

  selection-screen begin of line.
    parameters p_first radiobutton group r1.
    selection-screen comment 5(60) text-m03.
  selection-screen end of line.

  selection-screen begin of line.
    parameters p_all   radiobutton group r1.
    selection-screen comment 5(60) text-m04.
  selection-screen end of line.

selection-screen end of block b2.
