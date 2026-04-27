*&---------------------------------------------------------------------*
*& Include          ZMDIK_P77_I003
*&---------------------------------------------------------------------*

CLASS lcl_report DEFINITION FINAL.
  PUBLIC SECTION.
   data: mo_alv       type ref to cl_salv_table,
          mo_columns   type ref to cl_salv_columns_table,
          mo_column    type ref to cl_salv_column_table,
          mo_events    type ref to cl_salv_events_table,
          mo_selection type ref to cl_salv_selections.
    METHODS: run,
      prepare_alv,
     select_data,
     set_alv_properties,
    create_alv,
   mark_gaps_for_row
 CHANGING   cs_row  TYPE ty_out,
*     show_minute_popup
*    IMPORTING
*      is_row  TYPE ty_out
*      iv_hour TYPE i,
show_segment_popup
    IMPORTING
      is_row      TYPE ty_out
      iv_start_h  TYPE i
      iv_start_m  TYPE i,
  on_double_click FOR EVENT double_click OF cl_salv_events_table
    IMPORTING row column,
  on_link_click   FOR EVENT link_click   OF cl_salv_events_table
    IMPORTING row column,
        idx_to_c5
    IMPORTING iv_idx TYPE i
    EXPORTING ev_c5  TYPE c .

     PRIVATE SECTION.
    " ——— ZEHO_T600 içindeki alan adlarını BURADAN AYARLA ———
    CONSTANTS: c_time1  TYPE fieldname VALUE 'B_PRTIM',    " 1. saat alanı
               c_time2  TYPE fieldname VALUE 'E_PRTIM',   " 2. saat alanı (varsa)
               c_amount TYPE fieldname VALUE 'AMOUNT'.   " tutar alanı
ENDCLASS.

CLASS lcl_report IMPLEMENTATION.

  METHOD run.
    select_data( ).

    IF gt_out IS INITIAL.
      MESSAGE 'Seçim kriterlerine uyan kayıt bulunamadı.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

     LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<s_row>).
    me->mark_gaps_for_row( CHANGING cs_row = <s_row> ).
  ENDLOOP.

    create_alv( ).
    set_alv_properties( ).
    mo_alv->display( ).
  ENDMETHOD.

 METHOD select_data.
  SELECT bankc,
         bukrs,
         bankn,
         refbk,
         prdat
    FROM zeho_t600
    INTO CORRESPONDING FIELDS OF TABLE @gt_out
    WHERE bukrs IN @s_bukrs and
    prdat IN @s_prdat and
       bankc IN @s_bankc and
       bankn IN @s_bankn and
       refbk IN @s_refbk .
ENDMETHOD.


  METHOD prepare_alv.
  CLEAR gt_out.
  LOOP AT gt_table ASSIGNING FIELD-SYMBOL(<s>).
    CLEAR gs_out.
    MOVE-CORRESPONDING <s> TO gs_out.
    APPEND gs_out TO gt_out.
  ENDLOOP.
ENDMETHOD.

  METHOD create_alv.
  " 1) SALV'i üret
  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = mo_alv
        CHANGING  t_table      = gt_out ).
    CATCH cx_salv_msg.
      CLEAR mo_alv.
      RETURN.
  ENDTRY.
  IF mo_alv IS NOT BOUND.
    RETURN.
  ENDIF.

  " 2) (Opsiyonel) Fonksiyonları aç, görünüm düzeni
  TRY.
      mo_alv->get_functions( )->set_all( abap_true ).
      mo_alv->get_display_settings( )->set_striped_pattern( abap_true ).
    CATCH cx_salv_msg.
  ENDTRY.

  " 3) SEÇİM MODU: row+column (çift tıkta sütun adını alabilelim)
  TRY.
      mo_selection = mo_alv->get_selections( ).
      mo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).
    CATCH cx_salv_msg.
  ENDTRY.

  " 4) (Opsiyonel) Sıraları temizle
  TRY.
      DATA(lo_sorts) = mo_alv->get_sorts( ).
      lo_sorts->clear( ).
    CATCH cx_salv_msg.
  ENDTRY.

  " 5) OLAYLARI bağla (display'den önce)
  TRY.
      mo_events = mo_alv->get_event( ).
    CATCH cx_salv_msg.
      CLEAR mo_events.
  ENDTRY.

  IF mo_events IS BOUND.
    SET HANDLER me->on_double_click FOR mo_events.  " çift tık: garanti yol
    SET HANDLER me->on_link_click   FOR mo_events.  " hotspot varsa tek tık
  ENDIF.
