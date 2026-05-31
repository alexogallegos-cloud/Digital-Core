       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZZDEAD009.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : obsolete
      * ACCESS  : update (writes)
      * FAN-IN  : 9   FAN-OUT : 9   LOC approx: 143
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
           CALL 'CUSD0065'.
           CALL 'PAYD0067'.
           CALL 'UDMSIIRD'.
           CALL 'ULOGWRT'.
           CALL 'ZZDEAD003'.
           CALL 'ZZDEAD012'.
           CALL 'ZZDEAD026'.
           CALL 'ZZDEAD027'.
           CALL 'ZZDEAD029'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
