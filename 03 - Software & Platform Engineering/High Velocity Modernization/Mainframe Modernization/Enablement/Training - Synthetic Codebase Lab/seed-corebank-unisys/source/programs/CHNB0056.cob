       IDENTIFICATION DIVISION.
       PROGRAM-ID. CHNB0056.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : channels
      * ACCESS  : update (writes)
      * FAN-IN  : 7   FAN-OUT : 8   LOC approx: 557
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY CHN-AUXILIAR.
           COPY CHN-CATALOGO.
           COPY CHN-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CHNB0057'.
           CALL 'CHNB0329'.
           CALL 'CHND0039'.
           CALL 'CHND0085'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           CALL 'UERRHND'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
