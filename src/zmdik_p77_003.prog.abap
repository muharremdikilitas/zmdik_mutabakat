*&---------------------------------------------------------------------*
*& Include          ZMDIK_P77_I003
*&---------------------------------------------------------------------*

class lcl_report definition final.
  public section.
    data: mo_alv       type ref to cl_salv_table,
          mo_columns   type ref to cl_salv_columns_table,
          mo_column    type ref to cl_salv_column_table,
          mo_events    type ref to cl_salv_events_table,
          mo_selection type ref to cl_salv_selections.
    methods: run,
      prepare_alv,
      select_data,
      set_alv_properties,
      create_alv,
      mark_gaps_for_row
        changing cs_row type ty_out,
      show_segment_popup
        importing
          is_row     type ty_out
          iv_start_h type i
          iv_start_m type i,
      on_double_click for event double_click of cl_salv_events_table
        importing row column,
      on_link_click   for event link_click   of cl_salv_events_table
        importing row column,
      idx_to_c5
        importing iv_idx type i
        exporting ev_c5  type c ,
      on_close for event close of cl_gui_dialogbox_container importing sender.

  private section.
    "canstans ile tanımlıyorum ve birdaha değiştirilmiyor
    constants: c_time1  type fieldname value 'B_PRTIM',    " 1. saat alanı
               c_time2  type fieldname value 'E_PRTIM',   " 2. saat alanı (varsa)
               c_amount type fieldname value 'AMOUNT'.   " tutar alanı
    data: mo_seg_cont type ref to cl_gui_dialogbox_container,
          mo_seg_grid type ref to cl_gui_alv_grid.
endclass.

