interface ZIF_ZMDIK_UPDATE2
  public .


  types:
    NUM10 type N length 000010 .
  types:
    KUNNR type C length 000010 .
  types:
    BUKRS type C length 000004 .
  types:
    BUTXT type C length 000025 .
  types:
    NAME1 type C length 000030 .
  types:
    UNAME type C length 000012 .
  types:
    CHAR100 type C length 000100 .
  types:
    CHAR10 type C length 000010 .
  types:
    GJAHR type N length 000004 .
  types:
    MONAT type N length 000002 .
  types:
    STCD1 type C length 000016 .
  types:
    DMBTR type P length 12  decimals 000002 .
  types:
    WAERS type C length 000005 .
  types:
    ZMDIK_DE001 type C length 000001 .
  types:
    begin of ZMDIK_ODATA_STR,
      ID type NUM10,
      KUNNR type KUNNR,
      BUKRS type BUKRS,
      BUTXT type BUTXT,
      NAME1 type NAME1,
      UNAME type UNAME,
      EMAIL type CHAR100,
      REC_MAIL type CHAR100,
      AUTHORIZEDP type CHAR10,
      GJAHR type GJAHR,
      MONAT type MONAT,
      STCD1 type STCD1,
      UPB_BALANCE type DMBTR,
      UPB_WAERS type WAERS,
      AGREEMENT_STS type ZMDIK_DE001,
      DESCRIPTION type CHAR100,
    end of ZMDIK_ODATA_STR .
endinterface.
