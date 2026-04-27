*&---------------------------------------------------------------------*
*& Include          ZMDIK_P45_TOP
*&---------------------------------------------------------------------*

data: go_grid type REF TO cl_gui_alv_grid,
      go_cont TYPE ref to cl_gui_custom_container.



     data :gt_scarr TYPE TABLE OF scarr,
           gs_scarr type scarr,
           gt_fcat type LVC_T_FCAT,
           gs_fcat  type LVC_S_FCAT,
           gs_layout TYPE LVC_S_LAYO.

     data : go_spli TYPE REF TO cl_gui_splitter_container,
            go_sub1 TYPE REF TO cl_gui_container,
            go_sub2 TYPE REF TO cl_gui_container.

     FIELD-SYMBOLS <gfs_scarr> type scarr.


     FIELD-SYMBOLS <gfs_fcat> type  lvc_s_fcat.

     data: go_docu type REF TO cl_dd_document.


     class cl_event_receiver DEFINITION DEFERRED.    "class tanımlamalarında include mantığında sorun olmaması için yaparız.


     data: go_event_receiver type REF TO cl_event_receiver.
