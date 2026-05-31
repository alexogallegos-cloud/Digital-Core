       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSB0034.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : customer
      * ACCESS  : update (writes)
      * FAN-IN  : 1   FAN-OUT : 10   LOC approx: 795
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-CLIENTE.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY CUS-AUXILIAR.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CUSB0017'.
           CALL 'CUSB0029'.
           CALL 'CUSB0063'.
           CALL 'CUSD0026'.
           CALL 'CUSD0108'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIWR'.
           CALL 'UERRHND'.
           CALL 'ULOGWRT'.
           CALL 'UTRACE'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