class lcl_report implementation.

  method run.
    select_data( ).

    if gt_out is initial.
      message 'Seçim kriterlerine uyan kayıt bulunamadı.' type 'S' display like 'E'.
      return.
    endif.

    loop at gt_out assigning field-symbol(<s_row>).
      me->mark_gaps_for_row( changing cs_row = <s_row> ).
    endloop.

    create_alv( ).
    set_alv_properties( ).
    mo_alv->display( ).

  endmethod.

  method select_data.
    select distinct bankc,
           bukrs,
           bankn,
           refbk,
           prdat
      from zeho_t600
      into corresponding fields of table @gt_out
      where bukrs in @s_bukrs and
         prdat in @s_prdat and
         bankc in @s_bankc and
         bankn in @s_bankn and
         refbk in @s_refbk .
  endmethod.

  method prepare_alv.
    clear gt_out.
    loop at gt_table assigning field-symbol(<s>).           "gt_table nin satırlarını alıyoruz
      clear gs_out.
      move-corresponding <s> to gs_out.                     "bunları çekip gs_out a atıp append ediyoruz gt_out a
      append gs_out to gt_out.
    endloop.
  endmethod.

  method create_alv.
    try.
        cl_salv_table=>factory(
          importing r_salv_table = mo_alv
          changing  t_table      = gt_out ).
      catch cx_salv_msg.
        clear mo_alv.
        return.
    endtry.
    if mo_alv is not bound.
      return.
    endif.
    try.
        mo_alv->get_functions( )->set_all( abap_true ).
        mo_alv->get_display_settings( )->set_striped_pattern( abap_true ).
      catch cx_salv_msg.
    endtry.

    try.
        mo_selection = mo_alv->get_selections( ).
        mo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).     "hem satır hem sütun seçimi
      catch cx_salv_msg.
    endtry.

    try.
        data(lo_sorts) = mo_alv->get_sorts( ).           "kolonlara sıralama atamasın diye
        lo_sorts->clear( ).
      catch cx_salv_msg.
    endtry.

    try.
        mo_events = mo_alv->get_event( ).
      catch cx_salv_msg.
        clear mo_events.
    endtry.

    if mo_events is bound.
      set handler me->on_double_click for mo_events.  " çift tık: garanti yol   tetikliyoruz
      set handler me->on_link_click   for mo_events.  " hotspot varsa tek tık
    endif.
  endmethod.

  method set_alv_properties.
    check mo_alv is bound.
    try.
        mo_columns = mo_alv->get_columns( ).          "kolon nesnesi
      catch cx_salv_msg.
        return.
    endtry.
    check mo_columns is bound.

    try. mo_columns->set_optimize( abap_false ). catch cx_salv_msg. endtry.         "otomatik düzeltmeyi kapat

    data: lv_h       type i,
          lv_next    type i,
          lv_h2n     type n length 2,
          lv_nx2n    type n length 2,
          lv_h2      type c length 2,
          lv_nx2     type c length 2,
          lv_from    type c length 5,
          lv_to      type c length 5,
          lv_short   type c length 10,
          lv_med     type c length 20,
          lv_long    type c length 40,
          lv_colname type c length 30.
    data lo_col type ref to cl_salv_column.

    try.
        mo_columns->set_color_column( 'CELLTAB' ).                                        "kolonlara renk verir celltab
      catch cx_salv_data_error cx_salv_not_found cx_salv_msg.
    endtry.
    do 24 times.                                                          "kolon için döngü
      lv_h    = sy-index - 1.
      lv_next = lv_h + 1.

      clear: lv_h2n, lv_nx2n, lv_h2, lv_nx2.
      lv_h2n = lv_h.       " '00'..'23' (0 padding)
      lv_h2  = lv_h2n.
      if lv_next = 24.
        lv_nx2 = '00'.
      else.
        lv_nx2n = lv_next. " '01'..'23'
        lv_nx2  = lv_nx2n.
      endif.

      concatenate lv_h2  ':00' into lv_from.     " HH:00
      concatenate lv_nx2 '.00' into lv_to.       " HH.00

      clear: lv_short, lv_med, lv_long.
      concatenate lv_h2 '-'   lv_nx2 into lv_short.   " HH-HH
      concatenate lv_from '-' lv_to  into lv_med.     " HH:00-HH.00
      lv_long = lv_med.

      clear lv_colname.
      concatenate 'H' lv_h2 into lv_colname.          " H00..H23

      " --- KRİTİK: adlandırılmış parametre ve boşluk kontrolü
      check lv_colname is not initial.

      clear lo_col.
      try.
          lo_col = mo_columns->get_column( columnname = lv_colname ).
        catch cx_salv_not_found.
          continue.
        catch cx_salv_msg.
          continue.
      endtry.

      try.
          lo_col->set_short_text(  lv_short ).
          lo_col->set_medium_text( lv_med ).
          lo_col->set_long_text(   lv_long ).
          lo_col->set_output_length( 12 ).
          lo_col->set_alignment( if_salv_c_alignment=>centered ).
        catch cx_salv_msg.
          " görsel ayar hataları kritik değil
      endtry.
    enddo.
  endmethod.

  method mark_gaps_for_row.
    data: lt_raw type standard table of zeho_t600,
          ls_raw like line of lt_raw.

    " 1) Satır anahtarına göre ilgili kayıtları çek
    select * from zeho_t600 into table @lt_raw
      where bankc = @cs_row-bankc
        and bukrs = @cs_row-bukrs
        and bankn = @cs_row-bankn
        and refbk = @cs_row-refbk
        and prdat = @cs_row-prdat.

    " 2) 1440 dakikalık kapsama matrisi (1-based index)
    data coverage type standard table of abap_bool with empty key.
    data total type i.
    total = 1440.                                         "döngü 1440 kez döner
    do total times.
      append abap_false to coverage.
    enddo.

    " (Zaman1/Zaman2/Tutar)
    field-symbols: <t1>  type t,
                   <t2>  type t,
                   <amt> type any.

    data: lv_time  type t,
          lv_hh    type c length 2,
          lv_mm    type c length 2,
          lv_h     type i,
          lv_m     type i,
          idx1     type i,
          flag_val type abap_bool.

    " 3) Kayıtlardan kapsama doldur
    loop at lt_raw into ls_raw.
      unassign <t1>.  unassign <t2>.  unassign <amt>.
      assign component c_time1  of structure ls_raw to <t1>.        "ls_raw ın c_time1 satırını t1 e bağlıyoruz.
      assign component c_time2  of structure ls_raw to <t2>.
      assign component c_amount of structure ls_raw to <amt>.

      clear lv_time.
      if <t1> is assigned.
        if <t1> is not initial.
          lv_time = <t1>.
        endif.
      endif.

      if lv_time is initial and <t2> is assigned.
        if <t2> is not initial.
          lv_time = <t2>.
        endif.
      endif.

      if lv_time is initial.
        continue.  " zaman yoksa bu kaydı atla
      endif.

      " Tutar kontrolü: kısa devre garantili, nested IF
      if <amt> is assigned.                       "bir veri nesnesine bağlanmış mı bağlanmamış mı
        if <amt> is initial.
          continue.  " tutar boşsa bu dakikayı 'dolu' saymayız
        endif.
      endif.

      " Saat/dakika ayır (substring atamada)
      lv_hh = lv_time+0(2).
      lv_mm = lv_time+2(2).
      lv_h  = lv_hh.                                "parçaladığımızı integere dönüştürüyoz
      lv_m  = lv_mm.

      " 1-based index ve işaretleme (field-symbol kullanmadan)
      idx1 = lv_h * 60 + lv_m + 1.
      if idx1 between 1 and total.
        clear flag_val.
        read table coverage index idx1 into flag_val.
        if sy-subrc = 0.
          flag_val = abap_true.
          modify coverage index idx1 from flag_val.
        endif.
      endif.
    endloop.

    " 4) Eksik dakika olan saatlerin hücrelerini kırmızı boya
    clear cs_row-celltab.
    data: ls_col     type lvc_s_scol,
          h          type i,
          m          type i,
          filled_cnt type i,
          idx2       type i,
          h2         type n length 2,
          lv_fname   type c length 3,     " <-- EK: 'H00'..'H23'
          lv_text    type c length 10.

    field-symbols: <cell> type any.

    do 24 times.
      h = sy-index - 1.      " 0..23
      filled_cnt = 0.

      do 60 times.
        m = sy-index - 1.    " 0..59
        idx2 = h * 60 + m + 1.

        if idx2 between 1 and total.
          clear flag_val.
          read table coverage index idx2 into flag_val.
          if sy-subrc = 0 and flag_val = abap_true.
            filled_cnt = filled_cnt + 1.
          endif.
        endif.
      enddo.

      clear h2.
      h2 = h.
      clear lv_fname.
      concatenate 'H' h2 into lv_fname.
      " -- Hxx hücresine DOLU dakika sayısını yaz (ör. 55)
      unassign <cell>.
      assign component lv_fname of structure cs_row to <cell>.
      if <cell> is assigned.
        clear lv_text.
        write filled_cnt to lv_text.     " '        55' gibi doldurur
        condense lv_text no-gaps.        " '55' haline getir
        <cell> = lv_text.                " CHAR/Numerik -> otomatik dönüşür
      endif.

      if filled_cnt < 60.    " saat içinde en az 1 dakika eksik ⇒ kırmızı boya
        clear ls_col.
        h2 = h.
        concatenate 'H' h2 into ls_col-fname.   " 'H00'..'H23'
        ls_col-color-col = 6.   " kırmızı
        ls_col-color-int = 1.
        ls_col-color-inv = 0.
        append ls_col to cs_row-celltab.
      endif.
    enddo.
  endmethod.

  method on_double_click.
    " --- DEBUG: row/col'u güvenli biçimde gör
    data: lv_row_c type c length 10,
          lv_col_c type c length 30,
          lv_dbg   type c length 80.

    clear: lv_row_c, lv_col_c, lv_dbg.
    write row to lv_row_c.     " i -> C dönüşümü
    lv_col_c = column.
    concatenate 'on_double_click: row/col=' lv_row_c '/' lv_col_c
           into lv_dbg separated by space.

    " --- Sütun adını normalize et
    data lv_col type c length 30.
    lv_col = lv_col_c.
    condense lv_col no-gaps.
    translate lv_col to upper case.

    " --- 'Hxx' ise saat çıkar
    data lv_hh type c length 2.
    data lv_h  type i.
    clear: lv_hh, lv_h.
    if lv_col(1) = 'H'.
      lv_hh = lv_col+1(2).   " '00'..'23' veya '6 '
      lv_h  = lv_hh.         " C -> I implicit dönüşüm
    else.
      return.                 " saat kolonu değilse işlem yok
    endif.

    " --- Tıklanan satırı al ve popup aç
    data ls_row type ty_out.
    read table gt_out into ls_row index row.
    if sy-subrc <> 0.
      message 'Satır okunamadı' type 'S' display like 'E'.
      return.
    endif.
    me->show_segment_popup( is_row = ls_row iv_start_h = lv_h iv_start_m = 0 ).
  endmethod.

  method on_link_click.
    on_double_click( row = row column = column ).
  endmethod.

  method show_segment_popup.
    "  Sadece tıklanan saat aralığı
    data total          type i value 1440.
    data hour_start_idx type i.
    hour_start_idx = iv_start_h * 60 + 1.          " [HH:00)
    data hour_end_idx type i.
    hour_end_idx   = ( iv_start_h + 1 ) * 60 + 1.  " [HH+1:00)

    "  Bu satıra ait ham kayıtlar
    data: lt_raw type standard table of zeho_t600,
          ls_raw like line of lt_raw.
    select * from zeho_t600 into table lt_raw
      where bankc = is_row-bankc
        and bukrs = is_row-bukrs
        and bankn = is_row-bankn
        and refbk = is_row-refbk
        and prdat = is_row-prdat.

    "  Saat içindeki olaylar başlangıç dakikası, o kaydın periyodu
    field-symbols: <t1>  type t,
                   <t2>  type t,
                   <amt> type any.

    data: lv_t1    type t, lv_t2 type t, lv_base type t,
          h1       type i, m1 type i, h2 type i, m2 type i,
          base_h   type i, base_m type i,
          idx      type i,
          step_min type i.

    types ty_i_set type hashed table of i with unique key table_line.       "Bu tablo sadece o saat içindeki dakikaları toplar
    data lt_idx_hour_set type ty_i_set.

    types: begin of ty_evt,
             idx  type i,
             step type i,
           end of ty_evt.
    data lt_evt type standard table of ty_evt with empty key.
    data ls_evt type ty_evt.

    loop at lt_raw into ls_raw.
      unassign <t1>. unassign <t2>. unassign <amt>.
      assign component c_time1  of structure ls_raw to <t1>.
      assign component c_time2  of structure ls_raw to <t2>.
      assign component c_amount of structure ls_raw to <amt>.

      " tutar boşsa sayma
      if <amt> is assigned and <amt> is initial.
        continue.
      endif.

      clear: lv_t1, lv_t2, lv_base.
      if <t1> is assigned and <t1> is not initial. lv_t1 = <t1>. endif.
      if <t2> is assigned and <t2> is not initial. lv_t2 = <t2>. endif.

      " periyot: iki zaman farkı (dakika)
      step_min = 0.
      if lv_t1 is not initial and lv_t2 is not initial.
        h1 = lv_t1+0(2).  m1 = lv_t1+2(2).
        h2 = lv_t2+0(2).  m2 = lv_t2+2(2).
        step_min = ( h2 * 60 + m2 ) - ( h1 * 60 + m1 ).
        if step_min < 0. step_min = - step_min. endif.
      endif.

      " olayın başlangıç dakikası: B_PRTIM varsa onu, yoksa E_PRTIM
      if lv_t1 is not initial.
        lv_base = lv_t1.
      elseif lv_t2 is not initial.
        lv_base = lv_t2.
      else.
        continue.
      endif.

      base_h = lv_base+0(2).  base_m = lv_base+2(2).
      idx    = base_h * 60 + base_m + 1.

      " sadece bu saat
      if idx < hour_start_idx or idx >= hour_end_idx.
        continue.
      endif.

      if step_min <= 0.  step_min = 1.  endif.
      if step_min > 240. step_min = 60. endif.

      ls_evt-idx  = idx.
      ls_evt-step = step_min.
      append ls_evt to lt_evt.

      insert idx into table lt_idx_hour_set.
    endloop.

    "Olayları sırala
    sort lt_evt by idx.

    "  Saat boyunca blok üret (her olayın step'ine göre)
    data: lt_seg type tt_seg_tab,
          ls_seg type ty_seg_row.
    data cur type i.
    cur = hour_start_idx.
    data nxt type i.
    data lv_lines type i.
    describe table lt_evt lines lv_lines.

    if lt_evt is initial.
      " Kaydı olmayan saat: örnek olarak 10'ar dk YOK (istersen 5/15 yap)
      while cur < hour_end_idx.
        nxt = cur + 10.
        if nxt > hour_end_idx. nxt = hour_end_idx. endif.
        me->idx_to_c5( exporting iv_idx = cur importing ev_c5 = ls_seg-from_c5 ).
        me->idx_to_c5( exporting iv_idx = nxt importing ev_c5 = ls_seg-to_c5   ).
        ls_seg-status  = 'YOK'.
        ls_seg-minutes = nxt - cur.
        clear ls_seg-celltab.
        data lc0 type lvc_s_scol.
        clear lc0.
        lc0-fname = 'STATUS'. lc0-color-int = 1. lc0-color-col = 6.
        append lc0 to ls_seg-celltab.
        append ls_seg to lt_seg.
        cur = nxt.
      endwhile.
    else.
      data l_evt type ty_evt.
      do lv_lines times.
        read table lt_evt index sy-index into l_evt.

        "  Olaydan önceki boşluk: o olayın step'i ile YOK
        while cur < l_evt-idx.
          nxt = cur + l_evt-step.
          if nxt > l_evt-idx. nxt = l_evt-idx. endif.
          me->idx_to_c5( exporting iv_idx = cur importing ev_c5 = ls_seg-from_c5 ).
          me->idx_to_c5( exporting iv_idx = nxt importing ev_c5 = ls_seg-to_c5   ).
          ls_seg-status  = 'YOK'.
          ls_seg-minutes = nxt - cur.
          clear ls_seg-celltab.
          data lc1 type lvc_s_scol.
          clear lc1.
          lc1-fname = 'STATUS'. lc1-color-int = 1. lc1-color-col = 6.
          append lc1 to ls_seg-celltab.
          if ls_seg-minutes > 0. append ls_seg to lt_seg. endif.
          cur = nxt.
        endwhile.

        "  Olayın kendi bloğu: [idx .. idx+step) VAR
        nxt = l_evt-idx + l_evt-step.
        if nxt > hour_end_idx. nxt = hour_end_idx. endif.
        me->idx_to_c5( exporting iv_idx = l_evt-idx importing ev_c5 = ls_seg-from_c5 ).
        me->idx_to_c5( exporting iv_idx = nxt       importing ev_c5 = ls_seg-to_c5   ).
        ls_seg-status  = 'VAR'.
        ls_seg-minutes = nxt - l_evt-idx.
        clear ls_seg-celltab.
        data lc2 type lvc_s_scol.
        clear lc2.
        lc2-fname = 'STATUS'. lc2-color-int = 1. lc2-color-col = 5.
        append lc2 to ls_seg-celltab.
        if ls_seg-minutes > 0. append ls_seg to lt_seg. endif.
        cur = nxt.

        "  Olaydan sonra, sıradaki olaya kadar YOK (aynı step)
        if sy-index < lv_lines.
          data next_evt type ty_evt.
          read table lt_evt index sy-index + 1 into next_evt.
          while cur < next_evt-idx.
            nxt = cur + l_evt-step.
            if nxt > next_evt-idx. nxt = next_evt-idx. endif.
            me->idx_to_c5( exporting iv_idx = cur importing ev_c5 = ls_seg-from_c5 ).
            me->idx_to_c5( exporting iv_idx = nxt importing ev_c5 = ls_seg-to_c5   ).
            ls_seg-status  = 'YOK'.
            ls_seg-minutes = nxt - cur.
            clear ls_seg-celltab.
            data lc3 type lvc_s_scol.
            clear lc3.
            lc3-fname = 'STATUS'. lc3-color-int = 1. lc3-color-col = 6.
            append lc3 to ls_seg-celltab.
            if ls_seg-minutes > 0. append ls_seg to lt_seg. endif.
            cur = nxt.
          endwhile.
        endif.
      enddo.
      " Son olaydan sonra saat sonuna kadar YOK (son step ile)
      if cur < hour_end_idx.
        data last_evt type ty_evt.
        read table lt_evt index lv_lines into last_evt.
        while cur < hour_end_idx.
          nxt = cur + last_evt-step.
          if nxt > hour_end_idx. nxt = hour_end_idx. endif.
          me->idx_to_c5( exporting iv_idx = cur importing ev_c5 = ls_seg-from_c5 ).
          me->idx_to_c5( exporting iv_idx = nxt importing ev_c5 = ls_seg-to_c5   ).
          ls_seg-status  = 'YOK'.
          ls_seg-minutes = nxt - cur.
          clear ls_seg-celltab.
          data lc4 type lvc_s_scol.
          clear lc4.
          lc4-fname = 'STATUS'. lc4-color-int = 1. lc4-color-col = 6.
          append lc4 to ls_seg-celltab.
          if ls_seg-minutes > 0. append ls_seg to lt_seg. endif.
          cur = nxt.
        endwhile.
      endif.
    endif.

    " Popup ALV
    if mo_seg_grid is bound. free mo_seg_grid. endif.
    if mo_seg_cont is bound. free mo_seg_cont. endif.

    data nh type n length 2.
    nh = iv_start_h.
    data cap type c length 60.
    concatenate 'Aralıklar (saat: ' nh ':00)' into cap separated by space.

    create object mo_seg_cont
      exporting
        width   = 600
        height  = 420
        top     = 120
        left    = 160
        caption = cap.

    if mo_seg_cont is bound.
      set handler me->on_close for mo_seg_cont.
    endif.

    create object mo_seg_grid
      exporting
        i_parent = mo_seg_cont.

    data: lt_fcat type lvc_t_fcat,
          ls_fcat type lvc_s_fcat,
          ls_layo type lvc_s_layo.
    clear lt_fcat.

    clear ls_fcat. ls_fcat-fieldname = 'FROM_C5'. ls_fcat-coltext = 'Başlangıç'. ls_fcat-outputlen = 5.  append ls_fcat to lt_fcat.
    clear ls_fcat. ls_fcat-fieldname = 'TO_C5'.   ls_fcat-coltext = 'Bitiş'.     ls_fcat-outputlen = 5.  append ls_fcat to lt_fcat.
    clear ls_fcat. ls_fcat-fieldname = 'STATUS'.  ls_fcat-coltext = 'Durum'.     ls_fcat-outputlen = 5.  append ls_fcat to lt_fcat.
    clear ls_fcat. ls_fcat-fieldname = 'MINUTES'. ls_fcat-coltext = 'Dakika'.    ls_fcat-outputlen = 5.  append ls_fcat to lt_fcat.

    clear ls_layo. ls_layo-ctab_fname = 'CELLTAB'.

    call method mo_seg_grid->set_table_for_first_display
      exporting
        is_layout       = ls_layo
      changing
        it_outtab       = lt_seg
        it_fieldcatalog = lt_fcat.

    call method cl_gui_cfw=>flush.
  endmethod.

  method idx_to_c5.                         "bu method indisi saate çevirir.
    data l_idx type i.
    if iv_idx < 1.
      l_idx = 0.
    else.
      l_idx = iv_idx - 1.
    endif.

    data l_h type i.
    data l_m type i.
    l_h = l_idx div 60.
    l_m = l_idx mod 60.
    data ch type n length 2.
    data cm type n length 2.
    ch = l_h.
    cm = l_m.

    clear ev_c5.
    concatenate ch ':' cm into ev_c5.
  endmethod.

  method on_close.
    try.
        if mo_seg_grid is bound.
          free mo_seg_grid.
        endif.
      catch cx_root.
    endtry.
    try.
        if sender is bound.
          sender->free( ).
        endif.
      catch cx_root.
    endtry.
    clear: mo_seg_grid, mo_seg_cont.
    cl_gui_cfw=>flush( ).
  endmethod.
endclass.