ENDMETHOD.


METHOD set_alv_properties.
  CHECK mo_alv IS BOUND.
  TRY.
      mo_columns = mo_alv->get_columns( ).
    CATCH cx_salv_msg.
      RETURN.
  ENDTRY.
  CHECK mo_columns IS BOUND.

  TRY. mo_columns->set_optimize( abap_false ). CATCH cx_salv_msg. ENDTRY.

  DATA: lv_h       TYPE i,
        lv_next    TYPE i,
        lv_h2n     TYPE n LENGTH 2,
        lv_nx2n    TYPE n LENGTH 2,
        lv_h2      TYPE c LENGTH 2,
        lv_nx2     TYPE c LENGTH 2,
        lv_from    TYPE c LENGTH 5,
        lv_to      TYPE c LENGTH 5,
        lv_short   TYPE c LENGTH 10,
        lv_med     TYPE c LENGTH 20,
        lv_long    TYPE c LENGTH 40,
        lv_colname TYPE c LENGTH 30.
  DATA lo_col TYPE REF TO cl_salv_column.

  TRY.
    mo_columns->set_color_column( 'CELLTAB' ).                                        "kolonlara renk verir celltab
  CATCH cx_salv_data_error cx_salv_not_found cx_salv_msg.
ENDTRY.






  DO 24 TIMES.
    lv_h    = sy-index - 1.
    lv_next = lv_h + 1.

    CLEAR: lv_h2n, lv_nx2n, lv_h2, lv_nx2.
    lv_h2n = lv_h.       " '00'..'23' (0 padding)
    lv_h2  = lv_h2n.
    IF lv_next = 24.
      lv_nx2 = '24'.
    ELSE.
      lv_nx2n = lv_next. " '01'..'23'
      lv_nx2  = lv_nx2n.
    ENDIF.

    CONCATENATE lv_h2  ':00' INTO lv_from.     " HH:00
    CONCATENATE lv_nx2 '.00' INTO lv_to.       " HH.00

    CLEAR: lv_short, lv_med, lv_long.
    CONCATENATE lv_h2 '-'   lv_nx2 INTO lv_short.   " HH-HH
    CONCATENATE lv_from '-' lv_to  INTO lv_med.     " HH:00-HH.00
    lv_long = lv_med.

    CLEAR lv_colname.
    CONCATENATE 'H' lv_h2 INTO lv_colname.          " H00..H23

    " --- KRİTİK: adlandırılmış parametre ve boşluk kontrolü
    CHECK lv_colname IS NOT INITIAL.

    CLEAR lo_col.
    TRY.
        lo_col = mo_columns->get_column( columnname = lv_colname ).
      CATCH cx_salv_not_found.
        CONTINUE.
      CATCH cx_salv_msg.
        CONTINUE.
    ENDTRY.

    TRY.
        lo_col->set_short_text(  lv_short ).
        lo_col->set_medium_text( lv_med ).
        lo_col->set_long_text(   lv_long ).
        lo_col->set_output_length( 12 ).
        lo_col->set_alignment( if_salv_c_alignment=>centered ).
      CATCH cx_salv_msg.
        " görsel ayar hataları kritik değil
    ENDTRY.
  ENDDO.
ENDMETHOD.

