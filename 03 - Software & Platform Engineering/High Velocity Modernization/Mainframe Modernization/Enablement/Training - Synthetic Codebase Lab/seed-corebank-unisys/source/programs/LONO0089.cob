       IDENTIFICATION DIVISION.
       PROGRAM-ID. LONO0089.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : loans
      * ACCESS  : update (writes)
      * FAN-IN  : 0   FAN-OUT : 3   LOC approx: 153
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-CLIENTE.
           COPY CB-CUENTA.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY LON-AUXILIAR.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'LONB0001'.
           CALL 'LONB0087'.
           CALL 'LONB0391'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
