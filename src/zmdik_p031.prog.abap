*&---------------------------------------------------------------------*
*& Report ZMDIK_P031
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P031.


INCLUDE zmdik_p031_p001.
INCLUDE zmdik_p031_p002.



START-OF-SELECTION.
PERFORM set_fc.
PERFORM get_data.
PERFORM set_layout.
PERFORM display_alv.
