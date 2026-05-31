       IDENTIFICATION DIVISION.
       PROGRAM-ID. LONB0432.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : loans
      * ACCESS  : update (writes)
      * FAN-IN  : 0   FAN-OUT : 6   LOC approx: 403
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CUENTA.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY LON-AUXILIAR.
           COPY LON-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'LONB0083'.
           CALL 'LONB0126'.
           CALL 'LOND0022'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
