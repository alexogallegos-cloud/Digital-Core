       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTO0105.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : reporting
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 1   FAN-OUT : 4   LOC approx: 118
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
           CALL 'CHNB0329'.
           CALL 'DEPB0180'.
           CALL 'RPTB0315'.
           CALL 'RPTB0345'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
