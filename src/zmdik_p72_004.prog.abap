*&---------------------------------------------------------------------*
*& Include          ZMDIK_P069_004
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

module user_command_0100 input.

  case sy-ucomm .
    when '&REPORT'.
      call screen '0103'.
    when '&SAVE'.
      go_report->handle_save( ).
    when '&BACK' .
      set screen 0.
    when 'CHG'.                           "tetiklendiğini göstermek için yapıyoruz
  endcase.
endmodule.
##DECL_MODUL
module islem.
  data: ls_fx_account type zeho_t002.
  if gv_fx_acc_no is not initial.
    ##WARN_OK
    select single  iban, waers
       from zeho_t002
      into corresponding fields of @ls_fx_account
      where hktid = @gv_fx_acc_no.
    gv_fx_iban = ls_fx_account-iban.
    gv_fx_pb   = ls_fx_account-waers.
  endif.

  data: ls_fx_account_2 type zeho_t002.
  if gv_fx_acc_no_2 is not initial.
    ##WARN_OK
    select single  iban, waers
       from zeho_t002
      into corresponding fields of @ls_fx_account_2
      where hktid = @gv_fx_acc_no_2.
    gv_fx_iban2     = ls_fx_account-iban.
    gv_fx_pb_trans  = ls_fx_account-waers.
  endif.

  loop at screen.
    if screen-name = 'GV_FX_IBAN' or screen-name = 'GV_FX_PB'.
      screen-input = '1'.
      modify screen.
    endif.
  endloop.
endmodule.

module proc_type.
  case gv_proc_type.
    when '1' .
      go_report->module_case( ).
    when '2'.
      go_report->module_case( ).
      gv_rvc_bank = gv_snd_bank.
    when '3'.
      gv_snd_cust_no = gv_rcv_cust_no = gv_comp_code.
      go_report->module_case( ).
    when '4'.
      gv_snd_cust_no = gv_rcv_cust_no = gv_comp_code.
      go_report->module_case( ).
      gv_rvc_bank = gv_snd_bank.
    when '5'.
  endcase.
endmodule.

module user_command_0102 input.
  case sy-ucomm.
    when 'FXCHG'.
  endcase.
endmodule.
##DECL_MODUL
module fx_spot_calc input.
  if gv_fx_curr_type = 'S'.
    data: lv_rate       type ukurs.
    data: lv_amt type p  decimals 2,
          lv_cur type p  decimals 5,
          lv_res type p  decimals 2.

    if gv_fx_amount is not initial and gv_fx_curr is not initial.
      lv_amt = gv_fx_amount.
      lv_cur = gv_fx_curr.
      lv_res = lv_amt * lv_cur.
      gv_fx_amount_trans = lv_res.
      gv_fx_upb_amount   = lv_amt.
    else.
      clear: gv_fx_amount_trans, gv_fx_upb_amount.
    endif.

  elseif gv_fx_curr_type = 'M'.
    call function 'CONVERT_TO_LOCAL_CURRENCY'
      exporting
        client           = sy-mandt
        date             = gv_fx_valid_date
        foreign_amount   = gv_fx_amount
        foreign_currency = gv_fx_pb
        local_currency   = gv_fx_pb_trans
        type_of_rate     = gv_fx_curr_type
      importing
        exchange_rate    = lv_rate
        local_amount     = gv_fx_amount_trans
      exceptions
        no_rate_found    = 1
        overflow         = 2
        no_factors_found = 3
        no_spread_found  = 4
        derived_2_times  = 5
        others           = 6.

    if sy-subrc = 0.
      gv_fx_curr        = lv_rate.
      gv_fx_upb_amount = gv_fx_amount_trans.
    else.
      clear: gv_fx_curr, gv_fx_amount_trans, gv_fx_upb_amount.
      message text-004 type 'S'.
    endif.

    if gv_fx_pb <> 'TRY'.
      ##NEEDED
      data: lv_try_rate   type ukurs,
            lv_try_amount type p length 15 decimals 2.

      call function 'CONVERT_TO_LOCAL_CURRENCY'
        exporting
          client           = sy-mandt
          date             = gv_fx_valid_date
          foreign_amount   = gv_fx_amount
          foreign_currency = gv_fx_pb
          local_currency   = 'TRY'
          type_of_rate     = gv_fx_curr_type
        importing
          exchange_rate    = lv_try_rate
          local_amount     = lv_try_amount
        exceptions
          no_rate_found    = 1
          overflow         = 2
          no_factors_found = 3
          no_spread_found  = 4
          derived_2_times  = 5
          others           = 6.

      if sy-subrc = 0.
        gv_fx_upb_amount = lv_try_amount.
      else.
        clear gv_fx_upb_amount.
        message text-005 type 'S'.
      endif.
    else.
      gv_fx_upb_amount = gv_fx_amount.
    endif.
  endif.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0103 input.

  data lv_valid type abap_bool.
  case sy-ucomm .

    when '&REPORT'.
      if gv_proc_type = '1' or  gv_proc_type = '2' or  gv_proc_type = '3' or  gv_proc_type = '4'.
        lv_valid = go_report->check_required_fields( ).
        if lv_valid = abap_true.
          go_report->save_data( ).
        endif.
        call transaction 'ZMDP_001'.

      else.
        lv_valid = go_report->check_required_fields_fx( ).
        if lv_valid = abap_true.
          go_report->save_data( ).
        endif.
        call transaction 'ZMDP_002'.

      endif.
    when '&SAVE'.
      go_report->handle_save( ).
    when '&BACK' .
      set screen 0.
    when 'CHG'.                           "tetiklendiğini göstermek için yapıyoruz
  endcase.
endmodule.
