
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
report zmdik_p75.

INCLUDE ZMDIK_P75_001.
*include zmdik_p72_i001.  "data definiations
INCLUDE ZMDIK_P75_002.
*include zmdik_p72_i002.  "class
INCLUDE ZMDIK_P75_003.
*include zmdik_p72_i003.  "pbo
INCLUDE ZMDIK_P75_004.
*include zmdik_p72_i004.  "pai


start-of-selection.
  call screen '0100'.

  free memory id 'Z_SELECTED_BANKC'.
  free memory id 'Z_SELECTED_BUKRS'.
