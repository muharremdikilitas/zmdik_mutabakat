*&---------------------------------------------------------------------*
*& Include          ZMDIK_P86_I03
*&---------------------------------------------------------------------*



class lcl_report definition.

  public section.

    types : begin of ts_list ,
              icon             type icon-id,
              bankc            type ZMDIK_t002-bankc,
              bukrs            type ZMDIK_t002-bukrs,
              hbkid            type ZMDIK_t002-hbkid,
              hktid            type ZMDIK_t002-hktid,
              iban             type ZMDIK_t002-iban,
              bankn            type ZMDIK_t002-bankn,
              hkont            type ZMDIK_t002-hkont,
              stcd2            type ZMDIK_t002-stcd2,
              rcomp            type ZMDIK_t002-rcomp,
              altkt            type ZMDIK_t002-altkt,
              waers            type ZMDIK_t002-waers,
              zuonr            type ZMDIK_t002-zuonr,
*              kkber    type ZMDIK_t002-kkber,
              gsber            type ZMDIK_t002-gsber,
              acc_type         type ZMDIK_t002-acc_type,
              acc_type_dsc(30),
              uname            type ZMDIK_t002-uname,
              cdate            type ZMDIK_t002-cdate,
              trcou            type zeho_t011-pcount, " Toplam Sorgu sayısı
              srcou            type zeho_t011-pcount, " Başarılı Sorgu sayısı
              ercou            type zeho_t011-pcount, " Hatalı Sorgu sayısı
              pcount           type zeho_t011-pcount, " Hatalı Sorgu sayısı
            end of ts_list .

    data : mt_list type standard table of ts_list,
           ms_list type ts_list,
           mt_t035 type standard table of ZMDIK_t035.

    methods :
      initialization,
      set_first_status,
      at_selection_screen,
      get_data returning value(rv_subrc) type sy-subrc,
      set_data,
      set_filter importing iv_list type ts_list,

      progress_indicator importing iv_text type any,
      check_fields,
      start_report,
      prepare_report,
      prepare_alv,
      counter returning value(iv_count) type i.

  protected section.

    data : mo_alv       type ref to cl_salv_table,
           mo_detail    type ref to cl_salv_table,
           mo_functions type ref to cl_salv_functions_list,
           mo_display   type ref to cl_salv_display_settings,
           mo_columns   type ref to cl_salv_columns_table,
           mo_column    type ref to cl_salv_column_table,
           mo_selection type ref to cl_salv_selections,
           mo_layout    type ref to cl_salv_layout,
           mo_events    type ref to cl_salv_events_table,
           mo_sorts     type ref to cl_salv_sorts,
           mo_agg       type ref to cl_salv_aggregations,
           mo_exp_msg   type ref to cx_salv_msg.

    data : ms_key   type salv_s_layout_key,
           ms_color type lvc_s_colo.

  private section.

    methods :
      create_alv,
      display_alv,
      set_pf_status,
      set_top_of_page,
      set_alv_properties,
      set_column_text
        importing iv_fname type lvc_fname
                  iv_text  type any,
      set_sort
        importing value(iv_col)  type lvc_fname
                  value(iv_seq)  type salv_de_sort_sequence
                  value(iv_subt) type sap_bool ,

      on_user_command for event added_function of cl_salv_events
        importing e_salv_function,

      on_link_click for event link_click of cl_salv_events_table
        importing row
                  column ,
      on_after_user_command for event after_salv_function of cl_salv_events
        importing e_salv_function .



endclass.                    "lcl_report definition

*----------------------------------------------------------------------*
*       class lcl_report implementation
*----------------------------------------------------------------------*
class lcl_report implementation.

  method initialization .
*-
  endmethod .

  method set_first_status.
*-
  endmethod.

  method at_selection_screen.

  endmethod.

  method get_data.
*
    rv_subrc = 0.
    progress_indicator( text-p01 ).

    select * from ZMDIK_t002 into corresponding fields of table mt_list
      where bukrs in s_bukrs
      and   bankc in s_bankc
      and   hbkid in s_hbkid
      and   hktid in s_hktid
      and   bankn in s_bankn .

    if sy-subrc <> 0. rv_subrc = 4. return. endif.

    select * from ZMDIK_t035 into CORRESPONDING FIELDS OF table mt_t035
      where bukrs in s_bukrs.
