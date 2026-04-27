*&---------------------------------------------------------------------*
*& Report ZMDIK_P62
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P62.

data: go_gbt         TYPE REF TO cl_gbt_multirelated_service,           "html formatında e posta gövdesi oluşturmak için
      go_bcs         type ref to cl_bcs,                                  "mail gönderim işlevini yapar
      go_doc_bcs     TYPE REF TO cl_document_bcs,                         "mail içeriğini tutan body nesnesi
      go_recipient   TYPE REF TO if_recipient_bcs,                        ": Alıcı arayüzü. Alıcıyı e-posta adresi olarak tanımlar.
      gt_soli        TYPE table of soli,                                    "mail içeriğini tutan metin satır türü
      gs_soli        TYPE  soli,
      gv_status      type   bcs_rqst,
      gv_content     type   string.

START-OF-SELECTION.


CREATE OBJECT go_gbt.

gv_content = 'Merhabalar, bu bir test mailidir! .'.

gt_soli = cl_document_bcs=>string_to_soli( gv_content ).                "string ifadeyi soli ye dönüştürüyor

call METHOD go_gbt->set_main_html                                         "gt_soli içeriği html olarak ayarlanıyor. Yani mail html olarak belirleniyor
  EXPORTING
    content     = gt_soli.

go_doc_bcs = cl_document_bcs=>create_from_multirelated(
               i_subject          = 'Test Mail BaşlığıV2'                   "başlık
               i_multirel_service = go_gbt                                  "html içeriği
             ).


go_recipient = cl_cam_address_bcs=>create_internet_address(
                 i_address_string = 'muharrem_273@hotmail.com' ).           "mailin kime göndereceği belirlenir.


go_bcs = cl_bcs=>create_persistent( ).                                       "maili gönderecek go_bcs oluşturuluyor. persistent gönderim gerçekleşene kadar bilgileri tutar.
go_bcs->set_document( i_document = go_doc_bcs ).                              "HTML doküman (gövde) go_bcs mail nesnesine bağlanıyor.
go_bcs->add_recipient(
  EXPORTING
    i_recipient  = go_recipient                                               "alıcı da go_bcs mail nesnesine ekleniyor.

).

gv_status = 'N'.                                                              "normal gönderim
call METHOD go_bcs->set_status_attributes
  EXPORTING
    i_requested_status = gv_status.                                             "Mailin durumu sistemde "normal gönderildi" olarak işaretleniyor.

  go_bcs->send( ).                                                              "Mail gönderiliyor
  commit WORK.                                                                    "değişiklikleri örneğin mail gönderimini sistemde kalıcı yapıyor.
  IF sy-subrc eq 0.
    MESSAGE 'Mail başarılı şekilde gönderildi!' type 'I' DISPLAY LIKE 'S'.

  ENDIF.
