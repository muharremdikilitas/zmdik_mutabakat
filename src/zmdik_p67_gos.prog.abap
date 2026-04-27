*****           Implementation of object type ZMDP_P03             *****
INCLUDE <OBJECT>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      REC_ID LIKE ZMDP_T001-REC_ID,
      COMP_CODE LIKE ZMDP_T001-COMP_CODE,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated

BEGIN_METHOD GOSADDOBJECTS CHANGING CONTAINER.
DATA:
  service(255),
  busidentifs  LIKE borident OCCURS 0,
  ls_borident  TYPE borident.

CLEAR ls_borident.
ls_borident-logsys = space.
ls_borident-objtype = 'ZMDP_P03'.
ls_borident-objkey = object-key.
APPEND ls_borident TO busidentifs.

swc_get_element container 'Service' service.
  swc_set_table container 'BusIdentifs' busidentifs.


END_METHOD.
