*&---------------------------------------------------------------------*
*& Include          ZMDIK_P035_P001
*&---------------------------------------------------------------------*
tables: bseg.

TYPES: BEGIN OF gsy_str.
  INCLUDE STRUCTURE bseg.
  TYPES: cell_color TYPE slis_t_specialcol_alv,
    end of gsy_str.

    data: gs_table TYPE gsy_str,
          gt_table TYPE TABLE of gsy_str.

data: gs_cell_color TYPE slis_specialcol_alv.

  data: gs_filedcat type slis_fieldcat_alv,
        gt_fieldcat TYPE slis_t_fieldcat_alv.

data: gs_layout TYPE slis_layout_alv.
