  FUNCTION ZMDIK_MTBK_INSERTDATA.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_KUNNR) TYPE  KUNNR OPTIONAL
*"  CHANGING
*"     VALUE(ES_TABLE) TYPE  ZMDIK_MUTAKABAT OPTIONAL
*"     VALUE(ET_TABLE) TYPE  ZMDIK_MUTAKANBAT_DE OPTIONAL
*"----------------------------------------------------------------------
*data: gs_mtbk type zmdik_mutakabat.
*
*
*select single * from zmdik_mutakabat into es_table where bukrs = p_bukrs.
*data: ls_mtbk type zmdik_mutakabat.
*  SELECT SINGLE * FROM zmdik_mutakabat
*     into ls_mtbk
*      WHERE bukrs = iv_str-bukrs.
*    MOVE-CORRESPONDING iv_str to es_table.
*
*      es_table-mtb_durum_acikla = iv_str-mtb_durum_acikla.
*      es_table-odk_text = iv_str-odk_text.
*
*      MODIFY zmdik_mutakabat FROM iv_str.

data : gs_str TYPE zmdik_mutakabat.

SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_str
  FROM zmdik_mutakabat
  WHERE kunnr = p_kunnr
    AND bukrs = es_table-bukrs
  and   yıl = es_table-yil
  and  odk_text = es_table-odk_text
  and  ay = es_table-ay.

*select single * into gs_str from zmdik_mutakabat where p_kunnr = kunnr and p_bukrs = bukrs.

  IF es_table-ay <> gs_str-ay.
      gs_str-ay = es_table-ay.
  ENDIF.

  IF es_table-bukrs <> gs_str-bukrs.
      gs_str-bukrs = es_table-bukrs.
  ENDIF.
  IF es_table-kunnr <> gs_str-kunnr.
      gs_str-kunnr = es_table-kunnr.
  ENDIF.

    IF es_table-borc_alacak <> gs_str-borc_alacak.
      gs_str-borc_alacak = es_table-borc_alacak.
  ENDIF.

  IF es_table-borc_alacak_text <> gs_str-borc_alacak_text.
      gs_str-borc_alacak_text = es_table-borc_alacak_text.
  ENDIF.

  IF es_table-butxt <> gs_str-butxt.
      gs_str-butxt = es_table-butxt.
  ENDIF.
    IF es_table-detay <> gs_str-detay.
      gs_str-detay = es_table-detay.
  ENDIF.


  IF es_table-intro_text <> gs_str-intro_text.
      gs_str-intro_text = es_table-intro_text.
  ENDIF.
  IF es_table-ktext <> gs_str-ktext.
      gs_str-ktext = es_table-ktext.
  ENDIF.
  IF es_table-mail <> gs_str-mail.
      gs_str-mail = es_table-mail.
  ENDIF.
  IF es_table-mandt <> gs_str-mandt.
      gs_str-mandt = es_table-mandt.
  ENDIF.
  IF es_table-mtb_durum_acikla <> gs_str-mtb_durum_acikla.
      gs_str-mtb_durum_acikla = es_table-mtb_durum_acikla.
  ENDIF.
  IF es_table-musteri_bakiye <> gs_str-musteri_bakiye.
      gs_str-musteri_bakiye = es_table-musteri_bakiye.
  ENDIF.
  IF es_table-musteri_bakiyepb <> gs_str-musteri_bakiyepb.
      gs_str-musteri_bakiyepb = es_table-musteri_bakiyepb.
  ENDIF.
  IF es_table-musteri_bakiyepb2 <> gs_str-musteri_bakiyepb2.
      gs_str-ay = es_table-ay.
  ENDIF.
     IF es_table-mutabat_durum <> gs_str-mutabat_durum.
      gs_str-mutabat_durum = es_table-mutabat_durum.
  ENDIF.

  IF es_table-name1 <> gs_str-name1.
      gs_str-name1 = es_table-name1.
  ENDIF.

  IF es_table-odk_gost <> gs_str-odk_gost.
      gs_str-odk_gost = es_table-odk_gost.
  ENDIF.

  IF es_table-odk_text <> gs_str-odk_text.
      gs_str-odk_text = es_table-odk_text.
  ENDIF.
  IF es_table-smtp_addr <> gs_str-smtp_addr.
      gs_str-smtp_addr = es_table-smtp_addr.
  ENDIF.
    IF es_table-stcd1 <> gs_str-stcd1.
      gs_str-stcd1 = es_table-stcd1.
  ENDIF.
    IF es_table-tarih <> gs_str-tarih.
      gs_str-tarih = es_table-tarih.
  ENDIF.
    IF es_table-ulke <> gs_str-ulke.
      gs_str-ulke = es_table-ulke.
  ENDIF.
    IF es_table-upb_bakiye <> gs_str-upb_bakiye.
      gs_str-upb_bakiye = es_table-upb_bakiye.
  ENDIF.
    IF es_table-upb_para_birimi <> gs_str-upb_para_birimi.
      gs_str-upb_para_birimi = es_table-upb_para_birimi.
  ENDIF.
  IF es_table-vergi_daire <> gs_str-vergi_daire.
      gs_str-vergi_daire = es_table-vergi_daire.
  ENDIF.
  IF es_table-y_kisi <> gs_str-y_kisi.
      gs_str-y_kisi = es_table-y_kisi.
  ENDIF.
    IF es_table-yil <> gs_str-yil.
      gs_str-yil = es_table-yil.
  ENDIF.



modify zmdik_mutakabat from gs_str.
IF sy-subrc = 0.
COMMIT WORK.
ENDIF.











*MOVE-CORRESPONDING es_table to gs_mtbk.

*gs_mtbk-stcd1 = es_table-stcd1.
*gs_mtbk-bukrs = es_table-bukrs.
*gs_mtbk-name1 = es_table-name1.
*gs_mtbk-upb_bakiye = es_table-upb_bakiye.
*gs_mtbk-upb_para_birimi = es_table-upb_para_birimi.
*gs_mtbk-mail = es_table-mail.
*gs_mtbk-tarih = es_table-tarih.
*gs_mtbk-y_kisi = es_table-y_kisi.

*gs_mtbk-smtp_addr = es_table-smtp_addr.










ENDFUNCTION.
