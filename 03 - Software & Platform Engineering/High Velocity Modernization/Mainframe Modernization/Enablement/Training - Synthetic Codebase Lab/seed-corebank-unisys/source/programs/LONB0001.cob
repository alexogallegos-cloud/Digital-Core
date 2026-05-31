       IDENTIFICATION DIVISION.
       PROGRAM-ID. LONB0001.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : loans
      * ACCESS  : update (writes)
      * FAN-IN  : 3   FAN-OUT : 7   LOC approx: 592
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CUENTA.
           COPY CB-ENCABEZADO.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY LON-AUXILIAR.
           COPY LON-CATALOGO.
           COPY LON-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'LONB0425'.
           CALL 'LOND0071'.
           CALL 'UCURRCNV'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           CALL 'ULOGWRT'.
           CALL 'UTRACE'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
