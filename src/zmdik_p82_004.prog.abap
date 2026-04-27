*&---------------------------------------------------------------------*
*& Include          ZMDIK_P79_004
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module  STATUS_0100  OUTPUT
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

  case sy-ucomm.

    when '&OK'.
      move-corresponding gs_erec to gs_data.

      if g_screen_mode = 'C'.    " --- CREATE ---
        if go_srv->validate( is_data = gs_data ) = abap_false.
          return.
        endif.

        if go_srv->create(
             exporting is_data      = gs_data
             changing  cs_data      = gs_data
           ) = abap_true.

          append gs_data to gt_data.

          append initial line to <gt_disp> assigning <gs_disp>.
          if <gs_disp> is assigned.
            move-corresponding gs_data to <gs_disp>.
            field-symbols: <loekz_ic> type any.
            assign component 'LOEKZ'    of structure <gs_disp> to <loekz>.
            assign component 'LOEKZ_IC' of structure <gs_disp> to <loekz_ic>.
            if <loekz_ic> is assigned.
              <loekz_ic> = cond #( when <loekz> is assigned and <loekz> = 'X' then icon_delete else space ).
            endif.
          endif.

          go_report->mo_alv->refresh( ).
          cl_gui_cfw=>flush( ).
        endif.
      elseif g_screen_mode = 'U'. " --- UPDATE ---

        data lv_idx type i.
        read table gt_sel_map index 1 into lv_idx.
        if lv_idx > 0.

          data(ls_orig) = gt_data[ lv_idx ].

          gs_data-parnr = ls_orig-parnr.
          gs_data-bukrs = ls_orig-bukrs.
          gs_data-mandt = ls_orig-mandt.
          gs_data-erdat = ls_orig-erdat.
          gs_data-erzet = ls_orig-erzet.

          if go_srv->validate( is_data = gs_data ) = abap_false.
            return.
          endif.
          " Güncelle
          if go_srv->update(
               exporting is_data      = gs_data
               changing  cs_data      = gs_data
             ) = abap_true.

            modify gt_data from gs_data index lv_idx.
            read table <gt_disp> index lv_idx assigning <gs_disp>.
            if sy-subrc = 0 and <gs_disp> is assigned.
              move-corresponding gs_data to <gs_disp>.
              assign component 'LOEKZ'    of structure <gs_disp> to <loekz>.
              assign component 'LOEKZ_IC' of structure <gs_disp> to <loekz_ic>.
              if <loekz_ic> is assigned.
                <loekz_ic> = cond #( when <loekz> is assigned and <loekz> = 'X' then icon_delete else space ).
              endif.
            endif.

            go_report->mo_alv->refresh( ).
            cl_gui_cfw=>flush( ).
          endif.
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

module f4_muhatap input.

  go_report->f4_muhatap(
    exporting
      iv_ptype  = gs_erec-ptype
      iv_bukrs  = gs_erec-bukrs
    changing
      cv_muhatap = gs_erec-accno
  ).
endmodule.