METHOD mark_gaps_for_row.
  DATA: lt_raw TYPE STANDARD TABLE OF zeho_t600,
        ls_raw LIKE LINE OF lt_raw.

  " 1) Satır anahtarına göre ilgili kayıtları çek
  SELECT * FROM zeho_t600 INTO TABLE @lt_raw
    WHERE bankc = @cs_row-bankc
      AND bukrs = @cs_row-bukrs
      AND bankn = @cs_row-bankn
      AND refbk = @cs_row-refbk
      AND prdat = @cs_row-prdat.

  " 2) 1440 dakikalık kapsama matrisi (1-based index)
  DATA coverage TYPE STANDARD TABLE OF abap_bool WITH EMPTY KEY.
  DATA total TYPE i.  total = 1440.
  DO total TIMES.
    APPEND abap_false TO coverage.
  ENDDO.

  " --- Dinamik alanlar (Zaman1/Zaman2/Tutar)
  FIELD-SYMBOLS: <t1>  TYPE t,
                 <t2>  TYPE t,
                 <amt> TYPE any.

  " --- Çalışma değişkenleri
  DATA: lv_time TYPE t,
        lv_hh   TYPE c LENGTH 2,
        lv_mm   TYPE c LENGTH 2,
        lv_h    TYPE i,
        lv_m    TYPE i,
        idx1    TYPE i,
        flag_val TYPE abap_bool.

  " 3) Kayıtlardan kapsama doldur (field-symbol güvenli)
  LOOP AT lt_raw INTO ls_raw.
    " !! FIELD-SYMBOL'leri asla CLEAR etme; önce UNASSIGN et, sonra ASSIGN !!
    UNASSIGN <t1>.  UNASSIGN <t2>.  UNASSIGN <amt>.
    ASSIGN COMPONENT c_time1  OF STRUCTURE ls_raw TO <t1>.
    ASSIGN COMPONENT c_time2  OF STRUCTURE ls_raw TO <t2>.
    ASSIGN COMPONENT c_amount OF STRUCTURE ls_raw TO <amt>.

    CLEAR lv_time.
    IF <t1> IS ASSIGNED.
      IF <t1> IS NOT INITIAL.
        lv_time = <t1>.
      ENDIF.
    ENDIF.

    IF lv_time IS INITIAL AND <t2> IS ASSIGNED.
      IF <t2> IS NOT INITIAL.
        lv_time = <t2>.
      ENDIF.
    ENDIF.

    IF lv_time IS INITIAL.
      CONTINUE.  " zaman yoksa bu kaydı atla
    ENDIF.

    " Tutar kontrolü: kısa devre garantili, nested IF
    IF <amt> IS ASSIGNED.                       "bir veri nesnesine bağlanmış mı bağlanmamış mı
      IF <amt> IS INITIAL.
        CONTINUE.  " tutar boşsa bu dakikayı 'dolu' saymayız
      ENDIF.
    ENDIF.

    " Saat/dakika ayır (substring atamada)
   lv_hh = lv_time+0(2).
lv_mm = lv_time+2(2).
lv_h  = lv_hh.   " karakter '03' -> 3 (implicit conversion)
lv_m  = lv_mm.

    " 1-based index ve işaretleme (field-symbol kullanmadan)
    idx1 = lv_h * 60 + lv_m + 1.
    IF idx1 BETWEEN 1 AND total.
      CLEAR flag_val.
      READ TABLE coverage INDEX idx1 INTO flag_val.
      IF sy-subrc = 0.
        flag_val = abap_true.
        MODIFY coverage INDEX idx1 FROM flag_val.
      ENDIF.
    ENDIF.
  ENDLOOP.

  " 4) Eksik dakika olan saatlerin hücrelerini kırmızı boya
  CLEAR cs_row-celltab.
  DATA: ls_col     TYPE lvc_s_scol,
        h          TYPE i,
        m          TYPE i,
        filled_cnt TYPE i,
        idx2       TYPE i,
        h2         TYPE n LENGTH 2,
        lv_fname   TYPE c LENGTH 3,     " <-- EK: 'H00'..'H23'
        lv_text    TYPE c LENGTH 10.


   FIELD-SYMBOLS: <cell> TYPE any.

  DO 24 TIMES.
    h = sy-index - 1.      " 0..23
    filled_cnt = 0.

    DO 60 TIMES.
      m = sy-index - 1.    " 0..59
      idx2 = h * 60 + m + 1.

      IF idx2 BETWEEN 1 AND total.
        CLEAR flag_val.
        READ TABLE coverage INDEX idx2 INTO flag_val.
        IF sy-subrc = 0 AND flag_val = abap_true.
          filled_cnt = filled_cnt + 1.
        ENDIF.
      ENDIF.
    ENDDO.


      CLEAR h2.
    h2 = h.
    CLEAR lv_fname.
    CONCATENATE 'H' h2 INTO lv_fname.

      " -- Hxx hücresine DOLU dakika sayısını yaz (ör. 55)
    UNASSIGN <cell>.
    ASSIGN COMPONENT lv_fname OF STRUCTURE cs_row TO <cell>.
    IF <cell> IS ASSIGNED.
      CLEAR lv_text.
      WRITE filled_cnt TO lv_text.     " '        55' gibi doldurur
      CONDENSE lv_text NO-GAPS.        " '55' haline getir
      <cell> = lv_text.                " CHAR/Numerik -> otomatik dönüşür
    ENDIF.






    IF filled_cnt < 60.    " saat içinde en az 1 dakika eksik ⇒ kırmızı boya
      CLEAR ls_col.
      h2 = h.
      CONCATENATE 'H' h2 INTO ls_col-fname.   " 'H00'..'H23'
      ls_col-color-col = 6.   " kırmızı
      ls_col-color-int = 1.
      ls_col-color-inv = 0.
      APPEND ls_col TO cs_row-celltab.
    ENDIF.
  ENDDO.
