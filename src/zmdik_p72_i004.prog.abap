*&---------------------------------------------------------------------*
*& Include          ZMDIK_P72_I004
*&---------------------------------------------------------------------*

module user_command_0100 input.

  case sy-ucomm.
    when '&REPORT'.
      if gv_proc_type = '1' or gv_proc_type = '2' or gv_proc_type = '3' or gv_proc_type = '4'.
        call transaction 'ZMDP_001'.
      else.
        call transaction 'ZMDP_002'.
      endif.

    when '&SAVE'.
      call method cl_gui_cfw=>set_new_ok_code
        exporting
          new_code = 'ENTER'.
      go_report->handle_save( ).

    when '&QUICK'.

      gv_qe_comp_code = gv_comp_code.
      gv_qe_bank = gv_snd_bank.
      gv_qe_date = gv_doc_date.

      call method cl_gui_cfw=>set_new_ok_code
        exporting
          new_code = 'ENTER'.

      call function 'ZMDPFIN_FM007'
        exporting
          iv_bank      = gv_snd_bank
          iv_comp_code = gv_comp_code
          iv_date      = gv_doc_date
        tables
          et_result    = gt_data.

      call screen 0103 starting at 10 10
                       ending at   80 0.
    when '&BACK'.
      leave to screen 0.

    when 'CHG'.   "tetiklendiğini göstermek için yapıyoruz
  endcase.
endmodule.

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

  if go_report->mv_prev_proc is initial.
    go_report->mv_prev_proc = gv_proc_type.          "ilk geliş: referans al
  elseif gv_proc_type <> go_report->mv_prev_proc.
    go_report->clear( ).                              "yalnızca değişimde temizle
    go_report->mv_prev_proc = gv_proc_type.
  endif.

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

module user_command_0103 input.
  data: ls_left  type zmdpfin_s003,
        ls_right type zmdpfin_s004.

  case sy-ucomm.
    when '&CANCEL'.
      free gt_data.
      clear : gv_qe_rcv_date,gv_qe_rcv_cc,
      gv_qe_rcv_bank,gv_qe_rcv_pb.

      free gt_rcv_data.
      qe_alv_report->rcv_alv_buyer( ).
      leave to screen 0 .

    when 'BTN1'.
      call function 'ZMDPFIN_FM008'
        exporting
          iv_qe_rcv_date = gv_qe_rcv_date
          iv_qe_rcv_cc   = gv_qe_rcv_cc
          iv_qe_rcv_bank = gv_qe_rcv_bank
          iv_qe_rcv_pb   = gv_qe_rcv_pb
        tables
          et_result      = gt_rcv_data.

      qe_alv_report->rcv_alv_buyer( ).

    when '&OK'.

      call function 'ZMDPFIN_FM009'
        exporting
          io_alv_right   = go_rcv_alv
          io_alv_left    = go_alv
          it_table_right = gt_rcv_data
          it_table_left  = gt_data
        importing
          es_row_right   = ls_right
          es_row_left    = ls_left.

      if ls_left is initial or ls_right is initial.
        message 'Her iki ALV için de seçim yapmalısınız' type 'S'.
        return.
      endif.

      gv_amount = ls_left-amount.
      gv_snd_acc_no = ls_left-hktid.
      gv_snd_pb = ls_left-waers.
      gv_rvc_acc_no = ls_right-hktid.
      gv_rvc_bank = ls_right-bankc.
      gv_rvc_pb = ls_right-waers.
      gv_rvc_amount = ls_right-amount.
      leave to screen 0.

  endcase.
endmodule.
