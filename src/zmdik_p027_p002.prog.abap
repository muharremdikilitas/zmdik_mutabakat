*&---------------------------------------------------------------------*
*& Include          ZMDIK_P027_P002
*&---------------------------------------------------------------------*

gs_kullanici-k_no = k_no.
gs_kullanici-k_adi = k_adi.
gs_kullanici-k_sifre = k_sifre.


IF sy-subrc = 0.

  MESSAGE |Kayıt başarıyla eklendi { gs_kullanici-k_no } | TYPE 'I'.
  gs_data-k_no = sy-index.
  gs_data-log_date = sy-datum.
  gs_data-log_time = sy-uzeit.
  gs_data-user_name = sy-uname.
  gs_data-log_result = ' '.
  gs_data-k_no = k_no.
INSERT zmdik_log from gs_data.
  ELSE.
    MESSAGE |Kayıt eklenemedi { gs_kullanici-k_no } | TYPE 'I'.
      gs_data-k_no = sy-index.
  gs_data-log_date = sy-datum.
  gs_data-log_time = sy-uzeit.
  gs_data-user_name = sy-uname.
  gs_data-log_result = 'X'.
  gs_data-k_no = k_no.
ENDIF.

INSERT zmdik_log from gs_data.
