FUNCTION zmdp_fm_001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

  " 1) Görünecek alanlar
  TYPES: BEGIN OF ty_buk_bankt,
           bankc TYPE zeho_t002-bankc,
           bankt TYPE zeho_t001-bankt,
         END OF ty_buk_bankt.

  DATA: lt_result    TYPE STANDARD TABLE OF ty_buk_bankt WITH EMPTY KEY,
        ls_result    TYPE ty_buk_bankt,
        ls_seahlpres TYPE seahlpres.

  " Gereksiz adımlarda çık
  IF callcontrol-step <> 'SELONE'
   AND callcontrol-step <> 'PRESEL'
   AND callcontrol-step <> 'SELECT'
   AND callcontrol-step <> 'DISP'
   AND callcontrol-step <> 'RETURN'.
    EXIT.
  ENDIF.

  IF callcontrol-step = 'SELONE'.
    EXIT.
  ENDIF.

  IF callcontrol-step = 'PRESEL'.
    EXIT.
  ENDIF.

  "----------------------------------------------------------------------
  " SELECT
  "----------------------------------------------------------------------
  IF callcontrol-step = 'SELECT'.

    " --- Şirket kodu (filtre)
    DATA lv_bukrs_mem TYPE string.
    TRY.
        IMPORT lv_bukrs = lv_bukrs_mem FROM MEMORY ID 'Z_SELECTED_BUKRS'.
      CATCH cx_sy_import_mismatch_error.
        CLEAR lv_bukrs_mem.
    ENDTRY.

    " --- Sadece bir kez gizlenecek banka (geçici)
    DATA lv_bankc_excl_mem TYPE string.
    TRY.
        IMPORT lv_bankc = lv_bankc_excl_mem FROM MEMORY ID 'Z_EXCLUDE_BANKC_ONCE'.
      CATCH cx_sy_import_mismatch_error.
        CLEAR lv_bankc_excl_mem.
    ENDTRY.

    " --- Veriyi çek
    IF lv_bukrs_mem IS NOT INITIAL.
      SELECT DISTINCT a~bankc,
                      b~bankt
        FROM zeho_t002 AS a
        INNER JOIN zeho_t001 AS b ON a~bankc = b~bankc
        INTO TABLE @lt_result
        WHERE a~bukrs = @lv_bukrs_mem.
    ELSE.
      SELECT DISTINCT a~bankc,
                      b~bankt
        FROM zeho_t002 AS a
        INNER JOIN zeho_t001 AS b ON a~bankc = b~bankc
        INTO TABLE @lt_result.
    ENDIF.

    " --- Bir kerelik gizleme (ALPHA IN ile normalize ederek)
    IF lv_bankc_excl_mem IS NOT INITIAL AND lt_result IS NOT INITIAL.
      DATA lv_bankc_excl_int TYPE zeho_t002-bankc.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING input  = lv_bankc_excl_mem
        IMPORTING output = lv_bankc_excl_int.
      DELETE lt_result WHERE bankc = lv_bankc_excl_int.

      " Bu gizleme sadece BİR SONRAKİ F4 için geçerli olsun:
      FREE MEMORY ID 'Z_EXCLUDE_BANKC_ONCE'.
    ENDIF.

    IF lt_result IS INITIAL.
      RAISE no_records.
    ENDIF.

    " --- Hit list'i doldur (manual string)
    LOOP AT lt_result INTO ls_result.
      CLEAR ls_seahlpres.
      ls_seahlpres-string    = |{ ls_result-bankc ALPHA = OUT WIDTH = 5 }{ ls_result-bankt WIDTH = 40 }|.
      ls_seahlpres-pack_no   = sy-tabix.
      ls_seahlpres-pack_kind = 'S'.
      APPEND ls_seahlpres TO record_tab.
    ENDLOOP.

    callcontrol-step = 'DISP'.
    RETURN.
  ENDIF.

  "----------------------------------------------------------------------
  " DISP
  "----------------------------------------------------------------------
  IF callcontrol-step = 'DISP'.
    EXIT.
  ENDIF.

  "----------------------------------------------------------------------
  " RETURN
  "----------------------------------------------------------------------
  IF callcontrol-step = 'RETURN'.

    " Kullanıcının seçtiği satır → BANKC'yi ayıkla
    READ TABLE record_tab INDEX 1 INTO DATA(ls_selected).
    IF sy-subrc = 0.
      DATA lv_bankc_sel TYPE string.
      SPLIT ls_selected-string AT space INTO lv_bankc_sel DATA(dummy).

      " 1) Kalıcı: Diğer SH'ler (ör. HKTID) bu BANKC ile filtre yapsın
      EXPORT lv_bankc = lv_bankc_sel TO MEMORY ID 'Z_SELECTED_BANKC'.

      " 2) Geçici: Bir SONRAKİ F4'te bu bankayı GİZLE,
      "    SELECT adımında okunup FREE edilecek
      EXPORT lv_bankc = lv_bankc_sel TO MEMORY ID 'Z_EXCLUDE_BANKC_ONCE'.
    ENDIF.

    EXIT.
  ENDIF.

ENDFUNCTION.
