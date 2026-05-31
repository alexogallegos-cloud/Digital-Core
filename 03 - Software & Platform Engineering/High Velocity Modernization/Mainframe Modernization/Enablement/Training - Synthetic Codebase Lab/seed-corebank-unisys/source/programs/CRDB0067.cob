       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRDB0067.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : cards
      * ACCESS  : update (writes)
      * FAN-IN  : 3   FAN-OUT : 5   LOC approx: 619
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-CLIENTE.
           COPY CB-ENCABEZADO.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY CRD-AUXILIAR.
           COPY CRD-CATALOGO.
           COPY CRD-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CRDB0382'.
           CALL 'CRDD0098'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           CALL 'UERRHND'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
