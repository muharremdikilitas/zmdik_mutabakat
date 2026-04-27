*&---------------------------------------------------------------------*
*& Include          ZMDIK_P77_I001
*&---------------------------------------------------------------------*
tables: zeho_t600.
type-pools: salv.

types: begin of ty_out,
         bankc   type zeho_t600-bankc,
         bukrs   type zeho_t600-bukrs,
         bankn   type zeho_t600-bankn,
         refbk   type zeho_t600-refbk,
         prdat   type zeho_t600-prdat,
         h00     type i, h01 type i, h02 type i, h03 type i, h04 type i, h05 type i,
         h06     type i, h07 type i, h08 type i, h09 type i, h10 type i, h11 type i,
         h12     type i, h13 type i, h14 type i, h15 type i, h16 type i, h17 type i,
         h18     type i, h19 type i, h20 type i, h21 type i, h22 type i, h23 type i,
         celltab type lvc_t_scol,
       end of ty_out.

data: gt_out type standard table of ty_out with empty key,
      gs_out type ty_out.

data: gs_table type zeho_t600,
      gt_table type table of zeho_t600.

class lcl_report definition deferred.
data: go_report type ref to lcl_report.


" Dakika popup satırı
types: begin of ty_min_row,
         time_rng type c length 11,   " 'HH:MM-HH:MM'
         status   type c length 5,    " 'VAR'/'YOK'
         celltab  type lvc_t_scol,
       end of ty_min_row.
types tt_min_tab type standard table of ty_min_row with empty key.

" Popup container/grid
data: mo_popup_cont type ref to cl_gui_dialogbox_container,
      mo_popup_grid type ref to cl_gui_alv_grid.

types: begin of ty_seg_row,
         from_c5 type c length 5,     " 'HH:MM'
         to_c5   type c length 5,     " 'HH:MM' (24:00 mümkün)
         status  type c length 3,     " 'VAR' / 'YOK'
         minutes type i,              " aralık uzunluğu (dakika)
         celltab type lvc_t_scol,     " renk
       end of ty_seg_row.
types tt_seg_tab type standard table of ty_seg_row with empty key.

data: mo_seg_cont type ref to cl_gui_dialogbox_container,
      mo_seg_grid type ref to cl_gui_alv_grid.
