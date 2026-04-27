class ZCL_ZMDIK_ODATA_001_DPC_EXT definition
  public
  inheriting from ZCL_ZMDIK_ODATA_001_DPC
  create public .

public section.
protected section.

  methods ZMDIK_PERSONELSE_GET_ENTITY
    redefinition .
  methods ZMDIK_PERSONELSE_GET_ENTITYSET
    redefinition .
  methods ZMDIK_PERSONELSE_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZMDIK_ODATA_001_DPC_EXT IMPLEMENTATION.


  method ZMDIK_PERSONELSE_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZMDIK_PERSONELSE_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

    data: gs_pers type zmdik_pers_t.

    data: ls_key_tab like LINE OF it_key_tab.

    READ TABLE it_key_tab into ls_key_tab WITH key name = 'PersId'.
    IF sy-subrc eq 0.
      data lv_persid type zmdik_pers_t-pers_id.
      lv_persid = ls_key_tab-value.
      select SINGLE * from zmdik_pers_t into gs_pers WHERE Pers_Id eq lv_persid.
        IF sy-subrc = 0.
            er_entity-pers_id = gs_pers-pers_id.
            er_entity-pers_ad = gs_pers-pers_ad.
            er_entity-pers_soyad = gs_pers-pers_soyad.
            er_entity-pers_cins = gs_pers-pers_cins.
        ENDIF.

    ENDIF.
  endmethod.


  method ZMDIK_PERSONELSE_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZMDIK_PERSONELSE_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    data: ls_entityset like line of ET_ENTITYSET.

    data: gt_pers TYPE table of zmdik_pers_t,
          gs_pers TYPE zmdik_pers_t.
    select * from zmdik_pers_t into table gt_pers.


      LOOP AT gt_pers into gs_pers.

*        ls_entityset-pers_id     =   gs_pers-pers_id.
*        ls_entityset-pers_ad     =   gs_pers-pers_ad.
*        ls_entityset-pers_soyad  =   gs_pers-pers_soyad.
*        ls_entityset-pers_cins   =   gs_pers-pers_cins.
        move gs_pers to ls_entityset.

        append ls_entityset to et_entityset.

      ENDLOOP.
  endmethod.


  method ZMDIK_PERSONELSE_UPDATE_ENTITY.
**try.
*CALL METHOD SUPER->ZMDIK_PERSONELSE_UPDATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  importing
**    er_entity               =
*    .
**  catch /iwbep/cx_mgw_busi_exception.
**  catch /iwbep/cx_mgw_tech_exception.
**endtry.
  endmethod.
ENDCLASS.
