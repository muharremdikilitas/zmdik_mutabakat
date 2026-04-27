
FORM display_alv .


*CREATE OBJECT go_cont
*  EXPORTING
*    container_name              = 'CC_ALV'.
*
*
*
*CREATE OBJECT go_alv
*  EXPORTING
*
*    i_parent                = cl_gui_container=>screen0.    "eğer ki hiç konteyner oluşturmadan ful alv yi ekrana sığdırmak istiyorsak böyle yaparız.
*  .

 IF go_alv is INITIAL.

   CREATE OBJECT go_cont
  EXPORTING
    container_name              = 'CC_ALV'.



CREATE OBJECT go_alv
  EXPORTING

    i_parent                = go_cont

  .


perform set_drop_down.

  call METHOD go_alv->set_table_for_first_display
*  EXPORTING
*    i_buffer_active               =
*    i_bypassing_buffer            =
*    i_consistency_check           =
*    i_structure_name              =
*    is_variant                    =
*    i_save                        =
*    i_default                     = 'X'
*    is_layout                     = gs_layout
*    is_print                      =
*    it_special_groups             =
*    it_toolbar_excluding          =
*    it_hyperlink                  =
*    it_alv_graphics               =
*    it_except_qinfo               =
*    ir_salv_adapter               =
  CHANGING
    it_outtab                     = gt_scarr
    it_fieldcatalog               = gt_fcat
*    it_sort                       =
*    it_filter                     =
*  EXCEPTIONS
*    invalid_parameter_combination = 1
*    program_error                 = 2
*    too_many_lines                = 3
*    others                        = 4
  .

*call method go_alv->register_edit_event
*  EXPORTING
*    i_event_id = cl_gui_alv_grid=>mc_evt_enter.       "yalnızca entere bastığımda yaptığım değişiklikleri program algılar

*
call method go_alv->register_edit_event
  EXPORTING
    i_event_id = cl_gui_alv_grid=>mc_evt_modified.      " herhangi bir değişiklik yakalar yakalamaz bunu algılar


else.
  call METHOD go_alv->refresh_table_display.         "yeni bir değişiklikte bu methodla refresh yap. var olan güncelemeler için



ENDIF.

ENDFORM.








FORM get_data .

SELECT * from scarr into CORRESPONDING FIELDS OF table gt_scarr.

  LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
    CASE <gfs_scarr>-currcode.
      WHEN'EUR' .
      <gfs_scarr>-dd_handle = '3'.
        WHEN'USD' .
      <gfs_scarr>-dd_handle = '4'.
        WHEN'JPY' .
      <gfs_scarr>-dd_handle = '5'.
    ENDCASE.

  ENDLOOP.


*LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
*  CASE <gfs_scarr>-currcode.
*    WHEN 'USD' .
*      <gfs_scarr>-durum = '@2O@'.
*
*  ENDCASE.
*
*ENDLOOP.

*  LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
*CASE <gfs_scarr>-currcode.
*  WHEN 'USD'.
*   <gfs_scarr>-line_color = 'C710'.
*   when 'JPY'.
*     <gfs_scarr>-line_color = 'C501'.
*     when 'EUR'.
*       CLEAR: gs_cell.
*       gs_cell-fname = 'URL'.
*       gs_cell-color-col = '3'.
*       gs_cell-color-int = '1'.
*       gs_cell-color-inv = '0'.
*       APPEND gs_cell to <gfs_scarr>-cell_color.
*ENDCASE.
*  ENDLOOP.

ENDFORM.

FORM set_data .
*
CLEAR: gs_fcat.
gs_fcat-fieldname ='durum '.
gs_fcat-scrtext_s ='ikon'.
gs_fcat-scrtext_m ='ikon'.
gs_fcat-scrtext_l ='ikon '.
*gs_fcat-key = abap_true.
append gs_fcat to gt_fcat.




