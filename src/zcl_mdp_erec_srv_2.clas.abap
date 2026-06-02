class ZCL_MDP_EREC_SRV_2 definition
  public
  final
  create public .

public section.

  types:
    tt_bapiret1 TYPE STANDARD TABLE OF bapiret1 WITH DEFAULT KEY .
  types:
*  types TY_EREC type ZGTY_STR .             " ALV satır yapısı
    begin of gty_table,

             parnr type   parnr,
             bukrs type   bukrs,
             koart type   /mdpes/erec_de092,
             accno type   /mdpes/erec_de058,
             ptype type   /mdpes/erec_de100,
             loekz type   loekz_edi,
             ename type   /mdpes/erec_de120,
             email type   ad_smtpadr,
             telf1 type   telf1,
             tckid type   /mdpes/erec_de139,
             erdat type   erdat,
             ernam type   ernam,
             erzet type   erzet,
             aenam type   aenam,
             aedat type   aedat,
             aezet type   aezet,
             icon  type   icon_d,
           end of gty_table .
  types TY_EREC type GTY_TABLE .
  types:
    ty_erec_tab type standard table of gty_table with empty key .
  types:
    tt_erec type standard table of ty_erec with empty key .
  types:
    begin of ty_template,
        parnr type string,
        bukrs type string,
        koart type string,
        accno type string,
        ptype type string,
        loekz type string,
        ename type string,
        email type string,
        telf1 type string,
        tckid type string,
      end of ty_template .
  types:
    tt_template type standard table of ty_template with empty key .
  types:
    tt_parnr TYPE STANDARD TABLE OF parnr WITH EMPTY KEY .

  constants C_NR_RANGE_NR type INRI-NRRANGENR value '01' ##NO_TEXT.
  constants C_NR_OBJECT type INRI-OBJECT value '/MDPES/ER2' ##NO_TEXT.
  data GT_ITAB type ZMDP_TT_ITAB .

  methods UPDATE
    importing
      value(IS_DATA) type TY_EREC optional
      value(IV_DO_COMMIT) type ABAP_BOOL default ABAP_TRUE
    changing
      !CS_DATA type TY_EREC
    returning
      value(RV_OK) type ABAP_BOOL .
  methods SOFT_DELETE
    importing
      value(IT_PARNR) type TT_PARNR optional
      value(IV_DO_COMMIT) type ABAP_BOOL default ABAP_TRUE
    returning
      value(RV_AFFECTED) type I .
  class-methods MESSAGE_TEXT_BUILD
    importing
      !IV_MSGID type RSDAG-ARBGB
      !IV_MSGNO type NUMC3
      !IV_LANGU type SY-LANGU
      !IV_MSGV1 type SYMSGV
      !IV_MSGV2 type SYMSGV
      !IV_MSGV3 type SYMSGV
      !IV_MSGV4 type SYMSGV
    returning
      value(EV_MESSAGE) type NATXT .
  class-methods SET_MESSAGE
    changing
      !ES_RETURN type BAPIRET1 .
  methods GET_NEXT_PARNR
    returning
      value(RV_PARNR) type PARNR .
  methods VALIDATE_FOR_ALV_ROW
    importing
      value(IS_DATA) type TY_EREC optional
    changing
      !ES_RETURN type BAPIRET1
      !ET_RETURN type TT_BAPIRET1
    returning
      value(RV_OK) type ABAP_BOOL .
  methods SAVE_ALL
    importing
      value(IT_DATA) type TY_EREC_TAB optional
    exporting
      !EV_SAVED type I
      !EV_UPDATED type I
      !EV_SKIPPED type I
      !EV_TOTAL type I .
  methods RESET_LOEKZ
    importing
      value(IS_ROW) type TY_EREC optional
    exporting
      !EV_OK type ABAP_BOOL
      !EV_MSG type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MDP_EREC_SRV_2 IMPLEMENTATION.


