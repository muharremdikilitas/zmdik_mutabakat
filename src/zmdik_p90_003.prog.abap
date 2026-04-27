*&---------------------------------------------------------------------*
*& Include          ZMDIK_P90_003
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
          cv_muhatap type zgty_str-accno,
      load_from_excel
        importing
                  iv_filename type rlgrap-filename
        exporting ev_ok       type abap_bool,
      upsert_into_gty_data
        importing it_new type tt_erec,

      normalize_row
        changing cs_row type ty_erec,

      build_match_key
        importing is_row        type ty_erec
        returning value(rv_key) type string,
      save_all_to_db,
      on_link_click
        for event link_click of cl_salv_events_table
        importing row column,
      download_template,
      write_cell
        importing
          io_sheet type ole2_object
          iv_row   type i
          iv_col   type i
          iv_value type string.

endclass.

class lcl_report implementation.

  method select_data.
    clear gty_data.
    select parnr, bukrs, koart, accno, ptype, loekz,
           ename, email, telf1, tckid,
           erdat, ernam, erzet, aenam, aedat, aezet
      from zmdik_erec
      into corresponding fields of table @gty_data.
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
    try.
        mo_selection = mo_alv->get_selections( ).
        mo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).
      catch cx_salv_msg.
    endtry.
    mo_columns = mo_alv->get_columns( ).
    mo_columns->set_optimize( abap_true ).

    try.
        mo_column ?= mo_columns->get_column( 'ICON' ).
        mo_column->set_short_text(  'Durum' ).
        mo_column->set_medium_text( 'Durum' ).
        mo_column->set_long_text(   'Yükleme Durumu' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      catch cx_salv_not_found.
    endtry.

    try.
        mo_column ?= mo_columns->get_column( 'LOEKZ' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
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
    data(lv_ok) = abap_true.

    me->load_from_excel(
      exporting
        iv_filename = p_file
      importing
        ev_ok       = lv_ok ).

    me->create_alv( ).
    me->set_pf_status( ).
    me->set_alv_properties( ).



    if lv_ok = abap_false.
      return.
    else.

      me->display_alv( ).
    endif.
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
            message 'Seçim okunamadı' type 'S' display like 'E'.
            return.
        endtry.

        if lt_rows is initial.
          message 'Lütfen en az bir satır seçin' type 'S' display like 'E'.
          return.
        endif.

        read table lt_rows index 1 into lv_idx.
        if sy-subrc = 0.
          read table gty_data index lv_idx into gsy_data.
        endif.

        if gsy_data is initial.
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
            message 'Seçim okunamadı' type 'S' display like 'E'.
            return.
        endtry.

        if lt_rows is initial.
          message 'Lütfen en az bir satır seçin' type 'S' display like 'E'.
          return.
        endif.

        " Başlık için
        read table lt_rows index 1 into lv_idx.
        if sy-subrc = 0 and lv_idx between 1 and lines( gty_data ).
          lv_parnr = gty_data[ lv_idx ]-parnr.
        endif.

        call function 'POPUP_TO_CONFIRM'
          exporting
            titlebar       = 'Silme Göstergesi'
            text_question  = |{ lv_parnr } numaralı kayıt için silme işlemi yapılsın mı?|
            text_button_1  = 'Evet'
            text_button_2  = 'Hayır'
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
      when '&UPLOAD'.
*        me->load_from_excel( ).

      when '&SAVE'.
        me->save_all_to_db( ).
      when others.
    endcase.
  endmethod.

  method f4_muhatap.
    data: lt_ret       type standard table of ddshretval with default key,
          ls_ret       type ddshretval,
          lv_val       type zgty_str-accno,
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

  method load_from_excel.
    ev_ok = abap_true.
    data: p_file      type rlgrap-filename,
          gt_intern   type standard table of alsmex_tabline,
          gs_intern   type alsmex_tabline,
          lv_startrow type i value 1,
          lv_curr_row type i,
          lv_val      type string.

    data: gs_row  type gty_itab,
          gt_itab type standard table of gty_itab with empty key.

    data: lt_new type standard table of zgty_str with empty key,
          ls_i   type gty_itab,
          ls_d   type zgty_str.

    data: lv_char_temp type string.

    field-symbols: <ls_old>   type zgty_str,
                   <ls_match> type zgty_str.

    data(lv_file) = iv_filename.
    if lv_file is initial.
      message 'Dosya yolu tanımlı değil.' type 'S' display like 'E'.
      ev_ok = abap_false.
      return.
    endif.
    "  Excel oku
    clear gt_intern.
    call function 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      exporting
        filename    = lv_file
        i_begin_col = 1
        i_begin_row = lv_startrow
        i_end_col   = 16
        i_end_row   = 99999
      tables
        intern      = gt_intern
      exceptions
        others      = 1.
    if sy-subrc <> 0 or gt_intern is initial.
      message 'Excel okunamadı veya veri yok.' type 'S' display like 'E'.
      return.
    endif.


    data: lt_expected_header type standard table of string with empty key,
          lt_actual_header   type standard table of string with empty key,
          lv_msg             type string,
          lv_index           type i,
          lv_exp             type string.

    lt_expected_header = value string_table(
     ( `Şirket Kodu` )
     ( `Hesap Türü` )
     ( `Muhatap` )
     ( `İlgili Kişi İşlevi` )
     ( `Silme Göstergesi` )
     ( `Mutabakat Sorumlusu Adı Soyadı` )
     ( `E-posta adresi` )
     ( `Telefon numarası` )
     ( `TC Kimlik No` )
 ).

    clear lt_actual_header.

    loop at gt_intern into gs_intern where row = lv_startrow.
      append gs_intern-value to lt_actual_header.
    endloop.


    if lines( lt_actual_header ) <> lines( lt_expected_header ).
      message 'Excel başlık sayısı hatalı!' type 'S' display like 'E'.
      return.
    endif.

    lv_index = 1.


    loop at lt_actual_header into data(lv_act).
      read table lt_expected_header index lv_index into lv_exp.

      if lv_act <> lv_exp.
        lv_msg = | Şablon Hatalı! { lv_index }. sütundaki başlık. Beklenen: { lv_exp }, Gelen: { lv_act }|.
        message lv_msg type 'S' display like 'E'.
        ev_ok = abap_false.
        return.
      endif.

      lv_index = lv_index + 1.
    endloop.

    sort gt_intern by row col.
    clear gt_itab.  clear gs_row.  lv_curr_row = 0.

    loop at gt_intern into gs_intern where row > lv_startrow.
      if lv_curr_row <> gs_intern-row.
        if lv_curr_row > 0.
          append gs_row to gt_itab.
        endif.
        clear gs_row.
        lv_curr_row = gs_intern-row.
      endif.

      lv_val = gs_intern-value.
      case gs_intern-col.
        when 1.  gs_row-gv_bukrs = lv_val.
        when 2.  gs_row-gv_koart = lv_val.
        when 3.  gs_row-gv_accno = lv_val.
        when 4.  gs_row-gv_ptype = lv_val.
        when 5.  gs_row-gv_loekz = lv_val.
        when 6.  gs_row-gv_ename = lv_val.
        when 7.  gs_row-gv_email = lv_val.
        when 8.  gs_row-gv_telf  = lv_val.
        when 9. gs_row-gv_tckid  = lv_val.

      endcase.
    endloop.
    if lv_curr_row > 0.
      append gs_row to gt_itab.
    endif.

    "  itabı zmdik_erec tablosuna aktarıyoruz.
    clear lt_new.
    loop at gt_itab into ls_i.
      clear ls_d.
      ls_d-bukrs = ls_i-gv_bukrs.
      ls_d-koart = ls_i-gv_koart.
      ls_d-accno = ls_i-gv_accno.
      ls_d-ptype = ls_i-gv_ptype.
      ls_d-loekz = ls_i-gv_loekz.
      ls_d-ename = ls_i-gv_ename.
      ls_d-email = ls_i-gv_email.
      ls_d-telf1 = ls_i-gv_telf.
      ls_d-tckid = ls_i-gv_tckid.

      append ls_d to lt_new.
    endloop.

    "  Mevcut veri anahtar normalize
    me->upsert_into_gty_data( it_new = lt_new ).

    field-symbols <ls> type ty_erec.
    data: ls_srv     type zgty_str,
          lv_errflds type string,
          lv_errmsg  type string,
          ls_err     type ty_errinfo.

    clear gt_errmap.

    loop at gty_data assigning <ls>.
      clear: ls_srv, lv_errflds, lv_errmsg, ls_err.

      move-corresponding <ls> to ls_srv.

      if go_srv is initial.
        create object go_srv.
      endif.

      if go_srv->validate_for_alv_row(
            exporting is_data     = ls_srv
            importing ev_errflds  = lv_errflds
                      ev_errmsg   = lv_errmsg ) = abap_false.

        <ls>-icon = '@0A@'.

        ls_err-key     = me->build_match_key( is_row = <ls> ).
        ls_err-errmsg  = lv_errmsg.
        ls_err-errflds = lv_errflds.
        insert ls_err into table gt_errmap.

      else.
        data(ls_k) = value ty_errinfo( key = me->build_match_key( is_row = <ls> ) ).
        delete table gt_errmap from ls_k.
      endif.
    endloop.

***    try.
***        mo_alv->refresh( ).
***      catch cx_salv_msg.
***        me->create_alv( ).
***        me->set_pf_status( ).
***        me->set_alv_properties( ).
***        mo_alv->display( ).
***    endtry.
  endmethod.

  method normalize_row.
    data: lv_temp type string.

    lv_temp = cs_row-parnr.
    replace all occurrences of regex '[[:cntrl:]]|[[:space:]]+' in lv_temp with ''.
    translate lv_temp to upper case.
    cs_row-parnr = lv_temp.

    lv_temp = cs_row-bukrs.
    replace all occurrences of regex '[[:cntrl:]]|[[:space:]]+' in lv_temp with ''.
    translate lv_temp to upper case.
    cs_row-bukrs = lv_temp.

    lv_temp = cs_row-koart.
    replace all occurrences of regex '[[:cntrl:]]|[[:space:]]+' in lv_temp with ''.
    translate lv_temp to upper case.
    cs_row-koart = lv_temp.

    lv_temp = cs_row-accno.
    replace all occurrences of regex '[[:cntrl:]]|[[:space:]]+' in lv_temp with ''.
    translate lv_temp to upper case.
    cs_row-accno = lv_temp.

    lv_temp = cs_row-email.
    replace all occurrences of regex '[[:cntrl:]]|[[:space:]]+' in lv_temp with ''.
    translate lv_temp to lower case.
    cs_row-email = lv_temp.

    if cs_row-parnr is not initial.
      call function 'CONVERSION_EXIT_ALPHA_INPUT'
        exporting
          input  = cs_row-parnr
        importing
          output = cs_row-parnr.
    endif.

    if cs_row-accno is not initial.
      call function 'CONVERSION_EXIT_ALPHA_INPUT'
        exporting
          input  = cs_row-accno
        importing
          output = cs_row-accno.
    endif.

  endmethod.

  method build_match_key.
    rv_key = |{ is_row-bukrs }| && '|' &&
             |{ is_row-koart }| && '|' &&
             |{ is_row-accno }| && '|' &&
             |{ is_row-email }|.
  endmethod.

  method upsert_into_gty_data.
    field-symbols: <ls_old> type ty_erec.

    "  Mevcut veriyi normalize et
    loop at gty_data assigning <ls_old>.
      me->normalize_row( changing cs_row = <ls_old> ).
    endloop.

    "  Hızlı lookup için key->index haritası
    types: begin of ty_kmap,
             key type string,
             idx type sy-tabix,
           end of ty_kmap.
    data: lt_kmap type hashed table of ty_kmap with unique key key,
          ls_kmap type ty_kmap.

    loop at gty_data assigning <ls_old>.
      ls_kmap-key = me->build_match_key( is_row = <ls_old> ).
      ls_kmap-idx = sy-tabix.
      insert ls_kmap into table lt_kmap.
    endloop.
    "  Yeni gelenleri normalize edip upsert et
    data ls_new type ty_erec.
    loop at it_new into ls_new.
      me->normalize_row( changing cs_row = ls_new ).

      " Boş anahtar satırlarını at
      if  ls_new-koart is initial
         or ls_new-accno is initial or ls_new-email is initial.
        continue.
      endif.

      data(lv_key) = me->build_match_key( is_row = ls_new ).
      read table lt_kmap into ls_kmap with table key key = lv_key.
      if sy-subrc = 0.
        assign gty_data[ ls_kmap-idx ] to <ls_old>.
        if <ls_old> is assigned.
          move-corresponding ls_new to <ls_old>.
          <ls_old>-icon = '@09@'.
        endif.
      else.
        ls_new-icon = '@08@'.
        append ls_new to gty_data.
        ls_kmap-key = lv_key.
        ls_kmap-idx = lines( gty_data ).
        insert ls_kmap into table lt_kmap.
      endif.
    endloop.

    sort gty_data by parnr koart accno email.
    delete adjacent duplicates from gty_data comparing parnr koart accno email bukrs.
  endmethod.

  method save_all_to_db.
    data: lv_ans      type c,
          lt_db_valid type standard table of zmdik_erec with empty key,
          ls_db       type zmdik_erec,
          lv_skipped  type i,
          lv_total    type i,
          lv_saved    type i.

    call function 'POPUP_TO_CONFIRM'
      exporting
        titlebar       = 'Toplu Kaydet'
        text_question  = |Geçerli satırları veri tabanına kaydetmek istiyor musunuz?|
        text_button_1  = 'Evet'
        text_button_2  = 'Hayır'
        default_button = '2'
      importing
        answer         = lv_ans.
    if lv_ans <> '1'.
      return.
    endif.

    "  kırmızı ikon
    field-symbols <ls> type ty_erec.
    clear: lt_db_valid, lv_skipped, lv_total.
    loop at gty_data assigning <ls>.
      lv_total = lv_total + 1.

      if <ls>-icon = '@0A@'.
        lv_skipped = lv_skipped + 1.
        continue.
      endif.

      "sarı güncelle
      if <ls>-icon = '@09@'.

        select single * from zmdik_erec
          where  bukrs = @<ls>-bukrs
            and koart = @<ls>-koart
            and accno = @<ls>-accno
            and email = @<ls>-email
          into @data(ls_db_old).

        if sy-subrc = 0.

          data(ls_new_update) = ls_db_old.

          if <ls>-ename is not initial.
            ls_new_update-ename = <ls>-ename.
          endif.

          if <ls>-tckid is not initial.
            ls_new_update-tckid = <ls>-tckid.
          endif.

          if <ls>-telf1 is not initial.
            ls_new_update-telf1 = <ls>-telf1.
          endif.

          ls_new_update-loekz = <ls>-loekz.
          ls_new_update-aenam = sy-uname.
          ls_new_update-aedat = sy-datum.
          ls_new_update-aezet = sy-uzeit.

          modify zmdik_erec from ls_new_update.

        endif.
      endif.

      "yeşil insert
      if <ls>-icon = '@08@'.
        if <ls>-parnr is initial.
          <ls>-parnr = go_srv->get_next_parnr( ).
          <ls>-erdat = sy-datum.
          <ls>-erzet = sy-uzeit.
          <ls>-ernam = sy-uname.

        endif.

        clear ls_db.
        move-corresponding <ls> to ls_db.
        append ls_db to lt_db_valid.

      endif.

    endloop.

    sort lt_db_valid by parnr bukrs koart accno email.
    delete adjacent duplicates from lt_db_valid
      comparing parnr bukrs koart accno email.

    lv_saved = 0.
    if lt_db_valid is not initial.
      modify zmdik_erec from table lt_db_valid.
      if sy-subrc <> 0.
        message 'Toplu kayıtta hata oluştu' type 'S' display like 'E'.
        rollback work.
        return.
      endif.
      lv_saved = sy-dbcnt.
    endif.

    commit work and wait.

    message |Toplam: { lv_total }, Kaydedilen: { lv_saved }, Atlanan (hatalı): { lv_skipped }|
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
            lv_line-line = 'Bu satır için hata detayı bulunamadı.'.
            append lv_line to lt_text.
          endif.

          call function 'POPUP_WITH_TABLE_DISPLAY'
            exporting
              titletext    = 'Doğrulama Hataları'
              startpos_row = 5
              startpos_col = 10
              endpos_row   = 20
              endpos_col   = 120
            tables
              valuetab     = lt_text     " << düzeltildi
            exceptions
              others       = 1.

        else.
          call function 'POPUP_TO_DISPLAY_TEXT'
            exporting
              titel     = 'Doğrulama'
              textline1 = 'Bu satırda doğrulama hatası bulunmadı.'.
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
            titlebar       = 'Kayıt Silme'
            text_question  = |Silme İşlemi geri alınsın mı?|
            text_button_1  = 'Evet'
            text_button_2  = 'Hayır'
            default_button = '2'
          importing
            answer         = lv_ans.

        if lv_ans <> '1'.
          return.
        endif.
        update zmdik_erec set
              loekz = @space,
              aedat = @sy-datum,
              aezet = @sy-uzeit,
              aenam = @sy-uname
            where parnr = @ls_row-parnr
              and bukrs = @ls_row-bukrs
              and koart = @ls_row-koart
              and accno = @ls_row-accno
              and email = @ls_row-email.

        if sy-subrc = 0.
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

          message 'Kayıt silindi.' type 'S'.
        else.
          message 'Veritabanında kayıt bulunamadı veya silinemedi.' type 'S' display like 'E'.
        endif.
      when others.
    endcase.
  endmethod.

  method download_template.

    type-pools ole2.

    types: begin of ty_template,
             parnr type string,
             bukrs type string,
             koart type string,
             accno type string,
             ptype type string,
             loekz type string,
             ename type string,
             email type string,
             telf1 type string,
             tckid type string,
             erdat type string,
             ernam type string,
             erzet type string,
             aenam type string,
             aedat type string,
             aezet type string,
           end of ty_template.

    data: lt_template type standard table of ty_template,
          ls_template type ty_template.

    data: lv_fullpath type string,
          lv_fname    type string,
          lv_path     type string,
          lv_action   type i.

    clear ls_template.

    ls_template-bukrs = 'Şirket Kodu'.
    ls_template-koart = 'Hesap Türü'.
    ls_template-accno = 'Muhatap'.
    ls_template-ptype = 'İlgili Kişi İşlevi'.
    ls_template-loekz = 'Silme Göstergesi'.
    ls_template-ename = 'Mutabakat Sorumlusu Adı Soyadı'.
    ls_template-email = 'E-posta adresi'.
    ls_template-telf1 = 'Telefon numarası'.
    ls_template-tckid = 'TC Kimlik No'.

    append ls_template to lt_template.
    clear ls_template.

    ls_template-bukrs = '1000'.
    ls_template-koart = 'K'.
    ls_template-accno = '1000109'.
    ls_template-ptype = '5'.
    ls_template-loekz = 'X'.
    ls_template-ename = 'Enver Dönertaş'.
    ls_template-email = 'enver.donertas@mdpgroup.com'.
    ls_template-telf1 = '05555555555'.
    ls_template-tckid = '23456789101'.

    append ls_template to lt_template.

    call method cl_gui_frontend_services=>file_save_dialog
      exporting
        default_extension = 'xlsx'
        default_file_name = 'Mutabakat İlgilisi Template.xlsx'
      changing
        filename          = lv_fname
        path              = lv_path
        fullpath          = lv_fullpath
        user_action       = lv_action.

    if lv_action <> cl_gui_frontend_services=>action_ok.
      message 'İndirme işlemi iptal edildi.' type 'S' display like 'E'.
      return.
    endif.

    data lo_excel type ole2_object.
    data lo_books type ole2_object.
    data lo_book  type ole2_object.
    data lo_sheet type ole2_object.

    create object lo_excel 'EXCEL.APPLICATION'.
    if sy-subrc <> 0.
      message 'Excel açılamadı.' type 'S' display like 'E'.
      return.
    endif.

    set property of lo_excel 'Visible' = 0.

    call method of lo_excel 'Workbooks' = lo_books.
    call method of lo_books 'Add'       = lo_book.

    get property of lo_excel 'ActiveSheet' = lo_sheet.

    data lv_row type i value 1.

    loop at lt_template into ls_template.

      me->write_cell( io_sheet = lo_sheet iv_row = lv_row iv_col = 1  iv_value = ls_template-bukrs ).
      me->write_cell( io_sheet = lo_sheet iv_row = lv_row iv_col = 2  iv_value = ls_template-koart ).
      me->write_cell( io_sheet = lo_sheet iv_row = lv_row iv_col = 3  iv_value = ls_template-accno ).
      me->write_cell( io_sheet = lo_sheet iv_row = lv_row iv_col = 4  iv_value = ls_template-ptype ).
      me->write_cell( io_sheet = lo_sheet iv_row = lv_row iv_col = 5  iv_value = ls_template-loekz ).
      me->write_cell( io_sheet = lo_sheet iv_row = lv_row iv_col = 6  iv_value = ls_template-ename ).
      me->write_cell( io_sheet = lo_sheet iv_row = lv_row iv_col = 7  iv_value = ls_template-email ).
      me->write_cell( io_sheet = lo_sheet iv_row = lv_row iv_col = 8  iv_value = ls_template-telf1 ).
      me->write_cell( io_sheet = lo_sheet iv_row = lv_row iv_col = 9  iv_value = ls_template-tckid ).

      lv_row = lv_row + 1.

    endloop.

    call method of lo_book 'SaveAs'
      exporting
        #1 = lv_fullpath.

    call method of lo_book 'Close'.
    call method of lo_excel 'Quit'.

    free: lo_sheet, lo_book, lo_books, lo_excel.

    message |Şablon indirildi: { lv_fullpath }| type 'S'.

  endmethod.

  method write_cell.
    data lo_cell type ole2_object.

    call method of io_sheet 'Cells' = lo_cell
      exporting
        #1 = iv_row
        #2 = iv_col.

    set property of lo_cell 'Value' = iv_value.
  endmethod.


endclass.
