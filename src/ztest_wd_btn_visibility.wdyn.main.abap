method ONACTIONONCANCEL .


    data lo_el_context type ref to if_wd_context_element.
    data ls_context type wd_this->element_context.
    data lv_vis_edit type wd_this->element_context-vis_edit.

*   get element via lead selection
    lo_el_context = wd_context->get_element( ).
*   @TODO handle not set lead selection
    if lo_el_context is initial.
    endif.

*   get single attribute
    lo_el_context->get_attribute(
      exporting
        name =  `VIS_EDIT`
      importing
        value = lv_vis_edit ).

    lv_vis_edit = '02'.


      lo_el_context = wd_context->get_element( ).

      lo_el_context->set_attribute(
        name =  `VIS_EDIT`
        value = lv_vis_edit ).





  data lv_vis_save type wd_this->element_context-vis_save.

* get element via lead selection
  lo_el_context = wd_context->get_element( ).

  lo_el_context->get_attribute(
    exporting
      name =  `VIS_SAVE`
    importing
      value = lv_vis_save ).

    lv_vis_save = '01'.


    lo_el_context = wd_context->get_element( ).

    lo_el_context->set_attribute(
      name =  `VIS_SAVE`
      value = lv_vis_save ).





  data lv_vis_cancel type wd_this->element_context-vis_cancel.


  lo_el_context = wd_context->get_element( ).

  lo_el_context->get_attribute(
    exporting
      name =  `VIS_CANCEL`
    importing
      value = lv_vis_cancel ).

  lv_vis_cancel = '01'.


    lo_el_context = wd_context->get_element( ).

    lo_el_context->set_attribute(
      name =  `VIS_CANCEL`
      value = lv_vis_cancel ).




































endmethod.

method ONACTIONONEDIT .

  data lo_el_context type ref to if_wd_context_element.
  data ls_context type wd_this->element_context.
  data lv_vis_edit type wd_this->element_context-vis_edit.

* get element via lead selection
  lo_el_context = wd_context->get_element( ).
* @TODO handle not set lead selection
  if lo_el_context is initial.
  endif.


  lo_el_context->get_attribute(
    exporting
      name =  `VIS_EDIT`
    importing
      value = lv_vis_edit ).

      lv_vis_edit = '01'.

       lo_el_context = wd_context->get_element( ).

*
       lo_el_context->set_attribute(
         name =  `VIS_EDIT`
         value = lv_vis_edit ).









  data lv_vis_save type wd_this->element_context-vis_save.

* get element via lead selection
  lo_el_context = wd_context->get_element( ).
* @TODO handle not set lead selection
  if lo_el_context is initial.
  endif.

* get single attribute
  lo_el_context->get_attribute(
    exporting
      name =  `VIS_SAVE`
    importing
      value = lv_vis_save ).

  lv_vis_save = '02'.

    lo_el_context = wd_context->get_element( ).

    lo_el_context->set_attribute(
      name =  `VIS_SAVE`
      value = lv_vis_save ).






      data lv_vis_cancel type wd_this->element_context-vis_cancel.

*     get element via lead selection
      lo_el_context = wd_context->get_element( ).
*     @TODO handle not set lead selection
      if lo_el_context is initial.
      endif.

*     get single attribute
      lo_el_context->get_attribute(
        exporting
          name =  `VIS_CANCEL`
        importing
          value = lv_vis_cancel ).

      lv_vis_cancel = '02'.

        lo_el_context = wd_context->get_element( ).

        lo_el_context->set_attribute(
          name =  `VIS_CANCEL`
          value = lv_vis_cancel ).












endmethod.

method ONACTIONON_SAVE .

  data lo_el_context type ref to if_wd_context_element.
  data ls_context type wd_this->element_context.
  data lv_vis_edit type wd_this->element_context-vis_edit.


  lo_el_context = wd_context->get_element( ).
  lo_el_context->get_attribute(
    exporting
      name =  `VIS_EDIT`
    importing
      value = lv_vis_edit ).

  lv_vis_edit = '02'.


  lo_el_context = wd_context->get_element( ).

  lo_el_context->set_attribute(
    name =  `VIS_EDIT`
    value = lv_vis_edit ).





  data lv_vis_save type wd_this->element_context-vis_save.

* get element via lead selection
  lo_el_context = wd_context->get_element( ).

  lo_el_context->get_attribute(
    exporting
      name =  `VIS_SAVE`
    importing
      value = lv_vis_save ).

lv_vis_save = '01'.

  lo_el_context = wd_context->get_element( ).


  lo_el_context->set_attribute(
    name =  `VIS_SAVE`
    value = lv_vis_save ).




  data lv_vis_cancel type wd_this->element_context-vis_cancel.

* get element via lead selection
  lo_el_context = wd_context->get_element( ).
* @TODO handle not set lead selection
  if lo_el_context is initial.
  endif.

* get single attribute
  lo_el_context->get_attribute(
    exporting
      name =  `VIS_CANCEL`
    importing
      value = lv_vis_cancel ).

lv_vis_cancel = '01'.


  lo_el_context = wd_context->get_element( ).


  lo_el_context->set_attribute(
    name =  `VIS_CANCEL`
    value = lv_vis_cancel ).





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

method wddoinit .


  data lo_el_context type ref to if_wd_context_element.
  data ls_context type wd_this->element_context.
  data lv_vis_edit type wd_this->element_context-vis_edit.




  lo_el_context = wd_context->get_element( ).

  lo_el_context->get_attribute(
    exporting
      name =  `VIS_EDIT`
    importing
      value = lv_vis_edit ).

  lv_vis_edit = '02'.

  lo_el_context = wd_context->get_element( ).

  lo_el_context->set_attribute(
    name =  `VIS_EDIT`
    value = lv_vis_edit ).





endmethod.

method WDDOMODIFYVIEW .
endmethod.

method WDDOONCONTEXTMENU .
endmethod.

