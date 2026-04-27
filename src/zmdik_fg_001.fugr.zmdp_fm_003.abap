FUNCTION ZMDP_FM_003.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------


  CONSTANTS: c_shlp_sender   TYPE shlpname VALUE 'ZSH_SND_BANK',
             c_shlp_receiver TYPE shlpname VALUE 'ZSH_RCV_BANK'.

  DATA(lv_is_sender)   = xsdbool( shlp-shlpname = c_shlp_sender ).
  DATA(lv_is_receiver) = xsdbool( shlp-shlpname = c_shlp_receiver ).

  " İlgili adımlar dışında çık
  IF callcontrol-step <> 'SELONE'
   AND callcontrol-step <> 'PRESEL'
   AND callcontrol-step <> 'SELECT'
   AND callcontrol-step <> 'DISP'
   AND callcontrol-step <> 'RETURN'.
    EXIT.
  ENDIF.

  "----------------------------- PRESEL ------------------------------
  " Alıcı SH’de, gönderen bankayı DB filtresine NE olarak ekle
  IF callcontrol-step = 'PRESEL' AND lv_is_receiver = abap_true.

    " 1) Gönderen bankayı ABAP Memory’den al
    DATA lv_sender_bankc_mem TYPE string.
    TRY.
        IMPORT lv_bankc = lv_sender_bankc_mem FROM MEMORY ID 'Z_SND_BANKC'.
      CATCH cx_sy_import_mismatch_error.
        CLEAR lv_sender_bankc_mem.
    ENDTRY.

    IF lv_sender_bankc_mem IS NOT INITIAL.
      " 2) İç format (ALPHA INPUT)
      DATA lv_sender_bankc_int TYPE zeho_t002-bankc.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING input  = lv_sender_bankc_mem
        IMPORTING output = lv_sender_bankc_int.

      " 3) BANKC NE <sender> satırını SELOPT'a ekle
      DATA ls_opt TYPE ddshselopt.
      CLEAR ls_opt.
      ls_opt-shlpfield = 'BANKC'.
      ls_opt-sign      = 'I'.
      ls_opt-option    = 'NE'.
      ls_opt-low       = lv_sender_bankc_int.

      APPEND ls_opt TO shlp-selopt.
      " Not: Dilersen daha önce eklenmiş aynı NE satırı varsa eklememek için
      " READ TABLE ... WITH KEY shlpfield='BANKC' option='NE' low=... kontrolü ekleyebilirsin.
    ENDIF.

    " Standart akış devam etsin (SELECT'e geçilecek)
    EXIT.
  ENDIF.

  "------------------------------ SELECT -----------------------------
  " İstersen burada custom liste üretebilirsin; gerek yoksa EXIT
  IF callcontrol-step = 'SELECT'.
    " Standart seçim çalışsın
    EXIT.
  ENDIF.

  "------------------------------- DISP ------------------------------
  IF callcontrol-step = 'DISP'.
    EXIT.
  ENDIF.

  "------------------------------ RETURN -----------------------------
  " Gönderen SH’de: seçilen bankayı hafızaya yaz (alıcıda gizlemek için)
  IF callcontrol-step = 'RETURN' AND lv_is_sender = abap_true.

    " BANKC'yi güvenle al (önce parametreyle dene, olmazsa stringten ayıkla)
    DATA lv_bankc_sel TYPE string.

    CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
      EXPORTING parameter = 'BANKC'
      IMPORTING value     = lv_bankc_sel
        TABLES    shlp_tab  = shlp_tab
                record_tab = record_tab
      CHANGING  shlp      = shlp
                callcontrol = callcontrol

      EXCEPTIONS
        parameter_unknown     = 1
        illegal_value_request = 2
        OTHERS                = 3.

    IF sy-subrc <> 0 OR lv_bankc_sel IS INITIAL.
      " Fallback: ilk token bankc kabul (listede BANKC baştaysa)
      READ TABLE record_tab INDEX 1 INTO DATA(ls_hit).
      IF sy-subrc = 0.
        SPLIT ls_hit-string AT space INTO lv_bankc_sel DATA(dummy).
      ENDIF.
    ENDIF.

    IF lv_bankc_sel IS NOT INITIAL.
      EXPORT lv_bankc = lv_bankc_sel TO MEMORY ID 'Z_SND_BANKC'.
    ENDIF.

    EXIT.
  ENDIF.


ENDFUNCTION.
