class ZCL_MDP_EREC_SRV definition
  public
  final
  create public .

public section.

  types:
    begin of ty_mail,
        bukrs     type bukrs,
        partner   type char10,        "KUNNR veya LIFNR
        koart     type bseg-koart,    " 'D' müşteri, 'K' satıcı
        adrnr     type ad_addrnum,
        smtp_addr type adr6-smtp_addr,
        remark    type adrt-remark,
        loekz     type   loekz_edi,
        name      type kna1-name1,
      end of ty_mail .
  types:
    tt_mail type standard table of ty_mail with empty key .
  types:
    tt_bapiret1 type standard table of bapiret1 with default key .
  types:
*  types TY_EREC type ZGTY_STR .             " ALV satır yapısı
    begin of gty_table,

        parnr  type   parnr,
        bukrs  type   bukrs,
        koart  type   /mdpes/erec_de092,
        accno  type   /mdpes/erec_de058,
        ptype  type   /mdpes/erec_de100,
        loekz  type   loekz_edi,
        ename  type   /mdpes/erec_de120,
        email  type   ad_smtpadr,
        telf1  type   telf1,
        tckid  type   /mdpes/erec_de139,
        erdat  type   erdat,
        ernam  type   ernam,
        erzet  type   erzet,
        aenam  type   aenam,
        aedat  type   aedat,
        aezet  type   aezet,
        remark type ad_remark2,
        icon   type   icon_d,
      end of gty_table .
  types TY_EREC type GTY_TABLE .
  types:
    ty_erec_tab type standard table of gty_table with empty key .
  types:
    ty_gt_data type standard table of gty_table
        with empty key
        with unique hashed key k_match
          components parnr bukrs koart accno email loekz .
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
    begin of ty_r_koart,
        sign   type ddsign,
        option type ddoption,
        low    type /mdpes/erec_t010-koart,
        high   type /mdpes/erec_t010-koart,
      end of ty_r_koart .
  types:
    tt_r_koart type standard table of ty_r_koart with default key .
  types:
    begin of ty_r_accno,
        sign   type ddsign,
        option type ddoption,
        low    type /mdpes/erec_t010-accno,
        high   type /mdpes/erec_t010-accno,
      end of ty_r_accno .
  types:
    tt_r_accno type standard table of ty_r_accno with default key .
  types:
    begin of ty_r_loekz,
        sign   type ddsign,
        option type ddoption,
        low    type /mdpes/erec_t010-loekz,
        high   type /mdpes/erec_t010-loekz,
      end of ty_r_loekz .
  types:
    tt_r_loekz type standard table of ty_r_loekz with default key .
  types:
    begin of ty_r_remark,
        sign   type ddsign,
        option type ddoption,
        low    type adrt-remark,
        high   type adrt-remark,
      end of ty_r_remark .
  types:
    tt_r_remark type standard table of ty_r_remark with default key .

  constants C_NR_RANGE_NR type INRI-NRRANGENR value '01' ##NO_TEXT.
  constants C_NR_OBJECT type INRI-OBJECT value '/MDPES/ER2' ##NO_TEXT.

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
      value(IT_PARNR) type ZTT_PARNR optional
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
      value(RV_PARNR) type /MDPES/EREC_T010-PARNR .
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
  methods GET_PARTNER_MAILS
    importing
      value(IV_BUKRS) type BUKRS optional
      !IT_KOART type TT_R_KOART
      !IT_ACCNO type TT_R_ACCNO
      !LV_RULE type C
      !IT_REMARK type TT_R_REMARK
    returning
      value(RT_MAIL) type TT_MAIL .
  methods BUILD_PARTNER_MAIL_DATA
    importing
      value(IV_BUKRS) type BUKRS optional
      !IT_KOART type TT_R_KOART
      !IT_ACCNO type TT_R_ACCNO
      !LV_RULE type C
      !IT_REMARK type TT_R_REMARK
    changing
      !CT_DATA type TT_EREC .
  methods APPLY_MAIL_RULE
    importing
      value(IV_RULE) type C optional
      !IT_REMARK type TT_R_REMARK
    changing
      !CT_MAIL type TT_MAIL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MDP_EREC_SRV IMPLEMENTATION.


