*&---------------------------------------------------------------------*
*& Report ZMDIK_P097
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P097.


PARAMETERS: p_bukrs  TYPE bukrs  OBLIGATORY,
            p_blart  TYPE blart  OBLIGATORY DEFAULT 'SA',
            p_bldat  TYPE bldat  OBLIGATORY,
            p_budat  TYPE budat  OBLIGATORY,
            p_waers  TYPE waers  OBLIGATORY DEFAULT 'TRY',
            p_xblnr  TYPE xblnr1,
            p_bktxt  TYPE bktxt,
            p_hkont1 TYPE hkont  OBLIGATORY,
            p_hkont2 TYPE hkont  OBLIGATORY,
            p_dmbtr  TYPE wrbtr  OBLIGATORY.

CLASS lcl_fbv1_park DEFINITION FINAL.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_result,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
             bstat TYPE bstat_d,
             msgty TYPE symsgty,
             msgtx TYPE string,
           END OF ty_result.

    METHODS:
      constructor
        IMPORTING
          iv_bukrs  TYPE bukrs
          iv_blart  TYPE blart
          iv_bldat  TYPE bldat
          iv_budat  TYPE budat
          iv_waers  TYPE waers
          iv_xblnr  TYPE xblnr1
          iv_bktxt  TYPE bktxt
          iv_hkont1 TYPE hkont
          iv_hkont2 TYPE hkont
          iv_dmbtr  TYPE wrbtr,

      execute
        RETURNING VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.

    DATA: mv_bukrs  TYPE bukrs,
          mv_blart  TYPE blart,
          mv_bldat  TYPE bldat,
          mv_budat  TYPE budat,
          mv_waers  TYPE waers,
          mv_xblnr  TYPE xblnr1,
          mv_bktxt  TYPE bktxt,
          mv_hkont1 TYPE hkont,
          mv_hkont2 TYPE hkont,
          mv_dmbtr  TYPE wrbtr.

    DATA: mt_ftpost TYPE STANDARD TABLE OF ftpost WITH DEFAULT KEY,
          mt_fttax  TYPE STANDARD TABLE OF fttax  WITH DEFAULT KEY,
          mt_blntab TYPE STANDARD TABLE OF blntab WITH DEFAULT KEY,
          mt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    METHODS:
      prepare_data,
      add_ftpost
        IMPORTING
          iv_stype TYPE ftpost-stype
          iv_count TYPE ftpost-count
          iv_fnam  TYPE ftpost-fnam
          iv_fval  TYPE ftpost-fval,
      call_preliminary_posting
        CHANGING
          cs_result TYPE ty_result,
      check_parked_status
        CHANGING
          cs_result TYPE ty_result.

ENDCLASS.

CLASS lcl_fbv1_park IMPLEMENTATION.

  METHOD constructor.
    mv_bukrs  = iv_bukrs.
    mv_blart  = iv_blart.
    mv_bldat  = iv_bldat.
    mv_budat  = iv_budat.
    mv_waers  = iv_waers.
    mv_xblnr  = iv_xblnr.
    mv_bktxt  = iv_bktxt.
    mv_hkont1 = iv_hkont1.
    mv_hkont2 = iv_hkont2.
    mv_dmbtr  = iv_dmbtr.
  ENDMETHOD.

  METHOD add_ftpost.
    DATA ls_ftpost TYPE ftpost.

    CLEAR ls_ftpost.
    ls_ftpost-stype = iv_stype.
    ls_ftpost-count = iv_count.
    ls_ftpost-fnam  = iv_fnam.
    ls_ftpost-fval  = iv_fval.

    APPEND ls_ftpost TO mt_ftpost.
  ENDMETHOD.

  METHOD prepare_data.
    CLEAR: mt_ftpost, mt_fttax, mt_blntab, mt_return.
    REFRESH: mt_ftpost, mt_fttax, mt_blntab, mt_return.

    " Header
    add_ftpost(
      iv_stype = 'K'
      iv_count = 1
      iv_fnam  = 'BKPF-BUKRS'
      iv_fval  = CONV ftpost-fval( mv_bukrs ) ).

    add_ftpost(
      iv_stype = 'K'
      iv_count = 1
      iv_fnam  = 'BKPF-BLART'
      iv_fval  = CONV ftpost-fval( mv_blart ) ).

    add_ftpost(
      iv_stype = 'K'
      iv_count = 1
      iv_fnam  = 'BKPF-BLDAT'
      iv_fval  = CONV ftpost-fval( mv_bldat ) ).

    add_ftpost(
      iv_stype = 'K'
      iv_count = 1
      iv_fnam  = 'BKPF-BUDAT'
      iv_fval  = CONV ftpost-fval( mv_budat ) ).

    add_ftpost(
      iv_stype = 'K'
      iv_count = 1
      iv_fnam  = 'BKPF-WAERS'
      iv_fval  = CONV ftpost-fval( mv_waers ) ).

    IF mv_xblnr IS NOT INITIAL.
      add_ftpost(
        iv_stype = 'K'
        iv_count = 1
        iv_fnam  = 'BKPF-XBLNR'
        iv_fval  = CONV ftpost-fval( mv_xblnr ) ).
    ENDIF.

    IF mv_bktxt IS NOT INITIAL.
      add_ftpost(
        iv_stype = 'K'
        iv_count = 1
        iv_fnam  = 'BKPF-BKTXT'
        iv_fval  = CONV ftpost-fval( mv_bktxt ) ).
    ENDIF.

    " 1. kalem - Borç
    add_ftpost(
      iv_stype = 'P'
      iv_count = 1
      iv_fnam  = 'RF05A-NEWBS'
      iv_fval  = '40' ).

    add_ftpost(
      iv_stype = 'P'
      iv_count = 1
      iv_fnam  = 'RF05A-NEWKO'
      iv_fval  = CONV ftpost-fval( mv_hkont1 ) ).

    add_ftpost(
      iv_stype = 'P'
      iv_count = 1
      iv_fnam  = 'BSEG-WRBTR'
      iv_fval  = CONV ftpost-fval( mv_dmbtr ) ).

    add_ftpost(
      iv_stype = 'P'
      iv_count = 1
      iv_fnam  = 'BSEG-SGTXT'
      iv_fval  = 'Borc kalemi' ).

    " 2. kalem - Alacak
    add_ftpost(
      iv_stype = 'P'
      iv_count = 2
      iv_fnam  = 'RF05A-NEWBS'
      iv_fval  = '50' ).

    add_ftpost(
      iv_stype = 'P'
      iv_count = 2
      iv_fnam  = 'RF05A-NEWKO'
      iv_fval  = CONV ftpost-fval( mv_hkont2 ) ).

    add_ftpost(
      iv_stype = 'P'
      iv_count = 2
      iv_fnam  = 'BSEG-WRBTR'
      iv_fval  = CONV ftpost-fval( mv_dmbtr ) ).

    add_ftpost(
      iv_stype = 'P'
      iv_count = 2
      iv_fnam  = 'BSEG-SGTXT'
      iv_fval  = 'Alacak kalemi' ).
  ENDMETHOD.

