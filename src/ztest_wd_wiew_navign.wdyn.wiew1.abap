method ONACTIONSHOW_WIEW2 .





    data lo_el_context type ref to if_wd_context_element.
    data ls_context type wd_this->element_context.
    data lv_carrid type wd_this->element_context-carrid.

*   get element via lead selection
    lo_el_context = wd_context->get_element( ).
*   @TODO handle not set lead selection
    if lo_el_context is initial.
    endif.

*   get single attribute
    lo_el_context->get_attribute(

      exporting
        name =  `CARRID`
      importing
        value = lv_carrid ).


 wd_this->fire_out_plug_wiew1_plg( carrid = lv_carrid ).












endmethod.

method WDDOAFTERACTION .
endmethod.

method WDDOBEFOREACTION .
*  data lo_api_controller type ref to if_wd_view_controller.
*  data lo_action         type ref to if_wd_action.

*  lo_api_controller = wd_this->wd_get_api( ).
*  lo_action = lo_api_controller->get_current_action( ).

*  if lo_action is bound.
*    case lo_action->name.
*      when '...'.

*    endcase.
*  endif.
endmethod.

method WDDOEXIT .
endmethod.

method WDDOINIT .
endmethod.

method WDDOMODIFYVIEW .
endmethod.

method WDDOONCONTEXTMENU .
endmethod.

