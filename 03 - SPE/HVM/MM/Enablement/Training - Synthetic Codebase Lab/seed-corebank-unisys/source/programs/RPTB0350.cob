       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTB0350.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : reporting
      * ACCESS  : update (writes)
      * FAN-IN  : 2   FAN-OUT : 8   LOC approx: 198
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY RPT-AUXILIAR.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CHNB0322'.
           CALL 'RPTB0152'.
           CALL 'RPTB0378'.
           CALL 'RPTD0042'.
           CALL 'RPTD0092'.
           CALL 'UDMSIIWR'.
           CALL 'UERRHND'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
