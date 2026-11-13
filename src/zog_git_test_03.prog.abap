*&---------------------------------------------------------------------*
*& Report ZOG_GIT_TEST_03
*&---------------------------------------------------------------------*
*& ZOG_ONAY_1 kayıtlarını ALV'de listeler. Araç çubuğundaki
*& "Kayıt Ekle" butonu açılır pencerede yeni kayıt alır, tabloya
*& yazar ve listeyi yeniler.
*&---------------------------------------------------------------------*
REPORT zog_git_test_03.

CLASS lcl_main DEFINITION FINAL.
  PUBLIC SECTION.
    CONSTANTS mc_fn_kayit_ekle TYPE salv_de_function VALUE 'KAYIT_EKLE'.

    CLASS-METHODS run.

  PRIVATE SECTION.
    TYPES tt_data TYPE STANDARD TABLE OF zog_onay_1 WITH EMPTY KEY.

    CLASS-DATA: mt_data TYPE tt_data,
                mo_salv TYPE REF TO cl_salv_table.

    CLASS-METHODS:
      get_data,
      display,
      set_columns,
      add_button,
      on_added_function FOR EVENT added_function OF cl_salv_events_table
        IMPORTING e_salv_function,
      kayit_ekle,
      get_input EXPORTING es_rec       TYPE zog_onay_1
                RETURNING VALUE(rv_ok) TYPE abap_bool.
ENDCLASS.

CLASS lcl_main IMPLEMENTATION.

  METHOD run.
    get_data( ).
    IF mt_data IS INITIAL.
      MESSAGE 'Tabloda kayıt yok; "Kayıt Ekle" ile yeni kayıt girebilirsiniz.'(m01) TYPE 'S'.
    ENDIF.
    display( ).
  ENDMETHOD.

  METHOD get_data.
    SELECT *
      FROM zog_onay_1
      ORDER BY PRIMARY KEY
      INTO TABLE @mt_data.
  ENDMETHOD.

  METHOD display.
    " Container modu: add_function ile toolbar'a buton eklenebilmesi için
    " ALV liste ekranının varsayılan container'ına yerleştirilir.
    TRY.
        cl_salv_table=>factory(
          EXPORTING
            r_container  = cl_gui_container=>default_screen
          IMPORTING
            r_salv_table = mo_salv
          CHANGING
            t_table      = mt_data ).
      CATCH cx_salv_msg INTO DATA(lx_msg).
        MESSAGE lx_msg TYPE 'I' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    mo_salv->get_display_settings( )->set_striped_pattern( abap_true ).
    mo_salv->get_display_settings( )->set_list_header( 'ZOG_ONAY_1 - Onay Süreci Kayıtları'(t02) ).

    set_columns( ).
    add_button( ).
    SET HANDLER on_added_function FOR mo_salv->get_event( ).

    mo_salv->display( ).

    " Liste ekranını açar; ALV bu ekranın container'ında görünür.
    WRITE space.
  ENDMETHOD.

  METHOD set_columns.
    " Başlıklar veri elemanlarından otomatik gelir. MANDT gizlenir,
    " veri elemanı olmayan ONAY_SURECI (CHAR30) için başlık verilir.
    DATA(lo_columns) = mo_salv->get_columns( ).
    lo_columns->set_optimize( abap_true ).

    TRY.
        lo_columns->get_column( 'MANDT' )->set_technical( abap_true ).

        DATA(lo_column) = lo_columns->get_column( 'ONAY_SURECI' ).
        lo_column->set_short_text( 'Onay Sür.'(c01) ).
        lo_column->set_medium_text( 'Onay Süreci'(c02) ).
        lo_column->set_long_text( 'Onay Süreci'(c02) ).
      CATCH cx_salv_not_found.
        "Sütun yoksa varsayılan başlıklarla devam edilir
    ENDTRY.
  ENDMETHOD.

  METHOD add_button.
    DATA(lo_functions) = mo_salv->get_functions( ).
    lo_functions->set_all( abap_true ).

    TRY.
        lo_functions->add_function(
          name     = mc_fn_kayit_ekle
          icon     = CONV string( icon_create )
          text     = CONV string( 'Kayıt Ekle'(b01) )
          tooltip  = CONV string( 'Yeni kayıt ekle'(b02) )
          position = if_salv_c_function_position=>right_of_salv_functions ).
      CATCH cx_salv_existing cx_salv_wrong_call INTO DATA(lx_salv).
        MESSAGE lx_salv TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD on_added_function.
    CASE e_salv_function.
      WHEN mc_fn_kayit_ekle.
        kayit_ekle( ).
    ENDCASE.
  ENDMETHOD.

  METHOD kayit_ekle.
    DATA ls_rec TYPE zog_onay_1.

    IF get_input( IMPORTING es_rec = ls_rec ) = abap_false.
      RETURN.
    ENDIF.

    " Aynı belge numarası varsa INSERT'e gitmeden kullanıcıya bildir
    SELECT SINGLE @abap_true
      FROM zog_onay_1
      WHERE belnr = @ls_rec-belnr
      INTO @DATA(lv_exists).
    IF sy-subrc = 0 AND lv_exists = abap_true.
      MESSAGE |{ ls_rec-belnr ALPHA = OUT } numaralı kayıt zaten var.| TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    INSERT zog_onay_1 FROM @ls_rec.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      MESSAGE |{ ls_rec-belnr ALPHA = OUT } numaralı kayıt eklenemedi (sy-subrc { sy-subrc }).| TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    COMMIT WORK AND WAIT.

    get_data( ).
    mo_salv->refresh( refresh_mode = if_salv_c_refresh=>full ).

    MESSAGE |{ ls_rec-belnr ALPHA = OUT } numaralı kayıt eklendi.| TYPE 'S'.
  ENDMETHOD.

  METHOD get_input.
    DATA: lt_fields TYPE STANDARD TABLE OF sval WITH EMPTY KEY,
          lv_rc     TYPE c LENGTH 1.

    CLEAR es_rec.

    " Alanlar DDIC'ten tiplenir: F4, dönüşüm (ALPHA, tarih) ve kontrol otomatik
    lt_fields = VALUE #( tabname = 'ZOG_ONAY_1'
                         ( fieldname = 'BELNR'       field_obl = abap_true )
                         ( fieldname = 'ONAY_SURECI' )
                         ( fieldname = 'UNAME'       value = sy-uname )
                         ( fieldname = 'DATUM'       value = sy-datum )
                         ( fieldname = 'UZEIT'       value = sy-uzeit ) ).

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        popup_title     = 'Yeni Onay Kaydı'(t01)
      IMPORTING
        returncode      = lv_rc
      TABLES
        fields          = lt_fields
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE 'Giriş penceresi açılamadı.'(m02) TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    IF lv_rc = 'A'.
      MESSAGE 'İşlem iptal edildi.'(m03) TYPE 'S'.
      RETURN.
    ENDIF.

    LOOP AT lt_fields INTO DATA(ls_field).
      ASSIGN COMPONENT ls_field-fieldname OF STRUCTURE es_rec TO FIELD-SYMBOL(<lv_value>).
      IF sy-subrc = 0.
        <lv_value> = ls_field-value.
      ENDIF.
    ENDLOOP.

    IF es_rec-belnr IS INITIAL.
      MESSAGE 'Belge numarası boş olamaz.'(m04) TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    es_rec-mandt = sy-mandt.
    rv_ok = abap_true.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  lcl_main=>run( ).
