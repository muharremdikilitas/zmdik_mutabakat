class ZMDIK_REST_API_RESOURCE definition
  public
  inheriting from CL_REST_RESOURCE
  final
  create public .

public section.

  methods IF_REST_RESOURCE~GET
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZMDIK_REST_API_RESOURCE IMPLEMENTATION.


  method IF_REST_RESOURCE~GET.
*CALL METHOD SUPER->IF_REST_RESOURCE~GET
*    .


*    mo_response->create_entity( )->set_string_data('Hello World!,') .


     data(lv_carrid) = mo_request->get_uri_query_parameter( iv_name = 'carrid' ).
    data(lv_connid) = mo_request->get_uri_query_parameter( iv_name = 'connid' ).

    data: lt_sflight type table of sflight.

    select  * from sflight into TABLE lt_sflight
      where carrid eq lv_carrid and connid eq lv_connid.

      data: lv_data type string.

      call METHOD /ui2/cl_json=>serialize
      exporting
        data = lt_sflight
              RECEIVING
              r_json =  lv_data.

*      mo_response->create_entity( )->set_string_data( iv_data = lv_data ).
*      mo_response->create_entity( )->set_content_type( if_rest_media_type=>gc_appl_json ).
*      mo_response->set_status( cl_rest_status_code=>gc_success_ok ).

data(lo_entity) = mo_response->create_entity( ).
lo_entity->set_content_type( if_rest_media_type=>gc_appl_json ).
lo_entity->set_string_data( iv_data = lv_data ).
mo_response->set_status( cl_rest_status_code=>gc_success_ok ).

  endmethod.
ENDCLASS.