METHOD GET_NEXT_PARNR.
  DATA(lv_parnr) = VALUE parnr( ).
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = c_nr_range_nr
      object      = c_nr_object
    IMPORTING
      number      = lv_parnr
    EXCEPTIONS
      OTHERS      = 5.
  IF sy-subrc <> 0 OR lv_parnr IS INITIAL.
    MESSAGE 'Numara aralığından PARNR alınamadı' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
  rv_parnr = lv_parnr.
ENDMETHOD.


  method MESSAGE_TEXT_BUILD.
*-
    data t100 type t100 .
    field-symbols: <f> type any .

    data : mess_1, mess_2, mess_3, mess_4.
    clear : mess_1, mess_2, mess_3, mess_4.

* T100 lesen
    select single * from t100 into t100
           where sprsl = iv_langu
           and   arbgb = iv_msgid
           and   msgnr = iv_msgno.

    if sy-subrc = 0.
      ev_message = t100-text.
    else.
      ev_message = text-001.
      exit.
    endif.

*1
    search ev_message for '&1'.
    if sy-subrc eq 0.
      mess_1 = 'X'.
      sy-fdpos = strlen( iv_msgv1 ).
      if sy-fdpos ne 0.
        assign iv_msgv1(sy-fdpos) to <f>.
        replace '&1' with <f> into ev_message.
      else.
        replace '&1' with space into ev_message.
      endif.
    endif.
*2
    search ev_message for '&2'.
    if sy-subrc eq 0.
      mess_2 = 'X'.
      sy-fdpos = strlen( iv_msgv2 ).
      if sy-fdpos ne 0.
        assign iv_msgv2(sy-fdpos) to <f>.
        replace '&2' with <f> into ev_message.
      else.
        replace '&2' with space into ev_message.
      endif.
    endif.
*3
    search ev_message for '&3'.
    if sy-subrc eq 0.
      mess_3 = 'X'.
      sy-fdpos = strlen( iv_msgv3 ).
      if sy-fdpos ne 0.
        assign iv_msgv3(sy-fdpos) to <f>.
        replace '&3' with <f> into ev_message.
      else.
        replace '&3' with space into ev_message.
      endif.
    endif.
*4
    search ev_message for '&4'.
    if sy-subrc eq 0.
      mess_4 = 'X'.
      sy-fdpos = strlen( iv_msgv4 ).
      if sy-fdpos ne 0.
        assign iv_msgv4(sy-fdpos) to <f>.
        replace '&4' with <f> into ev_message.
      else.
        replace '&4' with space into ev_message.
      endif.
    endif.
* 1
    if mess_1 is initial.
      sy-fdpos = strlen( iv_msgv1 ).
      if sy-fdpos ne 0.
        assign iv_msgv1(sy-fdpos) to <f>.
        replace '&1' with <f> into ev_message.
        if sy-subrc ne 0.
          replace '&' with <f> into ev_message.
        endif.
      else.
        replace '&1' with space into ev_message.
        if sy-subrc ne 0.
          replace '&' with space into ev_message.
        endif.
      endif.
    endif.
* 2
    if mess_2 is initial.
      sy-fdpos = strlen( iv_msgv2 ).
      if sy-fdpos ne 0.
        assign iv_msgv2(sy-fdpos) to <f>.
        replace '&2' with <f> into ev_message.
        if sy-subrc ne 0.
          replace '&' with <f> into ev_message.
        endif.
      else.
        replace '&2' with space into ev_message.
        if sy-subrc ne 0.
          replace '&' with space into ev_message.
        endif.
      endif.
    endif.
* 3
    if mess_3 is initial.
      sy-fdpos = strlen( iv_msgv3 ).
      if sy-fdpos ne 0.
        assign iv_msgv3(sy-fdpos) to <f>.
        replace '&3' with <f> into ev_message.
        if sy-subrc ne 0.
          replace '&' with <f> into ev_message.
        endif.
      else.
        replace '&3' with space into ev_message.
        if sy-subrc ne 0.
          replace '&' with space into ev_message.
        endif.
      endif.
    endif.
