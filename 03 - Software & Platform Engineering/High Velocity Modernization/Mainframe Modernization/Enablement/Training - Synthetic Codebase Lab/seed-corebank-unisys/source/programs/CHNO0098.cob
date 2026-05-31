       IDENTIFICATION DIVISION.
       PROGRAM-ID. CHNO0098.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : channels
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 4   LOC approx: 84
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY CHN-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CHNB0074'.
           CALL 'CHNB0190'.
           CALL 'CHNB0413'.
           CALL 'CRDB0383'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
