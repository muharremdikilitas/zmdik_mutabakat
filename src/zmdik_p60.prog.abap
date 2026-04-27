*&---------------------------------------------------------------------*
*& Report ZMDIK_P60
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P60.
  "iternal tableyi excel olarak kaydetme




data: gv_filename type string.

data: gt_scarr type table of scarr.


PARAMETERS: p_path TYPE string.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  call METHOD cl_gui_frontend_Services=>directory_browse                            "searchelpe tıkladığımda popup açacak ve oradan folder seçtirecek
    CHANGING
      selected_folder      =  p_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      others               = 4
    .
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



START-OF-SELECTION.

SELECt * from scarr into TABLE gt_scarr.

  CONCATENATE p_path
                '\'
                '-'
                sy-uzeit
                '.xls'
    into gv_filename.

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    filename                        = gv_filename
   FILETYPE                        = 'ASC'                          "dosyayo hangi türde indirmek istersen
*
   WRITE_FIELD_SEPARATOR           = 'X'                            "hücreleri neye göre bölmek istiyosun
  tables
    data_tab                        = gt_scarr
*   FIELDNAMES                      =
   .
