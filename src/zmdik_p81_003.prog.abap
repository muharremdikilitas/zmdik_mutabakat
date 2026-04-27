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
      control
        importing
          is_data         type zmdik_erec
        returning
          value(rv_check) type abap_bool.
    ENDCLASS.

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

        data: ls_row   type zmdik_erec,
              lt_upd   type standard table of zmdik_erec with default key,
              lv_ans   type c,
              lv_parnr type zmdik_erec-parnr.

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
          read table gt_data index lv_idx into ls_row.
          if sy-subrc = 0.
            lv_parnr = ls_row-parnr.   " <-- PARNR burada
          endif.
        endif.

        call function 'POPUP_TO_CONFIRM'
          exporting
            titlebar       = 'Silme Göstergesi'
            text_question  = |{ lv_parnr } numaralı kayıt için silme göstergesi X yapılsın mı?|
            text_button_1  = 'Evet'
            text_button_2  = 'Hayır'
            default_button = '2'
          importing
            answer         = lv_ans.

        if lv_ans <> '1'.
          return.
        endif.

        loop at lt_rows into lv_idx.
          read table gt_data index lv_idx into ls_row.
          if sy-subrc = 0.
            ls_row-loekz = 'X'.
            modify gt_data index lv_idx from ls_row.
            append ls_row to lt_upd.
          endif.
        endloop.

        if lt_upd is not initial.

          modify zmdik_erec from table lt_upd.
          if sy-subrc = 0.
            commit work and wait.
            message |{ lines( lt_upd ) } kayıt silindi | type 'S'.
          else.
            rollback work.
            message 'DB güncellemesi başarısız.' type 'S' display like 'E'.
          endif.
        endif.

        if me->mo_alv is bound.
          me->mo_alv->refresh( ).
        endif.
    endcase.
  endmethod.

METHOD f4_muhatap.
  DATA: lt_ret       TYPE STANDARD TABLE OF ddshretval WITH DEFAULT KEY,
        ls_ret       TYPE ddshretval,
        lv_val       TYPE zmdik_erec-accno,
        lt_dynp      TYPE STANDARD TABLE OF dynpread WITH DEFAULT KEY,
        ls_dynp      TYPE dynpread,
        lv_ptype_loc TYPE c.

  CLEAR: lt_ret, lv_val.

  " KOART: parametreden, boşsa ekrandan oku
  lv_ptype_loc = iv_ptype.
  TRANSLATE lv_ptype_loc TO UPPER CASE.
  IF lv_ptype_loc IS INITIAL.
    CLEAR lt_dynp.
    ls_dynp-fieldname = 'GS_EREC-KOART'.
    APPEND ls_dynp TO lt_dynp.
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname     = sy-repid
        dynumb     = sy-dynnr
      TABLES
        dynpfields = lt_dynp
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc = 0.
      READ TABLE lt_dynp INTO ls_dynp WITH KEY fieldname = 'GS_EREC-KOART'.
      IF sy-subrc = 0 AND ls_dynp-fieldvalue IS NOT INITIAL.
        lv_ptype_loc = ls_dynp-fieldvalue.
        TRANSLATE lv_ptype_loc TO UPPER CASE.
      ENDIF.
    ENDIF.
  ENDIF.

  " --- Tek F4: KOART=D -> DEBI/KNA1-KUNNR, KOART=K -> KRED/LFA1-LIFNR
  IF lv_ptype_loc = 'K'.         " Satıcı
    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
      EXPORTING
        tabname     = 'LFA1'
        fieldname   = 'LIFNR'
        searchhelp  = 'KRED'          " <-- YALNIZCA BU parametreler; SHLPTYPE/YALUE_ORG YOK
        dynpprog    = sy-repid
        dynpnr      = sy-dynnr
        dynprofield = 'GS_EREC-ACCNO'
      TABLES
        return_tab  = lt_ret
      EXCEPTIONS
        OTHERS      = 1.
  ELSE.                           " Müşteri (default)
    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
      EXPORTING
        tabname     = 'KNA1'
        fieldname   = 'KUNNR'
        searchhelp  = 'DEBI'
        dynpprog    = sy-repid
        dynpnr      = sy-dynnr
        dynprofield = 'GS_EREC-ACCNO'
      TABLES
        return_tab  = lt_ret
      EXCEPTIONS
        OTHERS      = 1.
  ENDIF.

  " Seçilen değeri program değişkenine de yaz (ekrana zaten yazıldı)
  IF lt_ret IS NOT INITIAL.
    CLEAR lv_val.
    READ TABLE lt_ret INTO ls_ret WITH KEY fieldname = 'KUNNR'.
    IF sy-subrc = 0 AND ls_ret-fieldval IS NOT INITIAL.
      lv_val = ls_ret-fieldval.
    ELSE.
      READ TABLE lt_ret INTO ls_ret WITH KEY fieldname = 'LIFNR'.
      IF sy-subrc = 0 AND ls_ret-fieldval IS NOT INITIAL.
        lv_val = ls_ret-fieldval.
      ELSE.
        READ TABLE lt_ret INTO ls_ret INDEX 1.
        IF sy-subrc = 0 AND ls_ret-fieldval IS NOT INITIAL.
          lv_val = ls_ret-fieldval.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_val IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING input  = lv_val
        IMPORTING output = lv_val.
      cv_muhatap    = lv_val.
      gs_erec-accno = lv_val.
      " NOT: DYNP_VALUES_UPDATE gerekmiyor; FIELD_VALUE_REQUEST alanı kendisi yazar.
    ENDIF.
  ENDIF.