* 4
    if mess_4 is initial.
      sy-fdpos = strlen( iv_msgv4 ).
      if sy-fdpos ne 0.
        assign iv_msgv4(sy-fdpos) to <f>.
        replace '&4' with <f> into ev_message.
        if sy-subrc ne 0.
          replace '&' with <f> into ev_message.
        endif.
      else.
        replace '&4' with space into ev_message.
        if sy-subrc ne 0.
          replace '&' with space into ev_message.
        endif.
      endif.
    endif.
  endmethod.


METHOD RESET_LOEKZ.

*  ev_ok = abap_false.
*  CLEAR ev_msg.
*
*  UPDATE zmdik_erec SET
*        loekz = space
*        aedat = sy-datum
*        aezet = sy-uzeit
*        aenam = sy-uname
*      WHERE parnr = is_row-parnr
*        AND bukrs = is_row-bukrs
*        AND koart = is_row-koart
*        AND accno = is_row-accno
*        AND email = is_row-email.
*
*  IF sy-subrc = 0.
*    ev_ok = abap_true.
*    ev_msg = |Kayıt başarıyla güncellendi.|.
*  ELSE.
*    ev_msg = |Kayıt güncellenemedi.|.
*  ENDIF.

ENDMETHOD.


  method SAVE_ALL.
*
*    data: lv_update  type i,
*          lv_saved   type i,
*          lv_skipped type i,
*          lv_total   type i.
*
*    data: lv_errflds type string,
*          lv_errmsg  type string,
*          ls_srv     type zgty_str.
*
*    data: ls_return type bapiret1,
*          lt_return type tt_bapiret1.
*
*    field-symbols <ls> type zgty_str.
*
*    data: lt_db_valid type standard table of zmdik_erec,
*          ls_db       type zmdik_erec.
*    data lt_insert_buffer type standard table of zmdik_erec with empty key.
*
*
*
*    clear: lv_update, lv_saved, lv_skipped, lv_total.
*
*    loop at it_data assigning <ls>.
*      lv_total = lv_total + 1.
*
*      " Kırmızı → Hatalı, atla
*      if <ls>-icon = '@0A@'.
*        lv_skipped = lv_skipped + 1.
*        continue.
*      endif.
*
*      " Sarı → Update
*      if <ls>-icon = '@09@'.
*
*        if <ls>-parnr is not initial.
*          select single * from zmdik_erec
*       where parnr = @<ls>-parnr
*       into @data(ls_upd).
*          if sy-subrc <> 0.
*            message 'Güncellenecek kayıt bulunamadı (PARNR).' type 'S' display like 'E'.
*            return.
*          endif.
*
*          <ls>-bukrs = ls_upd-bukrs.
*          <ls>-erdat = ls_upd-erdat.
*          <ls>-erzet = ls_upd-erzet.
*          <ls>-parnr = ls_upd-parnr.
*
*          if validate_for_alv_row(
*              exporting
*                is_data    =  <ls>                " global structure
*             changing  es_return = ls_return
*                        et_return = lt_return ) = abap_false.
*            lv_skipped = lv_skipped + 1.
*            return.
*          endif.
*
*          <ls>-aenam = sy-uname.
*          <ls>-aedat = sy-datum.
*          <ls>-aezet = sy-uzeit.
*
*          update zmdik_erec set
*            email = @<ls>-email,
*            ename = @<ls>-ename,
*            telf1 = @<ls>-telf1,
*            tckid = @<ls>-tckid,
*            koart = @<ls>-koart,
*            accno = @<ls>-accno,
*            loekz = @<ls>-loekz,
*            aedat = @<ls>-aedat,
*            aezet = @<ls>-aezet,
*            aenam = @<ls>-aenam
*            where parnr = @<ls>-parnr.
*
*
*          if sy-subrc = 0.
*
*            commit work and wait.
*
*            message 'Seçilen satır güncellendi' type 'S'.
*          else.
*
*            rollback work.
*            message 'Satır güncellenemedi.' type 'S' display like 'E'.
*          endif.
*
*        else.
*          select single * from zmdik_erec
*            where bukrs = @<ls>-bukrs
*              and koart = @<ls>-koart
*              and accno = @<ls>-accno
*              and email = @<ls>-email
*            into @data(ls_old).
*
*          if sy-subrc = 0.
*            ls_old-ename = <ls>-ename.
*            ls_old-tckid = <ls>-tckid.
*            ls_old-telf1 = <ls>-telf1.
*            ls_old-loekz = <ls>-loekz.
*            ls_old-aenam = sy-uname.
*            ls_old-aedat = sy-datum.
*            ls_old-aezet = sy-uzeit.
*
*            modify zmdik_erec from ls_old.
*            if sy-subrc = 0.
*              lv_update = lv_update + 1.
*            endif.
*          endif.
*
*          continue.
*        endif.
*      endif.
*
*
*      " Yeşil → Insert
*      if <ls>-icon = '@08@'.
*
*        if validate_for_alv_row(
*               exporting
*                 is_data    =  <ls>
*                changing  es_return = ls_return
*                   et_return = lt_return ) = abap_false.
*          lv_skipped = lv_skipped + 1.
*          lv_skipped = lv_skipped + 1.
*          continue.
*        endif.
*
*
*        if <ls>-parnr is initial.
*          <ls>-parnr = get_next_parnr( ).
*          <ls>-erdat = sy-datum.
*          <ls>-erzet = sy-uzeit.
*          <ls>-ernam = sy-uname.
*        endif.
*
*        if <ls>-parnr is initial.
*          lv_skipped = lv_skipped + 1.
*          continue.
*        endif.
*
*
*
*        clear ls_db.
*        move-corresponding <ls> to ls_db.
*
*        " 3.4 Toplu insert bufferına ekleme
*        append ls_db to lt_insert_buffer.
*
*        lv_saved = lv_saved + 1.
*
*        data ls_new type zmdik_erec.
*
*
*
*      endif.
*
*    endloop.
*
*
*
*    "-----------------------------------------------
*    " 4) TOPLU INSERT
*    "-----------------------------------------------
*    if lt_insert_buffer is not initial.
*
*      sort lt_insert_buffer by parnr bukrs koart accno email.
*      delete adjacent duplicates from lt_insert_buffer
*        comparing parnr bukrs koart accno email.
*
*      modify zmdik_erec from table lt_insert_buffer.
*
*    endif.
*    commit work and wait.
*
*    ev_saved   = lv_saved.
*    ev_updated = lv_update.
*    ev_skipped = lv_skipped.
*    ev_total   = lv_total.

  endmethod.


  method SET_MESSAGE.
