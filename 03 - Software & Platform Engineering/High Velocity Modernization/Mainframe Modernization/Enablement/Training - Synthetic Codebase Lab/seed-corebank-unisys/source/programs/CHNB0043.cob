       IDENTIFICATION DIVISION.
       PROGRAM-ID. CHNB0043.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : channels
      * ACCESS  : update (writes)
      * FAN-IN  : 0   FAN-OUT : 5   LOC approx: 389
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY CHN-CATALOGO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CHNB0388'.
           CALL 'CHND0008'.
           CALL 'CUSB0215'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
