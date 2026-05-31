       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZZDEAD028.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : obsolete
      * ACCESS  : update (writes)
      * FAN-IN  : 1   FAN-OUT : 8   LOC approx: 324
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
           CALL 'CUSD0097'.
           CALL 'UDMSIIRD'.
           CALL 'ULOGWRT'.
           CALL 'ZZDEAD000'.
           CALL 'ZZDEAD009'.
           CALL 'ZZDEAD014'.
           CALL 'ZZDEAD022'.
           CALL 'ZZDEAD029'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