CLEAR: gs_fcat.
gs_fcat-fieldname = 'CARRID'.
gs_fcat-scrtext_s = 'Havayolu'.
gs_fcat-scrtext_m = 'Havayolu Tanımı'.
gs_fcat-scrtext_l = 'Havayolu Şirketi Tanımı'.
*gs_fcat-key = abap_true.
append gs_fcat to gt_fcat.

CLEAR: gs_fcat.
gs_fcat-fieldname = 'CARRNAME'.
gs_fcat-scrtext_s = 'Havayolu'.
gs_fcat-scrtext_m = 'Havayolu Adı'.
gs_fcat-scrtext_l = 'Havayolu Şirketi Adı'.
*gs_fcat-edit = abap_true.
append gs_fcat to gt_fcat.


CLEAR: gs_fcat.
gs_fcat-fieldname = 'CURRCODE'.
gs_fcat-scrtext_s = 'Havayolu upb'.
gs_fcat-scrtext_m = 'Havayolu  upb Tanımı'.
gs_fcat-scrtext_l = 'Havayolu Şirketi upb  Tanımı'.
*gs_fcat-hotspot = abap_true.
append gs_fcat to gt_fcat.

CLEAR: gs_fcat.
gs_fcat-fieldname = 'URL'.
gs_fcat-scrtext_s = 'Havayolu url'.
gs_fcat-scrtext_m = 'Havayolu  url Tanımı'.
gs_fcat-scrtext_l = 'Havayolu Şirketi url Tanımı'.
*gs_fcat-col_opt = abap_true.
*gs_fcat-outputlen = 100.      "kolonu genişletir

*gs_fcat-ref_table = 'SCARR'.      "scarr tablosunun url kolonunu referans alarak direkt sistemdekini kopyalıyoruz.
*gs_fcat-ref_field = 'URL'.
append gs_fcat to gt_fcat.


CLEAR: gs_fcat.
gs_fcat-fieldname = 'COST'.
gs_fcat-scrtext_s = 'FİYAT'.
gs_fcat-scrtext_m = 'FİYAT'.
gs_fcat-scrtext_l = 'FİYAT'.
gs_fcat-edit  = abap_true.
append gs_fcat to gt_fcat.



CLEAR: gs_fcat.
gs_fcat-fieldname ='LOCATION '.
gs_fcat-scrtext_s ='location'.
gs_fcat-scrtext_m ='location'.
gs_fcat-scrtext_l ='location'.
gs_fcat-edit = abap_true.
gs_fcat-drdn_hndl = 1.           "seçenek sunmak için
append gs_fcat to gt_fcat.


CLEAR: gs_fcat.
gs_fcat-fieldname ='seatl '.
gs_fcat-scrtext_s ='koltuk harf'.
gs_fcat-scrtext_m ='koltuk harf'.
gs_fcat-scrtext_l ='koltuk harf'.
gs_fcat-edit = abap_true.
gs_fcat-drdn_hndl = 2.           "seçenek sunmak için
append gs_fcat to gt_fcat.




CLEAR: gs_fcat.
gs_fcat-fieldname ='seatp'.
gs_fcat-scrtext_s ='koltuk sırası'.
gs_fcat-scrtext_m ='koltuk sırası'.
gs_fcat-scrtext_l ='koltuk sırası'.
gs_fcat-edit = abap_true.
gs_fcat-drdn_field = 'DD_HANDLE'.           "dinamik yapmak için drdn_field verdik
append gs_fcat to gt_fcat.


