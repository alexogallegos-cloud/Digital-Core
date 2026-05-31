       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPO0007.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : deposits
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 1   FAN-OUT : 4   LOC approx: 352
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CUENTA.
           COPY CB-RETCODE.
           COPY DEP-AUXILIAR.
           COPY DEP-CATALOGO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'DEPB0195'.
           CALL 'DEPB0211'.
           CALL 'DEPB0370'.
           CALL 'DEPB0434'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
