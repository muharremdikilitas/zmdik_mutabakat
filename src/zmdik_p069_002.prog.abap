

*&---------------------------------------------------------------------*
*& Include          ZMDIK_P069_002
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZMDIK_P069_005
*&---------------------------------------------------------------------*

##CLASS_FINAL
class lcl_report definition.

  public section.
    data: mo_alv       type ref to cl_salv_table,
          mo_columns   type ref to cl_salv_columns_table,
          mo_column    type ref to cl_salv_column_table,
          mo_events    type ref to cl_salv_events_table,
          mo_selection type ref to cl_salv_selections.

    methods:
      save_data,
      select,
      check_required_fields,
      check_required_fields_fx,
      prepare_alv,
      create_alv,
      set_alv_properties,
      display_alv,
      talimat_report,
      module_case,
      gos_object importing iv_row type sy-tabix,
      gos_object_fx importing iv_row type sy-tabix,
      on_link_click for event link_click of cl_salv_events_table
        importing row column.
endclass.

class lcl_report implementation.
  method save_data.
    if gv_proc_type eq '1' or gv_proc_type eq '2' or gv_proc_type eq '3' or gv_proc_type eq '4' .
      data: lv_number type zmdp_t001-rec_id.

      call function 'NUMBER_GET_NEXT'
        exporting
          nr_range_nr = '01'
          object      = 'ZMDP_N001'
        importing
          number      = lv_number.
      gs_talimat-rec_id           = |{ lv_number }|.
      gs_talimat-proc_type        = gv_proc_type.
      gs_talimat-comp_code        = gv_comp_code.
      gs_talimat-time             = sy-uzeit.
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
      gs_talimat-icon_upload      = '@1U@'.

      append gs_talimat to gt_talimat.
      modify zmdp_t001 from table gt_talimat.
    else.
      data: lv_fx_number type zmdp_t002-rec_id.

      call function 'NUMBER_GET_NEXT'
        exporting
          nr_range_nr = '01'
          object      = 'ZMDP_N003'
        importing
          number      = lv_fx_number.
      gs_fx_talimat-rec_id            = |{ lv_fx_number }|.
      gs_fx_talimat-fx_comp_no        = gv_fx_comp_no.
      gs_fx_talimat-fx_time           = sy-uzeit.
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
      gs_fx_talimat-icon_upload       = '@1U@'.

      append gs_fx_talimat to gt_fx_talimat.
      modify zmdp_t002 from table gt_fx_talimat.
    endif.
  endmethod.
  method select.
    if gv_proc_type eq '1' or gv_proc_type eq '2' or gv_proc_type eq '3' or gv_proc_type eq '4'.
      select * from zmdp_t001 into table gt_talimat.
    else.
      select * from zmdp_t002 into table gt_fx_talimat.
    endif.
  endmethod.
  method check_required_fields.
    if gv_proc_type    is initial or
       gv_comp_code    is initial or
       gv_doc_date     is initial or
       gv_snd_acc_no   is initial or
       gv_amount       is initial or
       gv_rvc_acc_no   is initial or
       gv_rvc_amount   is initial or
       gv_rvc_iban     is initial or
       gv_rvc_pb       is initial.
      message text-001 type 'E'.
    endif.
  endmethod.
  method check_required_fields_fx.
    if  gv_fx_bank           is initial or
        gv_fx_iban           is initial or
        gv_fx_acc_no         is initial or
        gv_fx_amount         is initial or
        gv_fx_amount_trans   is initial or
        gv_fx_pb             is initial or
        gv_fx_pb_trans       is initial or
        gv_fx_valid_date     is initial or
        gv_fx_doc_date       is initial or
        gv_fx_upb_amount     is initial or
        gv_fx_curr_type      is initial or
        gv_fx_curr           is initial.
      message text-001 type 'E'.
    endif.
  endmethod.

  method create_alv.
    try.
        if gv_proc_type = 5.
          cl_salv_table=>factory(
            importing
              r_salv_table = mo_alv
            changing
              t_table      = gt_fx_talimat
          ).
        else.
          cl_salv_table=>factory(
            importing
              r_salv_table = mo_alv
            changing
              t_table      = gt_talimat
          ).
        endif.

        mo_columns = mo_alv->get_columns( ).
        mo_events  = mo_alv->get_event( ).

      catch cx_salv_msg into data(lo_error).
        message lo_error->get_text( ) type 'E'.
        return.
    endtry.
  endmethod.
  method set_alv_properties.
    set handler go_report->on_link_click for mo_events.
    mo_selection = mo_alv->get_selections( ).
    mo_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).

    mo_columns->set_optimize( abap_true ).
    data(lo_functions) = mo_alv->get_functions( ).
    lo_functions->set_all( abap_true ).
    try.
        mo_column ?= mo_columns->get_column( 'ICON' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
        mo_column->set_long_text( text-006 ).
        mo_column->set_short_text( 'PDF' ).
        ##NO_HANDLER
      catch cx_salv_not_found.
    endtry.
    try.
        mo_column ?= mo_columns->get_column( 'ICON_UPLOAD' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
        mo_column->set_long_text( text-003 ).
        ##NO_TEXT
        mo_column->set_short_text( 'Yükle' ).
        ##NO_HANDLER
      catch cx_salv_not_found.
    endtry.
  endmethod.

  method prepare_alv.
    if gv_proc_type eq '5'.
      me->check_required_fields_fx( ).
      me->create_alv( ).
      me->set_alv_properties( ).
      me->display_alv( ).
    else.
      me->check_required_fields( ).
      me->create_alv( ).
      me->set_alv_properties( ).
      me->display_alv( ).
    endif.
  endmethod.

  method display_alv.
    mo_alv->display( ).
  endmethod.

  method on_link_click.
    if gv_proc_type = '1' or gv_proc_type = '2' or gv_proc_type = '3' or gv_proc_type = '4'.
      read table gt_talimat into data(ls_row) index row.
      if sy-subrc <> 0.
        return.
      endif.

      if column = 'ICON'.
        gv_comp_code   = ls_row-comp_code.
        gv_doc_date    = ls_row-doc_date.
        gv_proc_type   = ls_row-proc_type.
        gv_snd_cust_no = ls_row-snd_cust_no.
        gv_snd_name    = ls_row-snd_name.
        gv_snd_bank    = ls_row-snd_bank.
        gv_snd_acc_no  = ls_row-snd_acc_no.
        gv_amount      = ls_row-amount.
        gv_snd_iban    = ls_row-snd_iban.
        gv_snd_pb      = ls_row-snd_pb.
        gv_rcv_cust_no = ls_row-rcv_cust_no.
        gv_rvc_name    = ls_row-rvc_name.
        gv_rvc_bank    = ls_row-rvc_bank.
        gv_rvc_acc_no  = ls_row-rvc_acc_no.
        gv_rvc_amount  = ls_row-rvc_amount.
        gv_rvc_iban    = ls_row-rvc_iban.
        gv_rvc_pb      = ls_row-rvc_pb.
        me->talimat_report( ).
      endif.
      if column = 'ICON_UPLOAD'.
        me->gos_object( iv_row = row  ).
      endif.
    else.
      read table gt_fx_talimat into data(ls_row_fx) index row.
      if sy-subrc <> 0.
        return.
      endif.
      if column = 'ICON'.
        gv_fx_comp_no          = ls_row_fx-fx_comp_no.
        gv_fx_bank             = ls_row_fx-fx_bank.
        gv_fx_iban             = ls_row_fx-fx_iban.
        gv_fx_acc_no           = ls_row_fx-fx_acc_no.
        gv_fx_amount           = ls_row_fx-fx_amount.
        gv_fx_amount_trans     = ls_row_fx-fx_amount_trans.
        gv_fx_pb               = ls_row_fx-fx_pb.
        gv_fx_pb_trans         = ls_row_fx-fx_pb_trans.
        gv_fx_valid_date       = ls_row_fx-fx_valid_date.
        gv_fx_doc_date         = ls_row_fx-fx_doc_date.
        gv_fx_upb_amount       = ls_row_fx-fx_upb_amount.
        gv_fx_curr_type        = ls_row_fx-fx_curr_type.
        gv_fx_curr             = ls_row_fx-fx_curr.
        me->talimat_report( ).
      endif.
      if column = 'ICON_UPLOAD'.
        me->gos_object_fx( iv_row = row ).
      endif.
    endif.
  endmethod.

  method talimat_report.

    if gv_proc_type = '1' or gv_proc_type = '3'.
      me->check_required_fields( ).
      data: lv_fm_name    type rs38l_fnam,
            ls_controls   type ssfctrlop,
            ls_output_opt type ssfcompop,
            lv_text       type string,
            lv_baslik     type string,
            lt_lines      type standard table of tline,
            ls_line       type tline,
            lv_amount_str type c length 30,
            lv_text_yazi  type spell,
            lv_amount     type p decimals 2.

      data: ls_com_info type zmdp_t003.
      ls_controls-no_dialog = abap_true.
      ls_controls-preview   = abap_true.
      ls_output_opt-tddest  = 'LP01'.

      write gv_amount to lv_amount_str right-justified decimals 2.
      condense lv_amount_str.
      lv_amount = gv_amount.

      call function 'SPELL_AMOUNT'
        exporting
          amount   = lv_amount
          currency = gv_snd_pb
          language = sy-langu
        importing
          in_words = lv_text_yazi.

      data(lv_clean_text) = lv_text_yazi-word.
      condense lv_clean_text no-gaps.

      " SO10 metni oku
      call function 'READ_TEXT'
        exporting
          id       = 'ST'
          name     = 'ZMDP_TXT001'
          language = sy-langu
          object   = 'TEXT'
        tables
          lines    = lt_lines.

      data: lv_line_index type sy-tabix.

      ##WARN_OK
      select single bankt into @data(lv_bank_name)
           from zeho_v002
           where bankc = @gv_snd_bank.

      lv_line_index = 0.
      loop at lt_lines into ls_line.
        lv_line_index = sy-tabix.

        replace '&1' in ls_line-tdline with lv_bank_name.
        replace '&2' in ls_line-tdline with gv_snd_iban.
        replace '&3' in ls_line-tdline with lv_amount_str.
        replace '&4' in ls_line-tdline with lv_clean_text.
        replace '&5' in ls_line-tdline with gv_rvc_bank.
        replace '&6' in ls_line-tdline with gv_rvc_iban.
        replace '&7' in ls_line-tdline with gv_snd_pb.

        " İlk satır ise başlığa, diğerleri metne
        if lv_line_index = 1.
          concatenate lv_baslik ls_line-tdline into lv_baslik separated by cl_abap_char_utilities=>newline.
        else.
          concatenate lv_text ls_line-tdline into lv_text separated by cl_abap_char_utilities=>newline.
        endif.

      endloop.
      select single * into ls_com_info
        from zmdp_t003
        where bukrs = gv_comp_code.

      call function 'SSF_FUNCTION_MODULE_NAME'
        exporting
          formname = 'ZMDP_SF002'
        importing
          fm_name  = lv_fm_name.

      call function lv_fm_name
        exporting
          control_parameters = ls_controls
          output_options     = ls_output_opt
          user_settings      = ' '
          iv_text            = lv_text
          iv_baslik          = lv_baslik
          iv_name1           = ls_com_info-name
          iv_logo            = ls_com_info-logo
          iv_address         = ls_com_info-adres
          iv_telno           = ls_com_info-telephone
          iv_faxno           = ls_com_info-fax
          iv_website         = ls_com_info-web_adres.

    elseif gv_proc_type = '2' or gv_proc_type = '4'.
      me->check_required_fields( ).
      ls_controls-no_dialog = abap_true.
      ls_controls-preview   = abap_true.
      ls_output_opt-tddest  = 'LP01'.

      write gv_amount to lv_amount_str right-justified decimals 2.      "chara çevir
      condense lv_amount_str.
      lv_amount = gv_amount.

      call function 'SPELL_AMOUNT'
        exporting
          amount   = lv_amount
          currency = gv_snd_pb
          language = sy-langu
        importing
          in_words = lv_text_yazi.

      ##NEEDED
      data: lv_clean_text_hv type string.
      lv_clean_text_hv = lv_text_yazi-word.
      condense lv_clean_text no-gaps.

      " SO10 metni oku
      call function 'READ_TEXT'
        exporting
          id       = 'ST'
          name     = 'ZMDP_TXT003'
          language = sy-langu
          object   = 'TEXT'
        tables
          lines    = lt_lines.
      ##WARN_OK
      select single bankt into @data(lv_bank_name_hv)
           from zeho_v002
           where bankc = @gv_snd_bank.

      lv_line_index = 0.
      loop at lt_lines into ls_line.
        lv_line_index = sy-tabix.

        replace '&1' in ls_line-tdline with lv_bank_name_hv.
        replace '&2' in ls_line-tdline with gv_snd_iban.
        replace '&3' in ls_line-tdline with lv_amount_str.
        replace '&4' in ls_line-tdline with lv_clean_text.
        replace '&5' in ls_line-tdline with gv_rvc_bank.
        replace '&6' in ls_line-tdline with gv_rvc_iban.
        replace '&7' in ls_line-tdline with gv_snd_pb.

        " İlk satır ise başlığa, diğerleri metne
        if lv_line_index = 1.
          concatenate lv_baslik ls_line-tdline into lv_baslik separated by cl_abap_char_utilities=>newline.
        else.
          concatenate lv_text ls_line-tdline into lv_text separated by cl_abap_char_utilities=>newline.
        endif.

      endloop.
      select single * into ls_com_info
        from zmdp_t003
        where bukrs = gv_comp_code.

      call function 'SSF_FUNCTION_MODULE_NAME'
        exporting
          formname = 'ZMDP_SF002'
        importing
          fm_name  = lv_fm_name.

      call function lv_fm_name
        exporting
          control_parameters = ls_controls
          output_options     = ls_output_opt
          user_settings      = ' '
          iv_text            = lv_text
          iv_baslik          = lv_baslik
          iv_name1           = ls_com_info-name
          iv_logo            = ls_com_info-logo
          iv_address         = ls_com_info-adres
          iv_telno           = ls_com_info-telephone
          iv_faxno           = ls_com_info-fax
          iv_website         = ls_com_info-web_adres.

    else.
      me->check_required_fields_fx( ).

      data: lv_fx_text         type string,
            lv_fx_baslik       type string,
            lt_fx_lines        type standard table of tline,
            ls_fx_line         type tline,
            lv_fx_amount_str_c type c length 30.

      data: lv_fx_amount_num   type p decimals 2,
            lv_fx_amount_spell type p decimals 0,
            lv_fx_text_yazi    type spell.

      data: lv_fx_amount_str     type c length 30,
            lv_fx_upb_amount_str type c length 30,
            lv_fx_currency       type c length 30.

      data: lv_fx_line_index type sy-tabix.

      ls_controls-no_dialog = abap_true.
      ls_controls-preview   = abap_true.
      ls_output_opt-tddest  = 'LP01'.

      call function 'READ_TEXT'
        exporting
          id       = 'ST'
          name     = 'ZMDP_TXT002'
          language = sy-langu
          object   = 'TEXT'
        tables
          lines    = lt_fx_lines.

      write gv_fx_amount_trans to lv_fx_amount_str_c right-justified decimals 2."currency 'EUR'.
      condense lv_fx_amount_str_c.

      lv_fx_amount_num = gv_fx_amount_trans.
      lv_fx_amount_spell = lv_fx_amount_num * 100.

      call function 'SPELL_AMOUNT'
        exporting
          amount   = lv_fx_amount_spell
          currency = gv_fx_pb_trans
          filler   = ' '
          language = sy-langu
        importing
          in_words = lv_fx_text_yazi.

      data(lv_fx_clean_text) = lv_fx_text_yazi-word.
      condense lv_fx_clean_text no-gaps.                  "boşluğu sil

      ##WARN_OK
      select single bankt into @data(lv_bank_fx_name)
    from zeho_v002
    where bankc = @gv_fx_bank.

      loop at lt_fx_lines into ls_fx_line.
        lv_fx_line_index = sy-tabix.

        replace '&1' in ls_fx_line-tdline with lv_bank_fx_name.
        replace '&2' in ls_fx_line-tdline with gv_fx_iban.
        replace '&3' in ls_fx_line-tdline with gv_fx_pb.
        replace '&4' in ls_fx_line-tdline with lv_fx_amount_str_c. " Yazı ile tutar
        replace '&5' in ls_fx_line-tdline with gv_fx_pb_trans.
        replace '&6' in ls_fx_line-tdline with lv_fx_clean_text.
        replace '&7' in ls_fx_line-tdline with gv_fx_pb_trans.

        if lv_fx_line_index = 1.
          concatenate lv_fx_baslik ls_fx_line-tdline into lv_fx_baslik separated by cl_abap_char_utilities=>newline.
        else.
          concatenate lv_fx_text ls_fx_line-tdline into lv_fx_text separated by cl_abap_char_utilities=>newline.
        endif.
      endloop.

      call function 'SSF_FUNCTION_MODULE_NAME'
        exporting
          formname           = 'ZMDP_SF003'
        importing
          fm_name            = lv_fm_name
        exceptions
          no_form            = 1
          no_function_module = 2
          others             = 3.
      if sy-subrc <> 0.
        message text-002 type 'E'.
      endif.

      select single * into ls_com_info
        from zmdpfin_db003
       where bukrs = gv_comp_code. " Ekrandan gelen şirket kodu

      write gv_fx_amount      to lv_fx_amount_str     .
      write gv_fx_upb_amount  to lv_fx_upb_amount_str .
      write gv_fx_curr        to lv_fx_currency .

      condense lv_fx_amount_str no-gaps.
      condense lv_fx_upb_amount_str no-gaps.
      condense lv_fx_currency no-gaps.

      call function lv_fm_name
        exporting
          control_parameters = ls_controls
          output_options     = ls_output_opt
          user_settings      = ' '
          iv_fx_text         = lv_fx_text
          iv_fx_baslik       = lv_fx_baslik
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
          iv_amount_str      = lv_fx_amount_str
          iv_upb_amount_str  = lv_fx_upb_amount_str
          iv_currency        = lv_fx_currency.
    endif.
  endmethod.

  method module_case.
    if gv_proc_type eq '1' or gv_proc_type eq '2' or gv_proc_type eq '3' or gv_proc_type eq '4'  .
      data: ls_t001 type t001.
      if gv_snd_cust_no is not initial.
        select single butxt from t001
              into corresponding fields of  @ls_t001
              where bukrs = @gv_snd_cust_no.
        gv_snd_name = ls_t001.
      endif.

      data: ls_t002 type t001.
      if gv_rcv_cust_no is not initial.
        select single butxt from t001
            into corresponding fields of  @ls_t002
            where bukrs = @gv_rcv_cust_no.
        gv_rvc_name = ls_t002.
      endif.

      data: ls_bukrs type t001.
      select single bukrs from t001
        into corresponding fields of ls_bukrs
        where bukrs = gv_comp_code.
      gv_comp_code = ls_bukrs-bukrs.

      data: ls_snd_comp type t001.
      select single bukrs from t001
        into corresponding fields of ls_snd_comp
        where bukrs = gv_snd_cust_no.
      gv_snd_cust_no = ls_snd_comp-bukrs.

      data: ls_rcv_comp type t001.
      select single bukrs from t001
        into corresponding fields of ls_rcv_comp
       where bukrs  = gv_rcv_cust_no.
      gv_rcv_cust_no = ls_rcv_comp-bukrs.

      data: ls_account type zeho_t002.
      if gv_snd_acc_no is not initial.
        ##WARN_OK
        select single  iban, waers
           from zeho_t002
          into corresponding fields of @ls_account
          where hktid = @gv_snd_acc_no.
        gv_snd_iban = ls_account-iban.
        gv_snd_pb   = ls_account-waers.
        gv_rvc_pb   = ls_account-waers.
      endif.

      data: ls_rcv_account type zeho_t002.
      if gv_rvc_acc_no is not initial.
        ##WARN_OK
        select single  iban
           from zeho_t002
          into corresponding fields of @ls_rcv_account
          where hktid = @gv_rvc_acc_no.
        gv_rvc_iban = ls_rcv_account-iban.
      endif.
      gv_rvc_amount = gv_amount.
    endif.
  endmethod.

  method gos_object.
    data: lo_gos_manager type ref to cl_gos_manager,
          ls_borident    type borident.
    constants: objtype type borident-objtype value 'ZMDIK_P03'.

    read table gt_talimat into gs_talimat index iv_row .

    ls_borident-objtype = objtype.
    ls_borident-objkey  = gs_talimat-comp_code && gs_talimat-rec_id.

    clear lo_gos_manager .
    create object lo_gos_manager
      exporting
        is_object    = ls_borident
        ip_no_commit = ''
      exceptions
        others       = 1.

    if sy-subrc <> 0.
      return.
    endif.

    call method lo_gos_manager->start_service_direct
      exporting
        ip_service       = 'VIEW_ATTA'
        is_object        = ls_borident
        ip_no_check      = 'X'
      exceptions
        no_object        = 1
        object_invalid   = 2
        execution_failed = 3
        others           = 4.

    if sy-subrc <> 0.
      return.
    endif.
  endmethod.

  method gos_object_fx.
    data: lo_gos_manager type ref to cl_gos_manager,
          ls_borident    type borident.

    constants: objtype type borident-objtype value 'ZMDIK_P04'.

    read table gt_talimat into gs_talimat index iv_row .
    if sy-subrc <> 0.
      return.
    endif.

    ls_borident-objtype = objtype.
    ls_borident-objkey  = gs_fx_talimat-fx_comp_no && gs_fx_talimat-rec_id.

    clear lo_gos_manager .
    create object lo_gos_manager
      exporting
        is_object    = ls_borident
        ip_no_commit = ''
      exceptions
        others       = 1.
    if sy-subrc <> 0.
      return.
    endif.

    call method lo_gos_manager->start_service_direct
      exporting
        ip_service       = 'VIEW_ATTA'
        is_object        = ls_borident
        ip_no_check      = 'X'
      exceptions
        no_object        = 1
        object_invalid   = 2
        execution_failed = 3
        others           = 4.
    if sy-subrc <> 0.
      return.
    endif.
  endmethod.
endclass.
