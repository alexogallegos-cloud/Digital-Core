       IDENTIFICATION DIVISION.
       PROGRAM-ID. GLB0186.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : gl
      * ACCESS  : update (writes)
      * FAN-IN  : 1   FAN-OUT : 5   LOC approx: 774
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-CUENTA.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY GL-AUXILIAR.
           COPY GL-CATALOGO.
           COPY GL-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'GLD0050'.
           CALL 'GLD0101'.
           CALL 'PAYB0039'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
