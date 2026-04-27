*&---------------------------------------------------------------------*
*& Report ZMDIK_P017
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P017.



TABLES: scarr.

  DATA: gs_str type scarr.
  DATA: gt_table like TABLE OF gs_str.
  DATA: go_alv TYPE REF TO cl_salv_table.

  select * FROM scarr  INTO CORRESPONDING FIELDS OF TABLE gt_table.

    cl_salv_table=>factory(
*      EXPORTING
*        list_display   = if_salv_c_bool_sap=>false
*        r_container    =
*        container_name =
     IMPORTING
       r_salv_table   = go_alv
      CHANGING
        t_table        = gt_table
    ).
*    CATCH cx_salv_msg.

   DATA(lo_display) = go_alv->get_display_settings( ).  " SALV Görünüm Ayarlarını Al
lo_display->set_list_header( 'SALV Eğitim' ).
lo_display->set_striped_pattern( value = 'X' ).  "renk ayarı

data: lo_cols TYPE REF TO cl_salv_columns.      "bütün başlıkların kutucuğunu ona göre ayarladı
lo_cols = go_alv->get_columns( ).
lo_cols->set_optimize( value = 'X' ).

data: lo_col TYPE REF TO cl_salv_column.   "text uzunluklarını ona göre ayarlıyor
lo_col = lo_cols->get_column( columnname = 'CURRCODE' ).
lo_col->set_long_text( value = 'Havayolu şirketinin ulusal para birimi'  ).
lo_col->set_short_text( value = 'curcode'  ).




lo_col = lo_cols->get_column( columnname = 'MANDT' ).   "mandt kolonunu sildi
lo_col->set_visible(
   value = if_salv_c_bool_sap=>false
).




data: lo_func TYPE REF TO cl_salv_functions.    "alv ler için fonksiyonlar ekledi
lo_func = go_alv->get_functions( ).
lo_func->set_all( abap_true ).






   go_alv->display( ).
