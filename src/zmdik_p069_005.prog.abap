*&---------------------------------------------------------------------*
*& Include          ZMDIK_P069_005
*&---------------------------------------------------------------------*


CLASS lcl_report DEFINITION.

  PUBLIC SECTION.
  DATA: mo_alv       TYPE REF TO cl_salv_table,
          mo_exp_msg   TYPE REF TO cx_salv_msg,
          mo_display   TYPE REF TO cl_salv_display_settings,
          mo_columns   TYPE REF TO cl_salv_columns_table,
          mo_column    TYPE REF TO cl_salv_column_table,
          mo_events    TYPE REF TO cl_salv_events_table,
          mo_layout    TYPE REF TO cl_salv_layout,
          mo_selection TYPE REF TO cl_salv_selections.









  methods:
  save_data,
  select,
  prepare_alv,
  create_alv,
  display_alv.












  ENDCLASS.



  class lcl_report IMPLEMENTATION.
method save_data.

  if gv_proc_type eq '1'.

  data: lv_number type zmdp_t001-rec_id.


  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr                   = '01'
      object                        = 'ZMDP_N001'

   IMPORTING
     NUMBER                        = lv_number.



    LOOP AT gt_talimat into gs_talimat.
     gs_talimat-rec_id = |{ lv_number }|.
     gs_talimat-proc_type = gv_proc_type.
     gs_talimat-comp_code = gv_comp_code.
     gs_talimat-doc_date = gv_doc_date.
     gs_talimat-snd_cust_no = gv_snd_cust_no.
     gs_talimat-snd_name = gv_snd_name.
     gs_talimat-snd_bank = gv_snd_bank.
     gs_talimat-snd_acc_no = gv_snd_acc_no.
     gs_talimat-amount = gv_amount.
     gs_talimat-snd_iban = gv_snd_iban.
     gs_talimat-snd_pb = gv_snd_pb.
     gs_talimat-rcv_cust_no = gv_rcv_cust_no.
     gs_talimat-rvc_name = gv_rvc_name.
     gs_talimat-rvc_bank = gv_rvc_bank.
     gs_talimat-rvc_acc_no = gv_rvc_acc_no.
     gs_talimat-rvc_amount = gv_rvc_amount.
     gs_talimat-rvc_iban = gv_rvc_iban.
     gs_talimat-rvc_pb = gv_rvc_pb.

     APPEND gs_talimat TO gt_talimat.
    ENDLOOP.

  MODIFY zmdp_t001 FROM TABLE gt_talimat.

ENDIF.
ENDMETHOD.
method select.


  SELECT * from zmdp_t001 into TABLE gt_talimat.



endmethod.





METHOD create_alv.
cl_salv_table=>factory(

      IMPORTING
        r_salv_table   = mo_alv
      CHANGING
        t_table        = gt_talimat
    ).

ENDMETHOD.



method prepare_alv.

  me->create_alv( ).
  me->display_alv( ).

  ENDMETHOD.






   METHOD display_alv.
  mo_alv->display( ).

    ENDMETHOD.




    ENDCLASS.
