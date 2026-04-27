*&---------------------------------------------------------------------*
*& Include          ZMDIK_P033_P001
*&---------------------------------------------------------------------*

TABLES:bkpf.
TYPES: BEGIN OF gsy_str.
  INCLUDE STRUCTURE bkpf.
 TYPES: line_color type char4,
        selkz type char1,
 end of gsy_str.

 data: gt_data TYPE  TABLE OF  gsy_str,
       gs_data TYPE bkpf.


data: gt_color TYPE slis_t_specialcol_alv,
      gs_color TYPE slis_specialcol_alv.

 data: gt_data2 TYPE  TABLE OF  gsy_str,
       gs_data2 TYPE bkpf.
data: go_alv TYPE REF TO cl_salv_table.

  data: gt_fieldcatalog TYPE  SLIS_T_FIELDCAT_ALV,
        gs_fieldcatalog TYPE slis_fieldcat_alv.
  DATA: gs_layout TYPE slis_layout_alv.

   DATA: gt_events type SLIS_T_EVENT,
        gs_event TYPE slis_alv_event.
