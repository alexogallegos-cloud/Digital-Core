       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSO0021.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : customer
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 1   LOC approx: 313
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
           COPY CUS-CATALOGO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CUSB0077'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
