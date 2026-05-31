       IDENTIFICATION DIVISION.
       PROGRAM-ID. GLB0028.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : gl
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 3   FAN-OUT : 6   LOC approx: 790
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY GL-AUXILIAR.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CUSB0296'.
           CALL 'GLB0361'.
           CALL 'GLD0059'.
           CALL 'UDMSIIRD'.
           CALL 'ULOGWRT'.
           CALL 'UTRACE'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
