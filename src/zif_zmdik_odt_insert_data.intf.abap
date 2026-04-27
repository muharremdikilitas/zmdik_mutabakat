interface ZIF_ZMDIK_ODT_INSERT_DATA
  public .


  types:
    MANDT type C length 000003 .
  types:
    ZMDIK_PERSAD_DE type C length 000030 .
  types:
    ZMDIK_PERSSOYAD_DE type C length 000040 .
  types:
    ZMDIK_PERSCINS_DE type C length 000001 .
  types:
    begin of ZMDIK_PERS_T,
      MANDT type MANDT,
      PERS_ID type INT1,
      PERS_AD type ZMDIK_PERSAD_DE,
      PERS_SOYAD type ZMDIK_PERSSOYAD_DE,
      PERS_CINS type ZMDIK_PERSCINS_DE,
    end of ZMDIK_PERS_T .
  types ZMDIK_PERSID_DE type INT1 .
endinterface.
