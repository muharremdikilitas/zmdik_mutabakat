*&---------------------------------------------------------------------*
*& Report ZMDIK_P035
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P035.
include zmdik_p035_p001.
include zmdik_p035_p002.
include zmdik_p035_p003.



START-OF-SELECTION.
PERFORM get_data.
PERFORM set_fcat.
PERFORM set_layout.
PERFORM display_alv.
