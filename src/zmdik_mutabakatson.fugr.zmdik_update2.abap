FUNCTION ZMDIK_UPDATE2.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_RECORD_ID) TYPE  NUM10 OPTIONAL
*"  CHANGING
*"     VALUE(ES_DATA) TYPE  ZMDIK_ODATA_STR OPTIONAL
*"----------------------------------------------------------------------
DATA: ls_data TYPE zmdik_odata_str.

  " Gelen verileri yerel yapıya aktar
  MOVE-CORRESPONDING es_data TO ls_data.

  " Kayıt güncelleme: DESCRIPTION ve AGREEMENT_STS alanlarını ls_data'dan alıp,
  " IV_RECORD_ID (record_id) üzerinden güncelliyoruz.
  UPDATE zmdik_mutabakat4
    SET description   = @ls_data-description,
        agreement_sts = @ls_data-agreement_sts
    WHERE id = @IV_RECORD_ID.

  IF sy-subrc <> 0.
*    RAISE update_error.
  ELSE.
    COMMIT WORK.
  ENDIF.




ENDFUNCTION.
