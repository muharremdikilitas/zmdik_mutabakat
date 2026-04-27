*&---------------------------------------------------------------------*
*& Include          ZMDIK_P89_004
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
               or 'GS_EREC-TELF1' or 'GS_EREC-TCKID'
            or 'GS_EREC-PTYPE'.
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

  data: lv_saved   type i,
        lv_updated type i,
        lv_skipped type i,
        lv_total   type i.

  case sy-ucomm.
    when '&OK'.
      move-corresponding gs_erec to gs_data.

      if g_screen_mode = 'C'. " Create

        if go_srv->validate_for_alv_row( exporting is_data = gs_data
                                         changing  es_return = ls_return
                                                   et_return = lt_return ) = abap_false.

          message ls_return-message type  'S' display like'E'.
          return.
        endif.

        clear gs_data.
        gs_data-parnr = gs_erec-parnr.
        gs_data-bukrs = gs_erec-bukrs.
        gs_data-koart = gs_erec-koart.
        gs_data-accno = gs_erec-accno.
        gs_data-ptype = gs_erec-ptype.
        gs_data-loekz = gs_erec-loekz.
        gs_data-ename = gs_erec-ename.
        gs_data-email = gs_erec-email.
        gs_data-telf1 = gs_erec-telf1.
        gs_data-tckid = gs_erec-tckid.

        gs_data-icon = '@08@'.
        append gs_data to gt_data.

        go_srv->save_all( exporting it_data    = gt_data
                          importing ev_saved   = lv_saved
                                    ev_updated = lv_updated
                                    ev_skipped = lv_skipped
                                    ev_total   = lv_total ).

        go_report->select_data( ).
        go_report->mo_alv->refresh( ).
        cl_gui_cfw=>flush( ).

      elseif g_screen_mode = 'U'. "Update

        read table gt_sel_map index 1 into data(lv_idx).
        if lv_idx > 0.
          data(ls_orig) = gt_data[ lv_idx ].

          gs_data-parnr = ls_orig-parnr.
          gs_data-bukrs = ls_orig-bukrs.
          gs_data-erdat = ls_orig-erdat.
          gs_data-erzet = ls_orig-erzet.

          if go_srv->validate_for_alv_row(  exporting is_data = gs_data
                                            changing  es_return = ls_return
                                                      et_return = lt_return ) = abap_false.

            message ls_return-message type  'S' display like'E'.
            return.
          endif.

          gs_data-icon = '@09@'.
          modify gt_data from gs_data index lv_idx.

          go_srv->save_all( exporting it_data    = gt_data
                            importing ev_saved   = lv_saved
                                      ev_updated = lv_updated
                                      ev_skipped = lv_skipped
                                      ev_total   = lv_total ).

          go_report->select_data( ).
          go_report->mo_alv->refresh( ).
          cl_gui_cfw=>flush( ).
        endif.
      endif.

      gv_init_0100 = abap_false.
      leave to screen 0.

    when '&CANCEL'.
      gv_init_0100 = abap_false.
      if go_report is bound and go_report->mo_alv is bound.
        go_report->mo_alv->refresh( ).
      endif.
      leave to screen 0.
  endcase.
endmodule.

module f4_interlocutor input.
  go_report->f4_interlocutor(
    exporting
      iv_ptype  = gs_erec-ptype
      iv_bukrs  = gs_erec-bukrs
    changing
      cv_interlocutor = gs_erec-accno
  ).
endmodule.
