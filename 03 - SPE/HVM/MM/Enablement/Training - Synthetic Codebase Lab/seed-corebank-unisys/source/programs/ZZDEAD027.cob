       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZZDEAD027.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : obsolete
      * ACCESS  : update (writes)
      * FAN-IN  : 8   FAN-OUT : 9   LOC approx: 438
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
           CALL 'CHND0044'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           CALL 'ZZDEAD007'.
           CALL 'ZZDEAD011'.
           CALL 'ZZDEAD019'.
           CALL 'ZZDEAD022'.
           CALL 'ZZDEAD024'.
           CALL 'ZZDEAD026'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