*      and   bankc in s_bankc
*      and   hbkid in s_hbkid
*      and   hktid in s_hktid
*      and   bankn in s_bankn
*      and   rbdat eq p_prdat .

  endmethod.

  method set_data .
    loop at mt_list assigning field-symbol(<ls_list>) .
      loop at mt_t035 into data(ls_t035) where bukrs eq <ls_list>-bukrs.
*                                         and   bankc eq <ls_list>-bankc
*                                         and   hbkid eq <ls_list>-hbkid
*                                         and   hktid eq <ls_list>-hktid
*                                         and   bankn eq <ls_list>-bankn .
        add 1 to <ls_list>-trcou .
        case ls_t035-statu .
          when '01' . add 1 to <ls_list>-srcou .
          when '02' . add 1 to <ls_list>-ercou .
        endcase .
        add ls_t035-lines to <ls_list>-pcount .
      endloop .

      <ls_list>-icon = cond #( when <ls_list>-trcou eq 0               then icon_initial
                               when <ls_list>-trcou eq <ls_list>-srcou then icon_led_green
                               when <ls_list>-trcou eq <ls_list>-ercou then icon_led_red
                               else icon_led_yellow ).

    endloop .
  endmethod .

  method progress_indicator.
*
    call function 'SAPGUI_PROGRESS_INDICATOR'
      exporting
        percentage = 75
        text       = iv_text.

  endmethod.

  method check_fields.

  endmethod.

  method start_report.
*
    me->prepare_report( ).

  endmethod.

  method prepare_report.
*
    data(lv_subrc) = me->get_data( ).
    progress_indicator( text-p02 ).
    me->set_data( ) .

  endmethod.

  method prepare_alv.
*
    me->create_alv( ).
    me->set_pf_status( ).
    me->set_alv_properties( ).
    me->set_top_of_page( ).
    me->display_alv( ).

  endmethod.                    "prepare_alv

  method create_alv.
*
    try.
        cl_salv_table=>factory(
          importing
            r_salv_table = mo_alv
          changing
            t_table      = mt_list ).
      catch
        cx_salv_msg into mo_exp_msg.
    endtry.

  endmethod.                    "create_alv

  method display_alv.
*
    mo_alv->display( ).

  endmethod.                    "display_alv

  method set_pf_status.
*
    mo_alv->set_screen_status(
                pfstatus      = 'MGUI'
                report        = sy-repid
                set_functions = mo_alv->c_functions_all ).

  endmethod.                    "set_pf_status

  method set_top_of_page.
*
    data : lo_grid_top    type ref to cl_salv_form_layout_grid,
           lo_text        type ref to cl_salv_form_text,
           lo_label       type ref to cl_salv_form_label,
           lo_logo        type ref to cl_salv_form_layout_logo,
           lv_count       type i,
           lv_date        type sy-datum,
           lo_grid_bottom type ref to cl_salv_form_layout_grid.

    create object lo_grid_top.

    lo_grid_top->create_header_information(
                  row     = 1
                  column  = 1
                  text    = text-t01
                  tooltip = text-t01 ).

    lo_grid_top->add_row( ).

    lv_count = me->counter( ).

    lo_grid_bottom = lo_grid_top->create_grid(
                   row    = 3
                   column = 1 ).

    lo_label = lo_grid_bottom->create_label(
                   row     = 1
                   column  = 1
                   text    = text-t02
                   tooltip = text-t02 ).

*    lv_date = |{ sy-datum date = environment }|.
*    WRITE sy-datum to lv_date.
    lo_text = lo_grid_bottom->create_text(
                   row     = 1
                   column  = 2
                   text    = lv_count
                   tooltip = lv_count ).

    lo_label->set_label_for( lo_text ).

    create object lo_logo.
*    lo_logo->set_right_logo( 'BL_LOGO' ).
    lo_logo->set_left_content( lo_grid_top ).

    mo_alv->set_top_of_list( lo_logo ).

  endmethod.                    "set_top_of_page

  method set_alv_properties.
*
    mo_display = mo_alv->get_display_settings( ).