METHOD call_preliminary_posting.

  DATA: lt_bkpf    TYPE STANDARD TABLE OF bkpf WITH DEFAULT KEY,
        ls_bkpf    TYPE bkpf,
        lt_bseg    TYPE STANDARD TABLE OF bseg WITH DEFAULT KEY,
        ls_bseg    TYPE bseg,
        lt_bsec    TYPE STANDARD TABLE OF bsec WITH DEFAULT KEY,
        lt_bset    TYPE STANDARD TABLE OF bset WITH DEFAULT KEY,
        lt_bsez    TYPE STANDARD TABLE OF bsez WITH DEFAULT KEY,
        lv_xepbbp  TYPE xfeld,
        lv_xblnr   TYPE xblnr1,
        ls_bkpf_db TYPE bkpf,
        ls_vbkpf   TYPE vbkpf.

  CLEAR: cs_result,
         lt_bkpf, lt_bseg, lt_bsec, lt_bset, lt_bsez.
  REFRESH: lt_bkpf, lt_bseg, lt_bsec, lt_bset, lt_bsez.

  " Benzersiz referans verelim ki belgeyi sonra bulabilelim
  IF mv_xblnr IS INITIAL.
    lv_xblnr = |PARK{ sy-datum+2(6) }{ sy-uzeit(6) }|.
  ELSE.
    lv_xblnr = mv_xblnr.
  ENDIF.

  "------------------------------------------------------------
  " BKPF
  "------------------------------------------------------------
  CLEAR ls_bkpf.
  ls_bkpf-bukrs = mv_bukrs.
  ls_bkpf-blart = mv_blart.
  ls_bkpf-bldat = mv_bldat.
  ls_bkpf-budat = mv_budat.
  ls_bkpf-waers = mv_waers.
  ls_bkpf-xblnr = lv_xblnr.
  ls_bkpf-bktxt = mv_bktxt.
  APPEND ls_bkpf TO lt_bkpf.

  "------------------------------------------------------------
  " BSEG - 1. satır / Borç
  "------------------------------------------------------------
  CLEAR ls_bseg.
  ls_bseg-buzei = '001'.
  ls_bseg-bschl = '40'.
  ls_bseg-hkont = mv_hkont1.
  ls_bseg-wrbtr = mv_dmbtr.
  ls_bseg-dmbtr = mv_dmbtr.
  ls_bseg-sgtxt = 'Borc kalemi'.
  APPEND ls_bseg TO lt_bseg.

  "------------------------------------------------------------
  " BSEG - 2. satır / Alacak
  "------------------------------------------------------------
  CLEAR ls_bseg.
  ls_bseg-buzei = '002'.
  ls_bseg-bschl = '50'.
  ls_bseg-hkont = mv_hkont2.
  ls_bseg-wrbtr = mv_dmbtr.
  ls_bseg-dmbtr = mv_dmbtr.
  ls_bseg-sgtxt = 'Alacak kalemi'.
  APPEND ls_bseg TO lt_bseg.

  "------------------------------------------------------------
  " Ön kayıt
  "------------------------------------------------------------
  CALL FUNCTION 'PRELIMINARY_POSTING_FB01'
    EXPORTING
      i_tcode = 'FBV1'
    IMPORTING
      xepbbp  = lv_xepbbp
    TABLES
      t_bkpf  = lt_bkpf
      t_bseg  = lt_bseg
      t_bsec  = lt_bsec
      t_bset  = lt_bset
      t_bsez  = lt_bsez
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc <> 0.
    cs_result-msgty = 'E'.
    cs_result-msgtx = |PRELIMINARY_POSTING_FB01 hata verdi. SY-SUBRC = { sy-subrc }|.
    RETURN.
  ENDIF.

  COMMIT WORK AND WAIT.

  "------------------------------------------------------------
  " Oluşan belgeyi BKPF/VBKPF üzerinden bul
  "------------------------------------------------------------
  CLEAR ls_bkpf_db.
  SELECT SINGLE *
    FROM bkpf
    INTO ls_bkpf_db
   WHERE bukrs = mv_bukrs
     AND xblnr = lv_xblnr
     AND blart = mv_blart
     AND bldat = mv_bldat
     AND budat = mv_budat.

  IF sy-subrc <> 0.
    cs_result-msgty = 'W'.
    cs_result-msgtx = 'Belge olustu ancak BKPF kaydi bulunamadi.'.
    RETURN.
  ENDIF.

  cs_result-belnr = ls_bkpf_db-belnr.
  cs_result-gjahr = ls_bkpf_db-gjahr.
  cs_result-bstat = ls_bkpf_db-bstat.

  CLEAR ls_vbkpf.
  SELECT SINGLE *
    FROM vbkpf
    INTO ls_vbkpf
   WHERE bukrs = ls_bkpf_db-bukrs
     AND belnr = ls_bkpf_db-belnr
     AND gjahr = ls_bkpf_db-gjahr.

  IF cs_result-bstat = 'V'.
    cs_result-msgty = 'S'.
    cs_result-msgtx = |On kayit basarili. Belge: { cs_result-belnr }/{ cs_result-gjahr } BSTAT=V|.
  ELSEIF sy-subrc = 0.
    cs_result-msgty = 'W'.
    cs_result-msgtx = |VBKPF kaydi var ancak BKPF-BSTAT = { cs_result-bstat }|.
  ELSE.
    cs_result-msgty = 'W'.
    cs_result-msgtx = |Belge bulundu fakat on kayit durumu net dogrulanamadi. BSTAT = { cs_result-bstat }|.
  ENDIF.

