       IDENTIFICATION DIVISION.
       PROGRAM-ID. GLD0057.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : DA       DOMAIN  : gl
      * ACCESS  : update (writes)
      * FAN-IN  : 12   FAN-OUT : 3   LOC approx: 131
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY GL-CATALOGO.
           COPY GL-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
