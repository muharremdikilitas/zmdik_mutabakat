*&---------------------------------------------------------------------*
*& Report ZMDIK_P008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmdik_p008.
DATA: gv_persid    TYPE zmdik_persid_de,
      gv_persad    TYPE zmdik_persad_de,
      gv_perssoyad TYPE zmdik_persad_de,
      gv_perscins  TYPE zmdik_perscins_de,
      gs_pers_t TYPE zmdik_pers_t,
      gt_pers_t TYPE TABLE of zmdik_pers_t.

gs_pers_t-pers_id = 1.
gs_pers_t-pers_ad = 'Muharrem'.
gs_pers_t-pers_soyad = 'Dikilitaş'.
gs_pers_t-pers_cins = 'Erkek'.


APPEND  gs_pers_t to gt_pers_t.







INSERT zmdik_pers_t FROM gs_pers_t.

WRITE: 'Komut çalıştı'.


*select * FROM zmdik_pers_t
*INTO TABLE gt_pers_t.
**
**SELECT SINGLE * from zmdik_pers_t
**  INTO gs_pers_t.
*
*loop at gt_pers_t into gs_pers_t.
*  WRITE gs_pers_t-pers_ad.
*  ENDLOOP.

CLEAR gs_pers_t.
cl_demo_output=>display_data( gs_pers_t ).

LOOP AT gt_pers_t into gs_pers_t.
  ENDLOOP.
   cl_demo_output=>display( gs_pers_t ).




*1-structure alanlarını doldur ve Zli tabloya insert yap
*gs_Str-ad = akif .
*
*gs_to gt .
*
*insert update modify delete
