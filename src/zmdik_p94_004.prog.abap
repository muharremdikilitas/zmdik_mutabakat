*&---------------------------------------------------------------------*
*& Include          ZMDIK_P90_004
*&---------------------------------------------------------------------*


module status_0100 output.
  set pf-status '0200'.
  set titlebar 'xxx'.

  if gv_init_0100 is initial.
    move-corresponding gs_data to gs_erec.
    gv_init_0100 = abap_true.
  endif.

  loop at screen.
    if screen-name cp 'GS_EREC-*'.

      if g_screen_mode = 'C'.
        case screen-name.
          when 'GS_EREC-PARNR' or 'GS_EREC-ERDAT' or 'GS_EREC-ERZET'
            or 'GS_EREC-AEDAT' or 'GS_EREC-AEZET' or 'GS_EREC-AENAM'.
            screen-input = 0.
          when others.
            screen-input = 1.
        endcase.
      elseif g_screen_mode = 'U'.
        case screen-name.
          when 'GS_EREC-PARNR' or 'GS_EREC-ERDAT' or 'GS_EREC-ERZET'
            or 'GS_EREC-AEDAT' or 'GS_EREC-AEZET' or 'GS_EREC-AENAM'.
            screen-input = 0.
          when 'GS_EREC-EMAIL' or 'GS_EREC-ENAME'
               or 'GS_EREC-TELF1' or 'GS_EREC-TCKID'.
            screen-input = 1.
          when others.
            screen-input = 0.
        endcase.
      endif.

      modify screen.
    endif.
  endloop.
endmodule.

module user_command_0100 input.

endmodule.

module f4_s input.

endmodule.
