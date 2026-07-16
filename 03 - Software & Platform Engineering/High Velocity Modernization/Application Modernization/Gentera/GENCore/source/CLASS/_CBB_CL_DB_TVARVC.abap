class /CBB/CL_DB_TVARVC definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_tvarvc,
        name TYPE tvarvc-name,
        type TYPE tvarvc-type,
        opti TYPE tvarvc-opti,
        low  TYPE tvarvc-low,
        high TYPE tvarvc-high,
      END OF ty_tvarvc .

  class-data:
    gt_tvarvc TYPE STANDARD TABLE OF ty_tvarvc .
  data GT_TVARVC_INST type /CBB/TY_TVARVC_RESULT .

  methods CONSTRUCTOR .
  methods IS_EVENT_ACTIVE
    importing
      !IV_EVENT_NAME type RVARI_VNAM
    returning
      value(RV_EVENT_ACTIVE) type FLAG .
  class-methods S_GET_INSTANCE
    returning
      value(RO_INSTANCE) type ref to /CBB/CL_DB_TVARVC .
  methods GET_ALL
    importing
      value(IV_NAME) type TVARVC-NAME
    changing
      !CT_MESSAGES type BAPIRET2_T optional
    returning
      value(RT_TVARVC) like GT_TVARVC
    raising
      /CBB/CX_DB_NOT_FOUND .
  methods GET_ALL_BY_NAME
    importing
      !IV_NAME type RVARI_VNAM
    changing
      !CT_RETURN type BAPIRET2_TAB optional
    returning
      value(RT_TVARVC) type /CBB/TY_TVARVC_RESULT .
  methods GET_BY_NAME_RANGE
    importing
      !IV_NAME type RVARI_VNAM
    changing
      !CT_RETURN type BAPIRET2_TAB optional
    returning
      value(RT_TVARVC) type /CBB/TT_RANGE_NAME .
  methods GET_BY_NAME
    importing
      !TT_RANGE_NAME type /CBB/TT_RANGE_NAME
    exporting
      value(RT_TVARVC) type /CBB/TY_TVARVC_RESULT
    changing
      !CT_RETURN type BAPIRET2_TAB optional
    raising
      /CBB/CX_DB_NOT_FOUND .
  methods SET_ALL_BY_NAME
    importing
      !IV_NAME type RVARI_VNAM
      !IV_LOW type TVARV_VAL
    changing
      !CT_RETURN type BAPIRET2_TAB optional .
  methods IS_EVENT_ACTIVE_HIGH
    importing
      !IV_EVENT_NAME type RVARI_VNAM
      !IV_LOW type RVARI_VAL_255
    returning
      value(RV_EVENT_ACTIVE) type FLAG .
protected section.
private section.

  class-data OG_INSTANCE type ref to /CBB/CL_DB_TVARVC .

  methods LOAD_TVARVC .
ENDCLASS.



CLASS /CBB/CL_DB_TVARVC IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /CBB/CL_DB_TVARVC->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

    IF gt_tvarvc_inst  IS INITIAL.
      me->load_tvarvc( ).
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /CBB/CL_DB_TVARVC->GET_ALL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NAME                        TYPE        TVARVC-NAME
* | [<-->] CT_MESSAGES                    TYPE        BAPIRET2_T(optional)
* | [<-()] RT_TVARVC                      LIKE        GT_TVARVC
* | [!CX!] /CBB/CX_DB_NOT_FOUND
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_all.
    CONSTANTS: c_table(30) TYPE c VALUE 'TVARVC'.
    "--------------------------------------------->

*TVARVC.
    SELECT name type opti low high
          FROM tvarvc INTO TABLE rt_tvarvc
            WHERE name EQ iv_name.

    IF sy-subrc NE 0.
      MESSAGE e005(/cbb/msg_ifrs_cn) WITH c_table INTO sy-msgli.
      /cbb/cl_exception_helper=>raise_db_not_found_exception( ).
    ENDIF.   "tvarvc.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /CBB/CL_DB_TVARVC->GET_ALL_BY_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NAME                        TYPE        RVARI_VNAM
* | [<-->] CT_RETURN                      TYPE        BAPIRET2_TAB(optional)
* | [<-()] RT_TVARVC                      TYPE        /CBB/TY_TVARVC_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_all_by_name.
    CLEAR rt_tvarvc[].

    IF iv_name IS INITIAL.
      "--No se proporcionaron datos de búsqueda.
*      MESSAGE e009(/cbcr/cm_zval) INTO sy-msgli.
*      /cbcr/cl_msg_helper=>add_system_message_to_log( CHANGING ct_return = ct_return ).
      RETURN.
    ENDIF.

    IF gt_tvarvc_inst IS INITIAL.
      SELECT  name type numb sign opti low high
        FROM  tvarvc
        INTO TABLE rt_tvarvc
        WHERE name EQ iv_name.
    ELSE.
      "Se extrae info de memoria temporal de la clase
      READ TABLE gt_tvarvc_inst INTO DATA(ls_tvarvc) WITH KEY name = iv_name.
      IF sy-subrc = 0.
        APPEND ls_tvarvc TO rt_tvarvc.
      ENDIF.

    ENDIF.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e005(/cbb/msg_ifrs_cn) INTO sy-msgli.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /CBB/CL_DB_TVARVC->GET_BY_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] TT_RANGE_NAME                  TYPE        /CBB/TT_RANGE_NAME
