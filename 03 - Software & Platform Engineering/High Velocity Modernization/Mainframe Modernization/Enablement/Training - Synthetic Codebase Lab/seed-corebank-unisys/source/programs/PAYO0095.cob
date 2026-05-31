       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYO0095.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : payments
      * ACCESS  : update (writes)
      * FAN-IN  : 0   FAN-OUT : 4   LOC approx: 271
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CLIENTE.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY PAY-CATALOGO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'PAYB0032'.
           CALL 'PAYB0132'.
           CALL 'PAYB0222'.
           CALL 'PAYB0226'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