ENDMETHOD.


 METHOD control.
  rv_check = abap_true.

  "=== SADECE E-POSTA ZORUNLU ===
  IF is_data-email IS INITIAL.
    MESSAGE 'E-posta adresi zorunludur' TYPE 'S' DISPLAY LIKE 'E'.
    rv_check = abap_false.
    RETURN.
  ENDIF.

  " E-posta format kontrolü (eğer girilmişse)
  DATA(lv_email) = |{ is_data-email }|.
  TRANSLATE lv_email TO LOWER CASE.
  FIND REGEX '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$' IN lv_email.
  IF sy-subrc <> 0.
    MESSAGE 'Geçersiz e-posta formatı' TYPE 'S' DISPLAY LIKE 'E'.
    rv_check = abap_false.
    RETURN.
  ENDIF.


  "=== Opsiyonel alanlar: sadece doluysa kontrol yapılır ===

  " Şirket kodu doluysa sistemde var mı kontrol et
  IF is_data-bukrs IS NOT INITIAL.
    SELECT SINGLE bukrs
      FROM t001
      INTO @DATA(lv_bukrs)
      WHERE bukrs = @is_data-bukrs.
    IF sy-subrc <> 0.
      MESSAGE 'Sistemde böyle bir şirket kodu yok' TYPE 'S' DISPLAY LIKE 'E'.
      rv_check = abap_false.
      RETURN.
    ENDIF.
  ENDIF.

" --- KOART + ACCNO opsiyonel kontrol (sadece ana veri: KNA1 / LFA1)
IF is_data-koart = 'D' AND is_data-accno IS NOT INITIAL.     " Müşteri
  " KUNNR var mı?
  SELECT SINGLE @abap_true
    FROM kna1
    WHERE kunnr = @is_data-accno
    INTO @DATA(lv_kna1_ok).
  IF sy-subrc <> 0 OR lv_kna1_ok IS INITIAL.
    MESSAGE 'Bu müşteri numarası (KUNNR) KNA1 ana veride yok.' TYPE 'S' DISPLAY LIKE 'E'.
    rv_check = abap_false.
    RETURN.
  ENDIF.

ELSEIF is_data-koart = 'K' AND is_data-accno IS NOT INITIAL. " Satıcı
  " LIFNR var mı?
  SELECT SINGLE @abap_true
    FROM lfa1
    WHERE lifnr = @is_data-accno
    INTO @DATA(lv_lfa1_ok).
  IF sy-subrc <> 0 OR lv_lfa1_ok IS INITIAL.
    MESSAGE 'Bu satıcı numarası (LIFNR) LFA1 ana veride yok.' TYPE 'S' DISPLAY LIKE 'E'.
    rv_check = abap_false.
    RETURN.
  ENDIF.
ENDIF.






  " Telefon doluysa sayısal kontrol
  IF is_data-telf1 IS NOT INITIAL.
    DATA(lv_phone) = |{ is_data-telf1 }|.
    REPLACE ALL OCCURRENCES OF REGEX '[^0-9]' IN lv_phone WITH ''.
    IF strlen( lv_phone ) < 11.
      MESSAGE 'Telefon en az 11 hane ve sadece rakam olmalı' TYPE 'S' DISPLAY LIKE 'E'.
      rv_check = abap_false.
      RETURN.
    ENDIF.
  ENDIF.

  " TC doluysa rakam ve 11 hane kontrolü
  IF is_data-tckid IS NOT INITIAL.
    FIND REGEX '[^0-9]' IN is_data-tckid.
    IF sy-subrc = 0.
      MESSAGE 'TC sadece rakamlardan oluşmalı!' TYPE 'S' DISPLAY LIKE 'E'.
      rv_check = abap_false.
      RETURN.
    ENDIF.
    IF strlen( is_data-tckid ) <> 11.
      MESSAGE 'TC 11 haneli olmalı!' TYPE 'S' DISPLAY LIKE 'E'.
      rv_check = abap_false.
      RETURN.
    ENDIF.
  ENDIF.

  " İsim doluysa format kontrolü
  IF is_data-ename IS NOT INITIAL.
    DATA(lv_name) = |{ is_data-ename }|.
    CONDENSE lv_name.
    FIND REGEX '\d' IN lv_name.
    IF sy-subrc = 0.
      MESSAGE 'İsim alanı rakam içeremez' TYPE 'S' DISPLAY LIKE 'E'.
      rv_check = abap_false.
      RETURN.
    ENDIF.

    FIND REGEX '^[A-Za-zÇĞİÖŞÜçğıöşü''\- ]+$' IN lv_name IGNORING CASE.
    IF sy-subrc <> 0.
      MESSAGE 'İsim yalnızca harf, boşluk, apostrof ve tire içerebilir' TYPE 'S' DISPLAY LIKE 'E'.
      rv_check = abap_false.
      RETURN.
    ENDIF.
  ENDIF.

ENDMETHOD.




endclass.
