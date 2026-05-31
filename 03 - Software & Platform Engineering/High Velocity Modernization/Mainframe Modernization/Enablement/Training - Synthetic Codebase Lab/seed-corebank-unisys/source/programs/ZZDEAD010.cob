       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZZDEAD010.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : obsolete
      * ACCESS  : update (writes)
      * FAN-IN  : 1   FAN-OUT : 10   LOC approx: 482
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
           CALL 'DEPD0090'.
           CALL 'PAYD0076'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           CALL 'ULOGWRT'.
           CALL 'ZZDEAD000'.
           CALL 'ZZDEAD002'.
           CALL 'ZZDEAD017'.
           CALL 'ZZDEAD022'.
           CALL 'ZZDEAD023'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