method apply_mail_rule.

  if iv_rule <> '2'.
    return.
  endif.

  data: lr_remark type range of adrt-remark,
        ls_r      like line of lr_remark,
        ls_in     type ty_r_remark.

  clear lr_remark.
  if it_remark is initial.
    ls_r-sign   = 'I'.
    ls_r-option = 'CP'.
    ls_r-low    = '*'.
    append ls_r to lr_remark.
  else.
    loop at it_remark into ls_in.
      clear ls_r.
      ls_r-sign   = ls_in-sign.
      ls_r-option = ls_in-option.
      ls_r-low    = ls_in-low.
      ls_r-high   = ls_in-high.
      append ls_r to lr_remark.
    endloop.
  endif.

  sort ct_mail by bukrs koart partner.

  data: lv_bukrs     type bukrs,
        lv_koart     type bseg-koart,
        lv_partner   type char10,
        lv_has_hit   type abap_bool,
        lv_first_idx type sy-tabix.

  field-symbols <ls> like line of ct_mail.
  data lv_idx type sy-tabix.

  do lines( ct_mail ) times.
    lv_idx = lines( ct_mail ) - sy-index + 1.

    read table ct_mail assigning <ls> index lv_idx.
    if sy-subrc <> 0.
      continue.
    endif.

    if lv_bukrs is initial
    or lv_bukrs   <> <ls>-bukrs
    or lv_koart   <> <ls>-koart
    or lv_partner <> <ls>-partner.

      lv_bukrs   = <ls>-bukrs.
      lv_koart   = <ls>-koart.
      lv_partner = <ls>-partner.

      lv_has_hit = abap_false.
      loop at ct_mail transporting no fields
        where bukrs   = lv_bukrs
          and koart   = lv_koart
          and partner = lv_partner
          and remark  is not initial
          and remark  in lr_remark.
        lv_has_hit = abap_true.
        exit.
      endloop.

      clear lv_first_idx.
      if lv_has_hit = abap_false.
        loop at ct_mail assigning <ls>
          where bukrs   = lv_bukrs
            and koart   = lv_koart
            and partner = lv_partner
            and remark  is initial.
          lv_first_idx = sy-tabix.
        endloop.
      endif.

      read table ct_mail assigning <ls> index lv_idx.
      if sy-subrc <> 0.
        continue.
      endif.
    endif.

    if lv_has_hit = abap_true.
      if <ls>-remark is initial or <ls>-remark not in lr_remark.
        delete ct_mail index lv_idx.
        continue.
      endif.
    else.
      if <ls>-remark is initial.
        if lv_first_idx is not initial and lv_idx <> lv_first_idx.
          delete ct_mail index lv_idx.
          continue.
        endif.
      endif.
    endif.
  enddo.
endmethod.


 METHOD build_partner_mail_data.

  DATA: lt_mail TYPE tt_mail,
        ls_mail TYPE ty_mail,
        ls_data TYPE gty_table.

  CLEAR ct_data.

  lt_mail = me->get_partner_mails( iv_bukrs = iv_bukrs
                                   it_koart = it_koart
                                   it_accno = it_accno
                                   lv_rule  = lv_rule
                                   it_remark = it_remark ).

  LOOP AT lt_mail INTO ls_mail.
    CLEAR ls_data.

    ls_data-bukrs = ls_mail-bukrs.
    ls_data-accno = ls_mail-partner.
    ls_data-koart = ls_mail-koart.
    ls_data-email = ls_mail-smtp_addr.
    ls_data-ptype = '5'.
    ls_data-remark = ls_mail-remark.
    ls_data-ename = ls_mail-name.

    ls_data-erdat = sy-datum.
    ls_data-erzet = sy-uzeit.
    ls_data-ernam = sy-uname.

    APPEND ls_data TO ct_data.
  ENDLOOP.


ENDMETHOD.


