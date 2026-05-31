       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPO0092.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : deposits
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 2   FAN-OUT : 2   LOC approx: 120
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CLIENTE.
           COPY CB-CUENTA.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY DEP-AUXILIAR.
           COPY DEP-CATALOGO.
           COPY DEP-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'DEPB0165'.
           CALL 'DEPB0398'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
