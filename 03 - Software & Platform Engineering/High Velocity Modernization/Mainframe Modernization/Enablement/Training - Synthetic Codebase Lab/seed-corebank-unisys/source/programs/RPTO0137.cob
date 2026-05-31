       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTO0137.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : reporting
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 3   LOC approx: 291
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-RETCODE.
           COPY RPT-AUXILIAR.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'RPTB0055'.
           CALL 'RPTB0174'.
           CALL 'RPTB0397'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
