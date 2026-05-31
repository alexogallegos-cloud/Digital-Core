       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSD0041.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : DA       DOMAIN  : customer
      * ACCESS  : update (writes)
      * FAN-IN  : 13   FAN-OUT : 2   LOC approx: 244
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-RETCODE.
           COPY CUS-AUXILIAR.
           COPY CUS-CATALOGO.
           COPY CUS-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
