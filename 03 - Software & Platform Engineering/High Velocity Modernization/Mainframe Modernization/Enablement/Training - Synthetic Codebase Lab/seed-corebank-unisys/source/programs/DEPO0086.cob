       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPO0086.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : deposits
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 3   LOC approx: 275
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-CLIENTE.
           COPY CB-CUENTA.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY DEP-CATALOGO.
           COPY DEP-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'DEPB0102'.
           CALL 'DEPB0187'.
           CALL 'DEPB0331'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