ENDMETHOD.

METHOD on_double_click.
  " --- DEBUG: row/col'u güvenli biçimde gör
  DATA: lv_row_c TYPE c LENGTH 10,
        lv_col_c TYPE c LENGTH 30,
        lv_dbg   TYPE c LENGTH 80.

  CLEAR: lv_row_c, lv_col_c, lv_dbg.
  WRITE row TO lv_row_c.     " i -> C dönüşümü
  lv_col_c = column.         " zaten genelde C; yine de C alana taşı
  CONCATENATE 'on_double_click: row/col=' lv_row_c '/' lv_col_c
         INTO lv_dbg SEPARATED BY space.
  " MESSAGE lv_dbg TYPE 'S'. " (istersen test için aç)

  " --- Sütun adını normalize et
  DATA lv_col TYPE c LENGTH 30.
  lv_col = lv_col_c.
  CONDENSE lv_col NO-GAPS.
  TRANSLATE lv_col TO UPPER CASE.

  " --- 'Hxx' ise saat çıkar
  DATA lv_hh TYPE c LENGTH 2.
  DATA lv_h  TYPE i.
  CLEAR: lv_hh, lv_h.
  IF lv_col(1) = 'H'.
    lv_hh = lv_col+1(2).   " '00'..'23' veya '6 '
    lv_h  = lv_hh.         " C -> I implicit dönüşüm
  ELSE.
    RETURN.                 " saat kolonu değilse işlem yok
  ENDIF.

  " --- Tıklanan satırı al ve popup aç
  DATA ls_row TYPE ty_out.
  READ TABLE gt_out INTO ls_row INDEX row.
  IF sy-subrc <> 0.
    MESSAGE 'Satır okunamadı' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  me->show_segment_popup( is_row = ls_row iv_start_h = lv_h iv_start_m = 0 ).

*  me->show_minute_popup( is_row = ls_row iv_hour = lv_h ).
ENDMETHOD.



METHOD on_link_click.
  " Hotspot kullanırsan tek tıkla da aynı davranış:
  on_double_click( row = row column = column ).
ENDMETHOD.

