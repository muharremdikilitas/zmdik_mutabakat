*&---------------------------------------------------------------------*
*& Report ZMDIK_P005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P005.
*
*SY-DATUM: Geçerli sistem tarihi
*SY-DATUM sistemdeki geçerli tarihi alır. Formatı YYYYMMDD şeklindedir.
*
*DATA: current_date TYPE sy-datum.
*
*START-OF-SELECTION.
*
*
*  current_date = sy-datum.
*
*  WRITE: / 'Bugünün Tarihi: ', current_date.






*SY-TIMLO: Geçerli saat
*SY-TIMLO sistemdeki geçerli saati, dakika, saniye ve milisaniye olarak alır.
*
*
*DATA: current_time TYPE sy-timlo.
*
*START-OF-SELECTION.
*
*  current_time = sy-timlo.
*
*  WRITE: / 'Geçerli Saat: ', current_time.







*SY-UNAME: Sisteme giriş yapan kullanıcı adı
*SY-UNAME sistemde oturum açan kullanıcının adını alır.
*
*Örnek:
*
*
*DATA: user_name TYPE sy-uname.
*
*START-OF-SELECTION.
*
*  user_name = sy-uname.
*  WRITE: / 'Kullanıcı Adı: ', user_name.









*SY-SUBRC: Son işlem sonucu (dönüş kodu)
*SY-SUBRC, son yapılan işlemin sonucunda dönen değeri tutar. Genellikle, işleme göre başarı durumu belirlemek için kullanılır. Örneğin, 0 genellikle başarıyı ifade eder.
*
*
*DATA: result_code TYPE sy-subrc.
*
*START-OF-SELECTION.
*
*  result_code = 0.
*
*  IF result_code = 0.
*    WRITE: / 'İşlem Başarılı (Subrc = 0)'.
*  ELSE.
*    WRITE: / 'İşlem Hatalı (Subrc = ', result_code, ')'.
*  ENDIF.








*. SY-MANDT: Mevcut sistemin müşteri (client) numarası
*SY-MANDT sistemi çalıştıran client'ın numarasını tutar.
*
*
*DATA: client_number TYPE sy-mandt.
*
*START-OF-SELECTION.
*
*  client_number = sy-mandt.
*
*  WRITE: / 'Client Numarası: ', client_number.





*SY-LANGU: Mevcut dil
*SY-LANGU, mevcut sistemde kullanılan dili belirtir.
*
*DATA: language TYPE sy-langu.
*
*START-OF-SELECTION.
*
*  language = sy-langu.
*
*  WRITE: / 'Mevcut Dil: ', language.





* SY-CLIENT: Mevcut sistemin client (müşteri) numarası
*SY-CLIENT sistemin client numarasını belirtir. SY-MANDT ile çok benzer bir işlevi vardır, genellikle aynı değeri tutar.
*
*DATA: client_number TYPE sy-client.
*
*START-OF-SELECTION.
*
*  client_number = sy-client.
*
*  WRITE: / 'Mevcut Client Numarası: ', client_number.
