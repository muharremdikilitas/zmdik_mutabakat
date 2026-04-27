*&**********************************************************************
*&                         MDP Group                                   *
*&**********************************************************************
*&  Program : zmdik_p72                                                *
*&  Version : 1.0                          Creation Date: 06.08.2025   *
*&  T.Code  : ZMM027                                                   *
*&  Author  : Muharrem Dikilitaş                                       *
*&**********************************************************************
*&  Program Description: Vodafone                                      *
*&                                                                     *
*&**********************************************************************
*&  Program - Changes                                                  *
*&  +-----------------------------------------------------------------+*
*&  | Code           | Programmer    | Title / Change                 |*
*&  +-----------------------------------------------------------------+*
*&  |                | mdik     | NEW                                 |*
*&  +-----------------------------------------------------------------+*
*&  Email : muharrem.dikiltas@mdpgroup.com                             *
************************************************************************
report zmdik_p72.

include zmdik_p72_i001.  "data definiations
include zmdik_p72_i002.  "class
include zmdik_p72_i003.  "pbo
include zmdik_p72_i004.  "pai


start-of-selection.
  call screen '0100'.

  free memory id 'Z_SELECTED_BANKC'.
  free memory id 'Z_SELECTED_BUKRS'.
