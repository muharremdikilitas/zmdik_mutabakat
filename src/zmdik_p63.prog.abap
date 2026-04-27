*&---------------------------------------------------------------------*
*& Report ZMDIK_P63
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P63.


data: go_gbt         TYPE REF TO cl_gbt_multirelated_service,
      go_bcs         type ref to cl_bcs,
      go_doc_bcs     TYPE REF TO cl_document_bcs,
      go_recipient   TYPE REF TO if_recipient_bcs,
      gt_soli        TYPE table of soli,
      gs_soli        TYPE  soli,
      gv_status      type   bcs_rqst,
      gv_content     type   string.

data: gt_scarr type table of scarr,
      gs_scarr TYPE          scarr.

START-OF-SELECTION.


CREATE OBJECT go_gbt.

select * from scarr into table gt_scarr.






       gv_content =       '<!DOCTYPE html>                              '
&&     '<html>                                       '
&&     '  <head>                                      '
&&     '       <meta charset="utf-8">                 '
&&     '         <style>                             '
&&     '         th {                                '
&&     '            background-color: lightgreen;   '
&&     '                border: 4px solid;           '
&&     '         }                                   '
&&     '         td {                                '
&&     '            background-color: lightblue;    '
&&     '                border: 1px solid;           '
&&     '         }                                   '
&&     '         </style>                            '
&&     '      </head>                                '
&&     '      <body>                                 '
&&     '          <table>                             '
&&     '            <tr>                             '
&&     '                                             '
&&     '             <th>Havayolu kısa tanımı </th>               '
&&     '             <th>Havayolu adı </th>               '
&&     '             <th>Havayolu ulusal pb </th>               '
&&     '            <th>Havayolu URL </th>                                 '
&&     '            </tr>                            '.



 LOOP AT gt_scarr INTO gs_scarr.
   gv_content = gv_content &&  '            <tr>                             '
&&     '            <td>'   && gs_scarr-carrid && '</td>                '
&&     '            <td>'  && gs_scarr-carrname && ' </td>                '
&&     '            <td>'  && gs_scarr-currcode &&  '</td>                '
&&     '            <td>'   && gs_scarr-url  &&   '</td>                '
&&     '            </tr>                            '.



 ENDLOOP.




           gv_content = gv_content &&  '            </table>                         '
          &&     '       </body>                               '
          &&     '    </html>                                  '.

gt_soli = cl_document_bcs=>string_to_soli( gv_content ).                "string ifadeyi table ye dönüştürüyor

call METHOD go_gbt->set_main_html
  EXPORTING
    content     = gt_soli.

go_doc_bcs = cl_document_bcs=>create_from_multirelated(                         "başlık
               i_subject          = 'Test Mail BaşlığıV2'
               i_multirel_service = go_gbt
             ).


go_recipient = cl_cam_address_bcs=>create_internet_address(
                 i_address_string = 'muharrem_test2@test.com' ).                    "alıcı


go_bcs = cl_bcs=>create_persistent( ).
go_bcs->set_document( i_document = go_doc_bcs ).
go_bcs->add_recipient(
  EXPORTING
    i_recipient  = go_recipient

).

gv_status = 'N'.
call METHOD go_bcs->set_status_attributes
  EXPORTING
    i_requested_status = gv_status.

  go_bcs->send( ).
  commit WORK.
  IF sy-subrc eq 0.
    MESSAGE 'Mail başarılı şekilde gönderildi!' type 'I' DISPLAY LIKE 'S'.

  ENDIF.
