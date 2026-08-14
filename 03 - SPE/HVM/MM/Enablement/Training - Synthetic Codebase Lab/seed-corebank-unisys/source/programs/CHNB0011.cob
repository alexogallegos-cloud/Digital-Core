       IDENTIFICATION DIVISION.
       PROGRAM-ID. CHNB0011.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : channels
      * ACCESS  : update (writes)
      * FAN-IN  : 3   FAN-OUT : 8   LOC approx: 466
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY CHN-CATALOGO.
           COPY CHN-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CHNB0139'.
           CALL 'CHNB0253'.
           CALL 'CHNB0399'.
           CALL 'CHNB0455'.
           CALL 'CHND0032'.
           CALL 'UDMSIIWR'.
           CALL 'ULOGWRT'.
           CALL 'UPARSEDT'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
