*&---------------------------------------------------------------------*
*& Include          ZMDIK_P027_P003
*&---------------------------------------------------------------------*


SELECT * FROM zmdik_log INTO table gt_data.



cl_salv_table=>factory(
*  EXPORTING
*    list_display   = if_salv_c_bool_sap=>false
*    r_container    =
*    container_name =
  IMPORTING
    r_salv_table   = go_alv
  CHANGING
    t_table        = gt_data
).
*CATCH cx_salv_msg.
go_alv->display( ).
