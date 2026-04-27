*&---------------------------------------------------------------------*
*& Include          ZMDIK_P72_I004
*&---------------------------------------------------------------------*

MODULE user_command_0100 INPUT.

  CASE sy-ucomm.

    WHEN '&REPORT'.
      IF gv_proc_type = '1' OR gv_proc_type = '2' OR gv_proc_type = '3' OR gv_proc_type = '4'.
        CALL TRANSACTION 'ZMDP_001'.
      ELSE.
        CALL TRANSACTION 'ZMDP_002'.
      ENDIF.

    WHEN '&SAVE'.
      CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTER'.
      go_report->handle_save( ).

    WHEN '&BACK'.
      LEAVE TO SCREEN 0.

    WHEN 'CHG'.
      "tetiklendiğini göstermek için yapıyoruz
  ENDCASE.

ENDMODULE.

##DECL_MODUL
module islem.
  loop at screen.
    if screen-name = 'GV_FX_IBAN' or screen-name = 'GV_FX_PB'.
      screen-input = '1'.
      modify screen.
    endif.
  endloop.
endmodule.

module proc_type.

  IF go_report->mv_prev_proc IS INITIAL.
    go_report->mv_prev_proc = gv_proc_type.          "ilk geliş: referans al
  ELSEIF gv_proc_type <> go_report->mv_prev_proc.
    go_report->clear( ).                              "yalnızca değişimde temizle
    go_report->mv_prev_proc = gv_proc_type.
  ENDIF.

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
      go_report->module_case( ).
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
