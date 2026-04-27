*&---------------------------------------------------------------------*
*& Include          ZMDIK_P89_004
*&---------------------------------------------------------------------*

module status_0100 output.
  set pf-status '0200'.
  set titlebar 'xxx'.

  if gv_init_0100 is initial.
    move-corresponding gsy_data to gs_erec.
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
      move-corresponding gs_erec to gsy_data.

      if g_screen_mode = 'C'. " Yaratma Modu

        if go_srv->validate_for_alv_row(
         exporting is_data     = gsy_data
         importing ev_errflds  = lv_errflds
                   ev_errmsg   = lv_errmsg ) = abap_false.
          message lv_errmsg type 'S' display like 'E'.
          return.
        endif.

        clear gsy_data.

        gsy_data-parnr = gs_erec-parnr.
        gsy_data-bukrs = gs_erec-bukrs.
        gsy_data-koart = gs_erec-koart.
        gsy_data-accno = gs_erec-accno.
        gsy_data-ptype = gs_erec-ptype.
        gsy_data-loekz = gs_erec-loekz.
        gsy_data-ename = gs_erec-ename.
        gsy_data-email = gs_erec-email.
        gsy_data-telf1 = gs_erec-telf1.
        gsy_data-tckid = gs_erec-tckid.

        gsy_data-icon = '@08@'.

        append gsy_data to gty_data.

        go_srv->save_all(
           exporting
             it_data    = gty_data
           importing
             ev_saved   = lv_saved
             ev_updated = lv_updated
             ev_skipped = lv_skipped
             ev_total   = lv_total ).

        go_report->select_data( ).
        go_report->mo_alv->refresh( ).
        cl_gui_cfw=>flush( ).


      elseif g_screen_mode = 'U'. " --- UPDATE ---

        data lv_idx type i.
        read table gt_sel_map index 1 into lv_idx.
        if lv_idx > 0.

          data(ls_orig) = gty_data[ lv_idx ].

          gsy_data-parnr = ls_orig-parnr.
          gsy_data-bukrs = ls_orig-bukrs.
          gsy_data-erdat = ls_orig-erdat.
          gsy_data-erzet = ls_orig-erzet.

          if go_srv->validate_for_alv_row( exporting is_data     = gsy_data
                                           importing ev_errflds  = lv_errflds
                                                     ev_errmsg   = lv_errmsg ) = abap_false.
            message lv_errmsg type 'S' display like 'E'.
            return.
          endif.

          gsy_data-icon = '@09@'.
          modify gty_data from gsy_data index lv_idx.

          go_srv->save_all(
            exporting
              it_data    = gty_data
            importing
              ev_saved   = lv_saved
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
      iv_ptype  = gs_erec-ptype      " Hesap Türü: D= müşteri, K= satıcı
      iv_bukrs  = gs_erec-bukrs      " Şirket kodu
    changing
      cv_interlocutor = gs_erec-accno   " Ekran
  ).
endmodule.