*-
    if es_return-type is initial .
      case es_return-number .
        when 0 .      es_return-type = 'S' .
        when others . es_return-type = 'E' .
      endcase .
    endif .

    es_return-message = /mdpes/erec_cl00=>message_text_build(
      exporting
        iv_msgid = 'ZMDIK_ERECV'
         iv_langu = sy-langu
        iv_msgno = es_return-number
        iv_msgv1 = es_return-message_v1
        iv_msgv2 = es_return-message_v2
        iv_msgv3 = es_return-message_v3
        iv_msgv4 = es_return-message_v4 ) .

  endmethod.


 METHOD SOFT_DELETE.
*  rv_affected = 0.
*  IF it_parnr IS INITIAL.
*    RETURN.
*  ENDIF.
*
*  LOOP AT it_parnr INTO DATA(lv_key).
*    UPDATE zmdik_erec SET loekz = 'X'
*      WHERE parnr = @lv_key.
*    IF sy-subrc = 0.
*      rv_affected += 1.
*    ENDIF.
*  ENDLOOP.
*
*  IF rv_affected > 0 AND iv_do_commit = abap_true.
*    COMMIT WORK AND WAIT.
*    MESSAGE |{ rv_affected } kayıt silindi| TYPE 'S'.
*  ELSEIF rv_affected = 0.
*    MESSAGE 'Silinecek (işaretlenecek) kayıt bulunamadı.' TYPE 'S' DISPLAY LIKE 'E'.
*  ENDIF.
ENDMETHOD.


 method UPDATE.
