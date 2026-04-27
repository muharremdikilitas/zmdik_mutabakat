class ZMDIK_REST_API definition
  public
  inheriting from CL_REST_HTTP_HANDLER
  final
  create public .

public section.

  methods IF_REST_APPLICATION~GET_ROOT_HANDLER
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZMDIK_REST_API IMPLEMENTATION.


  method IF_REST_APPLICATION~GET_ROOT_HANDLER.
*CALL METHOD SUPER->IF_REST_APPLICATION~GET_ROOT_HANDLER
*  RECEIVING
*    RO_ROOT_HANDLER =
*    .

    data(lo_router) = new cl_rest_router( ).
    lo_router->attach( iv_template = '/hello' iv_handler_class = 'ZMDIK_REST_API_RESOURCE' ).
    ro_root_handler = lo_router.
  endmethod.
ENDCLASS.
