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
      upsert_into_gt_data
        importing it_new type tt_erec,

      normalize_row
        changing cs_row type ty_erec,

      build_match_key
        importing is_row        type ty_erec
        returning value(rv_key) type string,

      convert_date_to_dats
        importing iv_char_date        type any
        returning value(rv_dats_date) type dats,

      convert_time_to_tims
        importing iv_char_time        type any
        returning value(rv_tims_time) type tims.

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


      when others.
    endcase.
  endmethod.

  method load_from_excel.
    "------------------------------------------------------------
    " 0) Değişkenler
    "------------------------------------------------------------
    data: p_file      type rlgrap-filename,
          gt_intern   type standard table of alsmex_tabline,
          gs_intern   type alsmex_tabline,
          lv_startrow type i value 1,
          lv_curr_row type i,
          lv_val      type string.

    data: gs_row  type gty_itab,
          gt_itab type standard table of gty_itab with empty key.

    data: lt_new type standard table of zmdik_erec with empty key,
          ls_i   type gty_itab,
          ls_d   type zmdik_erec.

    data: lv_char_temp type string.

    field-symbols: <ls_old>   type zmdik_erec,
                   <ls_match> type zmdik_erec.

    "------------------------------------------------------------
    " 1) Dosya seçimi
    "------------------------------------------------------------
    call function 'F4_FILENAME'
      exporting
        field_name = 'P_FILE'
      importing
        file_name  = p_file.
    if p_file is initial.
      message 'Dosya seçilmedi.' type 'S' display like 'E'.  return.
    endif.

    "------------------------------------------------------------
    " 2) Excel oku
    "------------------------------------------------------------
    clear gt_intern.
    call function 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      exporting
        filename    = p_file
        i_begin_col = 1
        i_begin_row = lv_startrow
        i_end_col   = 16
        i_end_row   = 99999
      tables
        intern      = gt_intern
      exceptions
        others      = 1.
    if sy-subrc <> 0 or gt_intern is initial.
      message 'Excel okunamadı veya veri yok.' type 'S' display like 'E'.  return.
    endif.

    "------------------------------------------------------------
    " 3) Hücre -> Satır
    "------------------------------------------------------------
    sort gt_intern by row col.
    clear gt_itab.  clear gs_row.  lv_curr_row = 0.

    loop at gt_intern into gs_intern.
      if lv_curr_row <> gs_intern-row.
        if lv_curr_row > 0. append gs_row to gt_itab. endif.
        clear gs_row.  lv_curr_row = gs_intern-row.
      endif.

      lv_val = gs_intern-value.
      case gs_intern-col.
        when 1.  gs_row-gv_parnr = lv_val.
        when 2.  gs_row-gv_bukrs = lv_val.
        when 3.  gs_row-gv_koart = lv_val.
        when 4.  gs_row-gv_accno = lv_val.
        when 5.  gs_row-gv_ptype = lv_val.
        when 6.  gs_row-gv_loekz = lv_val.
        when 7.  gs_row-gv_ename = lv_val.
        when 8.  gs_row-gv_email = lv_val.
        when 9.  gs_row-gv_telf  = lv_val.
        when 10. gs_row-gv_tckid = lv_val.
        when 11. gs_row-gv_erdat = lv_val.
        when 12. gs_row-gv_ernam = lv_val.
        when 13. gs_row-gv_erzet = lv_val.
        when 14. gs_row-gv_aenam = lv_val.
        when 15. gs_row-gv_aedat = lv_val.
        when 16. gs_row-gv_aezet = lv_val.
      endcase.
    endloop.
    if lv_curr_row > 0. append gs_row to gt_itab. endif.

    "------------------------------------------------------------
    " 4) ITAB -> ZMDIK_EREC (ham liste)
    "------------------------------------------------------------
    clear lt_new.
    loop at gt_itab into ls_i.
      clear ls_d.
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

      ls_d-erdat = me->convert_date_to_dats( ls_i-gv_erdat ).
      ls_d-ernam  = ls_i-gv_ernam.
      ls_d-erzet = me->convert_time_to_tims( ls_i-gv_erzet ).
      ls_d-aenam  = ls_i-gv_aenam.
      ls_d-aedat = me->convert_date_to_dats( ls_i-gv_aedat ).
      ls_d-aezet = me->convert_time_to_tims( ls_i-gv_aezet ).
      " Kullanıcı Atamaları

      append ls_d to lt_new.
    endloop.
    .

    "------------------------------------------------------------
    " 5) Mevcut veri anahtar normalize (NBSP yok; tüm whitespace regex)
    "------------------------------------------------------------
    me->upsert_into_gt_data( it_new = lt_new ).

    "------------------------------------------------------------
    " 7) ALV refresh
    "------------------------------------------------------------
    try.
        mo_alv->refresh( ).
      catch cx_salv_msg.
        me->create_alv( ).
        me->set_pf_status( ).
        me->set_alv_properties( ).
        mo_alv->display( ).
    endtry.
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
    rv_key = |{ is_row-parnr }| && '|' &&
             |{ is_row-bukrs }| && '|' &&
             |{ is_row-koart }| && '|' &&
             |{ is_row-accno }| && '|' &&
             |{ is_row-email }|.
  endmethod.

  method upsert_into_gt_data.
    field-symbols: <ls_old> type ty_erec.

    " 1) Mevcut veriyi normalize et
    loop at gt_data assigning <ls_old>.
      me->normalize_row( changing cs_row = <ls_old> ).
    endloop.

    " 2) Hızlı lookup için key->index haritası
    types: begin of ty_kmap, key type string, idx type sy-tabix, end of ty_kmap.
    data: lt_kmap type hashed table of ty_kmap with unique key key,
          ls_kmap type ty_kmap.

    loop at gt_data assigning <ls_old>.
      ls_kmap-key = me->build_match_key( is_row = <ls_old> ).
      ls_kmap-idx = sy-tabix.
      insert ls_kmap into table lt_kmap.
    endloop.

    " 3) Yeni gelenleri normalize edip upsert et
    data ls_new type ty_erec.
    loop at it_new into ls_new.
      me->normalize_row( changing cs_row = ls_new ).

      " Boş anahtar satırlarını at
      if ls_new-parnr is initial or ls_new-koart is initial
         or ls_new-accno is initial or ls_new-email is initial.
        continue.
      endif.

      data(lv_key) = me->build_match_key( is_row = ls_new ).
      read table lt_kmap into ls_kmap with table key key = lv_key.
      if sy-subrc = 0.
        assign gt_data[ ls_kmap-idx ] to <ls_old>.
        if <ls_old> is assigned.
          move-corresponding ls_new to <ls_old>. " ⇒ GÜNCELLE
        endif.
      else.
        append ls_new to gt_data.                     " ⇒ EKLE
        ls_kmap-key = lv_key.
        ls_kmap-idx = lines( gt_data ).
        insert ls_kmap into table lt_kmap.
      endif.
    endloop.

    sort gt_data by parnr koart accno email.
    delete adjacent duplicates from gt_data comparing parnr koart accno email.
  endmethod.

  method convert_date_to_dats.
    data: lv_raw type string,
          lv_y   type i,
          lv_m   type i,
          lv_d   type i,
          lv_out type string.

    lv_raw = iv_char_date.

    replace all occurrences of ',' in lv_raw with '.'.
    replace all occurrences of regex '[[:space:]]+' in lv_raw with ''.


    if strlen( lv_raw ) = 10 and lv_raw+2(1) = '.' and lv_raw+5(1) = '.'.
      lv_d = lv_raw+0(2).
      lv_m = lv_raw+3(2).
      lv_y = lv_raw+6(4). " Tam 4 haneli yıl

      lv_out = |{ lv_y width = 4 align = right pad = '0' }{ lv_m width = 2 align = right pad = '0' }{ lv_d width = 2 align = right pad = '0' }|.
      rv_dats_date = lv_out.
      return.
    endif.

    if strlen( lv_raw ) = 8 and lv_raw+2(1) = '.' and lv_raw+5(1) = '.'.
      lv_d = lv_raw+0(2).
      lv_m = lv_raw+3(2).
      lv_y = lv_raw+6(2). " 2 haneli yıl (örn: 23)

      if lv_y >= 50.
        lv_y = 1900 + lv_y.
      else.
        lv_y = 2000 + lv_y.
      endif.

      lv_out = |{ lv_y width = 4 align = right pad = '0' }{ lv_m width = 2 align = right pad = '0' }{ lv_d width = 2 align = right pad = '0' }|.
      rv_dats_date = lv_out.
      return.
    endif.

    if strlen( lv_raw ) = 8 and lv_raw co '0123456789'.
      rv_dats_date = lv_raw.
      return.
    endif.

    rv_dats_date = space.
  endmethod.

  method convert_time_to_tims.
    data: lv_raw type string,
          lv_h   type i,
          lv_m   type i,
          lv_s   type i,
          lv_out type string.

    lv_raw = iv_char_time.

    " TR yereli: virgül -> nokta; tüm boşlukları temizle
    replace all occurrences of ',' in lv_raw with '.'.
    replace all occurrences of regex '[[:space:]]+' in lv_raw with ''.

    "  1) KRİTİK ÇÖZÜM: Excel gün kesri (0.xxx) - 00:00:00 hatasını çözer
    if lv_raw co '0123456789.'. " Nokta ve sayı içeriyor mu?

      data lv_frac    type p decimals 8.
      data lv_seconds type i.
      data lv_rem     type i.

      " lv_raw'ı sadece numerik ve ondalık nokta içerecek şekilde temizle
      replace all occurrences of regex '[^0-9\.]' in lv_raw with ''.

      if lv_raw is not initial.
        lv_frac = lv_raw.
        if lv_frac >= 0 and lv_frac < 1.
          lv_frac = lv_frac * '86400'. " Saniyeye çevir
          lv_seconds = trunc( lv_frac ).

          lv_h = lv_seconds div 3600.
          lv_rem = lv_seconds mod 3600.
          lv_m = lv_rem div 60.
          lv_s = lv_rem mod 60.

          lv_out = |{ lv_h width = 2 align = right pad = '0' }{ lv_m width = 2 align = right pad = '0' }{ lv_s width = 2 align = right pad = '0' }|.
          rv_tims_time = lv_out.
          return.
        endif.
      endif.
    endif.

    " 2) HH:MM:SS (En yaygın string formatı)
    if strlen( lv_raw ) = 8 and lv_raw+2(1) = ':' and lv_raw+5(1) = ':'.
      lv_h = lv_raw+0(2).  lv_m = lv_raw+3(2).  lv_s = lv_raw+6(2).
      lv_out = |{ lv_h width = 2 align = right pad = '0' }{ lv_m width = 2 align = right pad = '0' }{ lv_s width = 2 align = right pad = '0' }|.
      rv_tims_time = lv_out.
      return.
    endif.

    " 3) HHMMSS (6 hane - Zaten TIMS formatında)
    if strlen( lv_raw ) = 6 and lv_raw co '0123456789'.
      rv_tims_time = lv_raw.
      return.
    endif.

    " Diğer tüm formatlar (HH:MM, HHMM, HHMMSS'ten kısa olanlar) çıkarıldı.

    " 4) Anlaşılmadıysa 00:00:00
    rv_tims_time = '000000'.
  endmethod.
endclass.
