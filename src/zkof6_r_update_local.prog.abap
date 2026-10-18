*&---------------------------------------------------------------------*
*& Report ZKOF6_R_UPDATE_LOCAL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkof6_r_update_local.

DATA:
  ls_author_data   TYPE zkof6_d_author,
  ls_author_t_data TYPE zkof6_d_author_t.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-003.

PARAMETERS:
  p_authid TYPE zkof6_d_author-author_id,
  p_bdate  TYPE zkof6_d_author-birth_date,
  p_cntry  TYPE zkof6_d_author-country,
  p_fname  TYPE zkof6_d_author_t-author_first_name,
  p_lname  TYPE zkof6_d_author_t-author_last_name.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-004.

SELECTION-SCREEN:
PUSHBUTTON /1(20) btn_get USER-COMMAND get_author,
PUSHBUTTON 30(20) btn_save USER-COMMAND save_author.

SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.
  btn_get = TEXT-001.
  btn_save = TEXT-002.

AT SELECTION-SCREEN.

  CASE sy-ucomm.

    WHEN 'GET_AUTHOR'.
      SELECT SINGLE *
        FROM zkof6_d_author
        WHERE author_id = @p_authid
        INTO @ls_author_data.

      IF sy-subrc = 0.
        p_bdate = ls_author_data-birth_date.
        p_cntry = ls_author_data-country.
      ELSE.
        MESSAGE 'Author with the specified ID was not found.' TYPE 'E'.
      ENDIF.

      SELECT SINGLE *
      FROM zkof6_d_author_t
      WHERE author_id = @p_authid AND langu = @sy-langu
      INTO @ls_author_t_data.

      IF sy-subrc = 0.
        MESSAGE 'Successfully fetched author' TYPE 'S'.
        p_fname = ls_author_t_data-author_first_name.
        p_lname = ls_author_t_data-author_last_name.
      ELSE.
        CLEAR:
          p_bdate,
          p_cntry.
        MESSAGE 'Author translation with the specified ID was not found.' TYPE 'E'.
      ENDIF.

    WHEN 'SAVE_AUTHOR'.
      ls_author_data-birth_date = p_bdate.
      ls_author_data-country = p_cntry.
      ls_author_t_data-author_first_name = p_fname.
      ls_author_t_data-author_last_name = p_lname.

      PERFORM set_locks.

      SET UPDATE TASK LOCAL.

      CALL FUNCTION 'ZKOF6_UPDATE_AUTHOR' IN UPDATE TASK
        EXPORTING
          is_author   = ls_author_data
          is_author_t = ls_author_t_data.

      COMMIT WORK AND WAIT.

      MESSAGE 'Author updated successfully.' TYPE 'S'.

  ENDCASE.

FORM set_locks.

  CALL FUNCTION 'ENQUEUE_EZKOF6_AUTHOR'
    EXPORTING
      mode_zkof6_d_author   = 'E'
      mode_zkof6_d_author_t = 'E'
      mandt                 = sy-mandt
      author_id             = p_authid
      langu                 = sy-langu
*     X_AUTHOR_ID           = ' '
*     X_LANGU               = ' '
      _scope                = '2'
*     _WAIT                 = ' '
*     _COLLECT              = ' '
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.
  CASE sy-subrc.

    WHEN 0.
      MESSAGE 'Enqueue successful' TYPE 'I'.

    WHEN 1.
      DATA(lv_locked_by) = sy-msgv1.
      MESSAGE |Record already locked by { lv_locked_by }| TYPE 'E'.

    WHEN OTHERS.
      MESSAGE |Error in enqueue! SY-SUBRC:' { sy-subrc }| TYPE 'E'.

  ENDCASE.


ENDFORM.
