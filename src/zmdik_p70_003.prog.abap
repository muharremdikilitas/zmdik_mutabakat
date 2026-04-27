*&---------------------------------------------------------------------*
*& Include          ZMDIK_P069_003
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_0100 output.
  set pf-status '0100'.
  set titlebar '0100'.

  if go_report is initial.
    create object go_report.
  endif.
endmodule.


module set_dynpro_screen output.

  case gv_proc_type.
    when '1'  .
      gv_dynpro_num = '0101'.
    when '2'  .
      gv_dynpro_num = '0101'.
    when '3'  .
      gv_dynpro_num = '0101'.
    when '4'  .
      gv_dynpro_num = '0101'.
    when '5'.
      gv_dynpro_num = '0102'.
    when others.
      clear gv_dynpro_num.
  endcase.

endmodule.

module control_fields output.
  loop at screen .
    case gv_proc_type.
**
      when '1'. " Int Comp EFT
        if screen-name = 'GV_SND_NAME'
          or screen-name = 'GV_SND_IBAN'
          or screen-name = 'GV_RVC_NAME'
          or screen-name = 'GV_RVC_AMOUNT'
          or screen-name = 'GV_RVC_IBAN'
          or screen-name = 'GV_RVC_PB'.
          screen-input = '0'.
          modify screen.
        endif.
      when '2'.
        if screen-name = 'GV_SND_NAME'
          or screen-name = 'GV_SND_IBAN'
          or screen-name = 'GV_RVC_NAME'
          or screen-name = 'GV_RVC_AMOUNT'
          or screen-name = 'GV_RVC_IBAN'
          or screen-name = 'GV_RVC_PB'
          or screen-name = 'GV_RVC_BANK'.
          screen-input = '0'.
          modify screen.
        endif.
      when '3' .
        if screen-name = 'GV_SND_IBAN'
          or screen-name = 'GV_RVC_AMOUNT'
          or screen-name = 'GV_RVC_PB'.
          screen-input = '0'.
          modify screen.
        endif.
        if screen-name = 'GV_SND_CUST_NO'
          or screen-name = 'GV_SND_NAME'
          or screen-name = 'GV_RCV_CUST_NO'
          or screen-name = 'GV_RVC_NAME'
          or screen-name = 'T4'
          or screen-name = 'T5'
          or screen-name = 'T11'
          or screen-name = 'T12'.
          screen-active = '0'.
          modify screen.
        endif.
      when '4' .
        if screen-name = 'GV_SND_IBAN'
          or screen-name = 'GV_RVC_AMOUNT'
          or screen-name = 'GV_RVC_BANK'
          or screen-name = 'GV_RVC_PB'.
          screen-input = '0'.
          modify screen.
        endif.
        if screen-name = 'GV_SND_CUST_NO'
           or screen-name = 'GV_SND_NAME'
           or screen-name = 'GV_RCV_CUST_NO'
           or screen-name = 'GV_RVC_NAME'
           or screen-name = 'T4'
           or screen-name = 'T5'
           or screen-name = 'T11'
           or screen-name = 'T12'.
          screen-active = '0'.
          modify screen.
        endif.
      when '5'.
        if screen-name = 'GV_FX_CURR'.
          if gv_fx_curr_type = 'S'.
            screen-input = '1'.
          else.
            screen-input = '0'.
          endif.
          modify screen.
        endif.

        if screen-name = 'GV_FX_IBAN'
        or screen-name = 'GV_FX_AMOUNT_TRANS'
        or screen-name = 'GV_FX_UPB_AMOUNT'.
          screen-input = '0'.
          modify screen.
        endif.

    endcase.
  endloop.
endmodule.
