*&---------------------------------------------------------------------*
*& Report ZMDIK_P019
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P019.

DATA: hasta_tc TYPE ZMDIK_DETC,
      HASTA_AD TYPE ZMDIK_DEAD,
      HASTA_SOYAD TYPE ZMDIK_DESOYAD,
      DOGUM_TARIHI TYPE ZMDIK_DEDOGUMTARIHI,
      DOGUM_SEHRI TYPE  ZMDIK_DEDOGUMSEHRI,
      POLIKLINIK TYPE   ZMDIK_DEPOLIKLINIK,
      KAYIT_TARIHI TYPE  ZMDIK_DEKAYITTARIHI,
      KAYIT_SAATI TYPE   ZMDIK_DEKAYITSAATI,
      DOKTOR TYPE        ZMDIK_DEDOKTOR.

    data: gs_hasta TYPE zmdik_p001,
          gt_hasta TYPE table of zmdik_p001.

    gs_hasta-hasta_ad = 'Hakan'.
    gs_hasta-hasta_soyad = 'Dikilitaş'.
    gs_hasta-hasta_tc = '12345678911'.
    gs_hasta-dogum_sehri = 'Kayseri'.
    gs_hasta-dogum_tarihi = '1994.04.24'.
    gs_hasta-doktor = 'Ahmet'.
    gs_hasta-kayit_saati = '10:11:22'.
    gs_hasta-kayit_tarihi = '26.01.2025'.
    gs_hasta-poliklinik = 'A'.

  insert zmdik_p001 FROM gs_hasta.
