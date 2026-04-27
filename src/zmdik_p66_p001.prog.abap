*&---------------------------------------------------------------------*
*& Include          ZMDIK_P66_P001
*&---------------------------------------------------------------------*

*types: BEGIN OF ty_alv,
*  cust_id       type zmdik_customer-cust_id,
*  name          type zmdik_customer-name,
*  tax_number    type zmdik_customer-tax_num,
*  country       type zmdik_customer-country,
*  email         type zmdik_customer-email,
*  total_sales   type zmdik_sales-amount,
*  total_paymnet type zmdik_payment-amount,
*  balance       type zmdik_sales-amount,
*  detail_icon   type icon_d,
*  END OF ty_alv.
*
*
*
*TYPES: BEGIN OF ty_detail,
*         doc_date   TYPE d,
*         doc_type   TYPE char10,
*         item_text  TYPE char30,
*         ref_doc_no TYPE char20,
*         db_cr_ind  TYPE char1,
*         amount     TYPE p DECIMALS 2,
*         currency   TYPE waers,
*       END OF ty_detail.
*
*
*data: gt_detail type TABLE OF ty_detail,
*      gs_detail TYPE          ty_detail.
*
*
*
*  data: gt_alv TYPE TABLE of ty_alv,
*        gs_alv type          ty_alv.
*
*
*  data: gs_cust type zmdik_customer,
*        gt_cust type table of zmdik_customer.
*
*
*  data: gs_sal TYPE zmdik_sales,
*        gt_sal type TABLE OF  zmdik_sales.
*
*  data: gs_pay type zmdik_payment,
*        gt_pay  type TABLE OF zmdik_payment.
