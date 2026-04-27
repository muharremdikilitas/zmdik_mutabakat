*&---------------------------------------------------------------------*
*& Include          ZMDIK_P67_P003
*&---------------------------------------------------------------------*


form get_data.
  if p_carrid is initial or p_carrid ca gv_number.
    message 'eksik veya hatalı veri girişi' type 'I'.
  endif.

  data: lt_carrid type table of spfli-carrid,
        ls_carrid like line of  lt_carrid,
        rt_carrid type range of spfli-carrid,
        rs_carrid like line of  rt_carrid.

  split p_carrid at ',' into table lt_carrid.

  loop at lt_carrid into ls_carrid.
    rs_carrid-sign   = 'I'.
    rs_carrid-option = 'EQ'.
    rs_carrid-low    = ls_carrid.
    append rs_carrid to rt_carrid.
  endloop.

  select * from spfli  as sp
    inner join sflight as sf on sp~carrid eq sf~carrid
    into corresponding fields of table gt_flight_inf
    where sp~carrid in rt_carrid and
          sf~carrid in rt_carrid and
          sf~fldate in so_date.

  select * from sbook
    into corresponding fields of table gt_sbook up to 10 rows
  for all entries in gt_flight_inf
  where carrid eq gt_flight_inf-carrid and
        connid eq gt_flight_inf-connid and
        fldate eq gt_flight_inf-fldate.
endform.

form set_layout.
  gs_layout-window_titlebar   = 'Uçuş Bİlgileri'.
  gs_layout-zebra             = abap_true.
  gs_layout-colwidth_optimize = abap_true.
endform.

form set_fcat.
  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
    exporting
      i_structure_name = 'SBOOK'
    changing
      ct_fieldcat      = gt_fieldcatalog.
endform.

form display_alv.
  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS_SET'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcatalog
    tables
      t_outtab                 = gt_sbook
    exceptions
      program_error            = 1
      others                   = 2.

endform.


form pf_status_set using p_extab type slis_t_extab.
  set pf-status '0100'.
endform.

form user_command using p_ucomm     type sy-ucomm
                        ps_selfield type slis_selfield.
  data: ld_repid like sy-repid,
        ref_grid type ref to cl_gui_alv_grid.

  case p_ucomm.
    WHEN '&F03'.
      leave SCREEN.
    when '&EDT'.
      if gs_layout-edit eq abap_false.
        gs_layout-edit = abap_true.
        if ref_grid is initial.
          call function 'GET_GLOBALS_FROM_SLVC_FULLSCR'
            importing
              e_grid = ref_grid.
        endif.
        if not ref_grid is initial.
          call method ref_grid->check_changed_data .
        endif.
        ps_selfield-refresh = 'X'.
        ps_selfield-exit = 'X'.
        perform display_alv.

      else.
        gs_layout-edit = abap_false.
        if ref_grid is initial.
          call function 'GET_GLOBALS_FROM_SLVC_FULLSCR'
            importing
              e_grid = ref_grid.
        endif.
        if not ref_grid is initial.
          call method ref_grid->check_changed_data .
        endif.
        ps_selfield-refresh = 'X'.
        ps_selfield-exit = 'X'.
        perform display_alv.
      endif.
  endcase.
endform.