method get_next_parnr.
  data(lv_parnr) = value /mdpes/erec_t010-parnr( ).
  call function 'NUMBER_GET_NEXT'
    exporting
      nr_range_nr = c_nr_range_nr
      object      = c_nr_object
    importing
      number      = lv_parnr
    exceptions
      others      = 5.
  if sy-subrc <> 0 or lv_parnr is initial.
    message 'Numara aralığından PARNR alınamadı' type 'S' display like 'E'.
  endif.
  rv_parnr = lv_parnr.
endmethod.


method get_partner_mails.

  data: lv_sel_d type abap_bool,
        lv_sel_k type abap_bool.

  data: ls_koart type ty_r_koart.

  " KOART
  if it_koart is initial.
    lv_sel_d = abap_true.
    lv_sel_k = abap_true.
  else.
    clear: lv_sel_d, lv_sel_k.

    loop at it_koart into ls_koart.
      if ls_koart-sign = 'I' and ls_koart-option = 'EQ'.
        if ls_koart-low = 'D'.
          lv_sel_d = abap_true.
        elseif ls_koart-low = 'K'.
          lv_sel_k = abap_true.
        endif.
      endif.

      if ls_koart-sign = 'E' and ls_koart-option = 'EQ'.
        if ls_koart-low = 'D'.
          lv_sel_d = abap_false.
        elseif ls_koart-low = 'K'.
          lv_sel_k = abap_false.
        endif.
      endif.
    endloop.
  endif.

  " EMAIL
  data: lr_email type range of adr6-smtp_addr,
        ls_email like line of lr_email.

  clear: lr_email, ls_email.
  ls_email-sign   = 'I'.
  ls_email-option = 'CP'.
  ls_email-low    = '*'.
  append ls_email to lr_email.

  " ACCNO
  data: lr_kunnr type range of kna1-kunnr,
        ls_kunnr like line of lr_kunnr,
        lr_lifnr type range of lfa1-lifnr,
        ls_lifnr like line of lr_lifnr.

  data: ls_accno type ty_r_accno.

  clear: lr_kunnr, lr_lifnr.

  if it_accno is initial.
    clear ls_kunnr.
    ls_kunnr-sign   = 'I'.
    ls_kunnr-option = 'CP'.
    ls_kunnr-low    = '*'.
    append ls_kunnr to lr_kunnr.

    clear ls_lifnr.
    ls_lifnr-sign   = 'I'.
    ls_lifnr-option = 'CP'.
    ls_lifnr-low    = '*'.
    append ls_lifnr to lr_lifnr.
  else.
    loop at it_accno into ls_accno.
      clear ls_kunnr.
      ls_kunnr-sign   = ls_accno-sign.
      ls_kunnr-option = ls_accno-option.
      ls_kunnr-low    = ls_accno-low.
      ls_kunnr-high   = ls_accno-high.
      append ls_kunnr to lr_kunnr.

      clear ls_lifnr.
      ls_lifnr-sign   = ls_accno-sign.
      ls_lifnr-option = ls_accno-option.
      ls_lifnr-low    = ls_accno-low.
      ls_lifnr-high   = ls_accno-high.
      append ls_lifnr to lr_lifnr.
    endloop.
  endif.

  " BUKRS
  data: lr_bukrs type range of bukrs,
        ls_bukrs like line of lr_bukrs.

  clear: lr_bukrs, ls_bukrs.

  if iv_bukrs is initial.
    ls_bukrs-sign   = 'I'.
    ls_bukrs-option = 'CP'.
    ls_bukrs-low    = '*'.
    append ls_bukrs to lr_bukrs.
  else.
    ls_bukrs-sign   = 'I'.
    ls_bukrs-option = 'EQ'.
    ls_bukrs-low    = iv_bukrs.
    append ls_bukrs to lr_bukrs.
  endif.

  data: lr_remark    type range of adrt-remark,
        ls_remark    like line of lr_remark,
        ls_in_remark type ty_r_remark.

  data(lv_has_remark_filter) = xsdbool( it_remark is not initial ).

  clear lr_remark.
  if lv_has_remark_filter = abap_true.
    loop at it_remark into ls_in_remark.
      clear ls_remark.
      ls_remark-sign   = ls_in_remark-sign.
      ls_remark-option = ls_in_remark-option.
      ls_remark-low    = ls_in_remark-low.
      ls_remark-high   = ls_in_remark-high.
      append ls_remark to lr_remark.
    endloop.
  endif.

  clear rt_mail.

  "============================================================
  " MÜŞTERİ (D)
  "============================================================
  if lv_sel_d = abap_true.

    if lv_rule = '1'.

      if lv_has_remark_filter = abap_true.
        "---- RULE=1 + REMARK filtreli => INNER JOIN ADRT + remark IN
        select
            b~bukrs,
            a~kunnr as partner,
            'D'     as koart,
            a~adrnr,
            c~smtp_addr,
            t~remark,
            a~name1 as name
          from kna1 as a
          inner join knb1 as b
            on b~kunnr = a~kunnr
          inner join adr6 as c
            on c~addrnumber = a~adrnr
          inner join adrt as t
            on  t~addrnumber = c~addrnumber
            and t~consnumber = c~consnumber
            and t~langu      = @sy-langu
            and t~date_from  <= @sy-datum
          where b~bukrs     in @lr_bukrs
            and a~kunnr     in @lr_kunnr
            and c~smtp_addr in @lr_email
            and t~remark    in @lr_remark
          appending corresponding fields of table @rt_mail.

      else.
        "---- RULE=1 + REMARK filtresiz => LEFT JOIN ADRT (remark yoksa da gelsin)
        select
            b~bukrs,
            a~kunnr as partner,
            'D'     as koart,
            a~adrnr,
            c~smtp_addr,
            t~remark,
            a~name1 as name
          from kna1 as a
          inner join knb1 as b
            on b~kunnr = a~kunnr
          inner join adr6 as c
            on c~addrnumber = a~adrnr
          left outer join adrt as t
            on  t~addrnumber = c~addrnumber
            and t~consnumber = c~consnumber
            and t~langu      = @sy-langu
            and t~date_from  <= @sy-datum
          where b~bukrs     in @lr_bukrs
            and a~kunnr     in @lr_kunnr
            and c~smtp_addr in @lr_email
          appending corresponding fields of table @rt_mail.
      endif.

    else.
      "---- RULE != 1 (senin else mantığın) => remark filtresiz
      select
          b~bukrs,
          a~kunnr as partner,
          'D'     as koart,
          a~adrnr,
          c~smtp_addr,
          t~remark,
          a~name1 as name
        from kna1 as a
        inner join knb1 as b
          on b~kunnr = a~kunnr
        inner join adr6 as c
          on c~addrnumber = a~adrnr
        left outer join adrt as t
          on  t~addrnumber = c~addrnumber
          and t~consnumber = c~consnumber
          and t~langu      = @sy-langu
          and t~date_from  <= @sy-datum
        where b~bukrs     in @lr_bukrs
          and a~kunnr     in @lr_kunnr
          and c~smtp_addr in @lr_email
        appending corresponding fields of table @rt_mail.
    endif.

  endif.

  "============================================================
  " SATICI (K)
  "============================================================
  if lv_sel_k = abap_true.

    if lv_rule = '1'.

      if lv_has_remark_filter = abap_true.
        "---- RULE=1 + REMARK filtreli
        select
            b~bukrs,
            a~lifnr as partner,
            'K'     as koart,
            a~adrnr,
            c~smtp_addr,
            t~remark,
            a~name1 as name
          from lfa1 as a
          inner join lfb1 as b
            on b~lifnr = a~lifnr
          inner join adr6 as c
            on c~addrnumber = a~adrnr
          inner join adrt as t
            on  t~addrnumber = c~addrnumber
            and t~consnumber = c~consnumber
            and t~langu      = @sy-langu
            and t~date_from  <= @sy-datum
          where b~bukrs     in @lr_bukrs
            and a~lifnr     in @lr_lifnr
            and c~smtp_addr in @lr_email
            and t~remark    in @lr_remark
          appending corresponding fields of table @rt_mail.

      else.
        "---- RULE=1 + REMARK filtresiz
        select
            b~bukrs,
            a~lifnr as partner,
            'K'     as koart,
            a~adrnr,
            c~smtp_addr,
            t~remark,
            a~name1 as name
          from lfa1 as a
          inner join lfb1 as b
            on b~lifnr = a~lifnr
          inner join adr6 as c
            on c~addrnumber = a~adrnr
          left outer join adrt as t
            on  t~addrnumber = c~addrnumber
            and t~consnumber = c~consnumber
            and t~langu      = @sy-langu
            and t~date_from  <= @sy-datum
          where b~bukrs     in @lr_bukrs
            and a~lifnr     in @lr_lifnr
            and c~smtp_addr in @lr_email
          appending corresponding fields of table @rt_mail.
      endif.

    else.
      "---- RULE != 1
      select
          b~bukrs,
          a~lifnr as partner,
          'K'     as koart,
          a~adrnr,
          c~smtp_addr,
          t~remark,
          a~name1 as name
        from lfa1 as a
        inner join lfb1 as b
          on b~lifnr = a~lifnr
        inner join adr6 as c
          on c~addrnumber = a~adrnr
        left outer join adrt as t
          on  t~addrnumber = c~addrnumber
          and t~consnumber = c~consnumber
          and t~langu      = @sy-langu
          and t~date_from  <= @sy-datum
        where b~bukrs     in @lr_bukrs
          and a~lifnr     in @lr_lifnr
          and c~smtp_addr in @lr_email
        appending corresponding fields of table @rt_mail.
    endif.

  endif.

  sort rt_mail by bukrs partner koart adrnr smtp_addr remark.
  delete adjacent duplicates from rt_mail
    comparing bukrs partner koart adrnr smtp_addr remark.

  if lv_rule = '2'.
    me->apply_mail_rule(
      exporting
        iv_rule   = lv_rule
        it_remark = it_remark
      changing
        ct_mail   = rt_mail ).
  endif.

