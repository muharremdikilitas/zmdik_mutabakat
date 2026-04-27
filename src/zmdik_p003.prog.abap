*&---------------------------------------------------------------------*
*& Report ZMDIK_P003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDIK_P003.
**split : Bİr stringi belirli bir ayraç ile parçalara ayırır.

*DATA: text TYPE string value 'Merhaba -Dünya - Abap',
*      parca1 TYPE string,
*      parca2 TYPE string,
*      parca3 TYPE string.
*SPLIT text AT '-' INTO parca1 parca2 parca3.
*WRITE / parca1.
*WRITE / parca2.
*WRITE / parca3.
*
*
**kerning(karakter aralığı kontrolü)
*
*DATA: lv_text TYPE string VALUE 'M e r h a b a'.
*
*CONDENSE lv_text NO-GAPS. " Tüm boşlukları kaldırır
*WRITE: / lv_text. " Çıktı: Merhaba
*
*
***concatenate : stringleri birleştirir
*DATA: metin1 type string VALUE 'Merhaba',
*      metin2 type string VALUE 'Dünya',
*      toplam type string.
*CONCATENATE metin1 metin2 INTO toplam SEPARATED BY space.
*WRITE / toplam.



**Replace : Bir string içindeki belirli kısımları değiştirir.
*DATA metin TYPE string VALUE 'Merhaba Dünya'.
*REPLACE 'Dünya' WITH 'Arkadaşlar' INTO metin.
*WRITE metin.





*STRLEN (Karakter Sayısı)
*Bir string’in uzunluğunu döndürür.

*DATA: lv_text TYPE string VALUE 'ABAP Programlama',
*      lv_length TYPE i.
*
*lv_length = STRLEN( lv_text ).
*WRITE: / 'Karakter sayısı:', lv_length.




*CLEAR (Temizle)
*Bir değişkenin içeriğini temizler.
*
*DATA: lv_text TYPE string VALUE 'Merhaba Dünya'.
*
*CLEAR lv_text.
*WRITE: / lv_text.





*SHIFT (Karakter Taşıma)
*Bir string’i sola veya sağa kaydırır.

*DATA: lv_text TYPE string VALUE 'ABAP'.
*
*SHIFT lv_text BY 1 PLACES.
*WRITE: / lv_text.






* *SEARCH (Arama)
**Bir string içinde belirli bir metni arar.
*
*DATA: lv_text TYPE string VALUE 'Merhaba ABAP Dünya',
*      lv_substring TYPE string VALUE 'ABAP',
*      lv_position TYPE i.
*
*SEARCH lv_text FOR lv_substring.
*lv_position = SY-FDPOS.
*WRITE: / 'Pozisyon:', lv_position.





** CONDENSE (Boşlukları Kaldır)
**Bir string’in içindeki gereksiz boşlukları kaldırır.

*DATA: lv_text TYPE string VALUE '   Merhaba    Dünya   '.
*
*CONDENSE lv_text.
*WRITE: / lv_text.




* **FIND (Bul)
**Bir string’de bir metni bulur.
*
*
*DATA: lv_text TYPE string VALUE 'Merhaba ABAP Dünya'.
*
*FIND 'ABAP' IN lv_text.
*IF sy-subrc = 0.
*  WRITE: / 'Metin bulundu.'.
*ELSE.
*  WRITE: / 'Metin bulunamadı.'.
*ENDIF.





* CONVERT TEXT (Text Dönüşümü)
*Tarih veya sayı gibi farklı tipleri string’e dönüştürmek için kullanılır.
*
*DATA: lv_date TYPE d VALUE '20250120',
*      lv_text TYPE c.
*
*WRITE lv_date TO lv_text.
*WRITE: / lv_text.






*OVERLAY (Yükleme)
*Bir string’in belirli kısımlarını başka karakterlerle değiştirir.

*DATA: lv_text TYPE string VALUE 'Merhaba Dünya'.
*
*OVERLAY lv_text WITH 'XXXXX' ONLY 'Dünya'.
*WRITE: / lv_text.






*TRANSLATE (Dönüştürme)
*String’i büyük veya küçük harfe çevirir.
*
*DATA: lv_text TYPE string VALUE 'Merhaba Dünya'.
*
*TRANSLATE lv_text TO UPPER CASE.
*WRITE: / lv_text.









*SUBSTRING (Alt Metin Alma)
*Bir string’in belirli bir kısmını alır.
*
*DATA: lv_text TYPE string VALUE 'Merhaba Dünya',
*      lv_substring TYPE string.
*
*lv_substring = lv_text+8(5).
*WRITE: / lv_substring.









*. COUNT (Karakter Sayımı)
*Bir string’de belirli bir karakterin kaç kez geçtiğini sayar.

*DATA: lv_text TYPE string VALUE 'ABAP Programlama ABAP',
*      lv_count TYPE i,
*      lv_num TYPE i.
*
*
*WRITE: lv_text INTENSIFIED OFF.
*NEW-LINE.
*lv_num = COUNT( VAL = lv_text regex = 's' ).
*WRITE: / 'ABAP kelimesi sayısı:', lv_num.









* SEGMENT (Karakter Bölümü Alma)
*String’i parçalamak için kullanılır.
*
*DATA: lv_text TYPE string VALUE 'Merhaba Dünya',
*      lv_segment TYPE string.
*
*lv_segment = lv_text+0(7).
*WRITE: / lv_segment.







*SAYISAL FONKSİYONLAR (Numeric Functions ile Kullanım)
*String’den sayısal veriler elde edilebilir.
*
*DATA: lv_text TYPE string VALUE '12345',
*      lv_number TYPE i.
*
*lv_number = lv_text.
*WRITE: / 'Sayısal değer:', lv_number.
