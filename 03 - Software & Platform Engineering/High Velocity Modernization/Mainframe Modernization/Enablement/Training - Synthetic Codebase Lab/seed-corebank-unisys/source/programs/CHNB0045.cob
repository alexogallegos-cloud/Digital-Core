       IDENTIFICATION DIVISION.
       PROGRAM-ID. CHNB0045.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : channels
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 3   FAN-OUT : 7   LOC approx: 591
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-RETCODE.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CHNB0025'.
           CALL 'CHNB0441'.
           CALL 'CHND0058'.
           CALL 'CHND0104'.
           CALL 'UDMSIIRD'.
           CALL 'UERRHND'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