* Zebra sytle..
    mo_display->set_striped_pattern( cl_salv_display_settings=>true ).

    mo_columns = mo_alv->get_columns( ).
* Set optimize..
    mo_columns->set_optimize( abap_true ).

    mo_layout = mo_alv->get_layout( ).
* Set variant..
    ms_key-report = sy-repid.
    mo_layout->set_key( ms_key ).
    mo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
    mo_layout->set_default( abap_true ).


* Set selection..
    mo_selection = mo_alv->get_selections( ).
    mo_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).

    mo_events = mo_alv->get_event( ).
* Set ALV Events.
    set handler go_report->on_user_command for mo_events.
    set handler go_report->on_link_click for mo_events.

* Set Column Text..
    me->set_column_text( iv_fname = 'TRCOU' iv_text = text-h01 ).
    me->set_column_text( iv_fname = 'SRCOU' iv_text = text-h02 ).
    me->set_column_text( iv_fname = 'ERCOU' iv_text = text-h03 ).


* Hotspot.
    try.
        mo_column ?= mo_columns->get_column( 'TRCOU' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

        mo_column ?= mo_columns->get_column( 'SRCOU' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

        mo_column ?= mo_columns->get_column( 'ERCOU' ).
        mo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

      catch cx_salv_not_found .
    endtry.

*    mo_column ?= mo_columns->get_column( 'WRBTR' ). "Currency Value
*    mo_column->set_currency_column( 'WAERS' ). "Currency Key


*  Hide columns.
*    try.
**        if p_perio is initial.
*        mo_column ?= mo_columns->get_column( 'PERIO' ).
*        mo_column->set_technical( if_salv_c_bool_sap=>true ).
*
*      catch cx_salv_not_found.
*    endtry.

* Icon
*    TRY.
*        go_column ?= go_columns->get_column( 'ICON' ).
*        go_column->set_icon( mc_x ).
*      CATCH cx_salv_not_found .
*    ENDTRY.

* Column Color.
*    TRY.
*        gs_color-col = '7'.
*        gs_color-int = '0'.
*        gs_color-inv = '0'.
*        go_column ?= go_columns->get_column( 'MOVE_TYPE_543' ).
*        go_column->set_color( gs_color ).
*      CATCH cx_salv_not_found .
*    ENDTRY.

* Key.
*    TRY.
*        go_column ?= go_columns->get_column( 'TARIH' ).
*        go_column->set_key( mc_x ).
*      CATCH cx_salv_not_found .
*    ENDTRY.


  endmethod.                    "set_alv_properties

  method set_column_text.
*
    data : lv_textl type scrtext_l,
           lv_textm type scrtext_m,
           lv_texts type scrtext_s.

    lv_texts = lv_textm = lv_textl = iv_text.

    try.
        mo_column ?= mo_columns->get_column( iv_fname ).
        mo_column->set_long_text( lv_textl ).
        mo_column->set_medium_text( lv_textm ).
        mo_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.

  endmethod.                    "set_column_text

  method set_sort.
*
    try.
        mo_sorts->add_sort( columnname = iv_col
                            sequence   = iv_seq
                            subtotal   = iv_subt ).
      catch cx_salv_not_found .
      catch cx_salv_existing .
      catch cx_salv_data_error .
    endtry.

  endmethod.                    "set_sort

  method on_user_command.
*
*    case e_salv_function.
*      when 'EXCEL'.
*        mo_alv->refresh( ).
*      when others.
*    endcase.

  endmethod.                    "on_user_command

  method on_link_click.
*-
    data lo_alv       type ref to cl_salv_table.
    data lr_columns   type ref to cl_salv_columns_table.
    data lr_column    type ref to cl_salv_column.
    data lt_detail    type table of ZMDIK_t035 .
    data lr_functions type ref to cl_salv_functions_list.
    data : lv_textl type scrtext_l,
           lv_textm type scrtext_m,
           lv_texts type scrtext_s.

    check row ne 0 .
    read table mt_list into ms_list index row .

    loop at mt_t035 into  data(ls_t035) where bukrs eq ms_list-bukrs.
*                                       and   bankc eq ms_list-bankc
*                                       and   hbkid eq ms_list-hbkid
*                                       and   hktid eq ms_list-hktid
*                                       and   bankn eq ms_list-bankn .
      append ls_t035 to lt_detail .
    endloop .

    case column.
      when 'TRCOU' .
      when 'ERCOU' . delete lt_detail where statu eq '01' .
      when 'SRCOU' . delete lt_detail where statu eq '02' .
    endcase.

    try.
        cl_salv_table=>factory(
          importing
            r_salv_table = lo_alv
          changing
            t_table      = lt_detail[] ).

      catch cx_salv_msg.

    endtry.
    loop at lt_detail assigning field-symbol(<fs>).
      if <fs>-statu eq '01'.
        <fs>-statu_desc = 'Başarılı'.
      endif.
      if <fs>-statu eq '02'.
        <fs>-statu_desc = 'Başarısız'.
      endif.
      if <fs>-reqty eq '1'.
        <fs>-reqty_desc = 'Normal'.
      endif.
      if <fs>-reqty eq '2'.
        <fs>-reqty_desc = 'Sıkıştırma'.
      endif.
      if <fs>-reqty eq '3'.
        <fs>-reqty_desc = 'SOT'.
      endif.
    endloop.
    lr_columns = lo_alv->get_columns( ).
    lr_columns->set_optimize( abap_true ).

    lr_functions = lo_alv->get_functions( ).
    lr_functions->set_all( 'X' ).

    lr_column ?= lr_columns->get_column( 'MANDT' ).
    lr_column->set_visible( value  = if_salv_c_bool_sap=>false ).

    lv_texts = lv_textm = lv_textl = text-h04 .
    try.
        lr_column ?= lr_columns->get_column( 'RBDAT' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h05 .
    try.
        lr_column ?= lr_columns->get_column( 'RBTIM' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h06 .
    try.
        lr_column ?= lr_columns->get_column( 'REDAT' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h07 .
    try.
        lr_column ?= lr_columns->get_column( 'RETIM' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h08 .
    try.
        lr_column ?= lr_columns->get_column( 'PRDAT' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h09 .
    try.
        lr_column ?= lr_columns->get_column( 'PRTIM' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
**********************************************************************
    lv_texts = lv_textm = lv_textl = text-h13 .
    try.
        lr_column ?= lr_columns->get_column( 'STATU' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h13 .
    try.
        lr_column ?= lr_columns->get_column( 'STATU_DESC' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h14 .
    try.
        lr_column ?= lr_columns->get_column( 'BSTAT' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h15 .
    try.
        lr_column ?= lr_columns->get_column( 'REQTY' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h15 .
    try.
        lr_column ?= lr_columns->get_column( 'REQTY_DESC' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h16 .
    try.
        lr_column ?= lr_columns->get_column( 'BULKR' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
**********************************************************************
    lv_texts = lv_textm = lv_textl = text-h10 .
    try.
        lr_column ?= lr_columns->get_column( 'BATCH' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h11 .
    try.
        lr_column ?= lr_columns->get_column( 'LINES' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.
    lv_texts = lv_textm = lv_textl = text-h12 .
    try.
        lr_column ?= lr_columns->get_column( 'STEXT' ).
        lr_column->set_long_text( lv_textl ).
        lr_column->set_medium_text( lv_textm ).
        lr_column->set_short_text( lv_texts ).
      catch cx_salv_not_found .
    endtry.

    lo_alv->set_screen_popup(
      start_column = 20
      end_column   = 160
      start_line   = 1
      end_line     = 10 ).

    lo_alv->display( ).
*    wait up to 3 seconds .
*
*    me->get_data( ) .
*    me->set_data( ) .
*
*    mo_alv->refresh( refresh_mode = if_salv_c_refresh=>full ).

  endmethod.                    "on_link_click


  method on_after_user_command.
*
*    case e_salv_function.
*      when 'CREATE'.
*        data(lo_selection) = mo_alv->get_selections( ).
*        data(lt_rows) = lo_selection->get_selected_rows( ).
*
**        me->asset_batch( lt_rows ).
*
*        mo_alv->refresh( ).
*      when others.
*    endcase.

  endmethod.                    "on_user_command

  method counter.
*
    describe table mt_list lines iv_count.

  endmethod.
  method set_filter.


  endmethod.

endclass.