endmethod.


  method message_text_build.
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


method reset_loekz.

  ev_ok = abap_false.
  clear ev_msg.

  update /mdpes/erec_t010 set
        loekz = space
        aedat = sy-datum
        aezet = sy-uzeit
        aenam = sy-uname
      where parnr = is_row-parnr
        and bukrs = is_row-bukrs
        and koart = is_row-koart
        and accno = is_row-accno
        and email = is_row-email.

  if sy-subrc = 0.
    ev_ok = abap_true.
    ev_msg = |Kayıt başarıyla güncellendi.|.
  else.
    ev_msg = |Kayıt güncellenemedi.|.
  endif.

endmethod.


  method save_all.

    data: lv_update  type i,
          lv_saved   type i,
          lv_skipped type i,
          lv_total   type i.

    data: lv_errflds type string,
          lv_errmsg  type string.

    data: ls_return type bapiret1,
          lt_return type tt_bapiret1.

    field-symbols <ls> type ty_erec.

    data: lt_db_valid type standard table of /mdpes/erec_t010,
          ls_db       type /mdpes/erec_t010.
    data lt_insert_buffer type standard table of /mdpes/erec_t010 with empty key.



    clear: lv_update, lv_saved, lv_skipped, lv_total.

    loop at it_data assigning <ls>.
      lv_total = lv_total + 1.

      " Kırmızı → Hatalı, atla
      if <ls>-icon = '@0A@'.
        lv_skipped = lv_skipped + 1.
        continue.
      endif.

      " Sarı → Update
      if <ls>-icon = '@09@'.

        if <ls>-parnr is not initial.
          select single * from /mdpes/erec_t010
       where parnr = @<ls>-parnr
       into @data(ls_upd).
          if sy-subrc <> 0.
            message 'Güncellenecek kayıt bulunamadı (PARNR).' type 'S' display like 'E'.
            return.
          endif.

          <ls>-bukrs = ls_upd-bukrs.
          <ls>-erdat = ls_upd-erdat.
          <ls>-erzet = ls_upd-erzet.
          <ls>-parnr = ls_upd-parnr.

          if validate_for_alv_row(
              exporting
                is_data    =  <ls>                " global structure
             changing  es_return = ls_return
                        et_return = lt_return ) = abap_false.
            lv_skipped = lv_skipped + 1.
            return.
          endif.

          <ls>-aenam = sy-uname.
          <ls>-aedat = sy-datum.
          <ls>-aezet = sy-uzeit.

          update /mdpes/erec_t010 set
            email = @<ls>-email,
            ename = @<ls>-ename,
            telf1 = @<ls>-telf1,
            tckid = @<ls>-tckid,
            koart = @<ls>-koart,
            accno = @<ls>-accno,
            loekz = @<ls>-loekz,
            aedat = @<ls>-aedat,
            aezet = @<ls>-aezet,
            aenam = @<ls>-aenam
            where parnr = @<ls>-parnr.


          if sy-subrc = 0.

            commit work and wait.


            message 'Seçilen satır güncellendi' type 'S'.
          else.

            rollback work.
            message 'Satır güncellenemedi.' type 'S' display like 'E'.
          endif.

        else.
          select single * from /mdpes/erec_t010
            where bukrs = @<ls>-bukrs
              and koart = @<ls>-koart
              and accno = @<ls>-accno
              and email = @<ls>-email
            into @data(ls_old).

          if sy-subrc = 0.
            ls_old-ename = <ls>-ename.
            ls_old-tckid = <ls>-tckid.
            ls_old-telf1 = <ls>-telf1.
            ls_old-loekz = <ls>-loekz.
            ls_old-aenam = sy-uname.
            ls_old-aedat = sy-datum.
            ls_old-aezet = sy-uzeit.

            modify /mdpes/erec_t010 from ls_old.
            if sy-subrc = 0.
              lv_update = lv_update + 1.
            endif.
          endif.

          continue.
        endif.
      endif.


      " Yeşil → Insert
      if <ls>-icon = '@08@' or <ls>-icon = '@06@'.

        if validate_for_alv_row(
               exporting
                 is_data    =  <ls>
                changing  es_return = ls_return
                   et_return = lt_return ) = abap_false.
          lv_skipped = lv_skipped + 1.
          lv_skipped = lv_skipped + 1.
          continue.
        endif.


        if <ls>-parnr is initial.
          <ls>-parnr = get_next_parnr( ).
          <ls>-erdat = sy-datum.
          <ls>-erzet = sy-uzeit.
          <ls>-ernam = sy-uname.
        endif.

        if <ls>-parnr is initial.
          lv_skipped = lv_skipped + 1.
          continue.
        endif.

          if <ls>-loekz eq 'X'.
            <ls>-aenam  = sy-uname.
            <ls>-aedat  = sy-datum.
            <ls>-aezet  = sy-uzeit.
            endif.


        clear ls_db.
        move-corresponding <ls> to ls_db.

        " 3.4 Toplu insert bufferına ekleme
        append ls_db to lt_insert_buffer.

        lv_saved = lv_saved + 1.

        data ls_new type /mdpes/erec_t010.



      endif.




    endloop.



    "-----------------------------------------------
    " 4) TOPLU INSERT
    "-----------------------------------------------
    if lt_insert_buffer is not initial.

      sort lt_insert_buffer by parnr bukrs koart accno email.
      delete adjacent duplicates from lt_insert_buffer
        comparing parnr bukrs koart accno email.

      modify /mdpes/erec_t010 from table lt_insert_buffer.

    endif.
    commit work and wait.

    ev_saved   = lv_saved.
    ev_updated = lv_update.
    ev_skipped = lv_skipped.
    ev_total   = lv_total.

  endmethod.


  method SET_MESSAGE.
