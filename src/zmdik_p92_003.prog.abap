*&---------------------------------------------------------------------*
*& Include          ZMDIK_P89_003
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
      f4_interlocutor
        importing
          iv_ptype        type c
          iv_bukrs        type bukrs
        changing
          cv_interlocutor type zgty_str-accno,
      build_match_key
        importing is_row        type ty_erec
        returning value(rv_key) type string,

      save_all_to_db,
      on_link_click
        for event link_click of cl_salv_events_table
        importing row column.

endclass.

class lcl_report implementation.

  method select_data.

    clear gty_data.

    select parnr, bukrs, koart, accno,
           ptype, loekz, ename, email, telf1, tckid,
           erdat, ernam, erzet, aenam, aedat, aezet
       from zmdik_erec
       where ( bukrs = @p_bukrs or @p_bukrs is initial )
        and    koart in @p_koart
        and    accno in @p_acno
        and  ( email = @p_email  or @p_email is initial )
        and  ( loekz in @p_loekz or loekz is initial )
        into corresponding fields of table @gty_data  .

  endmethod.

  method create_alv.
    try.
        cl_salv_table=>factory(
          importing r_salv_table = mo_alv
          changing  t_table      = gty_data ).
      catch cx_salv_msg.
        clear mo_alv.
        return.
    endtry.
  endmethod.

  method set_alv_properties.

    data: gr_layout type ref to cl_salv_layout,
          gs_key    type salv_s_layout_key.

    try.
        mo_selection = mo_alv->get_selections( ).
        mo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).
      catch cx_salv_msg.
    endtry.
    mo_columns = mo_alv->get_columns( ).
    mo_columns->set_optimize( abap_true ).

    try.
        mo_column ?= mo_columns->get_column( text-022 ).
        mo_column->set_short_text(  |{ text-023 }| ).
        mo_column->set_medium_text( |{ text-023 }| ).
        mo_column->set_long_text(   |{ text-024 }| ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      catch cx_salv_not_found.
    endtry.

    try.
        mo_column ?= mo_columns->get_column( 'LOEKZ' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      catch cx_salv_not_found.
    endtry.

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
    set handler me->on_link_click    for mo_events.
  endmethod.

  method on_added_function.

    data(lv_height) = 10.
    data(lv_width)  = 70.
    data lv_top    type i.
    data lv_left   type i.
    data lv_bottom type i.
    data lv_right  type i.

    lv_top    = ( sy-srows - lv_height ) / 2.
    lv_left   = ( sy-scols - lv_width  ) / 2.
    lv_bottom = lv_top  + lv_height.
    lv_right  = lv_left + lv_width.

    case e_salv_function.
      when '&UPDATE'.
        g_screen_mode = 'U'.

        data lt_rows type salv_t_row.
        data lv_idx  type salv_de_row.

        try.
            lt_rows = mo_alv->get_selections( )->get_selected_rows( ).
          catch cx_salv_msg.
            message text-001 type 'S' display like 'E'.
            return.
        endtry.

        if lt_rows is initial.
          message text-002 type 'S' display like 'E'.
          return.
        endif.

        read table lt_rows index 1 into lv_idx.
        if sy-subrc = 0.
          read table gty_data index lv_idx into gsy_data.
        endif.

        if gsy_data is initial.
          message text-003 type 'S' display like 'E'.
          return.
        endif.

        clear gt_sel_map.
        append lv_idx to gt_sel_map.

        call screen 0100 starting at lv_left lv_top ending at lv_right lv_bottom.

        if me->mo_alv is bound.
          me->mo_alv->refresh( ).
        endif.

      when '&ZCREATE'.
        g_screen_mode = 'C'.
        clear gsy_data.

        call screen 0100 starting at lv_left lv_top ending at lv_right lv_bottom.

        if me->mo_alv is bound.
          me->mo_alv->refresh( ).
        endif.

      when '&DELETE'.
        data: lv_ans   type c,
              lv_parnr type zmdik_erec-parnr,
              lt_keys  type ztt_parnr.

        try.
            lt_rows = mo_alv->get_selections( )->get_selected_rows( ).
          catch cx_salv_msg.
            message text-001 type 'S' display like 'E'.
            return.
        endtry.

        if lt_rows is initial.
          message text-002 type 'S' display like 'E'.
          return.
        endif.

        " Başlık için
        read table lt_rows index 1 into lv_idx.
        if sy-subrc = 0 and lv_idx between 1 and lines( gty_data ).
          lv_parnr = gty_data[ lv_idx ]-parnr.
        endif.

        call function 'POPUP_TO_CONFIRM'
          exporting
            titlebar       = text-p01
            text_question  = |{ lv_parnr } numaralı kayıt için silme işlemi yapılsın mı?|
            text_button_1  = text-p02
            text_button_2  = text-p03
            default_button = '2'
          importing
            answer         = lv_ans.
        if lv_ans <> '1'.
          return.
        endif.

        loop at lt_rows into lv_idx.
          if lv_idx between 1 and lines( gty_data ).
            append gty_data[ lv_idx ]-parnr to lt_keys.
          endif.
        endloop.

        if go_srv is initial.
          create object go_srv.
        endif.

        data(lv_aff) = go_srv->soft_delete( it_parnr = lt_keys ).

        if lv_aff > 0.
          loop at lt_rows into lv_idx.
            read table gty_data index lv_idx into data(ls_db).
            if sy-subrc = 0.
              ls_db-loekz = 'X'.
              modify gty_data from ls_db index lv_idx.
            endif.

          endloop.
        endif.

        if me->mo_alv is bound.
          me->mo_alv->refresh( ).
          cl_gui_cfw=>flush( ).
        endif.
      when others.
    endcase.
  endmethod.

  method f4_interlocutor.
    data: lt_ret       type standard table of ddshretval with default key,
          ls_ret       type ddshretval,
          lv_val       type zgty_str-accno,
          lt_dynp      type standard table of dynpread with default key,
          ls_dynp      type dynpread,
          lv_ptype_loc type c.

    clear: lt_ret, lv_val.

    lv_ptype_loc = iv_ptype.
    translate lv_ptype_loc to upper case.
    if lv_ptype_loc is initial and sy-dynnr <> '1000'.
      clear lt_dynp.
      ls_dynp-fieldname = 'GS_EREC-KOART'.
      append ls_dynp to lt_dynp.
      call function 'DYNP_VALUES_READ'
        exporting
          dyname     = sy-repid
          dynumb     = sy-dynnr
        tables
          dynpfields = lt_dynp
        exceptions
          others     = 1.

      read table lt_dynp into ls_dynp with key fieldname = 'GS_EREC-KOART'.
      if sy-subrc = 0 and ls_dynp-fieldvalue is not initial.
        lv_ptype_loc = ls_dynp-fieldvalue.
        translate lv_ptype_loc to upper case.
      endif.
    endif.

    if lv_ptype_loc = 'K'.         " Satıcı
      call function 'F4IF_FIELD_VALUE_REQUEST'
        exporting
          tabname     = 'LFA1'
          fieldname   = 'LIFNR'
          searchhelp  = 'KRED'
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = 'GS_EREC-ACCNO'
        tables
          return_tab  = lt_ret
        exceptions
          others      = 1.
    else.                           " Müşteri
      call function 'F4IF_FIELD_VALUE_REQUEST'
        exporting
          tabname     = 'KNA1'
          fieldname   = 'KUNNR'
          searchhelp  = 'DEBI'
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = 'GS_EREC-ACCNO'
        tables
          return_tab  = lt_ret
        exceptions
          others      = 1.
    endif.

    if lt_ret is not initial.
      clear lv_val.
      read table lt_ret into ls_ret with key fieldname = 'KUNNR'.
      if sy-subrc = 0 and ls_ret-fieldval is not initial.
        lv_val = ls_ret-fieldval.
      else.
        read table lt_ret into ls_ret with key fieldname = 'LIFNR'.
        if sy-subrc = 0 and ls_ret-fieldval is not initial.
          lv_val = ls_ret-fieldval.
        else.
          read table lt_ret into ls_ret index 1.
          if sy-subrc = 0 and ls_ret-fieldval is not initial.
            lv_val = ls_ret-fieldval.
          endif.
        endif.
      endif.

      if lv_val is not initial.
        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = lv_val
          importing
            output = lv_val.
        cv_interlocutor    = lv_val.
        gs_erec-accno = lv_val.
      endif.
    endif.
  endmethod.

  method build_match_key.
    rv_key = |{ is_row-parnr }| && '|' &&
             |{ is_row-bukrs }| && '|' &&
             |{ is_row-koart }| && '|' &&
             |{ is_row-accno }| && '|' &&
             |{ is_row-email }|.
  endmethod.

  method save_all_to_db.

    data: lv_saved   type i,
          lv_updated type i,
          lv_skipped type i,
          lv_total   type i.

    go_srv->save_all(
   exporting
     it_data    = gty_data
   importing
     ev_saved   = lv_saved
     ev_updated = lv_updated
     ev_skipped = lv_skipped
     ev_total   = lv_total
 ).

    message |Toplam: { lv_total }, Kaydedilen: { lv_saved }, Güncellenen: { lv_updated }, Atlanan: { lv_skipped }|
      type 'S'.

    try.
        me->select_data( ).
        if me->mo_alv is bound.
          me->mo_alv->refresh( ).
        endif.
      catch cx_salv_msg.
    endtry.
  endmethod.


  method on_link_click.

    data lv_ok  type abap_bool.
    data lv_msg type string.
    case column.
      when 'ICON'.

        data ls_row type ty_erec.
        read table gty_data index row into ls_row.
        if sy-subrc <> 0.
          return.
        endif.

        data(lv_key) = me->build_match_key( is_row = ls_row ).
        read table gt_errmap with table key key = lv_key into data(ls_err).

        if sy-subrc = 0.

          types: begin of ty_popup_line,
                   line type char255,
                 end of ty_popup_line.

          data: lt_text  type standard table of ty_popup_line with empty key,
                lv_line  type ty_popup_line,
                lt_lines type standard table of string with empty key,
                lv_str   type string.

          if ls_err-errflds is not initial.
            lv_line-line = |Hatalı alanlar: { ls_err-errflds }|.
            append lv_line to lt_text.
          endif.

          if ls_err-errmsg is not initial.
            split ls_err-errmsg at cl_abap_char_utilities=>newline into table lt_lines.
            loop at lt_lines into lv_str.
              lv_line-line = lv_str.
              append lv_line to lt_text.
            endloop.
          endif.

          if lt_text is initial.
            lv_line-line = text-007.
            append lv_line to lt_text.
          endif.

          call function 'POPUP_WITH_TABLE_DISPLAY'
            exporting
              titletext    = text-026
              startpos_row = 5
              startpos_col = 10
              endpos_row   = 20
              endpos_col   = 120
            tables
              valuetab     = lt_text
            exceptions
              others       = 1.

        else.
          call function 'POPUP_TO_DISPLAY_TEXT'
            exporting
              titel     = text-p07
              textline1 = text-p08.
        endif.
        return.
      when 'LOEKZ'.

        read table gty_data index row into ls_row.
        if sy-subrc <> 0.
          return.
        endif.

        if ls_row-loekz <> 'X'.
          return.
        endif.

        data lv_ans type c.
        call function 'POPUP_TO_CONFIRM'
          exporting
            titlebar       = text-p09
            text_question  = text-p10
            text_button_1  = text-p02
            text_button_2  = text-p03
            default_button = '2'
          importing
            answer         = lv_ans.

        if lv_ans <> '1'.
          return.
        endif.
        go_srv->reset_loekz(
          exporting
    is_row = ls_row
  importing
    ev_ok  = lv_ok
    ev_msg = lv_msg
).
        if lv_ok = abap_true.
          ls_row-loekz = space.
          ls_row-icon = ''.
          modify gty_data from ls_row index row.
          try.
              if mo_alv is bound.
                mo_alv->refresh( ).
                cl_gui_cfw=>flush( ).
              endif.
            catch cx_salv_msg.
          endtry.

          message text-008 type 'S'.
        else.
          message text-009 type 'S' display like 'E'.
        endif.
      when others.
    endcase.
  endmethod.
endclass.
