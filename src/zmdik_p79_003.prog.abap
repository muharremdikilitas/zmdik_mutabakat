*&---------------------------------------------------------------------*
*& Include          ZMDIK_P79_003
*&---------------------------------------------------------------------*

class lcl_report definition.
  public section.

    data: mo_alv       type ref to cl_salv_table,
          mo_columns   type ref to cl_salv_columns_table,
          mo_column    type ref to cl_salv_column_table,
          mo_events    type ref to cl_salv_events_table,
          mo_selection type ref to cl_salv_selections.

    methods:
      select_data,
      create_alv,
      set_alv_properties,
      prepare_alv,
      display_alv,
      set_pf_status,
      bind_events,
      on_user_command FOR EVENT added_function OF cl_salv_events_table
  IMPORTING e_salv_function,
       open_edit_popup_grid IMPORTING is_row TYPE zmdik_erec.


      PRIVATE SECTION.
    " Popup içindeki ALV ve veri
    DATA: mo_dlg  TYPE REF TO cl_gui_dialogbox_container,
          mo_grid TYPE REF TO cl_gui_alv_grid,
          mt_one  TYPE STANDARD TABLE OF zmdik_erec WITH DEFAULT KEY,
          mv_res  TYPE c LENGTH 1,
          mv_idx  TYPE i.     " <-- seçili satırın ALV index'i

    " Grid event'leri
    METHODS on_grid_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.
    METHODS on_grid_ucomm   FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
        METHODS on_dlg_close FOR EVENT close OF cl_gui_dialogbox_container.

endclass.

class lcl_report implementation.

  method select_data.
    select * from zmdik_erec into table gt_data.
  endmethod.

  method create_alv.
    try.
        cl_salv_table=>factory(
          importing r_salv_table = mo_alv
          changing  t_table      = gt_data ).
      catch cx_salv_msg.
        clear mo_alv.
        return.
    endtry.
  endmethod.

  method set_alv_properties.
    try.
        mo_selection = mo_alv->get_selections( ).
        mo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).     "hem satır hem sütun seçimi
      catch cx_salv_msg.
    endtry.
    mo_columns = mo_alv->get_columns( ).
    mo_columns->set_optimize( abap_true ).
  endmethod.

  method prepare_alv.

    me->select_data( ).
    me->create_alv( ).
    me->set_pf_status( ).
    me->set_alv_properties( ).
    me->bind_events( ).
    me->display_alv( ).

  endmethod.

  method display_alv.
    mo_alv->display( ).
  endmethod.

 METHOD set_pf_status.
  mo_alv->set_screen_status(
    pfstatus      = '0100'
    report        = sy-repid
    set_functions = mo_alv->c_functions_all ).
ENDMETHOD.


  METHOD bind_events.
  mo_events = mo_alv->get_event( ).
  SET HANDLER me->on_user_command FOR mo_events.  " <-- added_function olayı
ENDMETHOD.


METHOD on_user_command.
  IF e_salv_function <> '&UPDATE'.
    RETURN.
  ENDIF.

  DATA lt_rows TYPE salv_t_row.
  DATA lv_idx  TYPE salv_de_row.
  DATA ls_row  TYPE zmdik_erec.

  lt_rows = mo_selection->get_selected_rows( ).
  IF lt_rows IS INITIAL OR lines( lt_rows ) <> 1.
    MESSAGE 'Lütfen bir satır seçiniz.' TYPE 'I'.
    RETURN.
  ENDIF.

  READ TABLE lt_rows INDEX 1 INTO lv_idx.
  IF sy-subrc <> 0 OR lv_idx <= 0.
    MESSAGE 'Seçili satır indeksi alınamadı.' TYPE 'E'.
    RETURN.
  ENDIF.

  " *** ESAS EKSİK PARÇA: seçili satırı GT_DATA'dan oku
  READ TABLE gt_data INDEX lv_idx INTO ls_row.
  IF sy-subrc <> 0.
    MESSAGE 'Seçili satır verisi bulunamadı.' TYPE 'E'.
    RETURN.
  ENDIF.

  mv_idx = lv_idx.  " ana ALV’deki satır indeksini sakla
  me->open_edit_popup_grid( EXPORTING is_row = ls_row ).
ENDMETHOD.