*   rv_ok = abap_false.
*   cs_data = is_data.
*
*   " Kayıt var mı?
*   select single * from zmdik_erec
*     where parnr = @is_data-parnr
*     into @data(ls_old).
*   if sy-subrc <> 0.
*     message 'Güncellenecek kayıt bulunamadı (PARNR).' type 'S' display like 'E'.
*     return.
*   endif.
*
*   " Korunan alanlar (akışına uygun)
*   cs_data-bukrs = ls_old-bukrs.
*   cs_data-erdat = ls_old-erdat.
*   cs_data-erzet = ls_old-erzet.
*   cs_data-parnr = ls_old-parnr.
*
*
*   cs_data-aenam = sy-uname.
*   cs_data-aedat = sy-datum.
*   cs_data-aezet = sy-uzeit.
*
*   update zmdik_erec set
*     email = @cs_data-email,
*     ename = @cs_data-ename,
*     telf1 = @cs_data-telf1,
*     tckid = @cs_data-tckid,
*     koart = @cs_data-koart,
*     accno = @cs_data-accno,
*     loekz = @cs_data-loekz,
*     aedat = @cs_data-aedat,
*     aezet = @cs_data-aezet,
*     aenam = @cs_data-aenam
*     where parnr = @cs_data-parnr.
*
*   if sy-subrc = 0.
*     if iv_do_commit = abap_true.
*       commit work and wait.
*     endif.
*     message 'Seçilen satır güncellendi' type 'S'.
*     rv_ok = abap_true.
*   else.
*     rollback work.
*     message 'Satır güncellenemedi.' type 'S' display like 'E'.
*   endif.
 endmethod.


METHOD VALIDATE_FOR_ALV_ROW.

  rv_ok = abap_true.

   CLEAR: es_return.
  CLEAR et_return.

  DATA: lv_email TYPE string,
        lv_phone TYPE string,
        lv_name  TYPE string.

*  DATA et_return TYPE table of bapiret1.

*--------------------------------------------------------------------*
* 1) E-POSTA KONTROLÜ
*--------------------------------------------------------------------*
  lv_email = |{ is_data-email }|.
  CONDENSE lv_email.

  IF is_data-email IS INITIAL.

    CLEAR es_return.
    es_return-number = '031'.

    set_message(
      CHANGING
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.


  ELSE.
    FIND REGEX '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'
      IN lv_email IGNORING CASE.
    IF sy-subrc <> 0.

      CLEAR es_return.
      es_return-number      = '032'.
      es_return-message_v1  = lv_email.

      set_message(
        CHANGING
          es_return = es_return ).


      rv_ok = abap_false.

        append es_return to et_return.

    ENDIF.
  ENDIF.

*--------------------------------------------------------------------*
* 2) ŞİRKET KODU (BUKRS)
*--------------------------------------------------------------------*





  IF is_data-bukrs IS NOT INITIAL.

    SELECT SINGLE bukrs
      FROM t001
      WHERE bukrs = @is_data-bukrs
      INTO @DATA(lv_bukrs).

    IF sy-subrc <> 0.

      CLEAR es_return.
      es_return-number     = '033'.
      es_return-message_v1 = |{ is_data-bukrs }|.

      set_message(
        CHANGING
          es_return = es_return ).


      rv_ok = abap_false.
        append es_return to et_return.

    ENDIF.

    else.

       CLEAR es_return.
      es_return-number     = '033'.
      es_return-message_v1 = |{ is_data-bukrs }|.

      set_message(
        CHANGING
          es_return = es_return ).
       rv_ok = abap_false.
        append es_return to et_return.
  ENDIF.

