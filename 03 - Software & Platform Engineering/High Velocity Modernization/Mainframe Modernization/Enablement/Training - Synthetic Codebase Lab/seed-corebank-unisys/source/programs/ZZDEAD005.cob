       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZZDEAD005.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : obsolete
      * ACCESS  : update (writes)
      * FAN-IN  : 3   FAN-OUT : 8   LOC approx: 400
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
           CALL 'CUSD0041'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           CALL 'ULOGWRT'.
           CALL 'ZZDEAD002'.
           CALL 'ZZDEAD003'.
           CALL 'ZZDEAD012'.
           CALL 'ZZDEAD027'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
