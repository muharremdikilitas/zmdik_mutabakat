*&---------------------------------------------------------------------*
*& Report ZMDIK_P44
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P44.

include ZMDIK_P44_top.
include ZMDIK_P44_pbo.
include ZMDIK_P44_pai.
include ZMDIK_P44_form.


START-OF-SELECTION.

START-OF-SELECTION.

perform get_data.

PERFORM set_data.

PERFORM set_layout.





call SCREEN 0100.
