*&---------------------------------------------------------------------*
*& Include          ZMDIK_P77_I001
*&---------------------------------------------------------------------*



tables: zeho_t600.
TYPE-POOLS: salv.

TYPES: BEGIN OF ty_out,
         bankc TYPE zeho_t600-bankc,
         bukrs TYPE zeho_t600-bukrs,
         bankn TYPE zeho_t600-bankn,
         refbk TYPE zeho_t600-refbk,
         prdat TYPE zeho_t600-prdat,
         " Saat başına adet yazacağız (0..60) – şimdilik boş/0 kalacak
         h00 TYPE i, h01 TYPE i, h02 TYPE i, h03 TYPE i, h04 TYPE i, h05 TYPE i,
         h06 TYPE i, h07 TYPE i, h08 TYPE i, h09 TYPE i, h10 TYPE i, h11 TYPE i,
         h12 TYPE i, h13 TYPE i, h14 TYPE i, h15 TYPE i, h16 TYPE i, h17 TYPE i,
         h18 TYPE i, h19 TYPE i, h20 TYPE i, h21 TYPE i, h22 TYPE i, h23 TYPE i,
  celltab TYPE lvc_t_scol,
       END OF ty_out.

DATA: gt_out TYPE STANDARD TABLE OF ty_out WITH EMPTY KEY,
      gs_out TYPE ty_out.




data:  gs_table type zeho_t600,
       gt_table type table of zeho_t600.



  class lcl_report definition deferred.
data: go_report type ref to lcl_report.


  " Dakika popup satırı (renk için CELLTAB ile)
  TYPES: BEGIN OF ty_min_row,
           time_rng TYPE c LENGTH 11,   " 'HH:MM-HH:MM'
           status   TYPE c LENGTH 5,    " 'VAR'/'YOK'
           celltab  TYPE lvc_t_scol,
         END OF ty_min_row.
  TYPES tt_min_tab TYPE STANDARD TABLE OF ty_min_row WITH EMPTY KEY.

  " Popup container/grid
  DATA: mo_popup_cont TYPE REF TO cl_gui_dialogbox_container,
        mo_popup_grid TYPE REF TO cl_gui_alv_grid.


   TYPES: BEGIN OF ty_seg_row,
           from_c5 TYPE c LENGTH 5,     " 'HH:MM'
           to_c5   TYPE c LENGTH 5,     " 'HH:MM' (24:00 mümkün)
           status  TYPE c LENGTH 3,     " 'VAR' / 'YOK'
           minutes TYPE i,              " aralık uzunluğu (dakika)
           celltab TYPE lvc_t_scol,     " renk
         END OF ty_seg_row.
  TYPES tt_seg_tab TYPE STANDARD TABLE OF ty_seg_row WITH EMPTY KEY.

  DATA: mo_seg_cont TYPE REF TO cl_gui_dialogbox_container,
        mo_seg_grid TYPE REF TO cl_gui_alv_grid.
