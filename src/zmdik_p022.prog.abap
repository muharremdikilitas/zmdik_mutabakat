*&---------------------------------------------------------------------*
*& Report ZMDIK_P022
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P022.
data: BEGIN OF gs_st,
  carrid TYPE scarr-carrid,
  carrname TYPE scarr-carrname,
  currcode TYPE scarr-currcode,
  fldate type sflight-fldate,
  connid TYPE sflight-connid,
  url TYPE scarr-url,
  end of gs_st.


  DATA: gt_it LIKE TABLE OF gs_st.

  SELECT a~carrid a~connid b~carrname b~currcode a~fldate b~url  UP TO 20 ROWS FROM
    sflight as a
    join scarr as b
    on a~carrid = b~carrid
    into CORRESPONDING FIELDS OF TABLE gt_it.

    data: go_alv TYPE REF TO cl_salv_table.

    cl_salv_table=>factory(
*      EXPORTING
*        list_display   = if_salv_c_bool_sap=>false
*        r_container    =
*        container_name =
    IMPORTING
        r_salv_table   = go_alv
      CHANGING
        t_table        = gt_it
    ).
*    CATCH cx_salv_msg.

    go_alv->display( ).
