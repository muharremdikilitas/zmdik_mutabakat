*&---------------------------------------------------------------------*
*& Include          ZMDIK_P83_002
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
      on_added_function for event added_function of cl_salv_events_table
        importing e_salv_function,
      load_from_excel,
      save_to_db.

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
        mo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).
      catch cx_salv_msg.
    endtry.
    mo_columns = mo_alv->get_columns( ).
    mo_columns->set_optimize( abap_true ).

    try.
        data(lo_col) = mo_columns->get_column( 'MANDT' ).
        lo_col->set_technical( abap_true ).
      catch cx_salv_not_found.
    endtry.


    "variant
    data: gr_layout type ref to cl_salv_layout,
          gs_key    type salv_s_layout_key.

    gr_layout = mo_alv->get_layout( ).
    gs_key-report = sy-repid.
    gr_layout->set_key( gs_key ).
    gr_layout->set_default( abap_true ).
    gr_layout->set_initial_layout( space ).
    gr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
  endmethod.

  method prepare_alv.
    me->select_data( ).
    me->create_alv( ).
    me->set_pf_status( ).
    me->set_alv_properties( ).
    me->display_alv( ).
  endmethod.

  method display_alv.
    mo_alv->display( ).
  endmethod.

  method set_pf_status.
    mo_alv->set_screen_status(
      pfstatus      = '0100'
      report        = sy-repid
      set_functions = mo_alv->c_functions_all ).
    mo_events = mo_alv->get_event( ).
    set handler me->on_added_function for mo_events.


  endmethod.


  method on_added_function.
    case e_salv_function.
      when '&UPLOAD'.
        me->load_from_excel( ).

      when '&SAVE'.
        me->save_to_db( ).

      when others.
        " diğer fonksiyonlar
    endcase.
  endmethod.

METHOD load_from_excel.
  DATA: p_file      TYPE rlgrap-filename,
        gt_intern   TYPE STANDARD TABLE OF alsmex_tabline WITH DEFAULT KEY,
        gs_intern   TYPE alsmex_tabline,
        gs_row      TYPE gty_itab,
        lv_curr_row TYPE i,
        lv_startrow TYPE i VALUE 1,    " Başlık yoksa 1 yapın
         lv_val      TYPE string.
  " 1) Dosya seçimi
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.
  IF p_file IS INITIAL.
    MESSAGE 'Dosya seçilmedi.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 2) Excel'i OLE ile oku (.XLS + Windows GUI)
  CLEAR gt_intern.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename    = p_file
      i_begin_col = 1
      i_begin_row = lv_startrow
      i_end_col   = 16         " A..P (16 sütun)
      i_end_row   = 99999
    TABLES
      intern      = gt_intern
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc <> 0 OR gt_intern IS INITIAL.
    MESSAGE 'Excel okunamadı veya veri yok.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 3) Satır/sütunlara göre dağıt (tarih/saat kolonları atlanır)
  SORT gt_intern BY row col.

  CLEAR gt_itab.
  CLEAR gs_row.
  lv_curr_row = 0.

  LOOP AT gt_intern INTO gs_intern.

    " Yeni satıra geçildiğinde, önce bir önceki satırı ekleyelim
    IF lv_curr_row <> gs_intern-row.
      IF lv_curr_row > 0.
        APPEND gs_row TO gt_itab.
      ENDIF.
      CLEAR gs_row.
      lv_curr_row = gs_intern-row.
    ENDIF.

   lv_val = gs_intern-value.

    CASE gs_intern-col.
      WHEN 1.  gs_row-gv_parnr = lv_val.
      WHEN 2.  gs_row-gv_bukrs = lv_val.
      WHEN 3.  gs_row-gv_koart = lv_val.
      WHEN 4.  gs_row-gv_accno = lv_val.
      WHEN 5.  gs_row-gv_ptype = lv_val.
      WHEN 6.  gs_row-gv_loekz = lv_val.
      WHEN 7.  gs_row-gv_ename = lv_val.
      WHEN 8.  gs_row-gv_email = lv_val.
      WHEN 9.  gs_row-gv_telf  = lv_val.
      WHEN 10. gs_row-gv_tckid    = lv_val.

      WHEN 12. gs_row-gv_ernam    = lv_val.
.
      WHEN 14. gs_row-gv_aenam    = lv_val.

    ENDCASE.

  ENDLOOP.

  " Son satırı ekle
  IF lv_curr_row > 0.
    APPEND gs_row TO gt_itab.
  ENDIF.
  CLEAR gt_data.
DATA: ls_i TYPE gty_itab,
      ls_d TYPE zmdik_erec.

LOOP AT gt_itab INTO ls_i.
  CLEAR ls_d.

  ls_d-parnr = ls_i-gv_parnr.
  ls_d-bukrs = ls_i-gv_bukrs.
  ls_d-koart = ls_i-gv_koart.
  ls_d-accno = ls_i-gv_accno.
  ls_d-ptype = ls_i-gv_ptype.
  ls_d-loekz = ls_i-gv_loekz.
  ls_d-ename = ls_i-gv_ename.
  ls_d-email = ls_i-gv_email.
  ls_d-telf1 = ls_i-gv_telf.
  ls_d-tckid = ls_i-gv_tckid.

  ls_d-ernam = ls_i-gv_ernam.
  ls_d-aenam = ls_i-gv_aenam.



  APPEND ls_d TO gt_data.
ENDLOOP.

" ALV’yi yenile
TRY.
    mo_alv->refresh( ).
  CATCH cx_salv_msg.
    " Bazı sürümlerde refresh yoksa yeniden kur-göster
    me->create_alv( ).
    me->set_alv_properties( ).
    me->display_alv( ).
ENDTRY.
ENDMETHOD.

  method save_to_db.
    " Ekrandaki olası değişiklikleri oku (SALV grid değil ama yine de emniyet)
    try.
        mo_alv->get_functions( ). " çağrı gerekli değilse çıkarılabilir
      catch cx_salv_msg.
    endtry.

    if gt_data is initial.
      message 'Kaydedilecek veri yok.' type 'S' display like 'E'.
      return.
    endif.

    " Basit örnek: önce varları sil, sonra toplu insert
    " İHTİYACA GÖRE: key alanına göre MODIFY/UPDATE tercih edebilirsin

    " Örnek: toplu insert
    insert zmdik_erec from table @gt_data.
    if sy-subrc = 0.
      commit work and wait.
      message |{ sy-dbcnt } satır kaydedildi.| type 'S'.
    else.
      rollback work.
      message 'Kaydetme sırasında hata oluştu.' type 'S' display like 'E'.
    endif.
  endmethod.




endclass.