*-
    if es_return-type is initial .
      case es_return-number .
        when 0 .      es_return-type = 'S' .
        when others . es_return-type = 'E' .
      endcase .
    endif .

    CALL  METHOD /mdpes/erec_cl00=>message_text_build
      exporting
        iv_msgid = '/MDPES/EREC_MC01'
        iv_langu = sy-langu
        iv_msgno = es_return-number
        iv_msgv1 = es_return-message_v1
        iv_msgv2 = es_return-message_v2
        iv_msgv3 = es_return-message_v3
        iv_msgv4 = es_return-message_v4
         RECEIVING
      ev_message = es_return-message.

  endmethod.


method soft_delete.

  data: lv_key  type /mdpes/erec_t010-parnr,
        lv_text type c length 200.

  rv_affected = 0.

  if it_parnr is initial.
    return.
  endif.

  loop at it_parnr into lv_key.

    update /mdpes/erec_t010
      set loekz = 'X'
      where parnr = lv_key.

    if sy-subrc = 0.
      rv_affected = rv_affected + 1.
    endif.

  endloop.

  if rv_affected > 0 and iv_do_commit = abap_true.

    commit work and wait.

    clear lv_text.
    write rv_affected to lv_text.
    concatenate lv_text text-005 into lv_text separated by space.
    message lv_text type 'S'.

  elseif rv_affected = 0.

    message text-004 type 'S' display like 'E'.

  endif.

