*&---------------------------------------------------------------------*
*& Report ZMDIK_P039
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P039.

INCLUDE ZMDIK_P039_p001.
INCLUDE ZMDIK_P039_p002.






START-OF-SELECTION.

PERFORM get_data.
PERFORM set_fc.
PERFORM set_layout.
PERFORM display_alv.
