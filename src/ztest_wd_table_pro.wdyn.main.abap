method ONACTIONGET_ITEM_DETAILS .
  DATA : lo_hdr_node TYPE REF TO if_wd_context_node,

         lo_hdr_elem  TYPE REF TO if_wd_context_element,

         lo_item_node TYPE REF TO if_wd_context_node,


         ls_vbak TYPE  wd_this->element_sales_hdr,

         lt_vbap TYPE  wd_this->elements_sales_item.



         call METHOD wd_context->get_child_node
           exporting
*             index      = use_lead_selection
             name       = 'SALES_HDR'
           receiving
             child_node =  lo_hdr_node
           .



          call METHOD lo_hdr_node->get_lead_selection
            receiving
              element = lo_hdr_elem
            .



         call METHOD lo_hdr_elem->get_static_attributes
           importing
             static_attributes = ls_vbak
           .


          IF ls_vbak IS NOT INITIAL.

    SELECT * FROM vbap INTO CORRESPONDING FIELDS OF TABLE  lt_vbap WHERE vbeln = ls_vbak-vbeln.

    CLEAR ls_vbak.

    CALL METHOD wd_context->get_child_node

      EXPORTING

        name       = 'SALES_ITEM'

      RECEIVING

        child_node = lo_item_node.


    CALL METHOD lo_item_node->bind_table

      EXPORTING

        new_items = lt_vbap.

  ENDIF.
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

METHOD wddoinit.

data: lt_vbak type TABLE OF wd_this->element_sales_hdr.

if lt_vbak is INITIAL.
  select * from vbak into CORRESPONDING FIELDS OF TABLE lt_vbak.
    endif.


    data: lo_hdr_node type REF TO if_wd_context_node.


    call METHOD wd_context->get_child_node            "Context altındaki 'SALES_HDR' node’una erişmeni sağlar.
      exporting
        name       = 'SALES_HDR'
      receiving
        child_node = lo_hdr_node
      .

      "bind_table metodu, internal table’daki veriyi context node’una bağlar.
       "Bağlama (binding) yapıldığında, ekran otomatik olarak context’ten veri çeker ve list/table UI elementine gösterir.

      call METHOD lo_hdr_node->bind_table
        exporting
          new_items            = lt_vbak
*          set_initial_elements = abap_true
*          index                =
        .


ENDMETHOD.

method WDDOMODIFYVIEW .
endmethod.

method WDDOONCONTEXTMENU .
endmethod.