endmethod.


 method update.
   rv_ok = abap_false.
   cs_data = is_data.

   " Kayıt var mı?
   select single * from /mdpes/erec_t010
     where parnr = @is_data-parnr
     into @data(ls_old).
   if sy-subrc <> 0.
     message 'Güncellenecek kayıt bulunamadı (PARNR).' type 'S' display like 'E'.
     return.
   endif.

   " Korunan alanlar (akışına uygun)
   cs_data-bukrs = ls_old-bukrs.
   cs_data-erdat = ls_old-erdat.
   cs_data-erzet = ls_old-erzet.
   cs_data-parnr = ls_old-parnr.


   cs_data-aenam = sy-uname.
   cs_data-aedat = sy-datum.
   cs_data-aezet = sy-uzeit.

   update /mdpes/erec_t010 set
     email = @cs_data-email,
     ename = @cs_data-ename,
     telf1 = @cs_data-telf1,
     tckid = @cs_data-tckid,
     koart = @cs_data-koart,
     accno = @cs_data-accno,
     loekz = @cs_data-loekz,
     aedat = @cs_data-aedat,
     aezet = @cs_data-aezet,
     aenam = @cs_data-aenam
     where parnr = @cs_data-parnr.

   if sy-subrc = 0.
     if iv_do_commit = abap_true.
       commit work and wait.
     endif.
     message 'Seçilen satır güncellendi' type 'S'.
     rv_ok = abap_true.
   else.
     rollback work.
     message 'Satır güncellenemedi.' type 'S' display like 'E'.
   endif.
 endmethod.


