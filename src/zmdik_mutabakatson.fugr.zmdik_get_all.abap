FUNCTION ZMDIK_GET_ALL.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_RECORD_ID) TYPE  NUM10 OPTIONAL
*"  EXPORTING
*"     VALUE(ET_TABLE) TYPE  ZMUTABAKATSTR
*"     VALUE(ES_TABLE) TYPE  ZMDIK_ODATA_STR
*"----------------------------------------------------------------------
 DATA: lt_temp TYPE TABLE OF ZMDIK_ODATA_STR,
        ls_temp TYPE ZMDIK_ODATA_STR.

  IF iv_record_id IS INITIAL.
    " Tüm kayıtları getir
    SELECT * FROM zmdik_mutabakat4
      into corresponding fields of table lt_temp.
    IF sy-subrc <> 0 OR lt_temp IS INITIAL.
*      RAISE not_found.
    ENDIF.
    " Her kaydı ek bilgilerle zenginleştiriyoruz
    LOOP AT lt_temp ASSIGNING FIELD-SYMBOL(<fs_rec>).
      SELECT SINGLE butxt FROM t001
        INTO <fs_rec>-butxt
        WHERE bukrs = <fs_rec>-bukrs.
      SELECT SINGLE name1 FROM kna1
        INTO <fs_rec>-name1
        WHERE kunnr = <fs_rec>-kunnr.
      SELECT SINGLE email FROM zcust_mail
        INTO <fs_rec>-email
        WHERE kunnr = <fs_rec>-kunnr.
      " REC_MAIL bilgisi, verinin tutulduğu diğer tablodan çekiliyor (zmdik_mail_tablo)
      SELECT SINGLE EMAIL FROM zmdik_mail_tablo
        INTO <fs_rec>-rec_mail.
*      SELECT SINGLE description FROM zmdik_mutabakat4
*        INTO <fs_rec>-description
*        WHERE kunnr = <fs_rec>-kunnr.

      <fs_rec>-uname = sy-uname.
      <fs_rec>-authorizedp = 'YES'. " Varsayılan yetki durumu
    ENDLOOP.
    et_table = lt_temp.
  ELSE.
    " Belirtilen record_id'ye göre tek kayıt getir
    SELECT SINGLE * FROM zmdik_mutabakat4
      into corresponding fields of ls_temp
      WHERE id = iv_record_id.
    IF sy-subrc <> 0.
*      RAISE not_found.
    ENDIF.
    SELECT SINGLE butxt FROM t001
      INTO ls_temp-butxt
      WHERE bukrs = ls_temp-bukrs.
    SELECT SINGLE name1 FROM kna1
      INTO ls_temp-name1
      WHERE kunnr = ls_temp-kunnr.
    SELECT SINGLE email FROM zcust_mail
      INTO ls_temp-email
      WHERE kunnr = ls_temp-kunnr.
    SELECT SINGLE EMAIL FROM zmdik_mail_tablo
      INTO ls_temp-rec_mail.
*    SELECT SINGLE description FROM zmdik_mutabakat4
*      INTO ls_temp-description
*      WHERE kunnr = ls_temp-kunnr.
    ls_temp-uname       = sy-uname.
    ls_temp-authorizedp = 'YES'.
    es_table = ls_temp.
  ENDIF.




ENDFUNCTION.
