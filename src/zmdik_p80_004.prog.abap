*&---------------------------------------------------------------------*
*& Include          ZMDIK_P79_004
*&---------------------------------------------------------------------*

module status_0100 output.
  set pf-status '0200'.
* SET TITLEBAR 'xxx'.
endmodule.

module user_command_0100 input.
  case sy-ucomm.
    when '&OK'.

      if go_alv is bound.
        go_alv->check_changed_data( ).
      endif.

      if gt_one is initial.
        message 'Popup verisi boş' type 'S' display like 'E'.
        leave to screen 0.
        return.
      endif.

      if g_screen_mode = 'C'. " Yaratma Modu
        data: ls_check type zmdik_erec.

        loop at gt_one into ls_check.
          if ls_check-email is initial.
            message 'E-posta adresi zorunludur.' type 'S'.
            return.
          endif.
          if ls_check-email cs '@'
             and ls_check-email cs '.'.
          else.
            message 'Geçersiz e-posta formatı.' type 'S'.
            return.
          endif.
        endloop.
        data: ls_new type zmdik_erec.
        loop at gt_one into ls_new.

          data: lv_parnr type zmdik_erec-parnr.
          call function 'NUMBER_GET_NEXT'
            exporting
              nr_range_nr            = '01'
              object                 = '/MDPES/ER2'
            importing
              number                 = lv_parnr
            exceptions
              interval_not_found     = 1
              number_range_not_found = 2
              quantity_is_zero       = 3
              quantity_is_negative   = 4
              others                 = 5.

          if sy-subrc = 0.
            ls_new-parnr = lv_parnr.
          endif.
          ls_new-erdat = sy-datum.
          ls_new-erzet = sy-uzeit.
          ls_new-aedat = sy-datum.
          ls_new-aezet = sy-uzeit.
          ls_new-aenam = sy-uname.

          insert zmdik_erec from ls_new.
          if sy-subrc = 0.
            commit work and wait.
            message 'Yeni kayıt başarıyla oluşturuldu.' type 'S'.
            append ls_new to gt_data.
            go_report->mo_alv->refresh( ).
          else.
            rollback work.
            message 'Yeni kayıt oluşturulamadı.' type 'S' display like 'E'.
          endif.
        endloop.

      elseif g_screen_mode = 'U'. " Güncelleme Modu
        data:
          lv_idx       type i,
          lv_popup_row type sy-tabix,
          lv_db_errors type i.

        loop at gt_one into ls_new.
          lv_popup_row = sy-tabix.

          read table gt_sel_map index lv_popup_row into lv_idx.
          if sy-subrc = 0 and lv_idx > 0.
            data(ls_orig) = gt_data[ lv_idx ].
            ls_new-mandt = ls_orig-mandt.
            ls_new-bukrs = ls_orig-bukrs.
            ls_new-erdat = ls_orig-erdat.
            ls_new-erzet = ls_orig-erzet.
            ls_new-aenam = sy-uname.
            ls_new-aedat = sy-datum.
            ls_new-aezet = sy-uzeit.
            ls_new-parnr = ls_orig-parnr.

            modify gt_data from ls_new index lv_idx.
          endif.

          update zmdik_erec from ls_new.
          if sy-subrc <> 0.
            lv_db_errors += 1.
          endif.
        endloop.

        if lv_db_errors = 0.
          commit work and wait.
          message 'Seçilen satırlar güncellendi' type 'S'.
        else.
          rollback work.
          message |{ lv_db_errors } satır güncellenemedi.| type 'S' display like 'E'.
        endif.

      endif.
      leave to screen 0.
    when '&CANCEL'.
      leave to screen 0.
  endcase.
endmodule.

module build_popup_cc output.

  set pf-status '0200'.
  set titlebar 'xxx'.

  if go_cont is initial.
    create object go_cont
      exporting
        container_name = 'CC_ALV'.
  endif.

  if go_alv is initial.
    create object go_alv
      exporting
        i_parent = go_cont.
  endif.

  data: lt_fcat     type lvc_t_fcat,
        ls_fcat     type lvc_s_fcat,
        ls_layout   type lvc_s_layo,
        lt_editable type standard table of fieldname with empty key.

  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_structure_name = 'ZMDIK_EREC'
    changing
      ct_fieldcat      = lt_fcat
    exceptions
      others           = 1.

  constants: lc_fixed_width type i value 12.

  loop at lt_fcat into ls_fcat.
    ls_fcat-outputlen = lc_fixed_width.
    modify lt_fcat from ls_fcat.
  endloop.

  if g_screen_mode = 'C'.
    loop at lt_fcat into ls_fcat.
      ls_fcat-edit = abap_true.
      modify lt_fcat from ls_fcat.
    endloop.

    loop at lt_fcat into ls_fcat.
      case ls_fcat-fieldname.
        when 'PARNR' or 'ERDAT' or 'ERTIM' or 'AEDAT' or 'AETIM' or 'AENAM'.
          ls_fcat-edit = abap_false.
      endcase.
      modify lt_fcat from ls_fcat.
    endloop.
  else.

    loop at lt_fcat into ls_fcat.
      ls_fcat-edit = abap_false.
      ls_fcat-outputlen = 25.
      modify lt_fcat from ls_fcat.
    endloop.

    append 'ENAME' to lt_editable.   " Adı Soyadı
    append 'EMAIL' to lt_editable.   " E-posta adresi
    append 'TELF1' to lt_editable.   " Telefon numarası
    append 'TCKID' to lt_editable.   " TC Kimlik No


    loop at lt_fcat into ls_fcat.
      if line_exists( lt_editable[ table_line = ls_fcat-fieldname ] ).
        ls_fcat-edit = abap_true.
      endif.

      modify lt_fcat from ls_fcat.
    endloop.
  endif.

  go_alv->set_table_for_first_display(
    exporting
      is_layout        = ls_layout
      i_save           = 'A'
    changing
      it_outtab        = gt_one
      it_fieldcatalog  = lt_fcat ).

  data ls_stable type lvc_s_stbl.
  ls_stable-row = abap_true.
  ls_stable-col = abap_true.
  go_alv->refresh_table_display( exporting is_stable = ls_stable ).
endmodule.
