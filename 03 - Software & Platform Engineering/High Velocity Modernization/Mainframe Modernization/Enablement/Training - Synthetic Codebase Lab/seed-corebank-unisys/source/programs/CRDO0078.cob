       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRDO0078.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : cards
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 1   LOC approx: 339
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY CRD-AUXILIAR.
           COPY CRD-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CRDB0072'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
