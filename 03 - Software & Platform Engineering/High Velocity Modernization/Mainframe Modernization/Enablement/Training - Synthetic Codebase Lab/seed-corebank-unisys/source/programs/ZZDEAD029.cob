       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZZDEAD029.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : obsolete
      * ACCESS  : update (writes)
      * FAN-IN  : 3   FAN-OUT : 7   LOC approx: 437
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
           CALL 'CRDD0005'.
           CALL 'LOND0102'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           CALL 'ZZDEAD001'.
           CALL 'ZZDEAD023'.
           CALL 'ZZDEAD026'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
