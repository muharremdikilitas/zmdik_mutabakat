***** Implementation of object type ZMDP_P02 *****
INCLUDE <OBJECT>.

BEGIN_DATA OBJECT. " Do not change.. DATA is generated
DATA:
      KEY LIKE SWOTOBJID-OBJKEY,
      _ZMDP_T001 LIKE ZMDP_T001.
END_DATA OBJECT.

BEGIN_METHOD GOSADDOBJECTS CHANGING CONTAINER.

  DATA: lv_service     TYPE string,
        lt_busidentifs TYPE STANDARD TABLE OF borident,
        ls_borident    TYPE borident.

  " BORIDENT yapısı GOS'un belge ilişkilendirme anahtar bilgisidir
  CLEAR ls_borident.
  ls_borident-logsys  = space.
  ls_borident-objtype = 'ZMDP_P02'.     " ← düz tırnak kullan
  ls_borident-objkey  = object-key.     " ← GOS'un beklediği anahtar

  APPEND ls_borident TO lt_busidentifs.

  " GOS'tan gelen servis bilgisini oku (CREATE_ATTA / DISPLAY_ATTA)
  swc_get_element container 'Service' lv_service.

  " BUSIDENTIFS tablosunu GOS'a geri ver
  swc_set_table container 'BusIdentifs' lt_busidentifs.

END_METHOD.
