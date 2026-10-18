FUNCTION ZKOF6_UPDATE_AUTHOR.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_AUTHOR) TYPE  ZKOF6_D_AUTHOR
*"     VALUE(IS_AUTHOR_T) TYPE  ZKOF6_D_AUTHOR_T
*"----------------------------------------------------------------------

UPDATE zkof6_d_author FROM is_author.

IF sy-subrc <> 0.
  MESSAGE 'Error updating AUTHOR Table' TYPE 'E'.
ENDIF.

UPDATE zkof6_d_author_t FROM is_author_t.

IF sy-subrc <> 0.
  MESSAGE 'Error updating AUTHOR_T Table' TYPE 'E'.
ENDIF.

ENDFUNCTION.
