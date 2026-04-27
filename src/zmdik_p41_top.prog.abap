*&---------------------------------------------------------------------*
*& Include          ZMDIK_P41_TOP
*&---------------------------------------------------------------------*

type-POOLs icon.

TABLES: scarr.

data: go_alv type REF TO cl_gui_alv_grid,
      go_cont TYPE ref to cl_gui_custom_container.

types: begin of gty_scarr,
          durum type icon_d,
          mandt type s_mandt,
          carrid type s_carr_id,
          carrname type s_carrname,
          currcode type s_currcode,
*          url type s_carrurl,
*          line_color type char4,
*          cell_color type lvc_t_scol,
          cost type int4,
          locaiton type char20,
          seatl type char1,
          seatp type char10,
          dd_handle type int4,
          end of gty_scarr.


      data: gs_cell type  lvc_s_scol.

     data: gt_scarr type table of gty_scarr,
           gs_scarr type gty_scarr.

     data : gt_fcat type LVC_T_FCAT,
           gs_fcat  type LVC_S_FCAT.

     data: gs_layout TYPE LVC_S_LAYO.


    FIELD-SYMBOLS: <gfs_scarr> type gty_scarr.
