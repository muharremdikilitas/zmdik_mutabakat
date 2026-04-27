*&---------------------------------------------------------------------*
*& Report ZMDIK_P40
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P40.



INCLUDE ZMDIK_P40_top.
INCLUDE ZMDIK_P40_pbo.
INCLUDE ZMDIK_P40_pai.
INCLUDE ZMDIK_P40_frm.

START-OF-SELECTION.

PERFORM get_data.






call SCREEN 0100.
