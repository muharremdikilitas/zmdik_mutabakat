*&---------------------------------------------------------------------*
*& Include          ZMDIK_P90_005
*&---------------------------------------------------------------------*

initialization.
  create object go_report.
  sscrfields-functxt_02 = '@2Q@ Şablon İndir'.

at selection-screen.
  case sy-ucomm.
    when 'FC02'.
      go_report->download_template( ).
  endcase.

at selection-screen on value-request for p_file.
  call function 'F4_FILENAME'
    exporting
      field_name = 'P_FILE'
    importing
      file_name  = p_file.
  if p_file is initial.
    message 'Dosya seçilmedi.' type 'S' display like 'E'.  return.
  else.
    message 'Dosya yolu başarıyla alındı.' type 'S'.
  endif.


start-of-selection.

  go_report->start_alv( ).
