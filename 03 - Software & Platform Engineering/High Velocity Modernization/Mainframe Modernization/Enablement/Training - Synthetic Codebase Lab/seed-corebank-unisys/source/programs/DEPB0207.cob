       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPB0207.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : deposits
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 6   FAN-OUT : 4   LOC approx: 728
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CLIENTE.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY DEP-AUXILIAR.
           COPY DEP-CATALOGO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'DEPD0088'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
