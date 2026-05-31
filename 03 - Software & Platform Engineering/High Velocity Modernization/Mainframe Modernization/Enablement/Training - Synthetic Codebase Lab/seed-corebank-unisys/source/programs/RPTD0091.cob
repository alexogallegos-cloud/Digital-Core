       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTD0091.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : DA       DOMAIN  : reporting
      * ACCESS  : update (writes)
      * FAN-IN  : 4   FAN-OUT : 3   LOC approx: 68
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY RPT-CATALOGO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
