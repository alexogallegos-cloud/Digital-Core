       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZZDEAD003.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : obsolete
      * ACCESS  : update (writes)
      * FAN-IN  : 5   FAN-OUT : 5   LOC approx: 172
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
           CALL 'CUSD0108'.
           CALL 'UDMSIIRD'.
           CALL 'ULOGWRT'.
           CALL 'ZZDEAD011'.
           CALL 'ZZDEAD024'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
