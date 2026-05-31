       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTO0084.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : reporting
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 1   FAN-OUT : 4   LOC approx: 222
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY RPT-CATALOGO.
           COPY RPT-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'GLB0243'.
           CALL 'RPTB0378'.
           CALL 'RPTB0397'.
           CALL 'RPTB0408'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
