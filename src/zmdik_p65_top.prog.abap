*&---------------------------------------------------------------------*
*& Include          ZMDIK_P65_TOP
*&---------------------------------------------------------------------*


TABLES: scarr.

data: go_grid type REF TO cl_gui_alv_grid,
      go_cont TYPE ref to cl_gui_custom_container.

data: go_alv TYPE REF TO cl_gui_alv_grid,
      go_alv2 TYPE REF TO cl_gui_alv_grid.



  data: go_splitter TYPE REF TO cl_gui_splitter_container,
        go_gui1 TYPE REF TO cl_gui_container,
        go_gui2 TYPE REF TO cl_gui_container.



  FIELD-SYMBOLS <gfs_fcat> type  lvc_s_fcat.

     data: go_docu type REF TO cl_dd_document.






     data :gt_scarr TYPE TABLE OF scarr,
           gt_scarr2 type TABLE OF scarr,
           gs_scarr type scarr,
           gs_scarr2 TYPE scarr,
           gt_fcat type LVC_T_FCAT,
           gt_fcat2 type LVC_T_FCAT,
           gs_fcat  type LVC_S_FCAT,
           gs_layout TYPE LVC_S_LAYO.


     class cl_event_receiver DEFINITION DEFERRED.


     data: go_event_receiver type REF TO cl_event_receiver.
