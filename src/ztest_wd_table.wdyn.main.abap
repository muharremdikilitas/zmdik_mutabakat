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

  data: lt_vbak type table of wd_this->element_sales_hdr.


  if lt_vbak is INITIAL.
    select * from vbak into CORRESPONDING FIELDS OF TABLE lt_vbak.
      ENDif.

      data: lo_hdr_node type REF TO if_wd_context_node.

      call METHOD wd_context->get_child_node
        exporting
          name       = 'SALES_HDR'
        receiving
          child_node = lo_hdr_node
        .


      call METHOD lo_hdr_node->bind_table
        exporting
          new_items            = lt_vbak
*          set_initial_elements = abap_true
*          index                =
        .










endmethod.

method WDDOMODIFYVIEW .
endmethod.

method WDDOONCONTEXTMENU .
endmethod.

