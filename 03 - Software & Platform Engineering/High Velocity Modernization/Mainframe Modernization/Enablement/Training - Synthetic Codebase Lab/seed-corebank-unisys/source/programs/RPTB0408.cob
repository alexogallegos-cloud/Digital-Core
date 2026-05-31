       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTB0408.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : reporting
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 2   FAN-OUT : 5   LOC approx: 503
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY RPT-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'RPTB0163'.
           CALL 'RPTB0366'.
           CALL 'RPTD0078'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
