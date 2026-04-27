*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTAKABAT_P001
*&---------------------------------------------------------------------*

TABLES: ZMDIK_MUTAKABAT.


data: begin of gt_lineitems occurs 0,
        doc_date   like bapi3007_2-doc_date,
        doc_type   like bapi3007_2-doc_type,
        item_text  like bapi3007_2-item_text,
        ref_doc_no like bapi3007_2-ref_doc_no,
        db_cr_ind  like bapi3007_2-db_cr_ind,
        currency   like bapi3007_2-currency,
      end of gt_lineitems.
data: gs_lineitems like line of gt_lineitems.




 DATA : gt_fcat2 TYPE slis_t_fieldcat_alv,
         gs_fcat2 TYPE slis_fieldcat_alv.

data: gt_mail type TABLE OF zmdik_mail_tablo,
      gs_mail TYPE zmdik_mail_tablo.


DATA: lt_mutabakat TYPE TABLE OF zmdik_mutakabat,
      ls_mutabakat type zmdik_mutakabat.

DATA: g_alv_grid TYPE REF TO cl_gui_alv_grid,
      g_custom_container TYPE REF TO cl_gui_custom_container.


DATA: gs_layout TYPE slis_layout_alv.


DATA: g_salv_table TYPE REF TO cl_salv_table.

data: gt_bapi TYPE TABLE OF bapi3007_3,
      gs_bapi  like LINE OF gt_bapi.

data: gt_listele TYPE TABLE OF ZMDIK_MTB_LOG,
      gs_listele type ZMDIK_MTB_LOG,
      gv_data TYPE c LENGTH 2.
