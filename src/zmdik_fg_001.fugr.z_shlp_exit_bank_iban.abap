FUNCTION z_shlp_exit_bank_iban.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"      DYNPFIELDS STRUCTURE  DYNPREAD OPTIONAL
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) TYPE  DDSHF4CTRL
*"  EXCEPTIONS
*"     NO_RECORDS
*"----------------------------------------------------------------------

  " 0) Gereksiz çağrılarda hemen çık
  IF callcontrol-step <> 'SELONE'
   AND callcontrol-step <> 'PRESEL'
   AND callcontrol-step <> 'SELECT'
   AND callcontrol-step <> 'DISP'
   AND callcontrol-step <> 'RETURN'.
    EXIT.
  ENDIF.

  " 1) (Ops.) Kollektif SH
  IF callcontrol-step = 'SELONE'.
    EXIT.
  ENDIF.

  " 2) (Ops.) PRESEL
  IF callcontrol-step = 'PRESEL'.
    " callcontrol-step = 'SELECT'. " Diyaloğu atlamak istersen
    EXIT.
  ENDIF.

  " 3) SELECT: Veriyi sen getir, record_tab'ı doldur
  IF callcontrol-step = 'SELECT'.

    " SHLP-INTERFACE ile aynı isimler
    TYPES: BEGIN OF ty_row,
             bukrs TYPE zeho_t002-bukrs,
             bankc TYPE zeho_t002-bankc,
             hktid TYPE zeho_t002-hktid,
             iban  TYPE zeho_t002-iban,
             waers TYPE zeho_t002-waers,
           END OF ty_row.

    DATA lt_rows TYPE STANDARD TABLE OF ty_row.

    " Bellekten okunacak ham (string) alanlar
    DATA: lv_bukrs_mem  TYPE string,
          lv_bankc_mem  TYPE string.

    " Sorguda kullanılacak tipli alanlar
    DATA: lv_bukrs TYPE bukrs,
          lv_bankc TYPE bankl.

    " --- Mismatch'a dayanıklı IMPORT (önce string’e çek)
    TRY.
        " Export tarafında 'LV_BUKRS' ismiyle yazıldıysa:
        IMPORT lv_bukrs = lv_bukrs_mem FROM MEMORY ID 'Z_SELECTED_BUKRS'.
      CATCH cx_sy_import_mismatch_error.
        CLEAR lv_bukrs_mem.
    ENDTRY.

    TRY.
        IMPORT lv_bankc = lv_bankc_mem FROM MEMORY ID 'Z_SELECTED_BANKC'.
      CATCH cx_sy_import_mismatch_error.
        CLEAR lv_bankc_mem.
    ENDTRY.

    " String → hedef tipe dönüştür (boş değilse)
    IF lv_bukrs_mem IS NOT INITIAL.
      lv_bukrs = CONV bukrs( lv_bukrs_mem ).
    ENDIF.
    IF lv_bankc_mem IS NOT INITIAL.
      lv_bankc = CONV bankl( lv_bankc_mem ).
    ENDIF.

    " (Ops.) PRESEL'den SELOPT oku (boşsa tamamla)
    DATA ls_opt TYPE ddshselopt.
    IF lv_bukrs IS INITIAL.
      READ TABLE shlp-selopt INTO ls_opt WITH KEY shlpfield = 'BUKRS'.
      IF sy-subrc = 0 AND ls_opt-low IS NOT INITIAL.
        lv_bukrs = CONV bukrs( ls_opt-low ).
      ENDIF.
    ENDIF.
    IF lv_bankc IS INITIAL.
      READ TABLE shlp-selopt INTO ls_opt WITH KEY shlpfield = 'BANKC'.
      IF sy-subrc = 0 AND ls_opt-low IS NOT INITIAL.
        lv_bankc = CONV bankl( ls_opt-low ).
      ENDIF.
    ENDIF.

    " 4 senaryo filtre
    IF lv_bukrs IS NOT INITIAL AND lv_bankc IS NOT INITIAL.
      SELECT bukrs, bankc, hktid, iban, waers
        FROM zeho_t002
        INTO TABLE @lt_rows
        WHERE bukrs = @lv_bukrs
          AND bankc = @lv_bankc.
    ELSEIF lv_bukrs IS NOT INITIAL.
      SELECT bukrs, bankc, hktid, iban, waers
        FROM zeho_t002
        INTO TABLE @lt_rows
        WHERE bukrs = @lv_bukrs.
    ELSEIF lv_bankc IS NOT INITIAL.
      SELECT bukrs, bankc, hktid, iban, waers
        FROM zeho_t002
        INTO TABLE @lt_rows
        WHERE bankc = @lv_bankc.
    ELSE.
      SELECT bukrs, bankc, hktid, iban, waers
        FROM zeho_t002
        INTO TABLE @lt_rows
        UP TO 200 ROWS.
    ENDIF.

    IF lt_rows IS INITIAL.
      RAISE no_records.
    ENDIF.

    " Listeyi SHLP-INTERFACE'e göre map et
    CALL FUNCTION 'F4UT_RESULTS_MAP'
      EXPORTING
        source_structure   = ''          " INTERFACE adları eşleşiyor
        apply_restrictions = ' '
      TABLES
        shlp_tab           = shlp_tab
        source_tab         = lt_rows
        record_tab         = record_tab
      CHANGING
        shlp               = shlp
        callcontrol        = callcontrol.

    callcontrol-step = 'DISP'.
    EXIT.
  ENDIF.

  " 4) (Ops.) DISP
  IF callcontrol-step = 'DISP'.
    EXIT.
  ENDIF.

  " 5) RETURN: seçilen değeri ek alanlara basmak istersen
  IF callcontrol-step = 'RETURN'.
    DATA ls_hit TYPE seahlpres.
    READ TABLE record_tab INTO ls_hit INDEX 1.
    IF sy-subrc = 0.
      DATA: lt_dynp TYPE STANDARD TABLE OF dynpread,
            ls_dynp TYPE dynpread.

      CLEAR ls_dynp.
      ls_dynp-fieldname  = 'GV_IBAN'.       " hedef ekran alanın
      ls_dynp-fieldvalue = ls_hit-string.   " gerekirse burada parse et
      APPEND ls_dynp TO lt_dynp.

      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          dyname     = sy-cprog    " veya sabit ekran adı
          dynumb     = sy-dynnr
        TABLES
          dynpfields = lt_dynp.
    ENDIF.
    EXIT.
  ENDIF.

ENDFUNCTION.
