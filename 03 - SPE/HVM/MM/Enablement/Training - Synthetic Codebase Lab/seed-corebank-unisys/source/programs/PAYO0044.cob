       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYO0044.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : payments
      * ACCESS  : update (writes)
      * FAN-IN  : 1   FAN-OUT : 3   LOC approx: 347
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY PAY-AUXILIAR.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'LONB0387'.
           CALL 'PAYB0032'.
           CALL 'RPTB0272'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
