*&---------------------------------------------------------------------*
*& Include          ZMDIK_P44_TOP
*&---------------------------------------------------------------------*

type-POOLs icon.

TABLES: scarr.

data: go_alv type REF TO cl_gui_alv_grid,
      go_alv2 type REF TO cl_gui_alv_grid,
      go_cont TYPE ref to cl_gui_custom_container.
*
*data: go_alv2 type REF TO cl_gui_alv_grid,
*      go_cont2 TYPE ref to cl_gui_custom_container.


data: go_splitter type ref to cl_gui_splitter_container,
      go_gui1 TYPE REF TO cl_gui_container,
        go_gui2 TYPE REF TO cl_gui_container.








     data :gt_scarr TYPE TABLE OF scarr,
           gt_sflight type TABLE OF sflight,
           gt_fcat type LVC_T_FCAT,
           gt_fcat2 type LVC_T_FCAT,
           gs_fcat  type LVC_S_FCAT,
           gs_layout TYPE LVC_S_LAYO.
