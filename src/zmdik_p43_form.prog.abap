*&---------------------------------------------------------------------*
*& Include          ZMDIK_P43_FORM
*&---------------------------------------------------------------------*
FORM display_alv .

  IF go_grid IS INITIAL.



    CREATE OBJECT go_cont                         "konteyner oluşturduk
      EXPORTING
        container_name = 'CC_ALV'.





    CREATE OBJECT go_spli
      EXPORTING

        parent                  = go_cont
        rows                    = 2
        columns                 = 1.



        call METHOD go_spli->get_container               "oluşturduğumuz split objesini sub1 be sub2 ye atıyoruz.
          EXPORTING
            row       = 1
            column    = 1
          RECEIVING
            container = go_sub1
          .





        call METHOD go_spli->get_container               "oluşturduğumuz split objesini sub1 be sub2 ye atıyoruz.
          EXPORTING
            row       = 2
            column    = 1
          RECEIVING
            container = go_sub2
          .


      call METHOD go_spli->set_row_height                     "satır yüksekliği
        EXPORTING
          id                = 1
          height            = 15 .



      CREATE OBJECT go_docu                               "alv başlığı için
        EXPORTING
          style            = 'ALV_GRID'.







          CREATE OBJECT go_grid                           "başlık üstte tablo altta olması için
      EXPORTING
        i_parent = go_sub2.





    create OBJECT go_event_receiver.                                            "obje yaratıp bir alttaki objeyi assign ediyoruz
    set HANDLER go_event_receiver->handle_top_of_page for go_grid.            "top of pageyi tetiklediğinde çalışması için






    CREATE OBJECT go_event_receiver.
    set HANDLER go_event_receiver->handle_hotspot_click for go_grid.




    set HANDLER go_event_receiver->handle_double_click for go_grid.


    SET HANDLER go_event_receiver->handle_data_changed for go_grid.

    SET HANDLER go_event_receiver->handle_onf4 for go_grid.




    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_scarr
        it_fieldcatalog = gt_fcat.


  call METHOD go_grid->list_processing_events                           "ALV’ye "TOP_OF_PAGE" özelliği ekleniyor.
                                                                          "Yani tablo çizilmeden önce üst kısma belge (go_docu) yazdırılacak.
    EXPORTING
      i_event_name      = 'TOP_OF_PAGE'
      i_dyndoc_id       = go_docu
    .







call METHOD go_grid->register_edit_event
  EXPORTING
    i_event_id = cl_gui_alv_grid=>mc_evt_modified
*  EXCEPTIONS
*    error      = 1
*    others     = 2
  .
IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.






PERFORM register_f4.


  ELSE.
    CALL METHOD go_grid->refresh_table_display. "yeni bir değişiklikte bu methodla refresh yap. var olan güncelemeler için



  ENDIF.

ENDFORM.




FORM get_data .

  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.











ENDFORM.

FORM set_data .
*
CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
 EXPORTING
   I_STRUCTURE_NAME             = 'SCARR'
  CHANGING
    ct_fieldcat                  = gt_fcat.


LOOP AT gt_fcat ASSIGNING  <gfs_fcat>.
  IF  <gfs_fcat>-fieldname eq 'CARRNAME'.
      <gfs_fcat>-edit = abap_true.
      <gfs_fcat>-f4availabl = abap_true.

  ENDIF.

ENDLOOP.


ENDFORM.



*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .
  CLEAR: gs_layout.
  gs_layout-cwidth_opt = abap_true.         "layoutta yaptığımız değişiklikler tüm alv nin tüm kolonlarını etkiler.
  gs_layout-no_toolbar = abap_true.     " bu alv de ki toolbarı kaldırır.
  gs_layout-stylefname = 'CELLSTYLE'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_f4 .

  data: lt_f4 type LVC_T_F4,
        ls_f4 type lvc_s_f4.

  CLEAR: ls_f4.
  ls_f4-fieldname = 'CARRNAME'.
  ls_f4-register = abap_true.
  append ls_f4 to lt_f4.

      call METHOD go_grid->register_f4_for_fields                             "search help yapmak için kullanırız.
        EXPORTING
          it_f4 = lt_f4
        .
ENDFORM.