METHOD open_edit_popup_grid.
  " 0) Tek satırı doldur
  CLEAR mt_one.
  APPEND is_row TO mt_one.

  " 1) Dialog (modal)
  CREATE OBJECT mo_dlg
    EXPORTING width = 1000 height = 220 top = 3 left = 5 caption = |Kaydı Düzenle|.
  mo_dlg->set_mode( 1 ).                 " modal
  SET HANDLER me->on_dlg_close FOR mo_dlg.

  " 2) Grid
  CREATE OBJECT mo_grid EXPORTING i_parent = mo_dlg.

  " 3) Event’ler
  mo_grid->set_toolbar_interactive( ).
  SET HANDLER me->on_grid_toolbar FOR mo_grid.
  SET HANDLER me->on_grid_ucomm   FOR mo_grid.

  " 4) Fieldcatalog
  DATA: lt_fcat TYPE lvc_t_fcat, ls_fcat TYPE lvc_s_fcat.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING i_structure_name = 'ZMDIK_EREC'
    CHANGING  ct_fieldcat      = lt_fcat.

  " 5) Editlenebilir kolonlar
  DATA lt_editable TYPE STANDARD TABLE OF fieldname WITH EMPTY KEY.
  APPEND 'ENAME' TO lt_editable.
  APPEND 'PTYPE' TO lt_editable.
  APPEND 'EMAIL' TO lt_editable.
  APPEND 'TELF1' TO lt_editable.
  APPEND 'TCKID' TO lt_editable.

  LOOP AT lt_fcat INTO ls_fcat.
    ls_fcat-edit = COND abap_bool( WHEN line_exists( lt_editable[ table_line = ls_fcat-fieldname ] )
                                   THEN abap_true ELSE abap_false ).
    MODIFY lt_fcat FROM ls_fcat.
  ENDLOOP.

  " 6) Layout + ilk gösterim
  DATA ls_layo TYPE lvc_s_layo.
  ls_layo-zebra      = abap_true.
  ls_layo-cwidth_opt = abap_true.

  mo_grid->set_table_for_first_display(
    EXPORTING is_layout       = ls_layo
    CHANGING  it_outtab       = mt_one
              it_fieldcatalog = lt_fcat ).

  mo_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).
  mo_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
  mo_grid->set_ready_for_input( 1 ).

  " İsteğe bağlı ama faydalı: ilk çizim
  TRY. cl_gui_cfw=>flush( ). CATCH cx_root. ENDTRY.
ENDMETHOD.







METHOD on_grid_toolbar.

   e_interactive = 'X'.
  " Basit 2 buton: Kaydet / İptal
  DATA ls_btn TYPE stb_button.

  CLEAR ls_btn.
  ls_btn-function  = 'SAVE'.
  ls_btn-icon      = icon_system_save.
  ls_btn-quickinfo = 'Kaydet'.
  ls_btn-text      = 'Kaydet'.
  ls_btn-disabled  = abap_false.
  APPEND ls_btn TO e_object->mt_toolbar.

  CLEAR ls_btn.
  ls_btn-function  = 'CANC'.
  ls_btn-icon      = icon_cancel.
  ls_btn-quickinfo = 'İptal'.
  ls_btn-text      = 'İptal'.
  ls_btn-disabled  = abap_false.
  APPEND ls_btn TO e_object->mt_toolbar.
ENDMETHOD.

METHOD on_grid_ucomm.
  CASE e_ucomm.
    WHEN 'SAVE'.
      IF mo_grid IS BOUND.
        mo_grid->check_changed_data( ).
      ENDIF.

      DATA ls_new TYPE zmdik_erec.
      READ TABLE mt_one INDEX 1 INTO ls_new.

      IF sy-subrc = 0.
        MODIFY gt_data FROM ls_new INDEX mv_idx.
      ELSE.
        DELETE gt_data INDEX mv_idx.
      ENDIF.

      TRY. mo_alv->refresh( ). CATCH cx_root. ENDTRY.

      IF mo_grid IS BOUND. FREE mo_grid. ENDIF.
      IF mo_dlg  IS BOUND. FREE mo_dlg.  ENDIF.

    WHEN 'CANC'.
      IF mo_grid IS BOUND. FREE mo_grid. ENDIF.
      IF mo_dlg  IS BOUND. FREE mo_dlg.  ENDIF.
  ENDCASE.
ENDMETHOD.

METHOD on_dlg_close.
  IF mo_grid IS BOUND. FREE mo_grid. ENDIF.
  IF mo_dlg  IS BOUND. FREE mo_dlg.  ENDIF.
ENDMETHOD.










endclass.
