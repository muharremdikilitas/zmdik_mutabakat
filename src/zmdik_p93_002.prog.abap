*&---------------------------------------------------------------------*
*& Include          ZMDIK_P89_002
*&---------------------------------------------------------------------*

selection-screen begin of block b1 with frame title text-t01.

  parameters: p_bukrs type bukrs.

  selection-screen begin of line.
    selection-screen comment 1(28) text-b07 for field p_koart.
    select-options p_koart for /mdpes/erec_t010-koart no intervals.
  selection-screen end of line.


  selection-screen begin of line.
    selection-screen comment 1(28) text-b06 for field p_loekz.
    select-options p_acno for /mdpes/erec_t010-accno no intervals.
  selection-screen end of line.

  parameters      p_email type /mdpes/erec_t010-email.

  selection-screen begin of line.
    selection-screen comment 1(28) text-b05 for field p_loekz.

    select-options p_loekz for /mdpes/erec_t010-loekz no intervals.
  selection-screen end of line.

selection-screen end of block b1.
