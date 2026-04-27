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


      if go_report->control( is_data = gs_data ) = abap_false.
        return.
      endif.
      if g_screen_mode = 'C'. " Yaratma Modu

        data: lv_parnr type zmdik_erec-parnr.

        call function 'NUMBER_GET_NEXT'
          exporting
            nr_range_nr = '01'
            object      = '/MDPES/ER2'
          importing
            number      = lv_parnr
          exceptions
            others      = 5.

        if sy-subrc = 0.
          gs_data-parnr = lv_parnr.
        endif.

        gs_data-erdat = sy-datum.
        gs_data-erzet = sy-uzeit.
        gs_data-aedat = sy-datum.
        gs_data-aezet = sy-uzeit.
        gs_data-ernam = sy-uname.

        insert zmdik_erec from gs_data.
        if sy-subrc = 0.
          commit work and wait.
          message 'Yeni kayıt başarıyla oluşturuldu.' type 'S'.
          append gs_data to gt_data.
        else.
          rollback work.
          message 'Yeni kayıt oluşturulamadı.' type 'S' display like 'E'.
        endif.

      elseif g_screen_mode = 'U'. " Güncelleme Modu

        data lv_idx type i.

        read table gt_sel_map index 1 into lv_idx.

        if lv_idx > 0.
          data(ls_orig) = gt_data[ lv_idx ].

          gs_data-mandt = ls_orig-mandt.
          gs_data-bukrs = ls_orig-bukrs.
          gs_data-erdat = ls_orig-erdat.
          gs_data-erzet = ls_orig-erzet.
          gs_data-parnr = ls_orig-parnr.

          gs_data-aenam = sy-uname.
          gs_data-aedat = sy-datum.
          gs_data-aezet = sy-uzeit.

          update zmdik_erec from gs_data.
          if sy-subrc = 0.
            commit work and wait.
            message 'Seçilen satır güncellendi' type 'S'.
            modify gt_data from gs_data index lv_idx.
          else.
            rollback work.
            message 'Satır güncellenemedi.' type 'S' display like 'E'.
          endif.
        endif.
      endif.
       gv_init_0100 = abap_false.
      leave to screen 0.

    when '&CANCEL'.
      gv_init_0100 = abap_false.
      leave to screen 0.
  endcase.
endmodule.

module f4_muhatap input.

  go_report->f4_muhatap(
    exporting
      iv_ptype  = gs_erec-ptype      " Hesap Türü: D= müşteri, K= satıcı (senin koduna göre)
      iv_bukrs  = gs_erec-bukrs      " Şirket kodu (opsiyonel filtre)
    changing
      cv_muhatap = gs_erec-accno   " Ekran alanın
  ).
endmodule.
