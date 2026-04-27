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
        importing e_salv_function,
      f4_muhatap
        importing
          iv_ptype   type c
          iv_bukrs   type bukrs
        changing
          cv_muhatap type zmdik_erec-accno,
      on_link_click for event link_click of cl_salv_events_table
        importing row column.
endclass.

class lcl_report implementation.

  method select_data.
    clear: gt_data, gt_disp.
    select * from zmdik_erec into table gt_data.

    " ZMDIK_EREC yapısını alıp LOEKZ alanını CHAR4 yap (ikon için)
    data(lo_src) = cast cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( 'ZMDIK_EREC' ) ).
    data lt_comp type cl_abap_structdescr=>component_table.
    lt_comp = lo_src->get_components( ).

    loop at lt_comp assigning field-symbol(<c>).
      if <c>-name = 'LOEKZ'.
        <c>-type = cl_abap_elemdescr=>get_c( 4 ).   " CHAR4 = ICON_D
        exit.
      endif.
    endloop.

    data lo_new type ref to cl_abap_structdescr.
    lo_new = cl_abap_structdescr=>create( lt_comp ).

    data lo_tab type ref to cl_abap_tabledescr.
    lo_tab = cl_abap_tabledescr=>create( p_line_type = lo_new ).

    create data gr_disp type handle lo_tab.
    assign gr_disp->* to <gt_disp>.
    clear <gt_disp>.

    " Ekran tablosunu doldur: LOEKZ='X' ise ikon koy
    loop at gt_data into data(ls_src).
      append initial line to <gt_disp> assigning <gs_disp>.
      move-corresponding ls_src to <gs_disp>.

      assign component 'LOEKZ' of structure <gs_disp> to <loekz>.
      if sy-subrc = 0.
        if ls_src-loekz = 'X'.
          <loekz> = icon_delete.
        else.
          clear <loekz>.
        endif.
      endif.
    endloop.
  endmethod.

  method create_alv.
    try.
        cl_salv_table=>factory(
          importing r_salv_table = mo_alv
          changing  t_table      = <gt_disp>  ).
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

        data  lo_disp   type ref to cl_salv_column_table.
        lo_disp ?= mo_columns->get_column( 'LOEKZ' ).
        lo_disp->set_icon( abap_true ).
        lo_disp->set_cell_type( if_salv_c_cell_type=>hotspot ). " ikona tıklanacak
        lo_disp->set_short_text(  'Sil' ).
        lo_disp->set_medium_text( 'Silme Göstergesi' ).
        lo_disp->set_long_text(   'Silme Göstergesi' ).

      catch cx_salv_not_found.
    endtry.

    try.
        data(lo) = mo_columns->get_column( 'MANDT' ).
        lo->set_technical( abap_true ).
      catch cx_salv_not_found.
    endtry.

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
    set handler me->on_link_click     for mo_events.
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
            message 'Seçim okunamadı' type 'S' display like 'E'.
            return.
        endtry.

        if lt_rows is initial.
          message 'Lütfen en az bir satır seçin' type 'S' display like 'E'.
          return.
        endif.

        read table lt_rows index 1 into lv_idx.
        if sy-subrc = 0.
          read table gt_data index lv_idx into gs_data.
        endif.

        if gs_data is initial.
          message 'Seçilen satır ana tabloda bulunamadı' type 'S' display like 'E'.
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
        clear gs_data.

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
            message 'Seçim okunamadı' type 'S' display like 'E'.
            return.
        endtry.

        if lt_rows is initial.
          message 'Lütfen en az bir satır seçin' type 'S' display like 'E'.
          return.
        endif.

        " Başlık için
        read table lt_rows index 1 into lv_idx.
        if sy-subrc = 0 and lv_idx between 1 and lines( gt_data ).
          lv_parnr = gt_data[ lv_idx ]-parnr.
        endif.

        call function 'POPUP_TO_CONFIRM'
          exporting
            titlebar       = 'Silme Göstergesi'
            text_question  = |{ lv_parnr } numaralı kayıt(lar) için silme işlemi yapılsın mı?|
            text_button_1  = 'Evet'
            text_button_2  = 'Hayır'
            default_button = '2'
          importing
            answer         = lv_ans.
        if lv_ans <> '1'.
          return.
        endif.

        " PARNR listesini GT_DATA'dan oluştur
        loop at lt_rows into lv_idx.
          if lv_idx between 1 and lines( gt_data ).
            append gt_data[ lv_idx ]-parnr to lt_keys.
          endif.
        endloop.

        if go_srv is initial.
          create object go_srv.
        endif.

        data(lv_aff) = go_srv->soft_delete( it_parnr = lt_keys ).

        if lv_aff > 0.
          loop at lt_rows into lv_idx.
            read table gt_data index lv_idx into data(ls_db).
            if sy-subrc = 0.
              ls_db-loekz = 'X'.
              modify gt_data from ls_db index lv_idx.
            endif.

            read table <gt_disp> assigning <gs_disp> index lv_idx.
            if sy-subrc = 0.
              assign component 'LOEKZ' of structure <gs_disp> to <loekz>.
              if sy-subrc = 0.
                <loekz> = icon_delete.
              endif.
            endif.
          endloop.
        endif.

        if me->mo_alv is bound.
          me->mo_alv->refresh( ).
          cl_gui_cfw=>flush( ).
        endif.

    endcase.
  endmethod.

  method f4_muhatap.
    data: lt_ret       type standard table of ddshretval with default key,
          ls_ret       type ddshretval,
          lv_val       type zmdik_erec-accno,
          lt_dynp      type standard table of dynpread with default key,
          ls_dynp      type dynpread,
          lv_ptype_loc type c.

    clear: lt_ret, lv_val.

    lv_ptype_loc = iv_ptype.
    translate lv_ptype_loc to upper case.
    if lv_ptype_loc is initial.
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
      if sy-subrc = 0.
        read table lt_dynp into ls_dynp with key fieldname = 'GS_EREC-KOART'.
        if sy-subrc = 0 and ls_dynp-fieldvalue is not initial.
          lv_ptype_loc = ls_dynp-fieldvalue.
          translate lv_ptype_loc to upper case.
        endif.
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
        cv_muhatap    = lv_val.
        gs_erec-accno = lv_val.
      endif.
    endif.
  endmethod.

  method on_link_click.
    if column <> 'LOEKZ'.
      return.
    endif.
    data: lv_idx   type i,
          ls_db    type zmdik_erec,
          lv_parnr type zmdik_erec-parnr,
          lv_ans   type c.

    lv_idx = row.

    read table <gt_disp> assigning <gs_disp> index lv_idx.
    if sy-subrc <> 0.
      return.
    endif.

    assign component 'LOEKZ' of structure <gs_disp> to <loekz>.
    if sy-subrc <> 0 or <loekz> is initial.
      return.
    endif.

    call function 'POPUP_TO_CONFIRM'
      exporting
        titlebar       = 'Silme İşlemini Geri Al'
        text_question  = |{ gt_data[ lv_idx ]-parnr } numaralı kayıt geri alınsın mı?|
        text_button_1  = 'Evet'
        text_button_2  = 'Hayır'
        default_button = '2'
      importing
        answer         = lv_ans.
    if lv_ans <> '1'.
      return.
    endif.

    read table gt_data index lv_idx into ls_db.
    if sy-subrc <> 0.
      return.
    endif.

    lv_parnr = ls_db-parnr.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = lv_parnr
      importing
        output = lv_parnr.

    update zmdik_erec
       set loekz = @space
     where parnr = @lv_parnr.
    " Ekranı ve iç tabloları senkronize et
    ls_db-loekz = space.
    modify gt_data from ls_db index lv_idx.

    clear <loekz>.

    if me->mo_alv is bound.
      me->mo_alv->refresh( ).
    endif.
  endmethod.
endclass.
