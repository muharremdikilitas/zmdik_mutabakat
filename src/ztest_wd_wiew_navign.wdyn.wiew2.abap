method HANDLEIN_PLUG_WIEW2 .


    data lo_el_context type ref to if_wd_context_element.
    data ls_context type wd_this->element_context.
    data lv_carrid_2 type wd_this->element_context-carrid_2.

*   get element via lead selection
    lo_el_context = wd_context->get_element( ).

*   @TODO handle not set lead selection
    if lo_el_context is initial.
    endif.

    lo_el_context->set_attribute(
      name =  `CARRID_2`
      value = lv_carrid_2 ).


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

