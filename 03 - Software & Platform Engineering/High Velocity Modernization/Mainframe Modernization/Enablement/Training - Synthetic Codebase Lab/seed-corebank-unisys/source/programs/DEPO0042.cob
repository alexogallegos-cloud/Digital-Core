       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPO0042.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : deposits
      * ACCESS  : update (writes)
      * FAN-IN  : 0   FAN-OUT : 1   LOC approx: 315
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CLIENTE.
           COPY CB-CUENTA.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY DEP-AUXILIAR.
           COPY DEP-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'DEPB0314'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