*  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
*   EXPORTING
*     I_STRUCTURE_NAME             = 'SCARR'
**      I_STRUCTURE_NAME             = 'ZMDIK_OOALV_S'
**     I_INTERNAL_TABNAME           =
*    CHANGING
*      ct_fieldcat                  = gt_fcat
*   EXCEPTIONS
*     INCONSISTENT_INTERFACE       = 1
*     PROGRAM_ERROR                = 2
*     OTHERS                       = 3
*            .
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .
*clear: gs_layout.
**gs_layout-cwidth_opt = abap_true.         "layoutta yaptığımız değişiklikler tüm alv nin tüm kolonlarını etkiler.
**gs_layout-edit = abap_true.
**gs_layout-no_toolbar = abap_true.     " bu alv de ki toolbarı kaldırır.
*gs_layout-zebra = abap_true.
*gs_layout-info_fname = 'line_color'.
*gs_layout-ctab_fname = 'cell_color'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_total_sum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_total_sum .
data: lv_total_sum type int4,
      lv_total_sum_c type char10,
      lv_lines type int4,
      lv_avarage type int4.


LOOP AT gt_scarr into gs_scarr .
      lv_total_sum = lv_total_sum + gs_scarr-cost.
ENDLOOP.

DESCRIBE TABLE gt_scarr LINES lv_lines.

lv_avarage = lv_total_sum / lv_lines.


LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
  IF <gfs_scarr>-cost > lv_avarage.
    <gfs_scarr>-durum = '@08@'.


    ELSEIF <gfs_scarr>-cost < lv_avarage.
      <gfs_scarr>-durum = '@0A@'.

      else.
        <gfs_scarr>-durum = '@09@'.
  ENDIF.

ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_drop_down
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_drop_down .
data: lt_dropdown type lvc_t_drop,
      ls_dropdown type  lvc_s_drop.

      clear: ls_dropdown.
      ls_dropdown-handle = 1.                "fieldcatalog kısmında verdiğimiz id ile aynı id yi kullanıp seçenek sunması için yapıyoruz.
      ls_dropdown-value = 'Yurtiçi'.
      APPEND ls_dropdown to lt_dropdown.

        clear: ls_dropdown.
      ls_dropdown-handle = 1.
      ls_dropdown-value = 'Yurtidışı'.
      APPEND ls_dropdown to lt_dropdown.



       clear: ls_dropdown.
      ls_dropdown-handle = 2.
      ls_dropdown-value = 'A'.
      APPEND ls_dropdown to lt_dropdown.

        clear: ls_dropdown.
      ls_dropdown-handle = 2.
      ls_dropdown-value = 'B'.
      APPEND ls_dropdown to lt_dropdown.


       clear: ls_dropdown.
      ls_dropdown-handle = 2.
      ls_dropdown-value = 'C'.
      APPEND ls_dropdown to lt_dropdown.

        clear: ls_dropdown.
      ls_dropdown-handle = 2.
      ls_dropdown-value = 'D'.
      APPEND ls_dropdown to lt_dropdown.

       clear: ls_dropdown.
      ls_dropdown-handle = 2.
      ls_dropdown-value = 'E'.
      APPEND ls_dropdown to lt_dropdown.


        clear: ls_dropdown.
      ls_dropdown-handle = 3.
      ls_dropdown-value = 'ön'.
      APPEND ls_dropdown to lt_dropdown.



        clear: ls_dropdown.
      ls_dropdown-handle = 3.
      ls_dropdown-value = 'kanat'.
      APPEND ls_dropdown to lt_dropdown.



        clear: ls_dropdown.
      ls_dropdown-handle = 3.
      ls_dropdown-value = 'arka'.
      APPEND ls_dropdown to lt_dropdown.


        clear: ls_dropdown.
      ls_dropdown-handle = 4.
      ls_dropdown-value = 'ön'.
      APPEND ls_dropdown to lt_dropdown.

        clear: ls_dropdown.
      ls_dropdown-handle = 4.
      ls_dropdown-value = 'arka'.
      APPEND ls_dropdown to lt_dropdown.


        clear: ls_dropdown.
      ls_dropdown-handle = 5.
      ls_dropdown-value = 'kanat'.
      APPEND ls_dropdown to lt_dropdown.


      go_alv->set_drop_down_table(
        EXPORTING
          it_drop_down       = lt_dropdown

      ).

ENDFORM.
