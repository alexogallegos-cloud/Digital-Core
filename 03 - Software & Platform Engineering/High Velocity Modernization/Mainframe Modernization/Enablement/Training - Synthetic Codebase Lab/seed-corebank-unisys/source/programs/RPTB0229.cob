       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTB0229.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : reporting
      * ACCESS  : update (writes)
      * FAN-IN  : 2   FAN-OUT : 7   LOC approx: 662
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY RPT-AUXILIAR.
           COPY RPT-CATALOGO.
           COPY RPT-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'GLB0201'.
           CALL 'RPTB0021'.
           CALL 'RPTB0240'.
           CALL 'RPTD0075'.
           CALL 'RPTD0092'.
           CALL 'UDMSIIWR'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