method validate_for_alv_row.

  rv_ok = abap_true.

  clear: es_return.
  clear et_return.

  data: lv_email type string,
        lv_phone type string,
        lv_name  type string.


*--------------------------------------------------------------------*
* 1) E-POSTA KONTROLÜ
*--------------------------------------------------------------------*
  lv_email = |{ is_data-email }|.
  condense lv_email.

  if is_data-email is initial.

    clear es_return.
    es_return-number = '031'.

    set_message(
      changing
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.


  else.
    find regex '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'
      in lv_email ignoring case.
    if sy-subrc <> 0.

      clear es_return.
      es_return-number      = '032'.
      es_return-message_v1  = lv_email.

      set_message(
        changing
          es_return = es_return ).


      rv_ok = abap_false.

      append es_return to et_return.

    endif.
  endif.

*--------------------------------------------------------------------*
* 2) ŞİRKET KODU (BUKRS)
*--------------------------------------------------------------------*





  if is_data-bukrs is not initial.

    select single bukrs
      from t001
      where bukrs = @is_data-bukrs
      into @data(lv_bukrs).

    if sy-subrc <> 0.

      clear es_return.
      es_return-number     = '033'.
      es_return-message_v1 = |{ is_data-bukrs }|.

      set_message(
        changing
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    endif.

  else.

    clear es_return.
    es_return-number     = '033'.
    es_return-message_v1 = |{ is_data-bukrs }|.

    set_message(
      changing
        es_return = es_return ).
    rv_ok = abap_false.
    append es_return to et_return.
  endif.

*--------------------------------------------------------------------*
* 3) KOART
*--------------------------------------------------------------------*
  if is_data-koart is not initial
     and is_data-koart <> 'D'
     and is_data-koart <> 'K'.

    clear es_return.
    es_return-number     = '034'.
    es_return-message_v1 = |{ is_data-koart }|.

    set_message(
      changing
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  endif.

*--------------------------------------------------------------------*
* 4) MUHATAP (ACCNO)
*--------------------------------------------------------------------*
  if is_data-accno is initial.

    clear es_return.
    es_return-number = '035'.

    set_message(
      changing
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  elseif is_data-koart = 'D'.

    data(lv_kunnr) = is_data-accno.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = lv_kunnr
      importing
        output = lv_kunnr.

    select single kunnr from kna1 into @data(lv_kna1)
      where kunnr = @lv_kunnr.

    if sy-subrc <> 0.

      clear es_return.
      es_return-number     = '036'.
      es_return-message_v1 = |{ is_data-accno }|.

      set_message(
        changing
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    endif.

  elseif is_data-koart = 'K'.

    data(lv_lifnr) = is_data-accno.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = lv_lifnr
      importing
        output = lv_lifnr.

    select single lifnr from lfa1 into @data(lv_lfa1)
      where lifnr = @lv_lifnr.

    if sy-subrc <> 0.

      clear es_return.
      es_return-number     = '037'.
      es_return-message_v1 = |{ is_data-accno }|.

      set_message(
        changing
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    endif.
  endif.

*--------------------------------------------------------------------*
* 5) TCKN
*--------------------------------------------------------------------*
  if is_data-tckid is not initial.

    find regex '[^0-9]' in is_data-tckid.
    if sy-subrc = 0.

      clear es_return.
      es_return-number     = '038'.
      es_return-message_v1 = |{ is_data-tckid }|.

      set_message(
        changing
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    endif.

    if strlen( is_data-tckid ) <> 11.

      clear es_return.
      es_return-number     = '039'.
      es_return-message_v1 = |{ is_data-tckid }|.

      set_message(
        changing
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    endif.
  endif.

*--------------------------------------------------------------------*
* 6) İSİM (ENAME)
*--------------------------------------------------------------------*
*  if is_data-ename is not initial.
*
*    lv_name = |{ is_data-ename }|.
*    condense lv_name.
*
*    find regex '^[A-Za-zÇĞİÖŞÜçğıöşü''\- ]+$'
*      in lv_name ignoring case.
*    if sy-subrc <> 0.
*
*      clear es_return.
*      es_return-number     = '040'.
*      es_return-message_v1 = lv_name.
*
*      set_message(
*        changing
*          es_return = es_return ).
*
*
*      rv_ok = abap_false.
*      append es_return to et_return.
*
*    endif.
*  endif.

*--------------------------------------------------------------------*
* 7) LOEKZ
*--------------------------------------------------------------------*
  if is_data-loekz is not initial and is_data-loekz <> 'X'.

    clear es_return.
    es_return-number     = '041'.
    es_return-message_v1 = |{ is_data-loekz }|.

    set_message(
      changing
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  endif.

*--------------------------------------------------------------------*
* 8) PTYPE
*--------------------------------------------------------------------*
  if is_data-ptype is initial.

    clear es_return.
    es_return-number = '042'.

    set_message(
      changing
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  elseif is_data-ptype <> '1'
     and is_data-ptype <> '2'
     and is_data-ptype <> '3'
     and is_data-ptype <> '4'
     and is_data-ptype <> '5'.

    clear es_return.
    es_return-number     = '043'.
    es_return-message_v1 = |{ is_data-ptype }|.

    set_message(
      changing
        es_return = es_return ).


    rv_ok = abap_false.
    append es_return to et_return.

  endif.

*--------------------------------------------------------------------*
* 9) TELEFON
*--------------------------------------------------------------------*
  if is_data-telf1 is not initial.

    lv_phone = |{ is_data-telf1 }|.
    replace all occurrences of regex '[^0-9]' in lv_phone with ''.

    if strlen( lv_phone ) <> 10 and strlen( lv_phone ) <> 11.

      clear es_return.
      es_return-number     = '044'.
      es_return-message_v1 = lv_phone.

      set_message(
        changing
          es_return = es_return ).


      rv_ok = abap_false.
      append es_return to et_return.

    endif.
  endif.



endmethod.
ENDCLASS.