*--------------------------------------------------------------------*
* 3) KOART
*--------------------------------------------------------------------*
  IF is_data-koart IS NOT INITIAL
     AND is_data-koart <> 'D'
     AND is_data-koart <> 'K'.

    CLEAR es_return.
    es_return-number     = '034'.
    es_return-message_v1 = |{ is_data-koart }|.

    set_message(
      CHANGING
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  ENDIF.

*--------------------------------------------------------------------*
* 4) MUHATAP (ACCNO)
*--------------------------------------------------------------------*
  IF is_data-accno IS INITIAL.

    CLEAR es_return.
    es_return-number = '035'.

    set_message(
      CHANGING
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  ELSEIF is_data-koart = 'D'.

    DATA(lv_kunnr) = is_data-accno.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING input  = lv_kunnr
      IMPORTING output = lv_kunnr.

    SELECT SINGLE kunnr FROM kna1 INTO @DATA(lv_kna1)
      WHERE kunnr = @lv_kunnr.

    IF sy-subrc <> 0.

      CLEAR es_return.
      es_return-number     = '036'.
      es_return-message_v1 = |{ is_data-accno }|.

      set_message(
        CHANGING
          es_return = es_return ).


      rv_ok = abap_false.
     append es_return to et_return.

    ENDIF.

  ELSEIF is_data-koart = 'K'.

    DATA(lv_lifnr) = is_data-accno.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING input  = lv_lifnr
      IMPORTING output = lv_lifnr.

    SELECT SINGLE lifnr FROM lfa1 INTO @DATA(lv_lfa1)
      WHERE lifnr = @lv_lifnr.

    IF sy-subrc <> 0.

      CLEAR es_return.
      es_return-number     = '037'.
      es_return-message_v1 = |{ is_data-accno }|.

      set_message(
        CHANGING
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    ENDIF.
  ENDIF.

*--------------------------------------------------------------------*
* 5) TCKN
*--------------------------------------------------------------------*
  IF is_data-tckid IS NOT INITIAL.

    FIND REGEX '[^0-9]' IN is_data-tckid.
    IF sy-subrc = 0.

      CLEAR es_return.
      es_return-number     = '038'.
      es_return-message_v1 = |{ is_data-tckid }|.

      set_message(
        CHANGING
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    ENDIF.

    IF strlen( is_data-tckid ) <> 11.

      CLEAR es_return.
      es_return-number     = '039'.
      es_return-message_v1 = |{ is_data-tckid }|.

      set_message(
        CHANGING
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    ENDIF.
  ENDIF.

*--------------------------------------------------------------------*
* 6) İSİM (ENAME)
*--------------------------------------------------------------------*
  IF is_data-ename IS NOT INITIAL.

    lv_name = |{ is_data-ename }|.
    CONDENSE lv_name.

    FIND REGEX '^[A-Za-zÇĞİÖŞÜçğıöşü''\- ]+$'
      IN lv_name IGNORING CASE.
    IF sy-subrc <> 0.

      CLEAR es_return.
      es_return-number     = '040'.
      es_return-message_v1 = lv_name.

      set_message(
        CHANGING
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    ENDIF.
  ENDIF.

*--------------------------------------------------------------------*
* 7) LOEKZ
*--------------------------------------------------------------------*
  IF is_data-loekz IS NOT INITIAL AND is_data-loekz <> 'X'.

    CLEAR es_return.
    es_return-number     = '041'.
    es_return-message_v1 = |{ is_data-loekz }|.

    set_message(
      CHANGING
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  ENDIF.

*--------------------------------------------------------------------*
* 8) PTYPE
*--------------------------------------------------------------------*
  IF is_data-ptype IS INITIAL.

    CLEAR es_return.
    es_return-number = '042'.

    set_message(
      CHANGING
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  ELSEIF is_data-ptype <> '1'
     AND is_data-ptype <> '2'
     AND is_data-ptype <> '3'
     AND is_data-ptype <> '4'
     AND is_data-ptype <> '5'.

    CLEAR es_return.
    es_return-number     = '043'.
    es_return-message_v1 = |{ is_data-ptype }|.

    set_message(
      CHANGING
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  ENDIF.

*--------------------------------------------------------------------*
* 9) TELEFON
*--------------------------------------------------------------------*
  IF is_data-telf1 IS NOT INITIAL.

    lv_phone = |{ is_data-telf1 }|.
    REPLACE ALL OCCURRENCES OF REGEX '[^0-9]' IN lv_phone WITH ''.

    IF strlen( lv_phone ) <> 10 AND strlen( lv_phone ) <> 11.

      CLEAR es_return.
      es_return-number     = '044'.
      es_return-message_v1 = lv_phone.

      set_message(
        CHANGING
          es_return = es_return ).


      rv_ok = abap_false.
     append es_return to et_return.

    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
