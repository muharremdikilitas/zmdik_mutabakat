*&---------------------------------------------------------------------*
*& Include          ZMDIK_P73_I002
*&---------------------------------------------------------------------*
class lcl_report definition.

  public section.
    data: mo_alv       type ref to cl_salv_table,
          mo_columns   type ref to cl_salv_columns_table,
          mo_column    type ref to cl_salv_column_table,
          mo_events    type ref to cl_salv_events_table,
          mo_selection type ref to cl_salv_selections.

    methods:
      select,
      prepare_alv,
      create_alv,
      set_alv_properties,
      display_alv,
      report,
      gos_object_fx importing iv_row type sy-tabix,
      on_link_click for event link_click of cl_salv_events_table
        importing row column,
      check_gos_attachment_exists
        importing is_borident type borident
        exporting ev_exists   type abap_bool.
endclass.

class lcl_report implementation.
  method select.
    select * from zmdp_t002 into corresponding fields of table @gt_fx_talimat.
  endmethod.

  method prepare_alv.
    data lv_valid type abap_bool.

    me->select( ).
    me->create_alv( ).
    me->set_alv_properties( ).
    me->display_alv( ).
  endmethod.

  method create_alv.
    try.
        cl_salv_table=>factory(
          importing
            r_salv_table = mo_alv
          changing
            t_table      = gt_fx_talimat
        ).
        mo_columns = mo_alv->get_columns( ).
        mo_events  = mo_alv->get_event( ).
      catch cx_salv_msg into data(lo_error).
        message lo_error->get_text( ) type 'S'.
        return.
    endtry.
  endmethod.

  method set_alv_properties.
    set handler go_report->on_link_click for mo_events.
    mo_selection = mo_alv->get_selections( ).
    mo_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).
    set handler me->on_link_click for mo_events.

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

DATA: gr_layout TYPE REF TO cl_salv_layout,
      gs_key    TYPE salv_s_layout_key.

gr_layout = mo_alv->get_layout( ).
gs_key-report = sy-repid.
gr_layout->set_key( gs_key ).
gr_layout->set_default( abap_true ).
gr_layout->set_initial_layout( space ).
gr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
  endmethod.

  method display_alv.
    mo_alv->display( ).
  endmethod.

  method on_link_click.

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
      me->report( ).
    endif.
    if column = 'ICON_UPLOAD'.
      me->gos_object_fx( iv_row = row ).
      data(ls_borident) = value borident(
      objtype = 'ZMDIK_P04'
      objkey  = gs_fx_talimat-fx_comp_no && gs_fx_talimat-rec_id ).

      data(lv_gos_exists) = abap_false.
      me->check_gos_attachment_exists(
        exporting is_borident = ls_borident
        importing ev_exists   = lv_gos_exists ).

      if lv_gos_exists = abap_true.
        gs_fx_talimat-icon_upload = '@08@'. " yeşil
      else.
        gs_fx_talimat-icon_upload = '@0A@'. " kırmızı
      endif.

      modify gt_fx_talimat from gs_fx_talimat index row.
      update zmdp_t002 set icon_upload = gs_fx_talimat-icon_upload
                           where rec_id = gs_fx_talimat-rec_id.
      mo_alv->refresh( ).
    endif.
  endmethod.

  method gos_object_fx.
    data: lo_gos_manager type ref to cl_gos_manager,
          ls_borident    type borident.

    constants: objtype type borident-objtype value 'ZMDIK_P04'.

    read table gt_fx_talimat into gs_fx_talimat index iv_row .
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

  method check_gos_attachment_exists.

    data: lt_connections type standard table of bdn_con with default key,
          lv_classname   type sbdst_classname.

    case is_borident-objtype.
      when 'ZMDIK_P03'. lv_classname = 'ZMDIK_P03'.
      when 'ZMDIK_P04'. lv_classname = 'ZMDIK_P04'.
    endcase.

    call function 'BDS_GOS_CONNECTIONS_GET'
      exporting
        classname       = lv_classname
        objkey          = is_borident-objkey
      tables
        gos_connections = lt_connections
      exceptions
        others          = 1.

    if sy-subrc = 0 and lt_connections is not initial.
      ev_exists = abap_true.
    else.
      ev_exists = abap_false.
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
  endmethod.
endclass.
