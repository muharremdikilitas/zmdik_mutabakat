*&---------------------------------------------------------------------*
*& Include          ZMDIK_P66_P003
*&---------------------------------------------------------------------*



CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
 types: BEGIN OF ty_alv,
  cust_id       type zmdik_customer-cust_id,
  name          type zmdik_customer-name,
  tax_number    type zmdik_customer-tax_num,
  country       type zmdik_customer-country,
  email         type zmdik_customer-email,
  total_sales   type zmdik_sales-amount,
  total_paymnet type zmdik_payment-amount,
  balance       type zmdik_sales-amount,
  detail_icon   type icon_d,
  END OF ty_alv.



TYPES: BEGIN OF ty_detail,
         doc_date   TYPE d,
         doc_type   TYPE char10,
         item_text  TYPE char30,
         ref_doc_no TYPE char20,
         db_cr_ind  TYPE char1,
         amount     TYPE dmbtr,
         currency   TYPE waers,
       END OF ty_detail.

    DATA: gt_alv     TYPE STANDARD TABLE OF ty_alv,
          gs_alv     TYPE ty_alv,
          gt_detail  TYPE STANDARD TABLE OF ty_detail,
          gs_detail  TYPE ty_detail.

    METHODS:
      get_data,
      display_alv,
      show_detail_popup
        IMPORTING iv_customer TYPE zmdik_customer-cust_id.
ENDCLASS.

CLASS lcl_report IMPLEMENTATION.
  METHOD get_data.
    DATA: lt_customer      TYPE TABLE OF zmdik_customer,
          ls_customer      TYPE zmdik_customer,
          lv_total_sales   TYPE p DECIMALS 2,
          lv_total_payment TYPE p DECIMALS 2.

    SELECT * FROM zmdik_customer INTO TABLE lt_customer.

    LOOP AT lt_customer INTO ls_customer.
      CLEAR: lv_total_sales, lv_total_payment.

      SELECT SUM( amount ) INTO lv_total_sales
        FROM zmdik_sales
        WHERE cust_id = ls_customer-cust_id.

      SELECT SUM( amount ) INTO lv_total_payment
        FROM zmdik_payment
        WHERE cust_id = ls_customer-cust_id.

      CLEAR gs_alv.
      gs_alv-cust_id       = ls_customer-cust_id.
      gs_alv-name          = ls_customer-name.
      gs_alv-tax_number    = ls_customer-tax_num.
      gs_alv-country       = ls_customer-country.
      gs_alv-email         = ls_customer-email.
      gs_alv-total_sales   = lv_total_sales.
      gs_alv-total_paymnet = lv_total_payment.
      gs_alv-balance       = lv_total_sales - lv_total_payment.
      gs_alv-detail_icon   = '@16@'.

      APPEND gs_alv TO gt_alv.
    ENDLOOP.
  ENDMETHOD.

  METHOD display_alv.
    DATA: lo_alv     TYPE REF TO cl_salv_table,
          lo_columns TYPE REF TO cl_salv_columns_table,
          lo_column  TYPE REF TO cl_salv_column_table,
          lo_events  TYPE REF TO cl_salv_events_table.

    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_alv
          CHANGING  t_table      = gt_alv ).

        lo_columns = lo_alv->get_columns( ).
        lo_column ?= lo_columns->get_column( 'DETAIL_ICON' ).
        lo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

        lo_events = lo_alv->get_event( ).
        SET HANDLER lcl_event_handler=>on_link_click FOR lo_events.

        lo_alv->get_functions( )->set_all( abap_true ).
        lo_alv->get_columns( )->set_optimize( abap_true ).
        lo_alv->display( ).
      CATCH cx_salv_msg INTO DATA(lx_msg).
        MESSAGE lx_msg->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD show_detail_popup.
    DATA: lt_payments TYPE TABLE OF ty_detail,
          lo_alv      TYPE REF TO cl_salv_table.

    CLEAR: gt_detail.

    SELECT doc_date, 'SATIŞ', 'Satış Belgesi', doc_id, 'H', amount, currency
      INTO CORRESPONDING FIELDS OF TABLE @gt_detail
      FROM zmdik_sales
      WHERE cust_id = @iv_customer.

    SELECT pay_date, 'TAHSILAT', method, pay_id, 'C', amount, currency
      INTO CORRESPONDING FIELDS OF TABLE @lt_payments
      FROM zmdik_payment
      WHERE cust_id = @iv_customer.

    APPEND LINES OF lt_payments TO gt_detail.

    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_alv
          CHANGING  t_table      = gt_detail ).
        lo_alv->get_functions( )->set_all( abap_true ).
        lo_alv->get_columns( )->set_optimize( abap_true ).
        lo_alv->display( ).
      CATCH cx_salv_msg INTO DATA(lx_msg).
        MESSAGE lx_msg->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_link_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_link_click.
    READ TABLE lcl_report=>gt_alv INTO DATA(ls_row) INDEX row.
    IF column = 'DETAIL_ICON'.
      DATA(lo_obj) = NEW lcl_report( ).
      lo_obj->show_detail_popup( iv_customer = ls_row-cust_id ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  DATA(lo_app) = NEW lcl_report( ).
  lo_app->get_data( ).
  lo_app->display_alv( ).
