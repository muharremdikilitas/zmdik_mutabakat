*&---------------------------------------------------------------------*
*& Report ZMDIK_P010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmdik_p010.
DATA: gv_persid    TYPE zmdik_persid_de,
      gv_persad    TYPE zmdik_persad_de,
      gv_perssoyad TYPE zmdik_persad_de,
      gv_perscins  TYPE zmdik_perscins_de,
      gs_pers_t    TYPE zmdik_pers_t,
      gt_pers_t    TYPE TABLE OF zmdik_pers_t,
      gt_pers_t2   TYPE TABLE OF zmdik_pers_t.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE lv_title.





  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(8) TEXT-001.
    PARAMETERS         p_id    TYPE zmdik_persid_de.

  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(8) tp2.
    PARAMETERS         p_ad    TYPE zmdik_persad_de.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(8) tp3.
    PARAMETERS         p_soyad TYPE zmdik_persad_de.

  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(8) tp4.
    PARAMETERS         p_pcins TYPE zmdik_perscins_de.

  SELECTION-SCREEN END OF LINE.


  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE lv_tit2.
    SELECTION-SCREEN BEGIN OF LINE.

      PARAMETERS insertt RADIOBUTTON GROUP gr1 USER-COMMAND gr1 DEFAULT 'X'.

      SELECTION-SCREEN COMMENT (20) t1.
      PARAMETERS    updatee RADIOBUTTON GROUP gr1.
      SELECTION-SCREEN COMMENT (20) t2.
      PARAMETERS       deletee RADIOBUTTON GROUP gr1.
      SELECTION-SCREEN COMMENT (20) t3.
      PARAMETERS       modifyy RADIOBUTTON GROUP gr1.
      SELECTION-SCREEN COMMENT (20) t4.
    SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  lv_tit2 = 'Kullanıcı Bilgileri'.
  t1 = 'İnsert'.
  t2 = 'Update'.
  t3 = 'Delete'.
  t4 = 'Modify'.
*tp1 = 'ID'.
  tp2 = 'AD'.
  tp3 = 'SOYAD'.
  tp4 = 'CİNSİYET'.

START-OF-SELECTION.

*  CASE sy-ucomm.
*
*      WHEN 'gr1'.

  gs_pers_t-pers_id = p_id .
  gs_pers_t-pers_ad = p_ad.
  gs_pers_t-pers_soyad = p_soyad.
  gs_pers_t-pers_cins = p_pcins.

  IF insertt = 'X'.
    INSERT zmdik_pers_t FROM gs_pers_t.
    IF sy-subrc = 0.
      WRITE / 'Kayıt başarıyla eklendi.'.
    ELSE.
      WRITE / 'Kayıt eklenemedi daha önce kayıtlı olabilir.'.
    ENDIF.



  ELSEIF updatee = 'X'.
    UPDATE zmdik_pers_t FROM gs_pers_t.
    IF sy-subrc = 0.
      WRITE / 'Kayıt başarıyla güncellendi.'.
    ELSE.
      WRITE / 'Kayıt başarıyla güncellenemedi.'.
    ENDIF.

  ELSEIF deletee = 'X'.
    DELETE zmdik_pers_t FROM gs_pers_t.
    IF sy-subrc = 0.
      WRITE / 'Kayıt başarıyla silindi.'.
    ELSE.
      WRITE / 'Kayıt başarıyla silinemedi.'.
    ENDIF.

  ELSEIF  modifyy = 'X'.
    MODIFY zmdik_pers_t FROM gs_pers_t.
    IF sy-subrc = 0.
      WRITE 'Kayıt başarıyla modify oldu.'.
    ELSE.
      WRITE 'Kayıt modify olamadı.'.
    ENDIF.
  ENDIF.

  SELECT * from zmdik_pers_t into table  gt_pers_t2 .
  IF sy-subrc = 0.
    cl_demo_output=>display( gt_pers_t2 ).
  ELSE.
    WRITE: / 'Tablo boş veya veriler getirilemedi.'.
  ENDIF.


*  ENDCASE.

*START-OF-SELECTION.
*
*IF insertt = 'X'.
*  WRITE: / 'Insert seçildi.'.
*ELSEIF updatee = 'X'.
*  WRITE: / 'Update seçildi.'.
*ELSEIF deletee = 'X'.
*  WRITE: / 'Delete seçildi.'.
*ELSEIF modifyy = 'X'.
*  WRITE: / 'Modify seçildi.'.
*ELSE.
*  WRITE: / 'Hiçbir seçenek seçilmedi.'.
*ENDIF.