ENDMETHOD.

  METHOD check_parked_status.
    DATA: ls_bkpf  TYPE bkpf,
          ls_vbkpf TYPE vbkpf.

    IF cs_result-belnr IS INITIAL OR cs_result-gjahr IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE *
      FROM bkpf
      INTO ls_bkpf
     WHERE bukrs = mv_bukrs
       AND belnr = cs_result-belnr
       AND gjahr = cs_result-gjahr.

    IF sy-subrc = 0.
      cs_result-bstat = ls_bkpf-bstat.
    ENDIF.

    SELECT SINGLE *
      FROM vbkpf
      INTO ls_vbkpf
     WHERE bukrs = mv_bukrs
       AND belnr = cs_result-belnr
       AND gjahr = cs_result-gjahr.

    IF cs_result-bstat = 'V'.
      cs_result-msgty = 'S'.
      cs_result-msgtx = |Belge on kayit olarak olustu. Belge no: { cs_result-belnr }/{ cs_result-gjahr }|.
    ELSEIF sy-subrc = 0.
      cs_result-msgty = 'W'.
      cs_result-msgtx = |Belge VBKPF'de bulundu ancak BKPF-BSTAT = { cs_result-bstat } geldi|.
    ELSE.
      cs_result-msgty = 'W'.
      cs_result-msgtx = |Belge olustu fakat parked status dogrulanamadi.|.
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    CLEAR rs_result.

    prepare_data( ).

    call_preliminary_posting(
      CHANGING
        cs_result = rs_result ).

    IF rs_result-msgty = 'E'.
      RETURN.
    ENDIF.

    check_parked_status(
      CHANGING
        cs_result = rs_result ).
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  DATA(lo_park) = NEW lcl_fbv1_park(
                    iv_bukrs  = p_bukrs
                    iv_blart  = p_blart
                    iv_bldat  = p_bldat
                    iv_budat  = p_budat
                    iv_waers  = p_waers
                    iv_xblnr  = p_xblnr
                    iv_bktxt  = p_bktxt
                    iv_hkont1 = p_hkont1
                    iv_hkont2 = p_hkont2
                    iv_dmbtr  = p_dmbtr ).

  DATA(ls_result) = lo_park->execute( ).

  WRITE: / 'MESAJ TIPI :', ls_result-msgty.
  WRITE: / 'MESAJ      :', ls_result-msgtx.
  WRITE: / 'BELGE NO   :', ls_result-belnr.
  WRITE: / 'MALI YIL   :', ls_result-gjahr.
  WRITE: / 'BKPF-BSTAT :', ls_result-bstat.