*METHOD show_minute_popup.
*  " 1) Seçilen satıra göre ham kayıtları çek
*  DATA: lt_raw TYPE STANDARD TABLE OF zeho_t600,
*        ls_raw LIKE LINE OF lt_raw.
*  SELECT * FROM zeho_t600 INTO TABLE lt_raw
*    WHERE bankc = is_row-bankc
*      AND bukrs = is_row-bukrs
*      AND bankn = is_row-bankn
*      AND refbk = is_row-refbk
*      AND prdat = is_row-prdat.
*
*  " 2) 1440 dakikalık coverage hazırla (bool tablo: 1..1440)
*  DATA coverage TYPE STANDARD TABLE OF abap_bool WITH EMPTY KEY.
*  DATA total TYPE i.  total = 1440.
*  DO total TIMES.
*    APPEND abap_false TO coverage.
*  ENDDO.
*
*  FIELD-SYMBOLS: <t1>  TYPE t,
*                 <t2>  TYPE t,
*                 <amt> TYPE any.
*
*  DATA: lv_time  TYPE t,
*        lv_hh    TYPE c LENGTH 2,
*        lv_mm    TYPE c LENGTH 2,
*        lv_h     TYPE i,
*        lv_m     TYPE i,
*        idx1     TYPE i,
*        flag_val TYPE abap_bool.
*
*  LOOP AT lt_raw INTO ls_raw.
*    UNASSIGN <t1>. UNASSIGN <t2>. UNASSIGN <amt>.
*    ASSIGN COMPONENT c_time1  OF STRUCTURE ls_raw TO <t1>.
*    ASSIGN COMPONENT c_time2  OF STRUCTURE ls_raw TO <t2>.
*    ASSIGN COMPONENT c_amount OF STRUCTURE ls_raw TO <amt>.
*
*    CLEAR lv_time.
*    IF <t1> IS ASSIGNED AND <t1> IS NOT INITIAL.
*      lv_time = <t1>.
*    ELSEIF <t2> IS ASSIGNED AND <t2> IS NOT INITIAL.
*      lv_time = <t2>.
*    ELSE.
*      CONTINUE.
*    ENDIF.
*
*    IF <amt> IS ASSIGNED AND <amt> IS INITIAL.
*      CONTINUE. " tutar boşsa sayma
*    ENDIF.
*
*   lv_hh = lv_time+0(2).
*lv_mm = lv_time+2(2).
*lv_h  = lv_hh.
*lv_m  = lv_mm.
*
*
*    idx1 = lv_h * 60 + lv_m + 1.
*    IF idx1 BETWEEN 1 AND total.
*      CLEAR flag_val.
*      READ TABLE coverage INDEX idx1 INTO flag_val.
*      IF sy-subrc = 0.
*        flag_val = abap_true.
*        MODIFY coverage INDEX idx1 FROM flag_val.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*  " 3) iv_hour için 60 satırlık dakika listesi üret (renkli)
*  TYPES: tt_min_tab TYPE STANDARD TABLE OF ty_min_row WITH EMPTY KEY.
*  DATA: lt_min TYPE tt_min_tab,
*        ls_min TYPE ty_min_row.
*
*  DATA m TYPE i.
*  DATA idx2 TYPE i.
*  DATA hh1 TYPE n LENGTH 2.
*  DATA mm1 TYPE n LENGTH 2.
*  DATA hh2 TYPE n LENGTH 2.
*  DATA mm2 TYPE n LENGTH 2.
*
*  DO 60 TIMES.
*    m    = sy-index - 1.                 " 0..59
*    idx2 = iv_hour * 60 + m + 1.
*
*    CLEAR hh1. CLEAR mm1.
*    hh1 = iv_hour.  mm1 = m.
*
*    " bitiş dakikası
*    DATA next_m TYPE i. next_m = m + 1.
*    CLEAR hh2. CLEAR mm2.
*    IF next_m < 60.
*      hh2 = iv_hour.  mm2 = next_m.
*    ELSE.
*      DATA nxh TYPE i. nxh = iv_hour + 1.
*      hh2 = nxh.  mm2 = 0.
*    ENDIF.
*
*    " 'HH:MM-HH:MM'
*    DATA lv_l TYPE c LENGTH 5.
*    DATA lv_r TYPE c LENGTH 5.
*    CLEAR lv_l. CLEAR lv_r. CLEAR ls_min-time_rng.
*    CONCATENATE hh1 ':' mm1 INTO lv_l.
*    CONCATENATE hh2 ':' mm2 INTO lv_r.
*    CONCATENATE lv_l '-' lv_r INTO ls_min-time_rng.
*
*    " durum + renk
*    CLEAR flag_val.
*    READ TABLE coverage INDEX idx2 INTO flag_val.
*    CLEAR ls_min-celltab.
*
*    IF sy-subrc = 0 AND flag_val = abap_true.
*      ls_min-status = 'VAR'.
*      DATA ls_scol TYPE lvc_s_scol.
*      CLEAR ls_scol.
*      ls_scol-fname      = 'STATUS'.
*      ls_scol-color-col  = 5. " yeşil
*      ls_scol-color-int  = 1.
*      ls_scol-color-inv  = 0.
*      APPEND ls_scol TO ls_min-celltab.
*    ELSE.
*      ls_min-status = 'YOK'.
*      DATA ls_scol2 TYPE lvc_s_scol.
*      CLEAR ls_scol2.
*      ls_scol2-fname     = 'STATUS'.
*      ls_scol2-color-col = 6. " kırmızı
*      ls_scol2-color-int = 1.
*      ls_scol2-color-inv = 0.
*      APPEND ls_scol2 TO ls_min-celltab.
*    ENDIF.
*
*    APPEND ls_min TO lt_min.
*  ENDDO.
*
*  " 4) Popup container + ALV
*  IF mo_popup_grid IS BOUND.
*    FREE mo_popup_grid.
*  ENDIF.
*  IF mo_popup_cont IS BOUND.
*    FREE mo_popup_cont.
*  ENDIF.
*
*  " Başlık
*  DATA th  TYPE n LENGTH 2. th  = iv_hour.
*  DATA th1 TYPE n LENGTH 2. th1 = iv_hour + 1.
*  DATA cap TYPE c LENGTH 50.
*  CONCATENATE th ':00 - ' th1 ':00 Dakika Kontrolü' INTO cap.
*
*  CREATE OBJECT mo_popup_cont
*    EXPORTING
*      width   = 520
*      height  = 520
*      top     = 100
*      left    = 160
*      caption = cap.
*
*  CREATE OBJECT mo_popup_grid
*    EXPORTING i_parent = mo_popup_cont.
*
*  " Alan kataloğu
*  DATA: lt_fcat TYPE lvc_t_fcat,
*        ls_fcat TYPE lvc_s_fcat.
*  CLEAR lt_fcat.
*
*  CLEAR ls_fcat.
*  ls_fcat-fieldname = 'TIME_RNG'.
*  ls_fcat-coltext   = 'Dakika'.
*  ls_fcat-outputlen = 11.
*  APPEND ls_fcat TO lt_fcat.
*
*  CLEAR ls_fcat.
*  ls_fcat-fieldname = 'STATUS'.
*  ls_fcat-coltext   = 'Durum'.
*  ls_fcat-outputlen = 5.
*  APPEND ls_fcat TO lt_fcat.
*
*  " Layout: hücre rengi
*  DATA ls_layo TYPE lvc_s_layo.
*  CLEAR ls_layo.
*  ls_layo-ctab_fname = 'CELLTAB'.
*
*  CALL METHOD mo_popup_grid->set_table_for_first_display
*    EXPORTING
*      is_layout       = ls_layo
*    CHANGING
*      it_outtab       = lt_min
*      it_fieldcatalog = lt_fcat.
*
*  CALL METHOD cl_gui_cfw=>flush.
*ENDMETHOD.


