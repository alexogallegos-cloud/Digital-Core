       IDENTIFICATION DIVISION.
       PROGRAM-ID. CHNB0025.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : channels
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 3   FAN-OUT : 7   LOC approx: 353
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
           CALL 'CHNB0190'.
           CALL 'CHNB0329'.
           CALL 'CHND0048'.
           CALL 'CHND0058'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           CALL 'UTRACE'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
