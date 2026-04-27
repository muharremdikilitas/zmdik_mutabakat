*&---------------------------------------------------------------------*
*& Report ZMDIK_P43
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P43.


include ZMDIK_P43_top.
include ZMDIK_P43_cls.
include ZMDIK_P43_pbo.
include ZMDIK_P43_pai.
include ZMDIK_P43_form.


START-OF-SELECTION.

perform get_data.

PERFORM set_data.

PERFORM set_layout.





call SCREEN 0100.