METHOD show_segment_popup.
  "-------- 0) Parametre kontrolleri --------
  DATA start_h TYPE i. start_h = iv_start_h.
  DATA start_m TYPE i. start_m = iv_start_m.
  IF start_h < 0. start_h = 0. ENDIF.
  IF start_h > 23. start_h = 23. ENDIF.
  IF start_m < 0. start_m = 0. ENDIF.
  IF start_m > 59. start_m = 59. ENDIF.

  "-------- 1) Bu satıra ait ham kayıtları topla --------
  DATA: lt_raw TYPE STANDARD TABLE OF zeho_t600,
        ls_raw LIKE LINE OF lt_raw.

  SELECT * FROM zeho_t600 INTO TABLE lt_raw
    WHERE bankc = is_row-bankc
      AND bukrs = is_row-bukrs
      AND bankn = is_row-bankn
      AND refbk = is_row-refbk
      AND prdat = is_row-prdat.

  "-------- 2) 1..1440 coverage vektörü oluştur --------
  DATA coverage TYPE STANDARD TABLE OF abap_bool WITH EMPTY KEY.
  DATA total TYPE i. total = 1440.
  DATA i TYPE i.
  DO total TIMES.
    APPEND abap_false TO coverage.
  ENDDO.

  FIELD-SYMBOLS: <t1>  TYPE t,
                 <t2>  TYPE t,
                 <amt> TYPE any.

  DATA: lv_time  TYPE t,
        lv_hh    TYPE c LENGTH 2,
        lv_mm    TYPE c LENGTH 2,
        lv_h     TYPE i,
        lv_m     TYPE i,
        idx1     TYPE i,
        flag_val TYPE abap_bool.

  LOOP AT lt_raw INTO ls_raw.
    UNASSIGN <t1>. UNASSIGN <t2>. UNASSIGN <amt>.
    ASSIGN COMPONENT c_time1  OF STRUCTURE ls_raw TO <t1>.
    ASSIGN COMPONENT c_time2  OF STRUCTURE ls_raw TO <t2>.
    ASSIGN COMPONENT c_amount OF STRUCTURE ls_raw TO <amt>.

    CLEAR lv_time.
    IF <t1> IS ASSIGNED AND <t1> IS NOT INITIAL.
      lv_time = <t1>.
    ELSEIF <t2> IS ASSIGNED AND <t2> IS NOT INITIAL.
      lv_time = <t2>.
    ELSE.
      CONTINUE.
    ENDIF.

    IF <amt> IS ASSIGNED AND <amt> IS INITIAL.
      CONTINUE. " tutar boşsa sayma
    ENDIF.

    lv_hh = lv_time+0(2).
    lv_mm = lv_time+2(2).
    lv_h  = lv_hh.   " implicit C->I
    lv_m  = lv_mm.

    idx1 = lv_h * 60 + lv_m + 1.
    IF idx1 BETWEEN 1 AND total.
      CLEAR flag_val.
      READ TABLE coverage INDEX idx1 INTO flag_val.
      IF sy-subrc = 0.
        flag_val = abap_true.
        MODIFY coverage INDEX idx1 FROM flag_val.
      ENDIF.
    ENDIF.
  ENDLOOP.

  "-------- 3) Başlangıç indeksi & ilk durum --------
  DATA start_idx TYPE i.
  start_idx = start_h * 60 + start_m + 1.
  IF start_idx < 1.     start_idx = 1.     ENDIF.
  IF start_idx > total. start_idx = total. ENDIF.

  DATA cur_bool TYPE abap_bool.
  CLEAR cur_bool.
  READ TABLE coverage INDEX start_idx INTO cur_bool.
  IF sy-subrc <> 0.
    cur_bool = abap_false.
  ENDIF.

  "-------- 4) Yardımcı: idx -> 'HH:MM' üret --------
  " iv_idx: 1..1440, cv_c5: 'HH:MM' (24:00 da üretilebilir)


  "-------- 5) Segment üretimi (run-length) --------
  DATA: lt_seg   TYPE tt_seg_tab,
        ls_seg   TYPE ty_seg_row,
        seg_beg  TYPE i,     " segment başlangıç indeksi (1..1440)
        next_val TYPE abap_bool.

  seg_beg = start_idx.

  DO total TIMES.  " segment bitişlerini arayacağız
    i = sy-index + start_idx.      " pratik şekilde ileri kaydır
    IF i > total.
      EXIT.
    ENDIF.

    CLEAR next_val.
    READ TABLE coverage INDEX i INTO next_val.
    IF sy-subrc <> 0.
      next_val = abap_false.
    ENDIF.

    " önceki ile farklıysa, [seg_beg, i-1) aralığı tamamlandı
    IF i > seg_beg AND next_val <> cur_bool.
      " segmenti kapa: [seg_beg .. i-1)
   me->idx_to_c5( EXPORTING iv_idx = seg_beg   IMPORTING ev_c5 = ls_seg-from_c5 ).
    me->idx_to_c5( EXPORTING iv_idx = i         IMPORTING ev_c5 = ls_seg-to_c5   ).
      IF cur_bool = abap_true.
        ls_seg-status  = 'VAR'.
      ELSE.
        ls_seg-status  = 'YOK'.
      ENDIF.
      ls_seg-minutes = ( i - seg_beg ).
      CLEAR ls_seg-celltab.
      DATA ls_col TYPE lvc_s_scol.
      CLEAR ls_col.
      ls_col-fname = 'STATUS'.
      IF cur_bool = abap_true.
        ls_col-color-col = 5.   " yeşil
      ELSE.
        ls_col-color-col = 6.   " kırmızı
      ENDIF.
      ls_col-color-int = 1.
      ls_col-color-inv = 0.
      APPEND ls_col TO ls_seg-celltab.
      APPEND ls_seg TO lt_seg.

      " yeni segment başlat
      seg_beg = i.
      cur_bool = next_val.
    ENDIF.
  ENDDO.

  " Gün sonuna kadar son segmenti ekle (varsa)
  IF seg_beg <= total.
   me->idx_to_c5( EXPORTING iv_idx = seg_beg   IMPORTING ev_c5 = ls_seg-from_c5 ).
    " gün sonu boundary: 1440'ın bir sonrası= 24:00
    DATA end_plus TYPE i. end_plus = total + 1.   " 1441 -> '24:00'
 me->idx_to_c5( EXPORTING iv_idx = end_plus  IMPORTING ev_c5 = ls_seg-to_c5   ).
    IF cur_bool = abap_true.
      ls_seg-status  = 'VAR'.
    ELSE.
      ls_seg-status  = 'YOK'.
    ENDIF.
    ls_seg-minutes = ( end_plus - seg_beg ).
    CLEAR ls_seg-celltab.
    DATA ls_col2 TYPE lvc_s_scol.
    CLEAR ls_col2.
    ls_col2-fname = 'STATUS'.
    IF cur_bool = abap_true.
      ls_col2-color-col = 5.
    ELSE.
      ls_col2-color-col = 6.
    ENDIF.
    ls_col2-color-int = 1.
    ls_col2-color-inv = 0.
    APPEND ls_col2 TO ls_seg-celltab.
    APPEND ls_seg TO lt_seg.
  ENDIF.

  "-------- 6) Popup ALV (segment görünümü) --------
  IF mo_seg_grid IS BOUND.
    FREE mo_seg_grid.
  ENDIF.
  IF mo_seg_cont IS BOUND.
    FREE mo_seg_cont.
  ENDIF.

  " Başlık
  DATA nh TYPE n LENGTH 2. nh = start_h.
  DATA nm TYPE n LENGTH 2. nm = start_m.
  DATA cap TYPE c LENGTH 70.
  CONCATENATE 'Aralıklar (başlangıç: ' nh ':' nm ')'
         INTO cap SEPARATED BY space.

  CREATE OBJECT mo_seg_cont
    EXPORTING width = 600 height = 420 top = 120 left = 160 caption = cap.

  CREATE OBJECT mo_seg_grid
    EXPORTING i_parent = mo_seg_cont.

  " Field catalog
  DATA: lt_fcat TYPE lvc_t_fcat,
        ls_fcat TYPE lvc_s_fcat.
  CLEAR lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'FROM_C5'.
  ls_fcat-coltext   = 'Başlangıç'.
  ls_fcat-outputlen = 5.
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'TO_C5'.
  ls_fcat-coltext   = 'Bitiş'.
  ls_fcat-outputlen = 5.
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'STATUS'.
  ls_fcat-coltext   = 'Durum'.
  ls_fcat-outputlen = 5.
  APPEND ls_fcat TO lt_fcat.

  CLEAR ls_fcat.
  ls_fcat-fieldname = 'MINUTES'.
  ls_fcat-coltext   = 'Dakika'.
  ls_fcat-outputlen = 5.
  APPEND ls_fcat TO lt_fcat.

  " Layout: hücre rengi
  DATA ls_layo TYPE lvc_s_layo.
  CLEAR ls_layo.
  ls_layo-ctab_fname = 'CELLTAB'.

  CALL METHOD mo_seg_grid->set_table_for_first_display
    EXPORTING is_layout       = ls_layo
    CHANGING  it_outtab       = lt_seg
              it_fieldcatalog = lt_fcat.

  CALL METHOD cl_gui_cfw=>flush.
ENDMETHOD.

METHOD idx_to_c5.
  DATA l_idx TYPE i.
  IF iv_idx < 1.
    l_idx = 0.
  ELSE.
    l_idx = iv_idx - 1.
  ENDIF.

  DATA l_h TYPE i.
  DATA l_m TYPE i.
  l_h = l_idx DIV 60.
  l_m = l_idx MOD 60.

  DATA ch TYPE n LENGTH 2.
  DATA cm TYPE n LENGTH 2.
  ch = l_h.
  cm = l_m.

  CLEAR ev_c5.
  CONCATENATE ch ':' cm INTO ev_c5.
ENDMETHOD.








ENDCLASS.
