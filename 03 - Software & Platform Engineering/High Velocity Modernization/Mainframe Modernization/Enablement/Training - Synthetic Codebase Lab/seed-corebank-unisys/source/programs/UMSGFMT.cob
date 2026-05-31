       IDENTIFICATION DIVISION.
       PROGRAM-ID. UMSGFMT.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : UTIL     DOMAIN  : shared
      * ACCESS  : no data access
      * FAN-IN  : 0   FAN-OUT : 0   LOC approx: 100
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
      *    (does not call other programs)
      *    (does not touch the database)
           GOBACK.
