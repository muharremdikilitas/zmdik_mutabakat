*&---------------------------------------------------------------------*
*& Include          ZMDIK_MUTABAKAT2_P001
*&---------------------------------------------------------------------*

TABLES: zmdik_mutakabat, zmdik_mail_tablo,  bkpf.


class lcl_report definition deferred.
*class cl_event_receiver definition deferred.



TYPES BEGIN OF gty_data.
  include STRUCTURE zmdik_mutakabat.
    types:   selkz type char1,
       end of gty_data.

  data: begin of gt_lineitems occurs 0,
        doc_date   like bapi3007_2-doc_date,
        doc_type   like bapi3007_2-doc_type,
        item_text  like bapi3007_2-item_text,
        text       type text_bslt,
        ref_doc_no like bapi3007_2-ref_doc_no,
        db_cr_ind  like bapi3007_2-db_cr_ind,
        currency   like bapi3007_2-currency,
        "Tutar  Borç/Alacak durumuna göre +/-
      end of gt_lineitems.
data: gs_lineitems like line of gt_lineitems.

data: go_lcl_report type ref to lcl_report,
*      go_event      type ref to cl_event_receiver,
      go_grid       type ref to   cl_gui_alv_grid,
      go_container  type ref to   cl_gui_custom_container.


data: gt_data type table of gty_data,
      gs_data type          gty_data.


data: gt_fcat type lvc_t_fcat,
      gs_fcat type lvc_s_fcat,
      gs_layo type lvc_s_layo.


data: gt_bapi type table of bapi3007_3,
      gs_bapi type          bapi3007_3.


data: gv_email type zmdik_mail_tablo-email,
      gv_butxt type zmdik_mutakabat-butxt.

data: gv_salv_index type i.
