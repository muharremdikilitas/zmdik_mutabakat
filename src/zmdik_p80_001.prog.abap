*&---------------------------------------------------------------------*
*& Include          ZMDIK_P79_001
*&---------------------------------------------------------------------*


data: gs_data type          zmdik_erec,
      gt_data type table of zmdik_erec,
       gv_last_idx TYPE i.


class lcl_report definition deferred.
data: go_report type ref to lcl_report.


data: go_alv  type ref to cl_gui_alv_grid,
      go_cont type ref to cl_gui_custom_container.

" --- Popup’ta göstereceğimiz tek satırlık tablo ---
DATA: gt_one TYPE STANDARD TABLE OF zmdik_erec WITH EMPTY KEY,
        gt_sel_map TYPE STANDARD TABLE OF i WITH EMPTY KEY.

DATA: g_screen_mode TYPE c. " 'C' for CREATE, 'U' for UPDATE
