*&---------------------------------------------------------------------*
*& Include          ZMDIK_P066_003
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.

  DATA: lt_join TYPE STANDARD TABLE OF ty_join,
        ls_join TYPE ty_join,
        lv_borc TYPE wrbtr.

  CLEAR gt_list.

  "― 3.1 Müşteri + şirket kodu JOIN ―
  SELECT
         b~bukrs,
         a~kunnr,
         a~name1
    INTO TABLE @lt_join
    FROM  kna1 AS a
    INNER JOIN knb1 AS b
      ON  a~kunnr = b~kunnr
    WHERE a~kunnr IN @s_kunnr
      AND b~bukrs IN @s_bukrs.

  "― 3.2 Her satır için borcu topla ―
  LOOP AT lt_join INTO ls_join.
    SELECT SUM( wrbtr ) INTO @lv_borc
      FROM bsid
      WHERE kunnr = @ls_join-kunnr
        AND bukrs = @ls_join-bukrs
        AND budat IN @s_fdate.

    "Sadece borçlular istendiyse kontrol et
    IF p_debt = 'X' AND lv_borc IS INITIAL.
      CONTINUE.
    ENDIF.

    ls_join-borc = lv_borc.
    ls_join-mail = ''.        "Gerçek sistemde ADR6'dan alınır
    ls_join-risk = 'A'.       "Örnek değer

    APPEND ls_join TO gt_list.
  ENDLOOP.

ENDFORM.                    "get_data




FORM build_fcat.

  CLEAR gt_fcat.

  PERFORM add_col USING 'KUNNR' 'Müşteri No'.
  PERFORM add_col USING 'NAME1' 'Müşteri Adı'.
  PERFORM add_col USING 'BORC'  'Toplam Borç'.
  PERFORM add_col USING 'MAIL'  'E-posta'.
  PERFORM add_col USING 'RISK'  'Risk'.

ENDFORM.

FORM add_col USING iv_field iv_text.
  CLEAR gs_fcat.
  gs_fcat-fieldname = iv_field.
  gs_fcat-coltext   = iv_text.
  APPEND gs_fcat TO gt_fcat.
ENDFORM.
