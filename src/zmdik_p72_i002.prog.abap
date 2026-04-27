*&---------------------------------------------------------------------*
*& Include          ZMDIK_P72_I002
*&---------------------------------------------------------------------*
##CLASS_FINAL
class lcl_report definition.

  public section.
    data: mo_alv       type ref to cl_salv_table,
          mo_columns   type ref to cl_salv_columns_table,
          mo_column    type ref to cl_salv_column_table,
          mo_events    type ref to cl_salv_events_table,
          mo_selection type ref to cl_salv_selections,
          mv_prev_proc type c length 1.
    methods:
      save_data
        changing
          cv_rec_id_t001 type zmdp_t001-rec_id optional
          cv_rec_id_t002 type zmdp_t002-rec_id optional,
      report,
      check_required_fields
        returning value(rv_valid) type abap_bool,
      check_required_fields_fx
        returning value(rv_valid) type abap_bool,
      module_case
        returning value(rv_check) type abap_bool,
      handle_save
        returning value(lv_answer) type abap_bool,
      clear.
endclass.

class lcl_qe_report definition.
  public section.
    data: gt_zeho type standard table of zeho_t011,
          gs_zeho type zeho_t011.

    methods:
      alv_display,
      rcv_alv_buyer.
endclass.

class lcl_qe_report implementation.

  method alv_display.

    set pf-status '0200'.
    set titlebar 'xxx'.

    if go_alv is initial. " İlk kez açılıyorsa
      create object go_cont
        exporting
          container_name = 'CC_ALV'.

      create object go_alv
        exporting
          i_parent = go_cont.

      call method go_alv->set_table_for_first_display
        exporting
          i_structure_name = 'ZMDPFIN_S003'
        changing
          it_outtab        = gt_data.

    else. " ALV zaten varsa sadece refresh et

      call method go_alv->refresh_table_display
        exporting
          is_stable = value lvc_s_stbl( row = 'X' col = 'X' )
        exceptions
          finished  = 1
          others    = 2.
    endif.
  endmethod.

  method rcv_alv_buyer.

    set pf-status '0200'.
    set titlebar 'xxx'.

    if go_rcv_alv is initial.

      create object go_cont
        exporting
          container_name = 'CC_ALV2'.

      create object go_rcv_alv
        exporting
          i_parent = go_cont.

      call method go_rcv_alv->set_table_for_first_display
        exporting
          i_structure_name = 'ZMDPFIN_S004'
        changing
          it_outtab        = gt_rcv_data.

    else.

      call method go_rcv_alv->refresh_table_display
        exporting
          is_stable      = value lvc_s_stbl( row = 'X' col = 'X' )
          i_soft_refresh = abap_false.

    endif.
  endmethod.
endclass.

