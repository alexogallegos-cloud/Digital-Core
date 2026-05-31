       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTO0061.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : reporting
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 4   LOC approx: 271
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'RPTB0078'.
           CALL 'RPTB0338'.
           CALL 'RPTB0366'.
           CALL 'RPTB0417'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