* | [<---] RT_TVARVC                      TYPE        /CBB/TY_TVARVC_RESULT
* | [<-->] CT_RETURN                      TYPE        BAPIRET2_TAB(optional)
* | [!CX!] /CBB/CX_DB_NOT_FOUND
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_BY_NAME.
    CLEAR rt_tvarvc[].


    SELECT  name type numb sign opti low high
      FROM  tvarvc
      INTO TABLE rt_tvarvc
      WHERE name IN tt_range_name.

    IF NOT sy-subrc IS INITIAL.
      MESSAGE e005(/cbb/msg_ifrs_cn) INTO sy-msgli.
      /cbb/cl_exception_helper=>raise_db_not_found_exception( ).
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /CBB/CL_DB_TVARVC->GET_BY_NAME_RANGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NAME                        TYPE        RVARI_VNAM
* | [<-->] CT_RETURN                      TYPE        BAPIRET2_TAB(optional)
* | [<-()] RT_TVARVC                      TYPE        /CBB/TT_RANGE_NAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_by_name_range.

    CLEAR rt_tvarvc[].

    SELECT  "name type numb
      sign opti low high
      FROM  tvarvc
      INTO TABLE rt_tvarvc
      WHERE name EQ iv_name.

    IF NOT sy-subrc IS INITIAL.
      MESSAGE e005(/cbb/msg_ifrs_cn) INTO sy-msgli.
      /cbb/cl_exception_helper=>add_system_message_to_log( CHANGING ct_return = ct_return ).
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /CBB/CL_DB_TVARVC->IS_EVENT_ACTIVE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_EVENT_NAME                  TYPE        RVARI_VNAM
* | [<-()] RV_EVENT_ACTIVE                TYPE        FLAG
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD is_event_active.
************************************************************************
* Fecha Creación : 02.05.2022                                          *
* Autor : Gabriel Alejandro Beltran Reyes                              *
* Usuario SAP : GBELTRAN                                               *
* OT y Tarea :   BSDK925874 - BSDK926605                               *
* Solicitante : Sergio Alejandro Talavera Soriano                      *
* Doc. Diseño : Diseño de Solucion - Producto operativo 1.0.0          *
* Espec. funcional : N/A                                               *
* Versión : 1.0.0                                                      *
* Desc. Solicitud : Producto operativo                                 *
* Categoría : nueva funcionalidad                                      *
* Id Espec. TEC : Nombre_de_ET                                         *
************************************************************************
* Log_scann : @02.05.2022_GABR                                         *
************************************************************************

  DATA: lt_tvarvc TYPE STANDARD TABLE OF ty_tvarvc.

  CLEAR rv_event_active.
  TRY.
      lt_tvarvc = me->get_all( iv_event_name ).
      rv_event_active = lt_tvarvc[ name = iv_event_name ]-low .
    CATCH cx_sy_itab_line_not_found
          /cbb/cx_db_not_found.
      rv_event_active = abap_false.
  ENDTRY.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /CBB/CL_DB_TVARVC->IS_EVENT_ACTIVE_HIGH
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_EVENT_NAME                  TYPE        RVARI_VNAM
* | [--->] IV_LOW                         TYPE        RVARI_VAL_255
* | [<-()] RV_EVENT_ACTIVE                TYPE        FLAG
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD IS_EVENT_ACTIVE_HIGH.
************************************************************************
* Fecha Creación : 02.05.2022                                          *
* Autor : Gabriel Alejandro Beltran Reyes                              *
* Usuario SAP : GBELTRAN                                               *
* OT y Tarea :   BSDK925874 - BSDK926605                               *
* Solicitante : Sergio Alejandro Talavera Soriano                      *
* Doc. Diseño : Diseño de Solucion - Producto operativo 1.0.0          *
* Espec. funcional : N/A                                               *
* Versión : 1.0.0                                                      *
* Desc. Solicitud : Producto operativo                                 *
* Categoría : nueva funcionalidad                                      *
* Id Espec. TEC : Nombre_de_ET                                         *
************************************************************************
* Log_scann : @02.05.2022_GABR                                         *
************************************************************************

  DATA: lt_tvarvc TYPE STANDARD TABLE OF ty_tvarvc.

  CLEAR rv_event_active.
  TRY.
      lt_tvarvc = me->get_all( iv_event_name ).
      rv_event_active = lt_tvarvc[ name = iv_event_name low = iv_low ]-high .
    CATCH cx_sy_itab_line_not_found
          /cbb/cx_db_not_found.
      rv_event_active = abap_false.
  ENDTRY.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method /CBB/CL_DB_TVARVC->LOAD_TVARVC
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method LOAD_TVARVC.

    "Se extrae toda las variables de TVARVC para manejar info en memoria temporal
    SELECT  name type numb sign opti low high
      FROM  tvarvc
      INTO TABLE gt_tvarvc_inst.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method /CBB/CL_DB_TVARVC->SET_ALL_BY_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NAME                        TYPE        RVARI_VNAM
* | [--->] IV_LOW                         TYPE        TVARV_VAL
* | [<-->] CT_RETURN                      TYPE        BAPIRET2_TAB(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method SET_ALL_BY_NAME.

     UPDATE tvarvc SET low = iv_low
    WHERE name = iv_name
    AND type = 'P'.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method /CBB/CL_DB_TVARVC=>S_GET_INSTANCE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RO_INSTANCE                    TYPE REF TO /CBB/CL_DB_TVARVC
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD s_get_instance.
    IF NOT og_instance IS BOUND.
      CREATE OBJECT og_instance.
    ENDIF.

    ro_instance = og_instance.
  ENDMETHOD.
ENDCLASS.