class lcl_report implementation.
  method save_data.
    data: lv_time type string.
    lv_time = |{ sy-uzeit+0(2) }:{ sy-uzeit+2(2) }:{ sy-uzeit+4(2) }|.
    if gv_proc_type eq '1' or gv_proc_type eq '2' or gv_proc_type eq '3' or gv_proc_type eq '4' .
      data: lv_number type zmdp_t001-rec_id.
      if gv_comp_code is initial and gv_doc_date is initial and gv_rvc_bank is initial and gv_rvc_acc_no is initial.
        return.
      endif.
      call function 'NUMBER_GET_NEXT'
        exporting
          nr_range_nr = '01'
          object      = 'ZMDP_N001'
        importing
          number      = lv_number.
      cv_rec_id_t001 = lv_number.
      clear gs_talimat.
      gs_talimat-rec_id           = |{ lv_number }|.
      gs_talimat-proc_type        = gv_proc_type.
      gs_talimat-comp_code        = gv_comp_code.
      gs_talimat-time             = lv_time.
      gs_talimat-name             = sy-uname.
      gs_talimat-doc_date         = gv_doc_date.
      gs_talimat-snd_cust_no      = gv_snd_cust_no.
      gs_talimat-snd_name         = gv_snd_name.
      gs_talimat-snd_bank         = gv_snd_bank.
      gs_talimat-snd_acc_no       = gv_snd_acc_no.
      gs_talimat-amount           = gv_amount.
      gs_talimat-snd_iban         = gv_snd_iban.
      gs_talimat-snd_pb           = gv_snd_pb.
      gs_talimat-rcv_cust_no      = gv_rcv_cust_no.
      gs_talimat-rvc_name         = gv_rvc_name.
      gs_talimat-rvc_bank         = gv_rvc_bank.
      gs_talimat-rvc_acc_no       = gv_rvc_acc_no.
      gs_talimat-rvc_amount       = gv_rvc_amount.
      gs_talimat-rvc_iban         = gv_rvc_iban.
      gs_talimat-rvc_pb           = gv_rvc_pb.
      gs_talimat-icon             = '@0S@'.
      gs_talimat-icon_upload      = '@0A@'.
      append gs_talimat to gt_talimat.
      if gv_proc_type eq '1'.
        modify zmdp_t001 from table gt_talimat.
      elseif gv_proc_type eq '2'.
        modify zmdp_t004 from table gt_talimat.
      elseif gv_proc_type eq '3'.
        modify zmdp_t005 from table gt_talimat.
      elseif gv_proc_type eq '4'.
        modify zmdp_t006 from table gt_talimat.
      endif.
      clear gs_talimat.
    else.
      data: lv_fx_number type zmdp_t002-rec_id.
      if gv_fx_bank is initial and gv_fx_iban is initial and gv_fx_acc_no is initial.
        return.
      endif.
      call function 'NUMBER_GET_NEXT'
        exporting
          nr_range_nr = '01'
          object      = 'ZMDP_N003'
        importing
          number      = lv_fx_number.

      cv_rec_id_t002 = lv_fx_number.
      clear gs_fx_talimat.
      gs_fx_talimat-rec_id            = |{ lv_fx_number }|.
      gs_fx_talimat-fx_comp_no        = gv_comp_code.
      gs_fx_talimat-fx_time           = lv_time.
      gs_fx_talimat-fx_date           = gv_doc_date.
      gs_fx_talimat-fx_uname          = sy-uname.
      gs_fx_talimat-fx_bank           = gv_fx_bank.
      gs_fx_talimat-fx_iban           = gv_fx_iban.
      gs_fx_talimat-fx_iban2          = gv_fx_iban2.
      gs_fx_talimat-fx_acc_no         = gv_fx_acc_no.
      gs_fx_talimat-fx_amount         = gv_fx_amount.
      gs_fx_talimat-fx_amount_trans   = gv_fx_amount_trans.
      gs_fx_talimat-fx_pb             = gv_fx_pb.
      gs_fx_talimat-fx_pb_trans       = gv_fx_pb_trans.
      gs_fx_talimat-fx_valid_date     = gv_fx_valid_date.
      gs_fx_talimat-fx_doc_date       = gv_fx_doc_date.
      gs_fx_talimat-fx_upb_amount     = gv_fx_upb_amount.
      gs_fx_talimat-fx_curr_type      = gv_fx_curr_type.
      gs_fx_talimat-fx_curr           = gv_fx_curr.
      gs_fx_talimat-icon              = '@0S@'.
      gs_fx_talimat-icon_upload        = '@0A@'.
      append gs_fx_talimat to gt_fx_talimat.
      modify zmdp_t002 from gs_fx_talimat.
    endif.
  endmethod.

  method check_required_fields.
    types: begin of ty_required,
             field_name type string,
             label      type string,
           end of ty_required.

    data: lt_required type table of ty_required,
          ls_required type ty_required.
    field-symbols: <val> type any.
    rv_valid = abap_true.
    lt_required = value #(
      ( field_name = 'gv_proc_type'        label = text-t01 )
      ( field_name = 'gv_comp_code'        label = text-011 )
      ( field_name = 'gv_doc_date'         label = text-012 )
      ( field_name = 'gv_snd_acc_no'       label = text-013 )
      ( field_name = 'gv_amount'           label = text-014 )
      ( field_name = 'gv_rvc_acc_no'       label = text-015 )
      ( field_name = 'gv_rvc_amount'       label = text-016 )
      ( field_name = 'gv_rvc_iban'         label = text-017 )
      ( field_name = 'gv_rvc_pb'           label = text-018 )
      ( field_name = 'gv_snd_cust_no'      label = text-046 )
      ( field_name = 'gv_snd_bank'         label = text-047 )
      ( field_name = 'gv_rvc_bank'         label = text-048 )
      ( field_name = 'gv_rcv_cust_no'      label = text-049 )
    ).

    if gv_proc_type = '3' or gv_proc_type = '4'.
      delete lt_required where field_name = 'gv_rcv_cust_no'
                           or field_name = 'gv_snd_cust_no'.
    endif.

    loop at lt_required into ls_required.
      assign (ls_required-field_name) to <val>.
      if sy-subrc = 0 and <val> is initial.
        message |{ ls_required-label } alanı boş bırakılamaz!| type 'W' display like 'I'.
        rv_valid = abap_false.
        return.
      endif.
    endloop.
  endmethod.
  method check_required_fields_fx.
    types: begin of ty_required,
             field_name type string,
             label      type string,
           end of ty_required.

    data: lt_required type table of ty_required,
          ls_required type ty_required.

    field-symbols: <val> type any.
    rv_valid = abap_true.

    lt_required = value #(
      ( field_name = 'gv_comp_code'         label = text-011 )
      ( field_name = 'gv_doc_date'          label = text-041 )
      ( field_name = 'gv_fx_bank'           label = text-019 )
      ( field_name = 'gv_fx_iban'           label = text-020 )
      ( field_name = 'gv_fx_acc_no'         label = text-021 )
      ( field_name = 'gv_fx_amount'         label = text-014 )
      ( field_name = 'gv_fx_amount_trans'   label = text-022 )
      ( field_name = 'gv_fx_pb'             label = text-023 )
      ( field_name = 'gv_fx_pb_trans'       label = text-024 )
      ( field_name = 'gv_fx_valid_date'     label = text-025 )
      ( field_name = 'gv_fx_doc_date'       label = text-026 )
      ( field_name = 'gv_fx_upb_amount'     label = text-027 )
      ( field_name = 'gv_fx_curr_type'      label = text-028 )
      ( field_name = 'gv_fx_curr'           label = text-029 )
      ( field_name = 'gv_fx_acc_no_2'       label = text-042 )
      ( field_name = 'gv_fx_iban2'          label = text-043 )

    ).
    loop at lt_required into ls_required.
      assign (ls_required-field_name) to <val>.
      if sy-subrc = 0 and <val> is initial.
        message |{ ls_required-label } alanı boş bırakılamaz!| type 'W' display like 'I'.
        rv_valid = abap_false.
        return.
      endif.
    endloop.
  endmethod.

  method module_case.
    rv_check = abap_true.
    data(lv_skip_cust_checks) = xsdbool( gv_proc_type = '3' or gv_proc_type = '4' ).

    if gv_proc_type eq '1' or gv_proc_type eq '2' or gv_proc_type eq '3' or gv_proc_type eq '4'  .

      data: comp_code type zeho_t002.
      if gv_comp_code is not initial .
        select single bukrs
        into corresponding fields of @comp_code
        from zeho_t002
        where bukrs = @gv_comp_code.
        if sy-subrc <> 0 .
          message text-044 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      data: ls_t001 type t001.
      if ( lv_skip_cust_checks = abap_false ) and ( gv_snd_cust_no is not initial ).
        select single butxt from t001
        into corresponding fields of  @ls_t001
        where bukrs = @gv_snd_cust_no.
        if sy-subrc = 0.
          gv_snd_name = ls_t001-butxt.
          condense gv_snd_name.
        else.
          message text-036 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      data: ls_t002 type t001.
      if ( lv_skip_cust_checks = abap_false ) and ( gv_rcv_cust_no is not initial ).
        select single butxt from t001
        into corresponding fields of  @ls_t002
        where bukrs = @gv_rcv_cust_no.
        if sy-subrc = 0.
          gv_rvc_name = ls_t002-butxt.
          condense gv_rvc_name.
        else.
          message text-037 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      if ( lv_skip_cust_checks = abap_false ) and ( gv_snd_cust_no is not initial ).
        data: ls_snd_comp type t001.
        select single bukrs from t001
        into corresponding fields of ls_snd_comp
        where bukrs = gv_snd_cust_no.
        if sy-subrc <> 0.
          message text-036 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      data: ls_snd_bank type zeho_t002.
      if gv_snd_bank is not initial.
        select single bankc
          from zeho_t002
          into corresponding fields of ls_snd_bank
          where bankc = gv_snd_bank.
        if sy-subrc <> 0.
          message text-050 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      data: ls_rcv_bank type zeho_t002.
      if gv_rvc_bank is not initial.
        select single bankc
          from zeho_t002
          into corresponding fields of ls_rcv_bank
          where bankc = gv_rvc_bank.
        if sy-subrc <> 0.
          message text-051 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      if gv_snd_acc_no is not initial.
        select single iban, waers
          into ( @gv_snd_iban, @gv_snd_pb )
          from zeho_t002
          where bukrs = @gv_snd_cust_no
                and bankc = @gv_snd_bank
                and hktid = @gv_snd_acc_no.
        if sy-subrc <> 0.
          message text-038 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      if gv_rvc_acc_no is not initial.
        select single iban, waers
         into ( @gv_rvc_iban, @gv_rvc_pb )
           from zeho_t002
         where bukrs = @gv_rcv_cust_no
               and bankc = @gv_rvc_bank
               and hktid = @gv_rvc_acc_no.
        if sy-subrc = 0.
          gv_rvc_amount = gv_amount.
        else.
          message text-039 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

    else.
      data: comp_code_fx type zeho_t002.
      if gv_comp_code is not initial .
        select single bukrs
          into corresponding fields of @comp_code_fx
          from zeho_t002
          where bukrs = @gv_comp_code.
        if sy-subrc <> 0 .
          message text-044 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      data: ls_fx_account type zeho_t002.
      if gv_fx_acc_no is not initial.
        ##WARN_OK
        select single  iban, waers
           from zeho_t002
          into corresponding fields of @ls_fx_account
          where hktid = @gv_fx_acc_no.
        if sy-subrc = 0 .
          gv_fx_iban = ls_fx_account-iban.
          gv_fx_pb   = ls_fx_account-waers.
        else.
          message text-038 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      data: ls_fx_account_2 type zeho_t002.
      if gv_fx_acc_no_2 is not initial.
        ##WARN_OK
        select single  iban, waers
           from zeho_t002
          into corresponding fields of @ls_fx_account_2
          where hktid = @gv_fx_acc_no_2.
        if sy-subrc = 0.
          gv_fx_iban2     = ls_fx_account-iban.
          gv_fx_pb_trans  = ls_fx_account-waers.
        else.
          message text-039 type 'S'.
          rv_check = abap_false.
        endif.
      endif.

      data: ls_bank type zeho_t002.
      if gv_fx_bank is not initial.
        select single hbkid
          from zeho_t002
          into corresponding fields of ls_bank
          where bankc = gv_fx_bank.
        if sy-subrc <> 0.
          message text-045 type 'S'.
          rv_check = abap_false.
        endif.
      endif.
    endif.
  endmethod.

  method report.
    data: lv_smartform  type tdsfname,
          lv_text_name  type thead-tdname,
          lv_fm_name    type rs38l_fnam,
          lt_lines      type standard table of tline,
          ls_line       type tline,
          lv_text       type string,
          lv_baslik     type string,
          lv_line_index type sy-tabix,
          lv_clean_text type string,
          lv_bank_name  type string.

    data: lv_amount_spell   type p decimals 0,
          lv_amount_str     type c length 30,
          lv_upb_amount_str type c length 30,
          lv_fx_currency    type c length 30,
          lv_text_yazi      type spell.

    data: ls_controls   type ssfctrlop,
          ls_output_opt type ssfcompop,
          ls_com_info   type zmdp_t003.

    data lv_char type char10.

    lv_char = gv_doc_date+6(2) && '.' && gv_doc_date+4(2) && '.' && gv_doc_date(4).

    select single smartform_name, text_name
    into (@lv_smartform, @lv_text_name)
    from zsmartform_map
    where proc_type = @gv_proc_type
      and bukrs       = @gv_comp_code.
    if sy-subrc <> 0.
      message text-009 type 'E'.
    endif.

    call function 'SSF_FUNCTION_MODULE_NAME'
      exporting
        formname = lv_smartform
      importing
        fm_name  = lv_fm_name.
    ##FM_SUBRC_OK
    if sy-subrc <> 0.
      message text-010 type 'E'.
    endif.

    ls_controls-no_dialog = abap_true.
    ls_controls-preview   = abap_true.
    ls_output_opt-tddest  = 'LP01'.

    call function 'READ_TEXT'
      exporting
        id       = 'ST'
        name     = lv_text_name
        language = sy-langu
        object   = 'TEXT'
      tables
        lines    = lt_lines.

    select single * into ls_com_info
      from zmdp_t003
      where bukrs = gv_comp_code.

    if gv_proc_type = '5'.
      me->check_required_fields_fx( ).

      write gv_fx_amount_trans to lv_amount_str.
      write gv_fx_upb_amount   to lv_upb_amount_str.
      write gv_fx_curr         to lv_fx_currency.
      condense: lv_amount_str, lv_upb_amount_str, lv_fx_currency.
      lv_amount_spell = gv_fx_amount_trans * 100.

      call function 'SPELL_AMOUNT'
        exporting
          amount   = lv_amount_spell
          currency = gv_fx_pb_trans
          filler   = ' '
          language = sy-langu
        importing
          in_words = lv_text_yazi.

      lv_clean_text = lv_text_yazi-word.
      condense lv_clean_text no-gaps.
      ##WARN_OK
      select single bankt into @lv_bank_name
           from zeho_v002
           where bankc = @gv_fx_bank.

      loop at lt_lines into ls_line.
        lv_line_index = sy-tabix.

        replace '&1' in ls_line-tdline with lv_bank_name.
        replace '&2' in ls_line-tdline with gv_fx_iban.
        replace '&3' in ls_line-tdline with gv_fx_pb.
        replace '&4' in ls_line-tdline with lv_amount_str.
        replace '&5' in ls_line-tdline with gv_fx_pb_trans.
        replace '&6' in ls_line-tdline with lv_clean_text.
        replace '&7' in ls_line-tdline with gv_fx_pb_trans.

        if lv_line_index = 1.
          concatenate lv_baslik ls_line-tdline into lv_baslik separated by cl_abap_char_utilities=>newline.
        else.
          concatenate lv_text ls_line-tdline into lv_text separated by cl_abap_char_utilities=>newline.
        endif.
      endloop.

      call function lv_fm_name
        exporting
          control_parameters = ls_controls
          output_options     = ls_output_opt
          user_settings      = ' '
          iv_tarih           = lv_char
          iv_fx_text         = lv_text
          iv_fx_baslik       = lv_baslik
          iv_fx_name1        = ls_com_info-name
          iv_logo            = ls_com_info-logo
          iv_fx_address      = ls_com_info-adres
          iv_fx_telno        = ls_com_info-telephone
          iv_fx_faxno        = ls_com_info-fax
          iv_fx_website      = ls_com_info-web_adres
          iv_pb              = gv_fx_pb
          iv_pb_target       = gv_fx_pb_trans
          iv_iban            = gv_fx_iban
          iv_iban2           = gv_fx_iban2
          iv_amount_str      = lv_amount_str
          iv_upb_amount_str  = lv_upb_amount_str
          iv_currency        = lv_fx_currency.
    else.
      me->check_required_fields( ).
      write gv_amount to lv_amount_str.
      condense lv_amount_str.

      call function 'SPELL_AMOUNT'
        exporting
          amount   = gv_amount
          currency = gv_snd_pb
          language = sy-langu
        importing
          in_words = lv_text_yazi.

      lv_clean_text = lv_text_yazi-word.
      condense lv_clean_text no-gaps.
      ##WARN_OK
      select single bankt into @lv_bank_name
            from zeho_v002
            where bankc = @gv_snd_bank.

      loop at lt_lines into ls_line.
        lv_line_index = sy-tabix.
        replace '&1' in ls_line-tdline with lv_bank_name.
        replace '&2' in ls_line-tdline with gv_snd_iban.
        replace '&3' in ls_line-tdline with gv_snd_pb.
        replace '&4' in ls_line-tdline with lv_amount_str.
        replace '&5' in ls_line-tdline with gv_rvc_bank.
        replace '&6' in ls_line-tdline with lv_clean_text.
        replace '&7' in ls_line-tdline with gv_rvc_iban.

        if lv_line_index = 1.
          concatenate lv_baslik ls_line-tdline into lv_baslik separated by cl_abap_char_utilities=>newline.
        else.
          concatenate lv_text ls_line-tdline into lv_text separated by cl_abap_char_utilities=>newline.
        endif.
      endloop.

      call function lv_fm_name
        exporting
          control_parameters = ls_controls
          output_options     = ls_output_opt
          user_settings      = ' '
          iv_tarih           = lv_char
          iv_text            = lv_text
          iv_baslik          = lv_baslik
          iv_name1           = ls_com_info-name
          iv_logo            = ls_com_info-logo
          iv_address         = ls_com_info-adres
          iv_telno           = ls_com_info-telephone
          iv_faxno           = ls_com_info-fax
          iv_website         = ls_com_info-web_adres.
    endif.
  endmethod.

  method handle_save.
    data: lv_valid       type abap_bool,
          lv_valid_2     type abap_bool,
          lv_answer1     type c,
          lv_answer2     type c,
          lv_rec_id_t001 type zmdp_t001-rec_id,
          lv_rec_id_t002 type zmdp_t002-rec_id,
          lv_question    type string,
          lv_message     type string.

    lv_answer = abap_false.

    if gv_proc_type = '5'.
      lv_valid = me->check_required_fields_fx( ).
      lv_valid_2 = me->module_case( ).

    else.
      lv_valid = me->check_required_fields( ).
      lv_valid_2 = me->module_case( ).
    endif.

    if lv_valid <> abap_true or lv_valid_2 <> abap_true.
      return.

    else.
      me->save_data(
   changing
     cv_rec_id_t001 = lv_rec_id_t001
     cv_rec_id_t002 = lv_rec_id_t002 ).

      if gv_proc_type = '5'.
        concatenate lv_rec_id_t002 text-040 into lv_message separated by space.
        message lv_message type 'S'.
      else.
        concatenate lv_rec_id_t001 text-040 into lv_message separated by space.
        message lv_message type 'S'.
      endif.
    endif.

    if gv_proc_type = '5'.
      concatenate lv_rec_id_t002 text-030 into lv_question separated by space.
    else.
      concatenate lv_rec_id_t001 text-030 into lv_question separated by space.
    endif.

    call function 'POPUP_TO_CONFIRM'
      exporting
        titlebar              = text-031
        text_question         = lv_question
        text_button_1         = text-032
        text_button_2         = text-033
        default_button        = '2'
        display_cancel_button = ''
      importing
        answer                = lv_answer1.

    if lv_answer1 = '2'.
      message text-007 type 'S'.
      go_report->clear( ).
      return.
    endif.

    if lv_answer1 = '1'.

      me->report( ).
      go_report->clear( ).
    else.
      message text-008 type 'S'.
    endif.
  endmethod.

  method clear.
    if gv_proc_type eq '5'.
      clear:
      gv_doc_date,
      gv_fx_bank,
      gv_fx_iban,
      gv_fx_iban2,
      gv_fx_acc_no,
      gv_fx_amount,
      gv_fx_amount_trans,
      gv_fx_pb,
      gv_fx_pb_trans,
      gv_fx_valid_date,
      gv_fx_doc_date,
      gv_fx_upb_amount,
      gv_fx_curr_type,
      gv_fx_curr.
    else.
      clear:
       gv_comp_code,
       gv_doc_date,
       gv_snd_cust_no,
       gv_snd_name,
       gv_snd_bank,
       gv_snd_acc_no,
       gv_amount,
       gv_snd_iban,
       gv_snd_pb,
       gv_rcv_cust_no,
       gv_rvc_name,
       gv_rvc_bank,
       gv_rvc_acc_no,
       gv_rvc_amount,
       gv_rvc_iban,
       gv_rvc_pb.
    endif.
  endmethod.
endclass.
