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
      on_added_function for event added_function of cl_salv_events_table
        importing e_salv_function.
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
      when '&UPDATE'.
        g_screen_mode = 'U'.  " Güncelleme modu
        data lt_rows type salv_t_row.
        data lv_idx  type salv_de_row.

        try.
            lt_rows = mo_alv->get_selections( )->get_selected_rows( ).
          catch cx_salv_msg.
            message 'Seçim okunamadı' type 'S' display like 'E'.
            return.
        endtry.

        if lt_rows is initial.
          message 'Lütfen en az bir satır seçin' type 'S' display like 'E'.
          return.
        endif.

        clear: gt_one, gt_sel_map.

        loop at lt_rows into lv_idx.
          data(ls_sel) = value zmdik_erec( ).
          read table gt_data index lv_idx into ls_sel.
          if sy-subrc = 0.
            append ls_sel to gt_one.     "Popup’ta gösterilecek satır
            append lv_idx to gt_sel_map. "Aynı sırada ana tablo indexini tut
          endif.
        endloop.

        if gt_one is initial.
          message 'Seçilen satırlar ana tabloda bulunamadı' type 'S' display like 'E'.
          return.
        endif.

        call screen 0100 starting at 2 3 ending at 160 25.
        if me->mo_alv is bound.
          me->mo_alv->refresh( ).
        endif.

      when '&ZCREATE'.

        g_screen_mode = 'C'.  " Yaratma modu
        clear gt_one.
        append initial line to gt_one.
        call screen 0100 starting at 2 3 ending at 160 25.
      when others.
    endcase.
  endmethod.
endclass.
