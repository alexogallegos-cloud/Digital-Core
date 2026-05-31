       IDENTIFICATION DIVISION.
       PROGRAM-ID. CHNO0059.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : channels
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 2   LOC approx: 242
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY CHN-AUXILIAR.
           COPY CHN-CATALOGO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CHNB0052'.
           CALL 'CHNB0329'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
