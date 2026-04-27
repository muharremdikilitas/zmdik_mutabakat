*&---------------------------------------------------------------------*
*& Report ZMDIK_P41
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P41.
include ZMDIK_P41_top.
include ZMDIK_P41_pbo.
include ZMDIK_P41_pai.
include ZMDIK_P41_form.

START-OF-SELECTION.

perform get_data.

PERFORM set_data.

PERFORM set_layout.





call SCREEN 0100.
