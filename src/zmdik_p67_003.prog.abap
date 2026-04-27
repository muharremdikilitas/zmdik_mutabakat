*&---------------------------------------------------------------------*
*& Include          ZMDIK_P67_003
*&---------------------------------------------------------------------*



TYPES: BEGIN OF ty_kunnr_range,
         low  TYPE kunnr,
         high TYPE kunnr,
       END OF ty_kunnr_range.

DATA: lt_kunnr       TYPE TABLE OF kunnr,     " KUNNR alanı için bir tablo
      lt_kunnr_range TYPE TABLE OF ty_kunnr_range,  " SELECT-OPTIONS aralığı
      ls_kunnr_range TYPE ty_kunnr_range,           " Tek bir aralık
      lv_low         TYPE kunnr,
      lv_high        TYPE kunnr.

" SELECT-OPTIONS aralığını almak
LOOP AT p_kunnr INTO DATA(ls_kunnr).
  CLEAR ls_kunnr_range.
  ls_kunnr_range-low = ls_kunnr-low.
  ls_kunnr_range-high = ls_kunnr-high.
  APPEND ls_kunnr_range TO lt_kunnr_range.
ENDLOOP.


DATA: lv_number TYPE num10.  " Numara almak için uygun veri tipi


LOOP AT lt_kunnr_range into ls_kunnr_range.
CLEAR gt_keybalance.



SELECT kunnr
  into TABLE lt_kunnr
  FROM kna1
  where kunnr BETWEEN ls_kunnr_range-low and ls_kunnr_range-high.

  "BAPI çağrısı her aralık için yapılır
  LOOP AT lt_kunnr INTO data(lv_kunnr).
          CALL FUNCTION 'BAPI_AR_ACC_GETKEYDATEBALANCE'
            EXPORTING
              companycode        = p_bukrs
              customer           = lv_kunnr     "low değeri kullanıyor
              keydate            =  p_tarih
             BALANCESPGLI       = 'X'
             NOTEDITEMS         = ' '
            TABLES
              keybalance         = gt_keybalance.

  LOOP AT gt_keybalance INTO ls_keybalance.
      CLEAR gs_data.

      "temel verileri ata
      gs_data-kunnr             = lv_kunnr.
      gs_data-gjahr             = p_tarih(4).
      gs_data-monat             = p_tarih+4(2).
      gs_data-bukrs             = p_bukrs.
      gs_data-oedk_bakiye       = gs_keybalance-lc_bal.
      gs_data-oedk              = gs_keybalance-sp_gl_ind.
      gs_data-bakiye            = gs_keybalance-t_curr_bal.
      gs_data-waers             = gs_keybalance-currency.
      gs_data-upb_bakiye        = gs_keybalance-lc_bal_long.
      gs_data-upb_waers         = gs_keybalance-loc_currcy.
      gs_data-detay             = '@3B@'.


      "T074T tablosundan ÖDK açıklaması al

      SELECT SINGLE ltext into gs_data-oedk_txt
        FROM t074t
        WHERE shbkz = gs_keybalance-sp_gl_ind
        and spras = 'T'.



            " ÖDK göstergesine göre tanıtıcı belirle
      gs_data-tanitici = COND string( WHEN gs_keybalance-sp_gl_ind IS NOT INITIAL
                                      THEN 'Müşteri ÖDK Bakiyesi'
                                      ELSE 'Müşteri Bakiyesi' ).

      " SHKZG domaininden açıklama al
      CALL FUNCTION 'DD_DOMVALUES_GET'
        EXPORTING
          domname        = 'SHKZG' " SHKZG domain adı
          text           = abap_true
        TABLES
          dd07v_tab      = gt_dd07l_tab " DD07L tablosu
        EXCEPTIONS
          wrong_textflag = 1
          OTHERS         = 2.


      IF sy-subrc = 0.
        LOOP AT gt_dd07l_tab INTO gs_dd07l.
          IF gs_dd07l-domvalue_l = gs_keybalance-db_cr_ind. " Burada VALUE doğru alan adı
            gv_shkzg_txt = gs_dd07l-ddtext.          " ddtext doğru açıklama alanı
          ENDIF.
        ENDLOOP.
      ENDIF.

      gs_data-tanim = gv_shkzg_txt.




  ENDLOOP.












  ENDLOOP.





ENDLOOP.
