interface ZIF_ZMDIK_MTBK_GETDATA2
  public .


  types:
    MANDT type C length 000003 .
  types:
    KUNNR type C length 000010 .
  types:
    BUKRS type C length 000004 .
  types:
    GJAHR type N length 000004 .
  types:
    UMSKZ type C length 000001 .
  types:
    MONAT type N length 000002 .
  types:
    STCD1 type C length 000016 .
  types:
    NAME1 type C length 000030 .
  types:
    LAND1 type C length 000003 .
  types:
    STCEG type C length 000020 .
  types:
    DMBTR type P length 12  decimals 000002 .
  types:
    DMSHB type P length 12  decimals 000002 .
  types:
    WAERS type C length 000005 .
  types:
    CHAR4 type C length 000004 .
  types:
    SHKZG type C length 000001 .
  types:
    ZMDIK_INTRO_TEXT type C length 000020 .
  types:
    ZMDIK_DE_TXT type C length 000006 .
  types:
    BUTXT type C length 000025 .
  types:
    CHAR100 type C length 000100 .
  types:
    UNAME type C length 000012 .
  types:
    AD_SMTPADR type C length 000241 .
  types:
    KTEXT type C length 000020 .
  types:
    ZMDIK_MTB_DE type C length 000001 .
  types:
    ZMDIK_MTB_ACK_DE type C length 000050 .
  types:
    begin of ZMDIK_MUTAKABAT,
      MANDT type MANDT,
      KUNNR type KUNNR,
      BUKRS type BUKRS,
      YIL type GJAHR,
      ODK_TEXT type UMSKZ,
      AY type MONAT,
      STCD1 type STCD1,
      NAME1 type NAME1,
      ULKE type LAND1,
      VERGI_DAIRE type STCEG,
      MUSTERI_BAKIYE type DMBTR,
      MUSTERI_BAKIYEPB type UMSKZ,
      UPB_BAKIYE type DMSHB,
      UPB_PARA_BIRIMI type WAERS,
      DETAY type CHAR4,
      TARIH type DATS,
      BORC_ALACAK type SHKZG,
      INTRO_TEXT type ZMDIK_INTRO_TEXT,
      BORC_ALACAK_TEXT type ZMDIK_DE_TXT,
      BUTXT type BUTXT,
      MAIL type CHAR100,
      Y_KISI type UNAME,
      SMTP_ADDR type AD_SMTPADR,
      MUSTERI_BAKIYEPB2 type WAERS,
      KTEXT type KTEXT,
      ODK_GOST type UMSKZ,
      MUTABAT_DURUM type ZMDIK_MTB_DE,
      MTB_DURUM_ACIKLA type ZMDIK_MTB_ACK_DE,
    end of ZMDIK_MUTAKABAT .
  types:
    ZMDIK_MTBK_DE                  type standard table of ZMDIK_MUTAKABAT                with non-unique default key .
endinterface.
